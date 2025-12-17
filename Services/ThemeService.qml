pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Singleton {
    id: root

    // Connect to WallpaperService to detect wallpaper changes
    Connections {
        target: WallpaperService
        function onWallpaperChanged(screenName, path) {
            if (path && path !== "") {
                console.log("[ThemeService] Wallpaper changed for", screenName, "to", path)
                generateTheme(path)
            }
        }
    }

    Component.onCompleted: {
        console.log("[ThemeService] ThemeService initialized")
    }

    function generateTheme(wallpaperPath) {
        console.log("[ThemeService] Generating theme from:", wallpaperPath)
        themeGenerator.command = [
            "matugen", "image", wallpaperPath,
            "-c", "/etc/xdg/quickshell/mannu/matugen/config.toml"
        ]
        themeGenerator.running = true
    }

    Process {
        id: themeGenerator
        command: []
        running: false

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                console.log("[ThemeService] Theme generated successfully, reloading shell...")
                Quickshell.reload(false)
            } else {
                console.error("[ThemeService] Failed to generate theme, exit code:", exitCode)
            }
        }
    }
}
