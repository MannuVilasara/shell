import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var timeZones: []
    property string currentSystemZone: ""
    property bool isLoading: true


    function setTimeZone(zone) {
        if (zone && zone !== currentSystemZone) {
            setZoneProc.targetZone = zone
            setZoneProc.running = true
        }
    }

    function refresh() {
        getZoneProc.running = true
        
        if (timeZones.length === 0) {
            listZonesProc.running = true
        }
    }

    
    Process {
        id: listZonesProc
        command: ["sh", "-c", "timedatectl list-timezones"]
        Component.onCompleted: running = true
        
        property string output: ""
        
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (line && line.trim()) {
                    listZonesProc.output += line + "\n"
                }
            }
        }
        
        onExited: (code) => {
            if (code === 0 && output.length > 0) {
                var zones = output.trim().split("\n").filter(z => z.length > 0)
                root.timeZones = zones
                root.isLoading = false
            }
        }
    }


    Process {
        id: getZoneProc
        command: ["sh", "-c", "timedatectl show --property=Timezone --value"]
        Component.onCompleted: running = true
        
        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    root.currentSystemZone = data.trim()
                }
            }
        }
    }


    Process {
        id: setZoneProc
        property string targetZone: ""
        command: ["pkexec", "timedatectl", "set-timezone", targetZone]
        running: false
        
        onExited: (code) => {
            if (code === 0) {

                root.currentSystemZone = targetZone
            }
            getZoneProc.running = true
        }
    }
}