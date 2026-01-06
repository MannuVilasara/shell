import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root

    property string title: loader.item ? loader.item.title : ""
    property bool isFullscreen: loader.item ? loader.item.isFullscreen : false
    property string layout: loader.item ? loader.item.layout : "Tiled"
    property int activeWorkspace: loader.item ? loader.item.activeWorkspace : 1
    property var workspaces: loader.item ? loader.item.workspaces : []
    property bool isSpecialOpen: (detectedCompositor === "hyprland") && loader.item ? loader.item.isSpecialOpen : false
    property string detectedCompositor: "hyprland"
    property int workspaceCount: loader.item ? loader.item.workspaceCount : 10

    property var windowList: loader.item ? loader.item.windowList : []
    
    function changeWorkspace(id) {
        if (loader.item)
            loader.item.changeWorkspace(id);

    }

    function changeWorkspaceRelative(delta) {
        if (loader.item)
            loader.item.changeWorkspaceRelative(delta);

    }

    function isWorkspaceOccupied(id) {
        if (loader.item && loader.item.isWorkspaceOccupied)
            return loader.item.isWorkspaceOccupied(id);
        return false;
    }

    function focusedWindowForWorkspace(id) {
        if (loader.item && loader.item.focusedWindowForWorkspace)
            return loader.item.focusedWindowForWorkspace(id);
        return null;
    }

    Process {
        id: detectProc

        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const val = data.trim().toLowerCase();
                if (val.includes("niri")) {
                    root.detectedCompositor = "niri";
                    loader.sourceComponent = niriComponent;
                } else if (val.includes("hyprland")) {
                    root.detectedCompositor = "hyprland";
                    loader.sourceComponent = hyprlandComponent;
                }
            }
        }

    }

    Loader {
        id: loader
    }

    Component {
        id: hyprlandComponent

        Item {
            id: hyprlandRoot

            property string title: activeToplevel?.title ?? ""
            property bool isFullscreen: activeToplevel?.fullscreen || (windowList && windowList.some(w => w.workspace.id === focusedWorkspaceId && w.fullscreen))
            property string layout: "Tiled" // simplified
            property int activeWorkspace: focusedWorkspaceId
            property var workspaces: Hyprland.workspaces.values
            property bool isSpecialOpen: {
                 if (!focusedMonitor || !monitorsInfo) return false
                 const m = monitorsInfo.find(m => m.id === focusedMonitor.id)
                 return m && m.specialWorkspace && m.specialWorkspace.name !== ""
            }
            property int workspaceCount: {
                let max = 5
                for (let i = 0; i < workspaces.length; i++) {
                    if (workspaces[i].id > max) max = workspaces[i].id
                }
                return max
            }

            readonly property var toplevels: Hyprland.toplevels
            readonly property var monitors: Hyprland.monitors
            readonly property var activeToplevel: Hyprland.focusedWindow 
            readonly property var focusedWorkspace: Hyprland.focusedWorkspace
            readonly property var focusedMonitor: Hyprland.focusedMonitor
            readonly property int focusedWorkspaceId: focusedWorkspace?.id ?? 1

            property var windowList: []
            property var windowByAddress: ({})
            property var addresses: []
            property var layers: ({})
            property var monitorsInfo: []
            property var workspacesInfo: []
            property var workspaceById: ({})
            property var workspaceIds: []
            property var activeWorkspaceInfo: null
            property string keyboardLayout: "?"

            function changeWorkspace(id) {
                if (id === focusedWorkspaceId) return
                Hyprland.dispatch("workspace " + id);
            }

            function changeWorkspaceRelative(delta) {
                
                
                let target = focusedWorkspaceId + delta
                if (target < 1) target = 1
                
                if (target === focusedWorkspaceId) return
                
                Hyprland.dispatch("workspace " + target) 
            }

            function focusedWindowForWorkspace(workspaceId) {
                const wsWindows = windowList.filter(w => w.workspace.id === workspaceId);
                if (wsWindows.length === 0) return null;

                return wsWindows.reduce((best, win) => {
                    const bestFocus = best?.focusHistoryID ?? Infinity;
                    const winFocus = win?.focusHistoryID ?? Infinity;
                    return winFocus < bestFocus ? win : best;
                }, null);
            }

            function isWorkspaceOccupied(id) {
                return Hyprland.workspaces.values.find((w) => {
                    return w?.id === id
                })?.lastIpcObject.windows > 0 || false
            }

            function updateAll() {
                getClients.running = true
                getLayers.running = true
                getMonitors.running = true
                getWorkspaces.running = true
                getActiveWorkspace.running = true
            }

            function refreshKeyboardLayout() {
                hyprctlDevices.running = true
            }

            Process {
                id: hyprctlDevices
                command: ["hyprctl", "devices", "-j"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            const devices = JSON.parse(this.text)
                            const keyboard = devices.keyboards.find(k => k.main) || devices.keyboards[0]
                            if (keyboard && keyboard.active_keymap) {
                                hyprlandRoot.keyboardLayout = keyboard.active_keymap.toUpperCase().slice(0, 2)
                            } else {
                                hyprlandRoot.keyboardLayout = "?"
                            }
                        } catch (err) {
                            console.error("Failed to parse keyboard layout:", err)
                            hyprlandRoot.keyboardLayout = "?"
                        }
                    }
                }
            }

            Process {
                id: getClients
                command: ["hyprctl", "clients", "-j"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            hyprlandRoot.windowList = JSON.parse(this.text)
                            let tempWinByAddress = {}
                            for (let win of hyprlandRoot.windowList) tempWinByAddress[win.address] = win
                            hyprlandRoot.windowByAddress = tempWinByAddress
                            hyprlandRoot.addresses = hyprlandRoot.windowList.map(w => w.address)
                        } catch (e) {
                            console.error("Failed to parse clients:", e)
                        }
                    }
                }
            }

            Process {
                id: getMonitors
                command: ["hyprctl", "monitors", "-j"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            hyprlandRoot.monitorsInfo = JSON.parse(this.text)
                        } catch (e) {
                            console.error("Failed to parse monitors:", e)
                        }
                    }
                }
            }

            Process {
                id: getLayers
                command: ["hyprctl", "layers", "-j"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            hyprlandRoot.layers = JSON.parse(this.text)
                        } catch (e) {
                            console.error("Failed to parse layers:", e)
                        }
                    }
                }
            }

            Process {
                id: getWorkspaces
                command: ["hyprctl", "workspaces", "-j"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            hyprlandRoot.workspacesInfo = JSON.parse(this.text)
                            let map = {}
                            for (let ws of hyprlandRoot.workspacesInfo) map[ws.id] = ws
                            hyprlandRoot.workspaceById = map
                            hyprlandRoot.workspaceIds = hyprlandRoot.workspacesInfo.map(ws => ws.id)
                        } catch (e) {
                            console.error("Failed to parse workspaces:", e)
                        }
                    }
                }
            }

            Process {
                id: getActiveWorkspace
                command: ["hyprctl", "activeworkspace", "-j"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            hyprlandRoot.activeWorkspaceInfo = JSON.parse(this.text)
                        } catch (e) {
                            console.error("Failed to parse active workspace:", e)
                        }
                    }
                }
            }

            Connections {
                target: Hyprland
                function onRawEvent(event) {
                    if (event.name.endsWith("v2"))
                        return

                    if (event.name.includes("activelayout"))
                        refreshKeyboardLayout()
                    else if (event.name.includes("mon"))
                        Hyprland.refreshMonitors()
                    else if (event.name.includes("workspace") || event.name.includes("window"))
                        Hyprland.refreshWorkspaces()
                    else
                        Hyprland.refreshToplevels()

                    updateAll()
                }
            }

            Component.onCompleted: {
                updateAll()
                refreshKeyboardLayout()
            }
        }

    }

    Component {
        id: niriComponent

        Item {
            id: niriItem

            property string title: ""
            property bool isFullscreen: false
            property string layout: "Tiled"
            property int activeWorkspace: 1
            property var workspaces: []
            property var workspaceCache: ({
            })
            property bool initialized: false

            function changeWorkspace(id) {
                sendSocketCommand(niriCommandSocket, {
                    "Action": {
                        "focus_workspace": {
                            "reference": {
                                "Id": id
                            }
                        }
                    }
                });
                dispatchProc.command = ["niri", "msg", "action", "focus-workspace", id.toString()];
                dispatchProc.running = true;
            }

            function changeWorkspaceRelative(delta) {
                const cmd = delta > 0 ? "focus-workspace-down" : "focus-workspace-up";
                dispatchProc.command = ["niri", "msg", "action", cmd];
                dispatchProc.running = true;
            }

            function sendSocketCommand(sock, command) {
                if (sock.connected)
                    sock.write(JSON.stringify(command) + "\n");

            }

            function startEventStream() {
                sendSocketCommand(niriEventStream, "EventStream");
            }

            function updateWorkspaces() {
                sendSocketCommand(niriCommandSocket, "Workspaces");
            }

            function updateWindows() {
                sendSocketCommand(niriCommandSocket, "Windows");
            }

            function updateFocusedWindow() {
                sendSocketCommand(niriCommandSocket, "FocusedWindow");
            }

            function recollectWorkspaces(workspacesData) {
                const workspacesList = [];
                workspaceCache = {
                };
                for (const ws of workspacesData) {

                    const wsData = {
                        "id": (ws.idx !== undefined ? ws.idx + 1 : ws.id),
                        "internalId": ws.id,
                        "idx": ws.idx,
                        "name": ws.name || "",
                        "output": ws.output || "",
                        "isFocused": ws.is_focused === true,
                        "isActive": ws.is_active === true
                    };
                    workspacesList.push(wsData);
                    workspaceCache[ws.id] = wsData;
                    if (wsData.isFocused)
                        activeWorkspace = wsData.id;

                }
                workspacesList.sort((a, b) => {
                    return a.id - b.id;
                });
                workspaces = workspacesList;
            }

            function recollectFocusedWindow(win) {
                if (win && win.title) {
                    title = win.title || "~";
                    isFullscreen = win.is_fullscreen || false;
                    layout = "Tiled"; // Niri is tiled mostly
                } else {
                    title = "~";
                    isFullscreen = false;
                    layout = "Tiled";
                }
            }

            Component.onCompleted: {
                if (Quickshell.env("NIRI_SOCKET")) {
                    niriCommandSocket.connected = true;
                    niriEventStream.connected = true;
                    initialized = true;
                }
            }

            Socket {
                id: niriCommandSocket

                path: Quickshell.env("NIRI_SOCKET") || ""
                connected: false
                onConnectedChanged: {
                    if (connected) {
                        updateWorkspaces();
                        updateFocusedWindow();
                    }
                }

                parser: SplitParser {
                    onRead: function(line) {
                        if (!line.trim())
                            return ;

                        try {
                            const data = JSON.parse(line);
                            if (data && data.Ok) {
                                const res = data.Ok;
                                if (res.Workspaces)
                                    recollectWorkspaces(res.Workspaces);
                                else if (res.FocusedWindow)
                                    recollectFocusedWindow(res.FocusedWindow);
                            }
                        } catch (e) {
                            console.warn("Niri socket parse error:", e);
                        }
                    }
                }

            }

            Socket {
                id: niriEventStream

                path: Quickshell.env("NIRI_SOCKET") || ""
                connected: false
                onConnectedChanged: {
                    if (connected)
                        startEventStream();

                }

                parser: SplitParser {
                    onRead: (data) => {
                        if (!data.trim())
                            return ;

                        try {
                            const event = JSON.parse(data.trim());
                            if (event.WorkspacesChanged)
                                recollectWorkspaces(event.WorkspacesChanged.workspaces);
                            else if (event.WorkspaceActivated)
                                updateWorkspaces(); // Re-fetch to be safe and get full state
                            else if (event.WindowFocusChanged)
                                updateFocusedWindow();
                            else if (event.WindowOpenedOrChanged)
                                updateFocusedWindow(); // Check if new window is focused
                            else if (event.WindowClosed)
                                updateFocusedWindow();
                        } catch (e) {
                            console.warn("Niri event stream parse error:", e);
                        }
                    }
                }

            }

            Process {
                id: dispatchProc
            }

        }

    }

}
