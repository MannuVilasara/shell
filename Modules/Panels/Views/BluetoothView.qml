import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Widgets
import qs.Services

Control {
    id: root
    padding: 16

    required property var globalState
    required property var theme
    
    signal backRequested()

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
                TapHandler { onTapped: root.backRequested() }
            }
            
            Text {
                text: "Bluetooth Devices"
                font.bold: true
                font.pixelSize: 16
                color: theme.text
            }
            
            Item { Layout.fillWidth: true }
            
            Rectangle {
                width: 44
                height: 24
                radius: 12
                color: BluetoothService.enabled ? theme.accentActive : theme.surface
                border.width: BluetoothService.enabled ? 0 : 1
                border.color: theme.border
                
                Rectangle {
                    x: BluetoothService.enabled ? 22 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20
                    height: 20
                    radius: 10
                    color: BluetoothService.enabled ? "#FFFFFF" : theme.subtext
                    Behavior on x { NumberAnimation { duration: 150 } }
                }

                TapHandler {
                    onTapped: BluetoothService.toggleBluetooth()
                }
                HoverHandler { cursorShape: Qt.PointingHandCursor }
            }
        }
        
        Text {
            visible: !BluetoothService.enabled
            text: "Bluetooth is Off"
            color: theme.muted
            anchors.centerIn: parent
            Layout.minimumHeight: 100
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            visible: BluetoothService.enabled
            model: BluetoothService.devices
            
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
                        if (modelData.connected) modelData.disconnect()
                        else modelData.connect()
                    }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Text {
                        text: "󰂯"
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
