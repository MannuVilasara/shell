import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Services
import qs.Modules.Launcher
import qs.Modules.Clipboard
import qs.Modules.Notifications
import qs.Modules.Panels

Item {
    id: root

    required property Context context
    

    NotificationManager {
        id: notifManager
    }

    NotificationToast {
        id: toast
        manager: notifManager
    }


    SidePanel {
        id: sidePanel
        globalState: root.context.appState
        notifManager: notifManager
        toastHovered: toast.hovered
    }

    WallpaperPanel {
        id: wallpaperPanel
        globalState: root.context.appState
    }

    PowerMenu {
        id: powerMenu
        isOpen: root.context.appState.powerMenuOpen
        globalState: root.context.appState
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
        target: "launcher"
        function toggle() { root.context.appState.toggleLauncher(); }
    }
    IpcHandler {
        target: "clipboard"
        function toggle() { root.context.appState.toggleClipboard(); }
    }
    IpcHandler {
        target: "sidePanel"
        function open() { sidePanel.show(); }
        function close() { sidePanel.hide(); }
        function toggle() { 
            if (sidePanel.forcedOpen) sidePanel.hide();
            else sidePanel.show();
        }
        function lock() { sidePanel.hoverLocked = true; }
        function unlock() { sidePanel.hoverLocked = false; }
        function toggleLock() { sidePanel.hoverLocked = !sidePanel.hoverLocked; }
    }
    IpcHandler {
        target: "wallpaperpanel"
        function toggle() { root.context.appState.toggleWallpaperPanel(); }
    }
    IpcHandler {
        target: "powermenu"
        function toggle() { root.context.appState.togglePowerMenu(); }
    }
    IpcHandler {
        target: "infopanel"
        function toggle() { root.context.appState.toggleInfoPanel(); }
    }
    IpcHandler {
        target: "cliphistService"
        function update() { clipboard.refresh(); }
    }
}
