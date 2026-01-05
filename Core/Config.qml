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
    property string barPosition: "top"
    property var colors: null
    property var openRgbDevices: [0]
    property bool disableLockBlur: false
    property bool disableLockAnimation: false
    property bool lockScreenCustomBackground: false
    property bool lockScreenMusicMode: false
    property bool lazyLoadLockScreen: true
    property bool shellLoaded: false
    property bool debug: false
    property bool _loading: false
    property bool hideWorkspaceNumbers: false
    property bool hideAppIcons: false

    function save() {
        if (_loading)
            return ;

        configAdapter.fontFamily = root.fontFamily;
        configAdapter.fontSize = root.fontSize;
        configAdapter.wallpaperDirectory = root.wallpaperDirectory;
        configAdapter.disableHover = root.disableHover;
        configAdapter.floatingBar = root.floatingBar;
        configAdapter.barPosition = root.barPosition;
        configAdapter.hideWorkspaceNumbers = root.hideWorkspaceNumbers;
        configAdapter.hideAppIcons = root.hideAppIcons;
        configAdapter.colors = root.colors;
        configAdapter.openRgbDevices = root.openRgbDevices;
        configAdapter.disableLockBlur = root.disableLockBlur;
        configAdapter.disableLockAnimation = root.disableLockAnimation;
        configAdapter.lockScreenCustomBackground = root.lockScreenCustomBackground;
        configAdapter.lockScreenMusicMode = root.lockScreenMusicMode;
        configAdapter.lazyLoadLockScreen = root.lazyLoadLockScreen;
        configAdapter.debug = root.debug;
        configFile.writeAdapter();
        Logger.d("Config", "Settings saved to " + root.configPath);
    }

    onDebugChanged: {
        Logger.debugEnabled = debug;
        if (!_loading)
            saveTimer.restart();

    }
    onHideWorkspaceNumbersChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onHideAppIconsChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onFontFamilyChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onFontSizeChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onWallpaperDirectoryChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onDisableHoverChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onFloatingBarChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onBarPositionChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onColorsChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onOpenRgbDevicesChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onDisableLockBlurChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onDisableLockAnimationChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onLockScreenCustomBackgroundChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onLockScreenMusicModeChanged: {
        if (!_loading)
            saveTimer.restart();

    }
    onLazyLoadLockScreenChanged: {
        if (!_loading)
            saveTimer.restart();

    }

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
        onLoaded: {
            root._loading = true;
            try {
                if (configAdapter.hideWorkspaceNumbers !== undefined)
                    root.hideWorkspaceNumbers = configAdapter.hideWorkspaceNumbers;

                if (configAdapter.hideAppIcons !== undefined)
                    root.hideAppIcons = configAdapter.hideAppIcons;

                if (configAdapter.fontFamily)
                    root.fontFamily = configAdapter.fontFamily;

                if (configAdapter.fontSize)
                    root.fontSize = configAdapter.fontSize;

                if (configAdapter.wallpaperDirectory)
                    root.wallpaperDirectory = configAdapter.wallpaperDirectory;

                if (configAdapter.disableHover !== undefined)
                    root.disableHover = configAdapter.disableHover;

                if (configAdapter.floatingBar !== undefined)
                    root.floatingBar = configAdapter.floatingBar;

                if (configAdapter.barPosition)
                    root.barPosition = configAdapter.barPosition;

                if (configAdapter.colors)
                    root.colors = configAdapter.colors;

                if (configAdapter.disableLockBlur !== undefined)
                    root.disableLockBlur = configAdapter.disableLockBlur;

                if (configAdapter.disableLockAnimation !== undefined)
                    root.disableLockAnimation = configAdapter.disableLockAnimation;

                if (configAdapter.lockScreenCustomBackground !== undefined)
                    root.lockScreenCustomBackground = configAdapter.lockScreenCustomBackground;

                if (configAdapter.lockScreenMusicMode !== undefined)
                    root.lockScreenMusicMode = configAdapter.lockScreenMusicMode;

                if (configAdapter.lazyLoadLockScreen !== undefined)
                    root.lazyLoadLockScreen = configAdapter.lazyLoadLockScreen;

                if (configAdapter.debug !== undefined)
                    root.debug = configAdapter.debug;

                if (configAdapter.openRgbDevices !== undefined) {
                    var dev = configAdapter.openRgbDevices;
                    var flatList = [];
                    var flatten = function flatten(val) {
                        if (val === undefined || val === null)
                            return ;

                        if (Array.isArray(val) || (typeof val === 'object' && val.length !== undefined)) {
                            for (var i = 0; i < val.length; i++) {
                                flatten(val[i]);
                            }
                        } else {
                            flatList.push(val);
                        }
                    };
                    flatten(dev);
                    root.openRgbDevices = flatList;
                    Logger.d("Config", "Loaded OpenRGB devices:", JSON.stringify(flatList));
                }
                Logger.i("Config", "Loaded from " + root.configPath);
            } catch (e) {
                Logger.e("Config", "Failed to apply config: " + e);
            }
            root._loading = false;
        }

        adapter: JsonAdapter {
            id: configAdapter

            property string fontFamily
            property int fontSize
            property string wallpaperDirectory
            property bool disableHover
            property bool floatingBar
            property string barPosition
            property var colors
            property var openRgbDevices
            property bool disableLockBlur
            property bool disableLockAnimation
            property bool lockScreenCustomBackground
            property bool lockScreenMusicMode
            property bool lazyLoadLockScreen
            property bool debug
            property bool hideWorkspaceNumbers
            property bool hideAppIcons
        }

    }

    Timer {
        id: saveTimer

        interval: 1000
        repeat: false
        onTriggered: root.save()
    }

}
