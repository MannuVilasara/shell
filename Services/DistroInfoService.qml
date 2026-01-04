import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string name: "Linux"
    property string url: "https://kernel.org"
    property string icon: "" // Default Tux
    property string distroId: ""

    // Run cat /etc/os-release to get system info
    property var _proc: Process {
        command: ["cat", "/etc/os-release"]
        running: true
        
        property string buffer: ""

        onStdout: (data) => {
            buffer += data
        }

        onExited: (code) => {
            if (code === 0) {
                root._parse(buffer)
            }
        }
    }

    function _parse(data) {
        const lines = data.split("\n");
        let info = {};
        
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line || line.startsWith("#")) continue;
            
            const eqIdx = line.indexOf("=");
            if (eqIdx === -1) continue;
            
            const key = line.substring(0, eqIdx);
            let val = line.substring(eqIdx + 1);
            
            // Remove quotes if present
            if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
                val = val.substring(1, val.length - 1);
            }
            
            info[key] = val;
        }

        // 1. Set Name
        if (info["PRETTY_NAME"]) root.name = info["PRETTY_NAME"];
        else if (info["NAME"]) root.name = info["NAME"];

        // 2. Set URL
        if (info["HOME_URL"]) root.url = info["HOME_URL"];
        else if (info["SUPPORT_URL"]) root.url = info["SUPPORT_URL"];

        // 3. Set Icon (Map ID to Nerd Font)
        if (info["ID"]) {
            root.distroId = info["ID"];
            root.icon = _getIcon(info["ID"]);
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
        // Check for exact match first
        if (map[lowerId]) return map[lowerId];
        
        // Check for partial matches (e.g. opensuse-tumbleweed -> opensuse)
        for (let key in map) {
            if (lowerId.includes(key)) return map[key];
        }
        
        return ""; // Tux fallback
    }
}