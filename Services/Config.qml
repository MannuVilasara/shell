import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
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
    property var openRgbDevices: [0]
    property bool debug: false

    onDebugChanged: {
        Logger.debugEnabled = debug
        if (!_loading) saveTimer.restart()
    }
    Component.onCompleted: Logger.debugEnabled = debug

    property bool _loading: false

    function save() {
        if (_loading) return;

        configAdapter.fontFamily = root.fontFamily;
        configAdapter.fontSize = root.fontSize;
        configAdapter.wallpaperDirectory = root.wallpaperDirectory;
        configAdapter.disableHover = root.disableHover;
        configAdapter.floatingBar = root.floatingBar;
        configAdapter.colors = root.colors;
        configAdapter.openRgbDevices = root.openRgbDevices;
        configAdapter.debug = root.debug;

        configFile.writeAdapter();
        Logger.d("Config", "Settings saved to " + root.configPath);
    }

    Timer {
        id: saveTimer
        interval: 1000
        onTriggered: save()
    }

    onFontFamilyChanged: if (!_loading) saveTimer.restart()
    onFontSizeChanged: if (!_loading) saveTimer.restart()
    onWallpaperDirectoryChanged: if (!_loading) saveTimer.restart()
    onDisableHoverChanged: if (!_loading) saveTimer.restart()
    onFloatingBarChanged: if (!_loading) saveTimer.restart()
    onColorsChanged: if (!_loading) saveTimer.restart()
    onOpenRgbDevicesChanged: if (!_loading) saveTimer.restart()

    FileView {
        id: configFile

        path: root.configPath
        watchChanges: true
        onFileChanged: {
            if (!root._loading) {
                Logger.d("Config", "Config file changed externally, reloading...");
                configFile.reload();
            }
        }

        adapter: JsonAdapter {
            id: configAdapter
            property string fontFamily
            property int fontSize
            property string wallpaperDirectory
            property bool disableHover
            property bool floatingBar
            property var colors
            property var openRgbDevices
            property bool debug
        }

        onLoaded: {
            root._loading = true;
            try {
                if (configAdapter.fontFamily) root.fontFamily = configAdapter.fontFamily;
                if (configAdapter.fontSize) root.fontSize = configAdapter.fontSize;
                if (configAdapter.wallpaperDirectory) root.wallpaperDirectory = configAdapter.wallpaperDirectory;
                if (configAdapter.disableHover !== undefined) root.disableHover = configAdapter.disableHover;
                if (configAdapter.floatingBar !== undefined) root.floatingBar = configAdapter.floatingBar;
                if (configAdapter.colors) root.colors = configAdapter.colors;
                if (configAdapter.debug !== undefined) root.debug = configAdapter.debug;

                if (configAdapter.openRgbDevices !== undefined) {
                    var dev = configAdapter.openRgbDevices;
                    if (Array.isArray(dev))
                        root.openRgbDevices = dev;
                    else
                        root.openRgbDevices = [dev]; // Handle single value
                }
                Logger.i("Config", "Loaded from " + root.configPath);
            } catch (e) {
                Logger.e("Config", "Failed to apply config: " + e);
            }
            root._loading = false;
        }
    }

}
