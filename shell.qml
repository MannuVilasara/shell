pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import "bar"
import "core"
import "background"
import "services"
import "launcher"
import "clipboard"
import "notifications"
import "panels"

ShellRoot {
    id: root

    // --- Services ---
    Colors {
        id: colors
    }
    CpuService {
        id: cpuService
    }
    OsService {
        id: osService
    }
    MemService {
        id: memService
    }
    DiskService {
        id: diskService
    }
    VolumeService {
        id: volumeService
    }
    TimeService {
        id: timeService
    }
    ActiveWindowService {
        id: activeWindowService
    }
    LayoutService {
        id: layoutService
    }
    GlobalState {
        id: appState
    }

    // --- Config ---
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    // --- System Info Props ---
    property string kernelVersion: osService.version
    property int cpuUsage: cpuService.usage
    property int memUsage: memService.usage
    property int diskUsage: diskService.usage
    property int volumeLevel: volumeService.level
    property string activeWindow: activeWindowService.title
    property string currentLayout: layoutService.layout

    NotificationManager {
        id: notifManager
    }

    NotificationToast {
        manager: notifManager
    }

    SidePanel {
        globalState: appState
        notifManager: notifManager
    }
    // --- Background (Wallpaper) ---
    Background {}

    // --- Launcher & Clipboard ---
    AppLauncher {
        id: launcher
        colors: colors
        globalState: appState
    }

    Clipboard {
        id: clipboard
        globalState: appState
        colors: colors
    }

    // --- IPC Handlers ---
    // Launcher Toggle
    IpcHandler {
        target: "launcher"
        function toggle() {
            appState.toggleLauncher();
        }
    }

    // Clipboard Toggle
    IpcHandler {
        target: "clipboard"
        function toggle() {
            appState.toggleClipboard();
        }
    }

    // Cliphist Update (Keeps refreshing logic separate)
    IpcHandler {
        target: "cliphistService"
        function update() {
            clipboard.refresh();
        }
    }
    // Side Panel Toggle
    IpcHandler {
        target: "sidePanel"
        function toggle() {
            appState.toggleSidePanel();
        }
    }

    // --- THE BAR ---
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            // Anchor to edges
            anchors {
                top: true
                left: true
                right: true
            }

            // Height & Margin Tweak
            // 1. Increased height slightly so it breathes (30 -> 34)
            implicitHeight: 34

            // 2. Added the "0.5 or sum" vertical gap (5px top margin)
            margins {
                top: 5
                bottom: 0
                left: 8  // Matching side margins for consistency
                right: 8
            }

            color: "transparent" // Let the Bar.qml handle the background (or transparent)

            Bar {
                // Pass all required props
                colors: colors
                fontFamily: root.fontFamily
                fontSize: root.fontSize
                kernelVersion: root.kernelVersion
                cpuUsage: root.cpuUsage
                memUsage: root.memUsage
                diskUsage: root.diskUsage
                volumeLevel: root.volumeLevel
                activeWindow: root.activeWindow
                currentLayout: root.currentLayout
                time: timeService.currentTime
            }
        }
    }
}
