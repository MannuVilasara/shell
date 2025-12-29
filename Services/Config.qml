import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property string configPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/mannu/config.json"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14
    property string wallpaperDirectory: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property bool disableHover: false
    property bool floatingBar: false
    property var colors: null

    FileView {
        id: configFile

        path: root.configPath
        watchChanges: true
        onFileChanged: {
            console.log("Config changed, reloading...");
            configFile.reload();
        }
        onLoaded: {
            try {
                var json = JSON.parse(configFile.text());
                if (json.fontFamily)
                    root.fontFamily = json.fontFamily;

                if (json.fontSize)
                    root.fontSize = json.fontSize;

                if (json.wallpaperDirectory)
                    root.wallpaperDirectory = json.wallpaperDirectory;

                if (json.disableHover !== undefined)
                    root.disableHover = json.disableHover;

                if (json.floatingBar !== undefined) {
                    root.floatingBar = json.floatingBar;
                    console.log("Config: floatingBar set to", root.floatingBar);
                }
                if (json.colors)
                    root.colors = json.colors;

                console.log("Config loaded from " + root.configPath);
            } catch (e) {
                console.error("Failed to parse config: " + e);
            }
        }
    }

}
