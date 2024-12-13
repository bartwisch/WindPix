const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld(
    'api', {
        // Add methods you want to expose to the renderer process here
        // For example:
        // send: (channel, data) => {
        //     ipcRenderer.send(channel, data);
        // },
        // receive: (channel, func) => {
        //     ipcRenderer.on(channel, (event, ...args) => func(...args));
        // }
    }
);
