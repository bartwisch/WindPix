const { app, BrowserWindow, globalShortcut, ipcMain, Tray, Menu, desktopCapturer, clipboard, screen, systemPreferences, dialog, shell } = require('electron');
const path = require('path');
const fs = require('fs');
const Store = require('electron-store');

const store = new Store();

let mainWindow;
let tray;
let selectionWindow;
let isAreaSelectMode = true; // Default to area select mode

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 400,
    height: 300,
    show: false,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    },
    resizable: false,
    maximizable: false,
    fullscreenable: false,
    icon: path.join(__dirname, 'assets', 'icon-window.png')
  });

  mainWindow.loadFile('index.html');
}

function createSelectionWindow() {
  const primaryDisplay = screen.getPrimaryDisplay();
  const { width, height } = primaryDisplay.size; // Using size instead of workAreaSize
  
  if (selectionWindow && !selectionWindow.isDestroyed()) {
    selectionWindow.close();
    selectionWindow = null;
  }

  selectionWindow = new BrowserWindow({
    width: width,
    height: height,
    x: 0,
    y: 0,
    frame: false,
    transparent: true,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    },
    hasShadow: false,
    enableLargerThanScreen: true,
    resizable: false
  });

  selectionWindow.setVisibleOnAllWorkspaces(true);
  selectionWindow.setAlwaysOnTop(true, 'screen-saver');
  selectionWindow.setBackgroundColor('#00000000');
  
  selectionWindow.loadFile('selection.html');

  // Pass the scale factor to the renderer
  selectionWindow.webContents.on('did-finish-load', () => {
    selectionWindow.webContents.send('init-scale-factor', primaryDisplay.scaleFactor);
  });

  // Ensure window can be closed with Cmd+Q
  globalShortcut.register('Command+Q', () => {
    app.quit();
  });
}

function updateTrayMenu() {
  const iconPath = path.join(__dirname, 'assets', 'icon-menu.png');
  if (!fs.existsSync(iconPath)) {
    console.error('Tray menu icon not found:', iconPath);
    return;
  }
  
  const contextMenu = Menu.buildFromTemplate([
    { 
      label: 'Select Area',
      type: 'checkbox',
      checked: isAreaSelectMode,
      click: () => {
        isAreaSelectMode = !isAreaSelectMode;
        updateTrayMenu();
      }
    },
    { 
      label: 'Take Screenshot',
      click: () => {
        if (isAreaSelectMode) {
          takeAreaScreenshot();
        } else {
          takeScreenshot();
        }
      }
    },
    { type: 'separator' },
    { label: 'Settings', click: () => mainWindow.show() },
    { type: 'separator' },
    { label: 'Quit', click: () => app.quit() }
  ]);

  if (tray) {
    tray.setContextMenu(contextMenu);
  }
}

function createTray() {
  const iconPath = path.join(__dirname, 'assets', 'icon-tray.png');
  if (!fs.existsSync(iconPath)) {
    console.error('Tray icon not found:', iconPath);
    return;
  }
  
  tray = new Tray(iconPath);
  tray.setToolTip('WindPix');
  updateTrayMenu();
}

function checkScreenCapturePermission() {
  if (process.platform === 'darwin') {
    const hasPermission = systemPreferences.getMediaAccessStatus('screen') === 'granted';
    if (!hasPermission) {
      const dialogOptions = {
        type: 'info',
        title: 'Permission Required',
        message: 'WindPix needs Screen and System Audio Recording permission to function properly.',
        detail: 'Please enable Screen and System Audio Recording for Windsurf in System Settings > Privacy & Security.',
        buttons: ['OK'],
        defaultId: 0
      };

      if (process.platform === 'darwin') {
        dialogOptions.buttons = ['Open System Settings', 'Cancel'];
        dialogOptions.defaultId = 0;
        dialogOptions.cancelId = 1;
      }

      dialog.showMessageBox(dialogOptions).then(({ response }) => {
        if (process.platform === 'darwin' && response === 0) {
          shell.openExternal('x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture');
        }
      });
      return false;
    }
  }
  return true;
}

async function takeAreaScreenshot() {
  try {
    if (!checkScreenCapturePermission()) {
      return;
    }

    const primaryDisplay = screen.getPrimaryDisplay();
    const sources = await desktopCapturer.getSources({
      types: ['screen'],
      thumbnailSize: { 
        width: primaryDisplay.size.width * primaryDisplay.scaleFactor,
        height: primaryDisplay.size.height * primaryDisplay.scaleFactor
      }
    });

    if (sources.length > 0) {
      // Clean up existing window if it exists
      if (selectionWindow && !selectionWindow.isDestroyed()) {
        selectionWindow.close();
        selectionWindow = null;
      }
      
      // Create new window
      createSelectionWindow();
    }
  } catch (error) {
    console.error('Failed to start area screenshot:', error);
    if (mainWindow) {
      mainWindow.webContents.send('screenshot-error', error.message);
      mainWindow.show();
    }
  }
}

