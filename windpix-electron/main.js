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
