pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<QtObject> networks: []
    readonly property var active: {
        for (var i = 0; i < networks.length; i++) {
            if (networks[i].active) return networks[i]
        }
        return null
    }
    property bool wifiEnabled: true
    readonly property bool scanning: rescanProc.running

    Component.onDestruction: {
        // Clean up all dynamically created objects before engine shuts down
        while (networks.length > 0) {
            var obj = networks.shift();
            if (obj) obj.destroy();
        }
    }

    function setWifiEnabled(enabled) {
        const cmd = enabled ? "on" : "off"
        enableWifiProc.command = ["nmcli", "radio", "wifi", cmd]
        enableWifiProc.running = true
    }

    function toggleWifi() {
        setWifiEnabled(!wifiEnabled)
    }

    function rescanWifi() {
        rescanProc.running = true
    }

    function connectToNetwork(ssid, password) {
        if (password) {
             connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
        } else {
             connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid]
        }
        connectProc.running = true
    }

    function disconnectFromNetwork() {
        if (active) {
            disconnectProc.command = ["nmcli", "connection", "down", active.ssid]
            disconnectProc.running = true
        }
    }


    Process {
        id: statusProc
        running: true
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            onRead: data => {
                if (data) root.wifiEnabled = (data.trim() === "enabled")
            }
        }
    }

    Process {
        id: enableWifiProc
        onExited: {
            statusProc.running = true
            if (wifiEnabled) rescanProc.running = true
        }
    }

    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: {
            getNetworks.running = true
        }
    }

    Process {
        id: connectProc
        onExited: {
            rescanProc.running = true 
        }
    }
    Process {
        id: disconnectProc
        onExited: rescanProc.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statusProc.running = true
            if (wifiEnabled) getNetworks.running = true // Periodic update without full rescan
        }
    }

    Process {
        id: getNetworks
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text) return
                
                
                var lines = text.trim().split("\n")
                var parsedList = []
                
                lines.forEach(line => {
                    var safeLine = line.replace(/\\:/g, "__COLON__")
                    var parts = safeLine.split(":")
                    if (parts.length >= 4 && parts[3].length > 0) {
                        var ssid = parts[3].replace(/__COLON__/g, ":")
                        if (ssid === "") return // Skip empty SSIDs
                        
                        parsedList.push({
                            active: parts[0] === "yes",
                            strength: parseInt(parts[1]) || 0,
                            frequency: parseInt(parts[2]) || 0,
                            ssid: ssid,
                            bssid: parts[4] ? parts[4].replace(/__COLON__/g, ":") : "",
                            security: parts[5] || ""
                        })
                    }
                })

                var uniqueMap = {}
                parsedList.forEach(net => {
                    var existing = uniqueMap[net.ssid]
                    if (!existing) {
                        uniqueMap[net.ssid] = net
                    } else {
                        if (net.active) uniqueMap[net.ssid] = net // Active wins
                        else if (!existing.active && net.strength > existing.strength) uniqueMap[net.ssid] = net // Stronger wins
                    }
                })

                
                var newObjects = []
                for (var ssid in uniqueMap) {
                    var data = uniqueMap[ssid]
                    newObjects.push(apComponent.createObject(root, {
                        ssid: data.ssid,
                        bssid: data.bssid,
                        strength: data.strength,
                        frequency: data.frequency,
                        active: data.active,
                        security: data.security
                    }))
                }
                
                newObjects.sort((a, b) => {
                    if (a.active) return -1
                    if (b.active) return 1
                    return b.strength - a.strength
                })

                while(root.networks.length > 0) {
                    root.networks.shift().destroy() // Clean up QObjects
                }
                
                for (var j=0; j<newObjects.length; j++) {
                    root.networks.push(newObjects[j])
                }
                
                root.networksChanged() // Signal update
            }
        }
    }

    Component {
        id: apComponent
        QtObject {
            property string ssid
            property string bssid
            property int strength
            property int frequency
            property bool active
            property string security
            readonly property bool isSecure: security.length > 0 && security !== "--"
        }
    }
}
