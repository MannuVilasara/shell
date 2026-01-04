import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string name: "Linux"
    property string url: "https://kernel.org"
    property string icon: "" // Default Tux icon
    property string bugUrl: ""
    property string supportUrl: ""
    property string distroId: ""

    property var _proc: Process {
        command: ["cat", "/etc/os-release"]
        running: true
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: (line) => {
                const trimmed = line.trim();
                if (!trimmed || trimmed.startsWith("#")) return;
                
                const eqIdx = trimmed.indexOf("=");
                if (eqIdx === -1) return;
                
                const key = trimmed.substring(0, eqIdx);
                let val = trimmed.substring(eqIdx + 1);
                
                // Strip quotes
                if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
                    val = val.substring(1, val.length - 1);
                }
                
                // Set properties directly as we parse each line
                if (key === "NAME" && root.name === "Linux") {
                    root.name = val;
                } else if (key === "PRETTY_NAME" && root.name === "Linux") {
                    root.name = val;
                } else if (key === "HOME_URL") {
                    root.url = val;
                } else if (key === "BUG_REPORT_URL") {
                    root.bugUrl = val;
                } else if (key === "SUPPORT_URL") {
                    root.supportUrl = val;
                } else if (key === "ID") {
                    root.distroId = val;
                    root.icon = _getIcon(val);
                }
            }
        }
        
        onExited: (code) => {
            // Set defaults if URLs weren't found
            if (root.bugUrl === "") root.bugUrl = root.url;
            if (root.supportUrl === "") root.supportUrl = root.url;
        }
    }

    function _getIcon(id) {
        const map = {
            "arch": "",
            "debian": "",
            "ubuntu": "",
            "fedora": "",
            "opensuse": "",
            "nixos": "",
            "gentoo": "",
            "linuxmint": "",
            "elementary": "",
            "manjaro": "",
            "endeavouros": "",
            "kali": "",
            "void": "",
            "alpine": "",
            "pop": "",
            "raspbian": "",
            "centos": "",
            "slackware": "",
            "rhel": ""
        };
        
        const lowerId = id.toLowerCase();
        // Exact match
        if (map[lowerId]) return map[lowerId];
        
        // Partial match
        for (let key in map) {
            if (lowerId.indexOf(key) !== -1) return map[key];
        }
        
        return ""; // Fallback Tux
    }
}