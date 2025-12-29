import QtQuick
import Quickshell.Io

Item {
    // Expose total and used (bytes) plus usage percent
    property int total: 0
    property int used: 0
    property int usage: 0
    // Temporary storage for output
    property string outputBuffer: ""

    Component.onCompleted: {
        console.log("[MemService] Component initialized");
    }

    Process {
        // onExited: (code) => {
        //     console.log("[MemService] Process exited with code:", code);
        // }
        // onStarted: {
        //     console.log("[MemService] Process started");
        // }

        id: memProc

        // Use free with bytes and parse Mem line
        command: ["sh", "-c", "free -b | grep '^Mem:' | awk '{print $2, $3}'"]

        // Capture stdout as it comes in
        stdout: SplitParser {
            onRead: (data) => {
                if (!data) {
                    console.log("[MemService] No data received");
                    return ;
                }
                var output = data.trim();
                if (output === "") {
                    console.log("[MemService] Empty output after trim");
                    return ;
                }
                // Split by whitespace
                var parts = output.split(/\s+/);
                if (parts.length < 2) {
                    console.log("[MemService] Not enough parts");
                    return ;
                }
                var totalBytes = parseInt(parts[0]);
                var usedBytes = parseInt(parts[1]);
                if (isNaN(totalBytes) || isNaN(usedBytes) || totalBytes <= 0) {
                    console.log("[MemService] Invalid values");
                    return ;
                }
                // Update properties
                total = totalBytes;
                used = usedBytes;
                usage = Math.round((usedBytes / totalBytes) * 100);
            }
        }

    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            memProc.running = true;
        }
    }

}
