import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Core
import qs.Services

Rectangle {
    id: barRoot

    // Required properties from the main configuration
    required property Colors colors
    required property string fontFamily
    required property int fontSize
    required property string kernelVersion
    required property int cpuUsage
    required property int memUsage
    required property int diskUsage
    required property int volumeLevel
    required property string activeWindow
    required property string currentLayout
    required property string time
    property bool floating: true

    anchors.fill: parent
    color: colors.bg
    radius: floating ? 12 : 0
    border.color: colors.muted
    border.width: floating ? 1 : 0

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: colors.muted
        visible: !parent.floating
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        // 1. Logo
        Rectangle {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: height / 2
            color: "transparent"

            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: "../../Assets/arch.svg"
                fillMode: Image.PreserveAspectFit
                opacity: 0.9
            }

        }

        VerticalDivider {
        }

        // 3. Workspace Switcher
        Rectangle {
            id: wsContainer

            Layout.preferredWidth: 150
            Layout.preferredHeight: 26
            color: Qt.rgba(0, 0, 0, 0.2)
            radius: height / 2
            clip: true

            MouseArea {
                anchors.fill: parent
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0)
                        Hyprland.dispatch("workspace -1");
                    else
                        Hyprland.dispatch("workspace +1");
                }
            }

            ListView {
                id: wsList

                anchors.fill: parent
                orientation: ListView.Horizontal
                spacing: 4
                interactive: false
                currentIndex: (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id - 1 : 0)
                model: 999

                delegate: Item {
                    property int wsIndex: index + 1
                    property var workspace: Hyprland.workspaces.values.find((ws) => {
                        return ws.id === wsIndex;
                    }) ?? null
                    property bool isActive: wsList.currentIndex === index
                    property bool hasWindows: workspace !== null

                    height: wsList.height
                    width: indicator.width

                    Rectangle {
                        id: indicator

                        anchors.centerIn: parent
                        height: 16
                        width: parent.isActive ? 32 : 16
                        radius: height / 2
                        color: (parent.isActive || parent.hasWindows) ? colors.accent : "transparent"
                        border.color: (!parent.isActive && !parent.hasWindows) ? colors.muted : "transparent"
                        border.width: (!parent.isActive && !parent.hasWindows) ? 2 : 0

                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.2
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }

                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Hyprland.dispatch("workspace " + parent.wsIndex)
                        cursorShape: Qt.PointingHandCursor
                    }

                }

            }

        }

        VerticalDivider {
        }

        // Keyboard Layout
        Text {
            text: currentLayout
            color: colors.fg
            font.pixelSize: fontSize - 2
            font.family: fontFamily
            font.bold: true
            opacity: 0.7
        }

        VerticalDivider {
        }

        // 4. Enhanced Media Pill (Prev | Play/Pause | Next | Title)
        Rectangle {
            id: mediaPill

            Layout.preferredHeight: 26
            // Dynamically size based on content, but cap at 300px
            Layout.preferredWidth: Math.min(mediaRow.implicitWidth + 24, 300)
            radius: height / 2
            // Chip Style background
            color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.15)
            border.color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.5)
            border.width: 1

            RowLayout {
                id: mediaRow

                anchors.centerIn: parent
                spacing: 6
                width: parent.width - 12

                // --- Previous Button ---
                Text {
                    text: "󰒮" // Nerd Font Previous
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: prevMouse.containsMouse ? colors.accent : colors.fg
                    opacity: 0.8
                    Layout.leftMargin: 4

                    MouseArea {
                        id: prevMouse

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: MprisService.previous()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                // --- Play/Pause Button (Circular) ---
                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: 10
                    color: playMouse.containsMouse ? colors.accentActive : colors.accent

                    Text {
                        anchors.centerIn: parent
                        text: MprisService.isPlaying ? "󰏤" : "󰐊"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: colors.bg
                        anchors.horizontalCenterOffset: MprisService.isPlaying ? 0 : 1
                    }

                    MouseArea {
                        id: playMouse

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: MprisService.playPause()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                // --- Next Button ---
                Text {
                    text: "󰒭" // Nerd Font Next
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: nextMouse.containsMouse ? colors.accent : colors.fg
                    opacity: 0.8

                    MouseArea {
                        id: nextMouse

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: MprisService.next()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                // --- Media Title ---
                Text {
                    text: MprisService.title !== "" ? MprisService.title : "No Media"
                    font.family: fontFamily
                    font.pixelSize: fontSize - 2
                    font.bold: true
                    color: colors.fg
                    opacity: 0.9
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    Layout.leftMargin: 4

                    // Clicking title also toggles play/pause for convenience
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.playPause()
                    }

                }

            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                }

            }

        }

        Item {
            Layout.fillWidth: true
        }

        // Active Window Title
        InfoPill {
            visible: activeWindow !== ""
            Layout.maximumWidth: 400
            border.width: 0
            color: Qt.rgba(0, 0, 0, 0.2)

            Text {
                text: activeWindow
                color: colors.fg
                font.pixelSize: fontSize - 1
                font.family: fontFamily
                font.bold: true
                elide: Text.ElideMiddle
                Layout.maximumWidth: 360
            }

        }

        Item {
            Layout.fillWidth: true
        }

        // System Stats
        InfoPill {
            Row {
                spacing: 6

                Text {
                    text: "CPU"
                    color: colors.red
                    font.bold: true
                    font.pixelSize: fontSize - 2
                    anchors.baseline: tCpu.baseline
                }

                Text {
                    id: tCpu

                    text: cpuUsage + "%"
                    color: colors.fg
                    font.pixelSize: fontSize - 1
                    font.family: fontFamily
                }

            }

            VerticalDivider {
                Layout.preferredHeight: 10
            }

            Row {
                spacing: 6

                Text {
                    text: "RAM"
                    color: colors.blue
                    font.bold: true
                    font.pixelSize: fontSize - 2
                    anchors.baseline: tRam.baseline
                }

                Text {
                    id: tRam

                    text: memUsage + "%"
                    color: colors.fg
                    font.pixelSize: fontSize - 1
                    font.family: fontFamily
                }

            }

        }

        // Volume
        InfoPill {
            Row {
                spacing: 6

                Text {
                    text: "VOL"
                    color: colors.yellow
                    font.bold: true
                    font.pixelSize: fontSize - 2
                    anchors.baseline: tVol.baseline
                }

                Text {
                    id: tVol

                    text: volumeLevel + "%"
                    color: colors.fg
                    font.pixelSize: fontSize - 1
                    font.family: fontFamily
                    font.bold: true
                }

            }

        }

        // Clock
        Rectangle {
            Layout.preferredHeight: 26
            Layout.preferredWidth: clockText.implicitWidth + 24
            radius: height / 2
            color: colors.accent

            Text {
                id: clockText

                anchors.centerIn: parent
                text: time
                color: colors.bg
                font.pixelSize: fontSize - 1
                font.family: fontFamily
                font.bold: true
            }

        }

        // Power Menu
        Rectangle {
            Layout.preferredHeight: 26
            Layout.preferredWidth: 26
            radius: height / 2
            color: "transparent"
            border.color: colors.muted
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "⏻"
                font.pixelSize: 16
                font.family: "Symbols Nerd Font"
                color: colors.red
            }

            Process {
                id: powerMenuIpcProcess

                command: ["quickshell", "ipc", "-c", "mannu", "call", "powermenu", "toggle"]
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: parent.color = Qt.rgba(colors.red.r, colors.red.g, colors.red.b, 0.2)
                onExited: parent.color = "transparent"
                onClicked: powerMenuIpcProcess.running = true
            }

        }

    }

    // Custom Components
    component VerticalDivider: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 14
        Layout.alignment: Qt.AlignVCenter
        color: colors.muted
        opacity: 0.5
    }

    component InfoPill: Rectangle {
        default property alias content: innerLayout.data

        Layout.preferredHeight: 26
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: innerLayout.implicitWidth + 20
        radius: height / 2
        color: "transparent"
        border.color: colors.muted
        border.width: 1

        RowLayout {
            id: innerLayout

            anchors.centerIn: parent
            spacing: 8
        }

    }

}
