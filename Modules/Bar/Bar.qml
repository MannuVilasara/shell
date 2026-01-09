import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import qs.Core
import qs.Modules.Bar.Widgets
import qs.Services
import qs.Widgets

Rectangle {
    id: barRoot

    required property Colors colors
    required property string fontFamily
    required property int fontSize
    required property string kernelVersion
    required property int volumeLevel
    required property string time
    property bool floating: true
    property bool trayOpen: false
    property var volumeService
    property var networkService
    property var globalState
    required property var compositor
    property var battery: UPower.displayDevice
    property real batteryPercent: battery && battery.percentage !== undefined ? battery.percentage * 100 : 0
    property bool batteryCharging: battery && battery.state === UPowerDeviceState.Charging
    property bool batteryFull: battery && battery.state === UPowerDeviceState.FullyCharged
    property bool batteryReady: battery && battery.ready && battery.percentage !== undefined && battery.isPresent

    anchors.fill: parent
    color: colors.bg
    radius: floating ? 12 : 0
    border.width: 0

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        ArchLogo {
        }

        VerticalDivider {
            colors: barRoot.colors
        }

        Workspaces {
            colors: barRoot.colors
            fontFamily: barRoot.fontFamily
            fontSize: barRoot.fontSize
            compositor: barRoot.compositor
        }

        VerticalDivider {
            colors: barRoot.colors
        }

        Media {
            colors: barRoot.colors
            fontFamily: barRoot.fontFamily
            fontSize: barRoot.fontSize
            globalState: barRoot.globalState
        }

        Item {
            Layout.fillWidth: true
        }

        Item {
            Layout.fillWidth: true
        }

        SystemTray {
            colors: barRoot.colors
            trayOpen: barRoot.trayOpen
        }

        VerticalDivider {
            colors: barRoot.colors
            visible: SystemTray.items.values.length > 0
        }

        Rectangle {
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: statusLayout.implicitWidth + 16
            radius: height / 2
            color: Qt.rgba(barRoot.colors.fg.r, barRoot.colors.fg.g, barRoot.colors.fg.b, 0.1)

            RowLayout {
                id: statusLayout

                anchors.centerIn: parent
                spacing: 0

                NetworkPill {
                    colors: barRoot.colors
                    fontFamily: barRoot.fontFamily
                    fontSize: barRoot.fontSize
                    globalState: barRoot.globalState
                    networkService: barRoot.networkService
                }

                VolumePill {
                    colors: barRoot.colors
                    fontFamily: barRoot.fontFamily
                    fontSize: barRoot.fontSize
                    volumeLevel: barRoot.volumeLevel
                    volumeService: barRoot.volumeService
                }

                BatteryPill {
                    colors: barRoot.colors
                    fontFamily: barRoot.fontFamily
                    fontSize: barRoot.fontSize
                }

                PowerButton {
                    colors: barRoot.colors
                    fontFamily: barRoot.fontFamily
                    fontSize: barRoot.fontSize
                }

            }

        }

    }

    Clock {
        colors: barRoot.colors
        fontFamily: barRoot.fontFamily
        fontSize: barRoot.fontSize
        time: barRoot.time
        globalState: barRoot.globalState
    }

}
