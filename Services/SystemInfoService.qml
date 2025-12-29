import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string userName: "User"
    property string osName: "Linux"
    property string hostName: "Localhost"
    property string kernelVersion: "Unknown"
    property string uptime: "Unknown"
    property string shellName: "Unknown"
    property string wmName: "Quickshell"

    Process {
        command: ["whoami"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    console.log("SystemInfo: User fetched -> " + data);
                    root.userName = data.trim();
                }
            }
        }

    }

    Process {
        command: ["sh", "-c", "grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '\"'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    console.log("SystemInfo: OS fetched -> " + data);
                    root.osName = data.trim();
                }
            }
        }

    }

    Process {
        command: ["cat", "/proc/sys/kernel/hostname"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "")
                    root.hostName = data.trim();

            }
        }

    }

    Process {
        command: ["uname", "-r"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.kernelVersion = data.trim();

            }
        }

    }

    Process {
        command: ["sh", "-c", "echo $SHELL | awk -F/ '{print $NF}'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.shellName = data.trim();

            }
        }

    }

    Process {
        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "")
                    root.wmName = data.trim();

            }
        }

    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: uptimeProc.running = true
    }

    Process {
        id: uptimeProc

        command: ["uptime", "-p"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.uptime = data.replace("up ", "").trim();

            }
        }

    }

}
