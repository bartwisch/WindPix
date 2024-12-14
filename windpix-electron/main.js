const { app, BrowserWindow, globalShortcut, ipcMain, Tray, Menu, desktopCapturer, clipboard, screen } = require('electron');
const path = require('path');
const fs = require('fs');
const Store = require('electron-store');

const store = new Store();

let mainWindow;
let tray;
let selectionWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    show: false,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  mainWindow.loadFile('index.html');
}

function createSelectionWindow() {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  
  if (selectionWindow) {
    selectionWindow.close();
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

  // Ensure window can be closed with Cmd+Q
  globalShortcut.register('Command+Q', () => {
    app.quit();
  });
}

function createTray() {
  const iconPath = path.join(__dirname, 'assets', 'icon.png');
  if (!fs.existsSync(iconPath)) {
    console.error('Tray icon not found:', iconPath);
    return;
  }
  
  tray = new Tray(iconPath);
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Take Screenshot', click: takeScreenshot },
    { label: 'Select Area', click: takeAreaScreenshot },
    { type: 'separator' },
    { label: 'Settings', click: () => mainWindow.show() },
    { type: 'separator' },
    { label: 'Quit', click: () => app.quit() }
  ]);
  tray.setToolTip('WindPix');
  tray.setContextMenu(contextMenu);
}

async function takeAreaScreenshot() {
  try {
    // First get the screen capture permission
    const sources = await desktopCapturer.getSources({ 
      types: ['screen'],
      thumbnailSize: { 
        width: screen.getPrimaryDisplay().workAreaSize.width,
        height: screen.getPrimaryDisplay().workAreaSize.height 
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
    const sources = await desktopCapturer.getSources({ 
      types: ['screen'],
      thumbnailSize: { 
        width: screen.getPrimaryDisplay().workAreaSize.width,
        height: screen.getPrimaryDisplay().workAreaSize.height 
      }
    });
    
    const primaryDisplay = sources[0];
    if (!primaryDisplay) {
      throw new Error('No display found');
    }

    // Get the cropped image using Electron's NativeImage
    const fullImage = primaryDisplay.thumbnail;
    const croppedImage = fullImage.crop(bounds);
    
    // Save to file
    const timestamp = new Date().getTime();
    const imgPath = path.join(app.getPath('pictures'), `screenshot-${timestamp}.png`);
    fs.writeFileSync(imgPath, croppedImage.toPNG());
    console.log('Area screenshot saved:', imgPath);
    
    // Copy to clipboard
    clipboard.writeImage(croppedImage);
    console.log('Area screenshot copied to clipboard');
    
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('screenshot-taken', imgPath);
      mainWindow.show();
    }
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
    console.log('Taking screenshot...');
    const sources = await desktopCapturer.getSources({ 
      types: ['screen'], 
      thumbnailSize: { width: 1920, height: 1080 } 
    });
    const primaryDisplay = sources[0];
    
    if (!primaryDisplay) {
      throw new Error('No display found');
    }

    // Save to file
    const timestamp = new Date().getTime();
    const imgPath = path.join(app.getPath('pictures'), `screenshot-${timestamp}.png`);
    fs.writeFileSync(imgPath, primaryDisplay.thumbnail.toPNG());
    console.log('Screenshot saved:', imgPath);
    
    // Copy to clipboard
    clipboard.writeImage(primaryDisplay.thumbnail);
    console.log('Screenshot copied to clipboard');
    
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('screenshot-taken', imgPath);
      mainWindow.show();
    }
  } catch (error) {
    console.error('Screenshot failed - Full error:', error);
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('screenshot-error', error.message);
      mainWindow.show();
    }
  }
}

function initialize() {
  createWindow();
  createTray();
  
  // Set up IPC handlers after window is created
  ipcMain.on('hide-window', () => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.hide();
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
  
  globalShortcut.register('CommandOrControl+P', takeScreenshot);
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
