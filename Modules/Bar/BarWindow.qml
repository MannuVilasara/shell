import QtQuick
import Quickshell
import qs.Modules.Bar
import qs.Services

Variants {
    id: root

    required property Context context

    model: Quickshell.screens

    PanelWindow {
        property var modelData

        screen: modelData
        implicitHeight: 48
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 0
            bottom: 0
            left: 0
            right: 0
        }

        Bar {
            colors: root.context.colors
            fontFamily: root.context.config.fontFamily
            fontSize: root.context.config.fontSize
            kernelVersion: root.context.os.version
            cpuUsage: root.context.cpu.usage
            memUsage: root.context.mem.usage
            diskUsage: root.context.disk.usage
            volumeLevel: root.context.volume.level
            activeWindow: root.context.activeWindow.title
            currentLayout: root.context.layout.layout
            time: root.context.time.currentTime
        }

    }

}
