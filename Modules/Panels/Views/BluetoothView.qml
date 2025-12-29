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
    required property var bluetoothService

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
                    text: "󰁮"
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
                text: "Bluetooth Devices"
                font.bold: true
                font.pixelSize: 16
                color: theme.text
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 44
                height: 24
                radius: 12
                color: bluetoothService.enabled ? theme.accentActive : theme.surface
                border.width: bluetoothService.enabled ? 0 : 1
                border.color: theme.border

                Rectangle {
                    x: bluetoothService.enabled ? 22 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20
                    height: 20
                    radius: 10
                    color: bluetoothService.enabled ? "#FFFFFF" : theme.subtext

                    Behavior on x {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

                TapHandler {
                    onTapped: bluetoothService.toggleBluetooth()
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

            }

        }

        Text {
            visible: !bluetoothService.enabled
            text: "Bluetooth is Off"
            color: theme.muted
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            visible: bluetoothService.enabled
            model: bluetoothService.devicesList

            delegate: Rectangle {
                width: parent.width
                height: 60
                radius: 12
                color: hoverHandler.hovered ? Qt.rgba(theme.tile.r, theme.tile.g, theme.tile.b, 0.5) : "transparent"

                HoverHandler {
                    id: hoverHandler

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        if (modelData.paired || modelData.trusted) {
                            if (modelData.connected) bluetoothService.disconnectDevice(modelData);
                            else bluetoothService.connectDevice(modelData);
                        } else {
                            bluetoothService.pairDevice(modelData);
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Text {
                        text: bluetoothService.getDeviceIcon(modelData)
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: modelData.connected ? theme.accentActive : theme.secondary
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        Text {
                            text: modelData.name || modelData.address
                            color: theme.text
                            font.pixelSize: 14
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available")
                            color: modelData.connected ? theme.accentActive : theme.muted
                            font.pixelSize: 12
                        }

                    }

                }

            }

        }

    }

}
