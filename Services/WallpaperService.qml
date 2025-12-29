import Qt.labs.folderlistmodel
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services
pragma Singleton

Singleton {
    id: root

    property string defaultDirectory: Config.wallpaperDirectory
    property var currentWallpapers: ({
    })
    property var wallpaperLists: ({
    })
    property int scanningCount: 0
    readonly property bool scanning: (scanningCount > 0)
    property bool isInitialized: false
    property string wallpaperCacheFile: Quickshell.env("HOME") + "/.cache/mannu/wallpapers.json"
    property string colorsCacheFile: Quickshell.env("HOME") + "/.cache/mannu/colors.json"
    property string defaultWallpaper: ""
    property string previewDirectory: Quickshell.env("HOME") + "/.cache/mannu/wallpreviews"

    signal wallpaperChanged(string screenName, string path)
    signal wallpaperListChanged(string screenName, int count)

    function init() {
        console.log("[WallpaperService] Starting service");
        dirCreator.running = true;
        Qt.callLater(loadFromCache);
        Qt.callLater(refreshWallpapersList);
    }

    function loadFromCache() {
        wallpaperCacheView.path = wallpaperCacheFile;
    }

    function getWallpaper(screenName) {
        return currentWallpapers[screenName] || root.defaultWallpaper;
    }

    function changeWallpaper(path, screenName) {
        if (screenName !== undefined) {
            _setWallpaper(screenName, path);
        } else {
            for (var i = 0; i < Quickshell.screens.length; i++) {
                _setWallpaper(Quickshell.screens[i].name, path);
            }
        }
    }

    function _setWallpaper(screenName, path) {
        if (path === "" || path === undefined)
            return ;

        if (screenName === undefined) {
            console.log("[WallpaperService] No screen specified");
            return ;
        }
        var oldPath = currentWallpapers[screenName] || "";
        currentWallpapers[screenName] = path;
        saveTimer.restart();
        if (oldPath !== path)
            root.wallpaperChanged(screenName, path);

        console.log("[WallpaperService] Set wallpaper for", screenName, "to", path);
        // Copy to fixed path for fast loading
        wallpaperCopier.command = ["cp", path, Quickshell.env("HOME") + "/.cache/mannu/current_wallpaper"];
        wallpaperCopier.running = true;
        generateColors(path);
    }

    function generateColors(path) {
        if (!path)
            return ;

        var cachePath = colorsCacheFile;
        var logPath = Quickshell.env("HOME") + "/.cache/mannu/matugen.log";
        var cmd = "/usr/bin/matugen image '" + path + "' -j hex > '" + cachePath + "' 2> '" + logPath + "'";
        console.log("[WallpaperService] Generating colors:", cmd);
        matugenProcess.command = ["sh", "-c", cmd];
        matugenProcess.running = true;
    }

    function applyOpenRGB() {
        // Reload the colors file to get latest data
        colorsFileView.path = "";
        colorsFileView.path = colorsCacheFile;
    }

    function getWallpapersList(screenName) {
        if (screenName !== undefined && wallpaperLists[screenName] !== undefined)
            return wallpaperLists[screenName];

        return [];
    }

    function refreshWallpapersList() {
        console.log("[WallpaperService] Refreshing wallpapers list");
        // Trigger thumbnail generation
        thumbnailGenerator.command = ["python3", "/etc/xdg/quickshell/mannu/Scripts/generate_previews.py", root.defaultDirectory, root.previewDirectory];
        thumbnailGenerator.running = true;
        scanningCount = 0;
        for (var i = 0; i < wallpaperScanners.count; i++) {
            var scanner = wallpaperScanners.objectAt(i);
            if (scanner)
                (function(s) {
                var directory = root.defaultDirectory;
                s.currentDirectory = "/tmp";
                Qt.callLater(function() {
                    s.currentDirectory = directory;
                });
            })(scanner);

        }
    }

    Component.onCompleted: init()

    Process {
        id: dirCreator

        command: ["mkdir", "-p", Quickshell.env("HOME") + "/.cache/mannu"]
        running: false
    }

    Process {
        id: matugenProcess

        running: false
        onExited: (code, status) => {
            if (code === 0) {
                console.log("[WallpaperService] Matugen finished successfully");
                // Wait a moment for file to be written, then apply OpenRGB
                Qt.callLater(applyOpenRGB);
            } else {
                console.error("[WallpaperService] Matugen failed with code:", code);
            }
        }
    }

    Process {
        id: thumbnailGenerator

        running: false
        onExited: (code, status) => {
            if (code === 0)
                console.log("[WallpaperService] Thumbnails generated successfully");
            else
                console.error("[WallpaperService] Thumbnail generation failed:", code);
        }
    }

    Process {
        id: keyboardRgb

        running: false
        onStarted: {
            console.log("[WallpaperService] OpenRGB command:", command.join(" "));
        }
        onExited: (code, status) => {
            if (code !== 0) {
                console.error("[WallpaperService] OpenRGB failed with code:", code);
                console.error("[WallpaperService] Try running manually: openrgb --list-devices");
            } else {
                console.log("[WallpaperService] OpenRGB updated successfully");
            }
        }
    }

    Process {
        id: wallpaperCopier

        running: false
        onExited: (code, status) => {
            if (code === 0)
                console.log("[WallpaperService] Current wallpaper copied to cache");
            else
                console.error("[WallpaperService] Failed to copy wallpaper:", code);
        }
    }

    FileView {
        id: colorsFileView

        path: ""
        onLoaded: {
            console.log("[WallpaperService] Colors file loaded, extracting color...");
            try {
                var colors = colorsAdapter.colors;
                var selectedColor = null;
                if (colors) {
                    if (colors.source_color)
                        selectedColor = (typeof colors.source_color === "string") ? colors.source_color : (colors.source_color.default || colors.source_color.light || colors.source_color.dark);
                    else if (colors.tertiary)
                        selectedColor = (typeof colors.tertiary === "string") ? colors.tertiary : (colors.tertiary.light || colors.tertiary.default);
                    else if (colors.primary)
                        selectedColor = (typeof colors.primary === "string") ? colors.primary : (colors.primary.light || colors.primary.default);
                }
                if (selectedColor) {
                    var hex = selectedColor.toString().replace("#", "");
                    console.log("[WallpaperService] Applying OpenRGB color (Source/Accent):", hex);
                    keyboardRgb.command = ["openrgb", "--device", "0", "--color", hex];
                    keyboardRgb.running = true;
                } else {
                    console.error("[WallpaperService] Could not extract color from colors.json");
                    console.log("[WallpaperService] JSON keys:", JSON.stringify(Object.keys(colors || {
                    })));
                }
            } catch (e) {
                console.error("[WallpaperService] Error parsing colors:", e);
            }
        }
        onLoadFailed: (error) => {
            console.error("[WallpaperService] Failed to load colors file:", error);
        }

        adapter: JsonAdapter {
            id: colorsAdapter

            property var colors
            property var palettes
            property string image
            property bool is_dark_mode
            property string mode
        }

    }

    FileView {
        id: wallpaperCacheView

        path: ""
        onLoaded: {
            root.currentWallpapers = wallpaperCacheAdapter.wallpapers || {
            };
            root.defaultWallpaper = wallpaperCacheAdapter.defaultWallpaper || "";
            console.log("[WallpaperService] Loaded wallpapers from cache:", Object.keys(root.currentWallpapers).length, "screens");
            var screens = Object.keys(root.currentWallpapers);
            if (screens.length > 0) {
                var first = root.currentWallpapers[screens[0]];
                console.log("[WallpaperService] Generating initial colors from:", first);
                generateColors(first);
            }
            root.isInitialized = true;
        }
        onLoadFailed: (error) => {
            console.log("[WallpaperService] Cache not found, starting fresh");
            root.currentWallpapers = {
            };
            root.isInitialized = true;
        }

        adapter: JsonAdapter {
            id: wallpaperCacheAdapter

            property var wallpapers: ({
            })
            property string defaultWallpaper: ""
        }

    }

    Timer {
        id: saveTimer

        interval: 500
        repeat: false
        onTriggered: {
            wallpaperCacheAdapter.wallpapers = root.currentWallpapers;
            wallpaperCacheAdapter.defaultWallpaper = root.defaultWallpaper;
            wallpaperCacheView.writeAdapter();
            console.log("[WallpaperService] Saved wallpapers to cache");
        }
    }

    Instantiator {
        id: wallpaperScanners

        model: Quickshell.screens

        delegate: FolderListModel {
            property string screenName: modelData.name
            property string currentDirectory: root.defaultDirectory

            folder: "file://" + currentDirectory
            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.gif", "*.webp", "*.bmp", "*.svg"]
            showDirs: false
            sortField: FolderListModel.Name
            onCurrentDirectoryChanged: folder = "file://" + currentDirectory
            onStatusChanged: {
                if (status === FolderListModel.Null) {
                    root.wallpaperLists[screenName] = [];
                    root.wallpaperListChanged(screenName, 0);
                } else if (status === FolderListModel.Loading) {
                    root.wallpaperLists[screenName] = [];
                    scanningCount++;
                } else if (status === FolderListModel.Ready) {
                    var files = [];
                    for (var i = 0; i < count; i++) {
                        var directory = root.defaultDirectory;
                        var fp = directory + "/" + get(i, "fileName");
                        files.push(fp);
                    }
                    root.wallpaperLists[screenName] = files;
                    scanningCount--;
                    console.log("[WallpaperService] Refreshed:", screenName, "count:", files.length);
                    root.wallpaperListChanged(screenName, files.length);
                }
            }
        }

    }

}
