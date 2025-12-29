import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Item {
    id: root

    // Track all nodes to ensure properties are updated
    // Track only sinks to minimize warnings on transient nodes
    PwObjectTracker {
        objects: sinks
    }

    // Filter for actual hardware sinks (not streams, check for audio capability)
    readonly property var sinks: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream && node.isSink && node.audio) {
            acc.push(node);
        }
        return acc;
    }, [])

    // Get the default sink from Pipewire service
    // Add null check and fallback logic if needed
    readonly property PwNode sink: {
        if (!Pipewire.ready) return null;
        
        let defaultSink = Pipewire.defaultAudioSink;
        
        // Basic validation: must be a real sink with audio
        if (defaultSink && !defaultSink.isStream && defaultSink.isSink && defaultSink.audio) {
            return defaultSink;
        }
        
        // Fallback: Use the first valid hardware sink found
        return sinks.length > 0 ? sinks[0] : null;
    }

    readonly property bool ready: !!sink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property string description: sink?.description ?? "Audio Output"
    
    // integer level 0-100 for Bar compatibility
    readonly property int level: Math.round(volume * 100)

    readonly property string icon: {
        if (muted) return "󰖁";
        const v = volume;
        if (v <= 0) return "󰝟";
        if (v < 0.33) return "󰕿";
        if (v < 0.66) return "󰖀";
        return "󰕾";
    }

    function setVolume(v) {
        if (sink && sink.audio) {
            if (sink.audio.muted) sink.audio.muted = false;
            sink.audio.volume = v;
        }
    }
    
    function toggleMute() {
        if (sink && sink.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }
    
    function increaseVolume(amount = 0.05) {
        setVolume(Math.min(1.0, volume + amount));
    }
    
    function decreaseVolume(amount = 0.05) {
        setVolume(Math.max(0.0, volume - amount));
    }
}