async function captureArea(bounds) {
  try {
    console.log('Taking area screenshot...', bounds);
    const primaryDisplay = screen.getPrimaryDisplay();
    const sources = await desktopCapturer.getSources({ 
      types: ['screen'],
      thumbnailSize: { 
        width: primaryDisplay.size.width * primaryDisplay.scaleFactor,
        height: primaryDisplay.size.height * primaryDisplay.scaleFactor
      }
    });
    
    const primarySource = sources[0];
    if (!primarySource) {
      throw new Error('No display found');
    }

    // Get the cropped image using Electron's NativeImage
    const fullImage = primarySource.thumbnail;
    const croppedImage = fullImage.crop(bounds);
    
    // Create a temporary file for preview
    const timestamp = new Date().getTime();
    const tempImgPath = path.join(app.getPath('temp'), `screenshot-${timestamp}.png`);
    fs.writeFileSync(tempImgPath, croppedImage.toPNG());

    // Copy to clipboard
    clipboard.writeImage(croppedImage);
    console.log('Area screenshot copied to clipboard');
    
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('screenshot-taken', tempImgPath);
      mainWindow.show();
    }

    // Focus Windsurf app
    if (process.platform === 'darwin') {
      shell.executeCommand('osascript -e \'tell application "Windsurf" to activate\'');
    }

    // Delete temporary file after a short delay to ensure preview is shown
    setTimeout(() => {
      try {
        fs.unlinkSync(tempImgPath);
      } catch (err) {
        console.error('Failed to delete temporary screenshot:', err);
      }
    }, 5000);
  } catch (error) {
    console.error('Area screenshot failed - Full error:', error);
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('screenshot-error', error.message);
      mainWindow.show();
    }
  } finally {
    if (selectionWindow && !selectionWindow.isDestroyed()) {
      selectionWindow.close();
      selectionWindow = null;
    }
  }
}

async function takeScreenshot() {
  try {
    if (!checkScreenCapturePermission()) {
      return;
    }

    console.log('Taking screenshot...');
    const primaryDisplay = screen.getPrimaryDisplay();
    const sources = await desktopCapturer.getSources({
      types: ['screen'], 
      thumbnailSize: { 
        width: primaryDisplay.size.width * primaryDisplay.scaleFactor,
        height: primaryDisplay.size.height * primaryDisplay.scaleFactor
      }
    });
    const primarySource = sources[0];
    
    if (!primarySource) {
      throw new Error('No display found');
    }

    // Create a temporary file for preview
    const timestamp = new Date().getTime();
    const tempImgPath = path.join(app.getPath('temp'), `screenshot-${timestamp}.png`);
    fs.writeFileSync(tempImgPath, primarySource.thumbnail.toPNG());

    // Copy to clipboard
    clipboard.writeImage(primarySource.thumbnail);
    console.log('Screenshot copied to clipboard');
    
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('screenshot-taken', tempImgPath);
      mainWindow.show();
    }

    // Focus Windsurf app
    if (process.platform === 'darwin') {
      shell.executeCommand('osascript -e \'tell application "Windsurf" to activate\'');
    }

    // Delete temporary file after a short delay to ensure preview is shown
    setTimeout(() => {
      try {
        fs.unlinkSync(tempImgPath);
      } catch (err) {
        console.error('Failed to delete temporary screenshot:', err);
      }
    }, 5000);
  } catch (error) {
    console.error('Screenshot failed - Full error:', error);
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('screenshot-error', error.message);
      mainWindow.show();
    }
  }
}

function initialize() {
  // Set dock icon for macOS
  if (process.platform === 'darwin') {
    const iconPath = path.join(__dirname, 'assets', 'icon-dock.png');
    if (fs.existsSync(iconPath)) {
      app.dock.setIcon(iconPath);
    }
  }

  checkScreenCapturePermission();
  createWindow();
  createTray();
  
  // Set up IPC handlers after window is created
  ipcMain.on('hide-window', () => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.hide();
    }
  });

  ipcMain.on('redo-screenshot', () => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.hide();
    }
    if (isAreaSelectMode) {
      takeAreaScreenshot();
    } else {
      takeScreenshot();
    }
  });

  ipcMain.on('area-selected', (event, bounds) => {
    captureArea(bounds);
  });

  ipcMain.on('cancel-selection', () => {
    if (selectionWindow && !selectionWindow.isDestroyed()) {
      selectionWindow.close();
      selectionWindow = null;
    }
  });
  
  // Register shortcut to take screenshot based on current mode
  globalShortcut.register('CommandOrControl+P', () => {
    // Hide the preview window if it's open
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.hide();
    }
    
    // Take new screenshot based on mode
    if (isAreaSelectMode) {
      takeAreaScreenshot();
    } else {
      takeScreenshot();
    }
  });
}

// Wait for app to be ready
app.whenReady().then(initialize);

// Quit when all windows are closed
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// On macOS, re-create window when dock icon is clicked
app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
