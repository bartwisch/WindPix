const { app, BrowserWindow, globalShortcut, ipcMain, Tray, Menu, desktopCapturer, clipboard } = require('electron');
const path = require('path');
const fs = require('fs');
const Store = require('electron-store');

const store = new Store();

let mainWindow;
let tray;

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

function createTray() {
  const iconPath = path.join(__dirname, 'assets', 'icon.png');
  if (!fs.existsSync(iconPath)) {
    console.error('Tray icon not found:', iconPath);
    return;
  }
  
  tray = new Tray(iconPath);
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Take Screenshot', click: takeScreenshot },
    { type: 'separator' },
    { label: 'Settings', click: () => mainWindow.show() },
    { type: 'separator' },
    { label: 'Quit', click: () => app.quit() }
  ]);
  tray.setToolTip('WindPix');
  tray.setContextMenu(contextMenu);
}

async function takeScreenshot() {
  try {
    console.log('Taking screenshot...');
    const sources = await desktopCapturer.getSources({ types: ['screen'], thumbnailSize: { width: 1920, height: 1080 } });
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
    const image = primaryDisplay.thumbnail;
    const buffer = image.toPNG();
    clipboard.writeImage(image);
    console.log('Screenshot copied to clipboard');
    
    mainWindow.webContents.send('screenshot-taken', imgPath);
    mainWindow.show();
  } catch (error) {
    console.error('Screenshot failed - Full error:', error);
    mainWindow.webContents.send('screenshot-error', error.message);
    mainWindow.show();
  }
}

function initialize() {
  createWindow();
  createTray();
  globalShortcut.register('CommandOrControl+P', takeScreenshot);
}

// Wait for app to be ready
app.on('ready', initialize);

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

// Handle IPC messages from renderer
ipcMain.on('hide-window', () => {
  mainWindow.hide();
const { app, BrowserWindow, globalShortcut, ipcMain, Tray, Menu } = require('electron');
const path = require('path');
const screenshot = require('screenshot-desktop');
const Store = require('electron-store');

const store = new Store();

let mainWindow;
let tray;

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

function createTray() {
  tray = new Tray(path.join(__dirname, 'assets', 'icon.png'));
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Take Screenshot', click: takeScreenshot },
    { type: 'separator' },
    { label: 'Settings', click: () => mainWindow.show() },
    { type: 'separator' },
    { label: 'Quit', click: () => app.quit() }
  ]);
  tray.setToolTip('WindPix');
  tray.setContextMenu(contextMenu);
}

async function takeScreenshot() {
  try {
    const imgPath = await screenshot();
    mainWindow.webContents.send('screenshot-taken', imgPath);
    mainWindow.show();
  } catch (error) {
    console.error('Screenshot failed:', error);
  }
}

app.whenReady().then(() => {
  createWindow();
  createTray();

  // Register global shortcut (Command+P on Mac, Ctrl+P on Windows/Linux)
  globalShortcut.register('CommandOrControl+P', takeScreenshot);

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// Handle IPC messages from renderer
ipcMain.on('hide-window', () => {
  mainWindow.hide();
});
});
