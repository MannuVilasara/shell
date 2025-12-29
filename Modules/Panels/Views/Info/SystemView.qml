import "../../../../Services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

ColumnLayout {
    id: root

    required property var theme

    spacing: 12

    // --- Services Instantiation ---
    CpuService {
        id: cpuService
    }

    MemService {
        id: memService
    }

    // Header
    Text {
        text: "System Resources"
        font.bold: true
        font.pixelSize: 14
        color: theme.fg
        Layout.leftMargin: 4
        opacity: 0.9
    }

    // --- Resources List ---
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        // 1. CPU Resource
        ResourceItem {
            label: "CPU"
            icon: "󰻠"
            iconColor: theme.urgent
            valueText: cpuService.usage > 0 ? cpuService.usage + "%" : "Loading..."
            progress: cpuService.usage > 0 ? (cpuService.usage / 100) : 0
        }

        // 2. RAM Resource
        ResourceItem {
            label: "RAM"
            icon: "󰍛"
            iconColor: theme.accent
            valueText: {
                // Check if we have valid data
                if (!memService.total || memService.total <= 0) {
                    // Check if at least percentage is available
                    if (memService.usage && memService.usage > 0)
                        return memService.usage + "%";

                    return "Loading...";
                }
                // Calculate GB values
                var usedGb = memService.used / 1.07374e+09;
                var totalGb = memService.total / 1.07374e+09;
                // Safety check for NaN
                if (isNaN(usedGb) || isNaN(totalGb) || totalGb <= 0)
                    return "N/A";

                // Format with one decimal place
                return usedGb.toFixed(1) + " / " + totalGb.toFixed(1) + " GB";
            }
            progress: {
                // If total is not available, use percentage
                if (!memService.total || memService.total <= 0) {
                    if (memService.usage && memService.usage > 0)
                        return memService.usage / 100;

                    return 0;
                }
                // Calculate progress from used/total
                var p = memService.used / memService.total;
                // Safety bounds
                if (isNaN(p) || p < 0)
                    return 0;

                if (p > 1)
                    return 1;

                return p;
            }
        }

        // 3. SSD Resource (Mock data for now - you can replace with actual disk service)
        ResourceItem {
            label: "SSD"
            icon: "󰋊"
            iconColor: theme.green
            valueText: "24%"
            progress: 0.24
        }

    }

    // Debug info (optional - remove in production)
    Text {
        text: "Debug: RAM Total=" + memService.total + " Used=" + memService.used + " Usage=" + memService.usage + "%"
        font.pixelSize: 9
        color: theme.fg
        opacity: 0.5
        Layout.leftMargin: 4
        visible: false // Set to true for debugging
    }

    // --- Reusable Component ---
    component ResourceItem: Rectangle {
        property string label
        property string icon
        property color iconColor
        property string valueText
        property real progress: 0

        Layout.fillWidth: true
        Layout.preferredHeight: 64
        radius: 12
        color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.4)
        border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 14

            // Icon
            Text {
                text: icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 22
                color: iconColor
            }

            // Info & Bar
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Layout.alignment: Qt.AlignVCenter

                // Header Row
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: label
                        font.pixelSize: 12
                        font.bold: true
                        color: theme.fg
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: valueText
                        font.pixelSize: 12
                        color: theme.fg
                        font.family: "JetBrains Mono" // Monospace for numbers
                    }

                }

                // Progress Bar Background
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)

                    // Active Progress
                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        color: iconColor
                        width: parent.width * Math.max(0, Math.min(1, progress))

                        // Smooth animation when values change
                        Behavior on width {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                }

            }

        }

    }

}
