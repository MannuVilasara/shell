import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    required property var colors
    required property string fontFamily
    required property int fontSize
    required property var globalState
    required property var networkService

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
                    duration: 250
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
                id: netText

                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (networkService.active)
                        return networkService.active.ssid;

                    if (networkService.ethernetConnected)
                        return "Ethernet";

                    return networkService.wifiEnabled ? "Disconnected" : "Off";
                }
                color: root.colors.fg
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
                font.bold: true
            }

            TextMetrics {
                id: textMetrics

                font: netText.font
                text: netText.text
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
                    duration: 250
                    easing.type: Easing.OutCubic
                }

            }

        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: (networkService.ethernetConnected || networkService.wifiEnabled) ? Qt.rgba(root.colors.purple.r, root.colors.purple.g, root.colors.purple.b, 0.2) : Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.2)

            Icon {
                anchors.centerIn: parent
                icon: networkService.ethernetConnected ? Icons.networkEthernet : (networkService.wifiEnabled ? Icons.networkWifiConnected : Icons.networkWifiDisconnected)
                color: (networkService.ethernetConnected || networkService.wifiEnabled) ? root.colors.purple : root.colors.muted
                font.pixelSize: root.fontSize
            }

        }

        Item {
            Layout.preferredWidth: 4
        }

    }

    TapHandler {
        onTapped: globalState.requestSidePanelMenu("wifi")
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton // Let TapHandler handle clicks, but set cursor
    }

}
