import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Core
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    required property var colors
    required property string fontFamily
    required property int fontSize
    property var battery: UPower.displayDevice
    property real batteryPercent: battery && battery.percentage !== undefined ? battery.percentage * 100 : 0
    property bool batteryCharging: battery && battery.state === UPowerDeviceState.Charging
    property bool batteryFull: battery && battery.state === UPowerDeviceState.FullyCharged
    property bool batteryReady: battery && battery.ready && battery.percentage !== undefined && battery.isPresent

    visible: batteryReady
    Layout.preferredHeight: 30
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: innerLayout.implicitWidth + 8
    radius: height / 2
    color: "transparent"

    HoverHandler {
        id: hoverHandler
    }

    RowLayout {
        id: innerLayout

        anchors.centerIn: parent
        spacing: 0
        width: parent.width

        Item {
            Layout.preferredWidth: hoverHandler.hovered ? 8 : 4

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        Item {
            id: textContainer

            Layout.preferredWidth: hoverHandler.hovered ? textMetrics.width : 0
            Layout.preferredHeight: root.height
            clip: true

            Text {
                id: batteryText

                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(root.batteryPercent) + "%"
                color: root.colors.fg
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
                font.bold: true
            }

            TextMetrics {
                id: textMetrics

                font: batteryText.font
                text: batteryText.text
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        Item {
            Layout.preferredWidth: hoverHandler.hovered ? 8 : 0

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: BatteryService.getStateColor(root.batteryPercent, root.batteryCharging, root.batteryFull)

            Icon {
                anchors.centerIn: parent
                icon: BatteryService.getIcon(root.batteryPercent, root.batteryCharging, root.batteryReady)
                color: root.colors.bg
                font.pixelSize: root.fontSize
            }

        }

        Item {
            Layout.preferredWidth: 4
        }

    }

}
