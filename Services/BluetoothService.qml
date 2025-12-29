pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    
    readonly property bool available: (adapter !== null)
    // readonly property bool enabled: adapter?.enabled ?? false // QML doesn't support '??' well in some versions, simpler:
    readonly property bool enabled: (adapter && adapter.enabled !== undefined) ? adapter.enabled : false
    
    readonly property bool discovering: (adapter && adapter.discovering) ? adapter.discovering : false
    readonly property bool blocked: (adapter && adapter.state === BluetoothAdapterState.Blocked)
    
    readonly property var devices: adapter ? adapter.devices : null
    
    readonly property var devicesList: {
        if (!adapter) return [];

        var list = (adapter.devices && adapter.devices.values) ? adapter.devices.values : [];
        var globalList = (Bluetooth.devices && Bluetooth.devices.values) ? Bluetooth.devices.values : [];
        
        // Prefer global list if adapter list is empty
        return (list.length > 0) ? list : globalList;
    }
    
    readonly property var connectedDevices: {
        if (!adapter || !adapter.devices) return [];
        return adapter.devices.values.filter(dev => dev && dev.connected);
    }

    // --- Bluetooth Agent ---
    // Needed for pairing authentication
    property var btAgent: null
    property bool btAgentRegistered: false
    property bool fallbackAgentAttempted: false

    function startFallbackAgent() {
        if (fallbackAgentAttempted) return;
        fallbackAgentAttempted = true;
        console.log("[Bluetooth] Starting fallback bluetoothctl agent");
        fallbackBluetoothctlAgent.running = true;
    }

    Timer {
        id: fallbackForceTimer
        interval: 500
        running: true
        repeat: false
        onTriggered: startFallbackAgent()
    }

    Component.onCompleted: {
        try {
             // Dynamic creation of BluetoothAgent to handle missing type definitions gracefully
            const qml = `
import QtQuick
import Quickshell
import Quickshell.Bluetooth

BluetoothAgent {
  id: dynAgent
  capability: BluetoothAgentCapability.KeyboardDisplay

  onRequestConfirmation: function(device, passkey, accept, reject) {
    console.log("[Bluetooth] Agent RequestConfirmation: " + passkey);
    accept();
  }

  onRequestPasskey: function(device, accept, reject) {
    console.log("[Bluetooth] Agent RequestPasskey");
    reject(); // Not implemented UI for passkey yet
  }

  onRequestPinCode: function(device, accept, reject) {
    console.log("[Bluetooth] Agent RequestPinCode");
    reject();
  }

  onDisplayPasskey: function(device, passkey) {
    console.log("[Bluetooth] Agent DisplayPasskey: " + passkey);
  }

  onAuthorizeService: function(device, uuid, accept, reject) {
    console.log("[Bluetooth] Agent AuthorizeService: " + uuid);
    accept();
  }

  onCancel: function() {
    console.log("[Bluetooth] Agent request canceled");
  }
}
`;
            btAgent = Qt.createQmlObject(qml, root, "DynamicBluetoothAgent");
            
            try {
                Bluetooth.agent = btAgent;
                if (btAgent.register) btAgent.register();
                console.log("[Bluetooth] BluetoothAgent registered");
                btAgentRegistered = true;
            } catch (regErr) {
                console.warn("[Bluetooth] Failed to register agent", regErr);
                btAgentRegistered = false;
                startFallbackAgent();
            }

        } catch (e) {
            console.log("[Bluetooth] BluetoothAgent unavailable, using fallback");
            startFallbackAgent();
        }
    }

    // Fallback agent using bluetoothctl
    Process {
        id: fallbackBluetoothctlAgent
        command: ["sh", "-c", "(pkill -f '^bt-agent( |$)' 2>/dev/null || true; pkill -f '^bluetoothctl( |$)' 2>/dev/null || true; " + "if command -v bt-agent >/dev/null 2>&1; then exec bt-agent -c DisplayYesNo; " + "else (printf 'agent off\nagent on\nagent KeyboardDisplay\ndefault-agent\n'; while sleep 3600; do :; done) | bluetoothctl; fi)"]
        running: false
         stdout: StdioCollector {} // Drain output
    }

    function toggleBluetooth() {
        if (adapter) adapter.enabled = !adapter.enabled;
    }

    function setBluetoothEnabled(state) {
        if (adapter) adapter.enabled = state;
    }

    function startDiscovery() {
        if (adapter && adapter.state === BluetoothAdapterState.Enabled) {
            adapter.discovering = true;
        }
    }

    function stopDiscovery() {
        if (adapter) adapter.discovering = false;
    }

    function connectDevice(device) {
        if (!device) return;
        console.log("[Bluetooth] Connecting to " + (device.name || device.address));
        try {
            device.connect();
        } catch (e) {
            console.warn("[Bluetooth] Connect failed, trying trust first:", e);
             try {
                device.trusted = true;
                device.connect();
            } catch(e2) {
                console.warn("[Bluetooth] Connect fallback failed:", e2);
            }
        }
    }

    function disconnectDevice(device) {
        if (device) {
            try {
                device.disconnect();
            } catch(e) {
                console.warn("[Bluetooth] Disconnect failed:", e);
            }
        }
    }

    function pairDevice(device) {
        if (!device) return;
        console.log("[Bluetooth] Pairing " + (device.name || device.address));
        
        // Use bluetoothctl if our internal agent isn't ready, as it handles its own agent
        if (!btAgentRegistered) {
            pairWithBluetoothctl(device);
            return;
        }

        try {
             if (typeof device.pair === 'function') {
                device.pair();
             } else {
                // Fallback
                device.trusted = true;
                device.connect();
             }
        } catch (e) {
            console.warn("[Bluetooth] Pair failed:", e);
            pairWithBluetoothctl(device);
        }
    }
    
    function unpairDevice(device) {
        if(device) {
            try {
                device.trusted = false;
                device.forget(); // or unpair if available, usually forget()
            } catch (e) {
                console.warn("[Bluetooth] Unpair failed:", e);
            }
        }
    }

    function pairWithBluetoothctl(device) {
        if (!device) return;
        var addr = device.address || "";
        if (!addr && device.nativePath && device.nativePath.indexOf("dev_") !== -1) {
             addr = device.nativePath.split("dev_")[1].replaceAll("_", ":");
        }
        
        if (!addr || addr.length < 7) {
            console.warn("[Bluetooth] Invalid address for pairing");
            return;
        }

        console.log("[Bluetooth] Pairing via CLI: " + addr);
        const script = `(
          printf 'agent DisplayYesNo\n';
          printf 'default-agent\n';
          printf 'pair ${addr}\n';
          sleep 2;
          printf 'yes\n';
          printf 'trust ${addr}\n';
          sleep 1;
          printf 'connect ${addr}\n';
          printf 'quit\n';
        ) | bluetoothctl`;
        
        try {
            Quickshell.execDetached(["sh", "-c", script]);
        } catch (e) {
             console.warn("[Bluetooth] CLI Pair failed:", e);
        }
    }

    function getDeviceIcon(device) {
        if (!device) return "bt-device-generic";
        
        var name = (device.name || device.deviceName || "").toLowerCase();
        var icon = (device.icon || "").toLowerCase();
        
        if (icon.indexOf("controller") !== -1 || name.indexOf("controller") !== -1) return "bt-device-gamepad";
        if (icon.indexOf("headset") !== -1 || name.indexOf("headset") !== -1 || name.indexOf("buds") !== -1) return "bt-device-headset";
        if (icon.indexOf("headphone") !== -1 || name.indexOf("headphone") !== -1) return "bt-device-headphones";
        if (icon.indexOf("audio") !== -1 || name.indexOf("speaker") !== -1) return "bt-device-speaker";
        if (icon.indexOf("mouse") !== -1 || name.indexOf("mouse") !== -1) return "bt-device-mouse";
        if (icon.indexOf("keyboard") !== -1 || name.indexOf("keyboard") !== -1) return "bt-device-keyboard";
        if (icon.indexOf("phone") !== -1 || name.indexOf("phone") !== -1) return "bt-device-phone";
        
        return "bt-device-generic";
    }

    Timer {
        id: discoveryTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (adapter && adapter.state === BluetoothAdapterState.Enabled) {
                console.log("[BluetoothService] Starting native discovery via Timer");
                adapter.discovering = true;
            }
        }
    }

    Connections {
        target: adapter
        function onStateChanged() {
            if (!adapter) return;
            
            if (adapter.state === BluetoothAdapterState.Enabled) {
                discoveryTimer.start();
            }
        }
        function onEnabledChanged() {
             if (adapter && adapter.enabled) discoveryTimer.start();
        }
    }
}
