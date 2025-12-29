import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services
import qs.Widgets

Control {
    id: root

    required property var globalState
    required property var theme

    signal backRequested()

    padding: 16

    contentItem: ColumnLayout {
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 16
            spacing: 12

            Rectangle {
                width: 32
                height: 32
                radius: 10
                color: backBtn.hovered ? theme.tile : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰁮" // Back arrow
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: theme.text
                }

                HoverHandler {
                    id: backBtn

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.backRequested()
                }

            }

            Text {
                text: "Wi-Fi"
                font.bold: true
                font.pixelSize: 18
                color: theme.text
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 40
                height: 20
                radius: 10
                color: NetworkService.wifiEnabled ? theme.accentActive : theme.surface
                border.width: NetworkService.wifiEnabled ? 0 : 1
                border.color: theme.border

                Rectangle {
                    x: NetworkService.wifiEnabled ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    radius: 8
                    color: NetworkService.wifiEnabled ? theme.bg : theme.subtext

                    Behavior on x {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

                TapHandler {
                    onTapped: NetworkService.toggleWifi()
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 64
            radius: 14
            color: theme.surface
            border.width: 1
            border.color: NetworkService.active ? theme.accent : theme.border
            visible: NetworkService.wifiEnabled

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 14

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.2)

                    Text {
                        anchors.centerIn: parent
                        text: "󰖩"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: theme.accentActive
                    }

                }

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: NetworkService.active ? NetworkService.active.ssid : "Not Connected"
                        color: theme.text
                        font.bold: true
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        Layout.maximumWidth: 180
                    }

                    Text {
                        text: NetworkService.active ? "Connected" : "Disconnected"
                        color: NetworkService.active ? theme.accentActive : theme.muted
                        font.pixelSize: 12
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "" // Checkmark
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: theme.accentActive
                    visible: NetworkService.active
                }

            }

        }

        Text {
            Layout.topMargin: 20
            Layout.bottomMargin: 8
            text: NetworkService.scanning ? "Scanning..." : "Available Networks"
            color: theme.muted
            font.pixelSize: 12
            font.bold: true
            Layout.leftMargin: 4
            visible: NetworkService.wifiEnabled
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 200
            clip: true
            spacing: 4
            visible: NetworkService.wifiEnabled
            model: NetworkService.networks

            delegate: Rectangle {
                width: parent.width
                visible: !modelData.active
                height: visible ? 52 : 0
                radius: 10
                color: hoverHandler.hovered ? theme.tile : "transparent"

                HoverHandler {
                    id: hoverHandler

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        NetworkService.connectToNetwork(modelData.ssid, "");
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 14
                    visible: parent.visible

                    Text {
                        text: "󰖩"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        color: theme.subtext
                    }

                    Text {
                        text: modelData.ssid
                        color: theme.text
                        font.pixelSize: 14
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: modelData.isSecure ? "󰌾" : ""
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: theme.muted
                    }

                }

            }

        }

        Text {
            visible: !NetworkService.wifiEnabled
            text: "Wi-Fi is Off"
            color: theme.muted
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

    }

}
