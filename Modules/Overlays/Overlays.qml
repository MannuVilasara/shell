import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Modules.Clipboard
import qs.Modules.Launcher
import qs.Modules.Notifications
import qs.Modules.Panels
import qs.Services

Item {
    id: root

    required property Context context

    NotificationManager {
        id: notifManager
    }

    NotificationToast {
        id: toast

        manager: notifManager
        colors: root.context.colors
    }

    SidePanel {
        id: sidePanel

        globalState: root.context.appState
        notifManager: notifManager
        colors: root.context.colors
        toastHovered: toast.hovered || false
        volumeService: root.context.volume
        bluetoothService: root.context.bluetooth
    }

    WallpaperPanel {
        id: wallpaperPanel

        globalState: root.context.appState
    }

    PowerMenu {
        id: powerMenu

        isOpen: root.context.appState.powerMenuOpen
        globalState: root.context.appState
        colors: root.context.colors
    }

    InfoPanel {
        id: infoPanel

        globalState: root.context.appState
    }

    AppLauncher {
        id: launcher

        colors: root.context.colors
        globalState: root.context.appState
    }

    Clipboard {
        id: clipboard

        globalState: root.context.appState
        colors: root.context.colors
    }

    IpcHandler {
        function toggle() {
            root.context.appState.toggleLauncher();
        }

        target: "launcher"
    }

    IpcHandler {
        function toggle() {
            root.context.appState.toggleClipboard();
        }

        target: "clipboard"
    }

    IpcHandler {
        function open() {
            sidePanel.show();
        }

        function close() {
            sidePanel.hide();
        }

        function toggle() {
            if (sidePanel.forcedOpen)
                sidePanel.hide();
            else
                sidePanel.show();
        }

        function lock() {
            sidePanel.hoverLocked = true;
        }

        function unlock() {
            sidePanel.hoverLocked = false;
        }

        function toggleLock() {
            sidePanel.hoverLocked = !sidePanel.hoverLocked;
        }

        target: "sidePanel"
    }

    IpcHandler {
        function toggle() {
            root.context.appState.toggleWallpaperPanel();
        }

        target: "wallpaperpanel"
    }

    IpcHandler {
        function toggle() {
            root.context.appState.togglePowerMenu();
        }

        target: "powermenu"
    }

    IpcHandler {
        function toggle() {
            root.context.appState.toggleInfoPanel();
        }

        target: "infopanel"
    }

    IpcHandler {
        function update() {
            clipboard.refresh();
        }

        target: "cliphistService"
    }

    IpcHandler {
        function set(path: string) {
            WallpaperService.changeWallpaper(path, undefined);
        }

        target: "wallpaper"
    }

}
