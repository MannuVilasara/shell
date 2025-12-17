

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string configPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/mannu/config.json"
    
    // Default values
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14
    property string wallpaperDirectory: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    
    property bool disableHover: false
    
    // Add more properties as needed
    property var colors: null

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        
        onLoaded: {
            try {
                var json = JSON.parse(configFile.text())
                if (json.fontFamily) root.fontFamily = json.fontFamily
                if (json.fontSize) root.fontSize = json.fontSize
                if (json.wallpaperDirectory) root.wallpaperDirectory = json.wallpaperDirectory
                if (json.disableHover !== undefined) root.disableHover = json.disableHover
                if (json.colors) root.colors = json.colors
                console.log("Config loaded from " + root.configPath)
            } catch (e) {
                console.error("Failed to parse config: " + e)
            }
        }
    }
}
