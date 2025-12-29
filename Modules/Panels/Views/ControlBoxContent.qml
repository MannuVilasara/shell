import "." as Views
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Modules.Notifications
import qs.Services
import qs.Widgets

ColumnLayout {
    id: root

    required property var globalState
    required property var theme
    required property var notifManager
    required property var volumeService
    required property var bluetoothService

    signal requestWifiMenu()
    signal requestBluetoothMenu()
    signal requestPowerMenu()

    width: 320 // Fixed width for the panel
    spacing: 12

    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: 4
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: 14

            Text {
                anchors.centerIn: parent
                text: "󰣇"
                font.pixelSize: 24
                font.family: "Symbols Nerd Font"
                color: theme.bg
            }

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: theme.tileActive
                }

                GradientStop {
                    position: 1
                    color: theme.accentActive
                }

            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: "Hey, " + Quickshell.env("USER")
                color: theme.text
                font.bold: true
                font.pixelSize: 15
                font.capitalization: Font.Capitalize
            }

            Text {
                text: Qt.formatDate(new Date(), "ddd, MMM d")
                color: theme.secondary
                font.pixelSize: 12
            }

        }

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 12
            color: powerBtn.pressed ? Qt.rgba(theme.urgent.r, theme.urgent.g, theme.urgent.b, 0.2) : "transparent"
            border.width: 1
            border.color: powerBtn.pressed ? theme.urgent : theme.border

            Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.pixelSize: 16
                font.family: "Symbols Nerd Font"
                color: theme.urgent
            }

            TapHandler {
                id: powerBtn

                onTapped: root.requestPowerMenu()
            }

        }

    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 10
        columnSpacing: 10

        Views.ToggleButton {
            Layout.fillWidth: true
            implicitHeight: 64
            label: "WiFi"
            sublabel: NetworkService.wifiEnabled ? (NetworkService.active ? NetworkService.active.ssid : "On") : "Off"
            icon: "󰖩"
            active: NetworkService.wifiEnabled
            showChevron: true
            theme: root.theme

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton)
                        root.requestWifiMenu();
                    else
                        NetworkService.toggleWifi();
                }
            }

        }

        Views.ToggleButton {
            Layout.fillWidth: true
            implicitHeight: 64
            label: "Bluetooth"
            sublabel: bluetoothService.enabled ? (bluetoothService.connectedDevices && bluetoothService.connectedDevices.length > 0 ? bluetoothService.connectedDevices[0].name : "On") : "Off"
            icon: "󰂯"
            active: bluetoothService.enabled
            showChevron: true
            theme: root.theme

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton)
                        root.requestBluetoothMenu();
                    else
                        bluetoothService.toggleBluetooth();
                }
            }

        }

        Views.ToggleButton {
            Layout.fillWidth: true
            implicitHeight: 56
            label: "Airplane"
            sublabel: "Off"
            icon: "󰀝"
            active: false
            showChevron: false
            theme: root.theme
        }

        Views.ToggleButton {
            Layout.fillWidth: true
            implicitHeight: 56
            label: "DND"
            sublabel: "Off"
            icon: "󰂛"
            active: false
            showChevron: false
            theme: root.theme
        }

    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12
        Layout.topMargin: 4

        Views.SliderControl {
            label: "Volume"
            icon: "󰕾"
            value: volumeService.volume
            theme: root.theme
            onChangeRequested: (v) => {
                return volumeService.setVolume(v);
            }
        }

        Views.SliderControl {
            label: "Brightness"
            icon: "󰃠"
            value: BrightnessService.brightness
            theme: root.theme
            onChangeRequested: (v) => {
                return BrightnessService.setBrightness(v);
            }
        }

    }

}
