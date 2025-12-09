import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../core"

Rectangle {
    id: barRoot
    anchors.fill: parent
    color: colors.bg
    radius: 12
    border.color: colors.muted
    border.width: 1

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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        // Logo
        Rectangle {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: height / 2
            color: "transparent"
            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: "file:///etc/xdg/quickshell/mannu/assets/arch.svg"
                fillMode: Image.PreserveAspectFit
                opacity: 0.9
            }
        }

        VerticalDivider {}

        // --- WORKSPACE CAROUSEL ---
        Rectangle {
            id: wsContainer
            Layout.preferredWidth: 150
            Layout.preferredHeight: 26

            color: Qt.rgba(0, 0, 0, 0.2)
            radius: height / 2
            clip: true

            // 1. GLOBAL SCROLL HANDLER (The Fix)
            // This sits underneath the items but captures the wheel events for the whole container
            MouseArea {
                anchors.fill: parent
                // Allow clicks to pass through to the buttons below
                propagateComposedEvents: true
                // Don't "eat" the click events, just the wheel events
                onClicked: mouse.accepted = false
                onPressed: mouse.accepted = false
                onReleased: mouse.accepted = false

                onWheel: wheel => {
                    // Standard scrolling logic
                    if (wheel.angleDelta.y > 0) {
                        Hyprland.dispatch("workspace -1");
                    } else {
                        Hyprland.dispatch("workspace +1");
                    }
                }
            }

            ListView {
                id: wsList
                anchors.fill: parent
                orientation: ListView.Horizontal
                spacing: 4

                // 2. Disable internal scrolling so it doesn't fight Hyprland
                interactive: false

                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: 12
                preferredHighlightEnd: 138
                highlightMoveDuration: 300
                highlightMoveVelocity: -1

                currentIndex: (Hyprland.focusedWorkspace.id - 1)
                model: 20

                delegate: Rectangle {
                    property int wsIndex: index + 1
                    property var workspace: Hyprland.workspaces.values.find(ws => ws.id === wsIndex) ?? null
                    property bool isActive: wsList.currentIndex === index
                    property bool hasWindows: workspace !== null

                    height: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: isActive ? 32 : 16
                    radius: height / 2

                    color: (isActive || hasWindows) ? colors.purple : "transparent"
                    border.color: (!isActive && !hasWindows) ? colors.muted : "transparent"
                    border.width: (!isActive && !hasWindows) ? 2 : 0

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

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        // Only handle clicks here. Scroll is handled by the parent.
                        onClicked: Hyprland.dispatch("workspace " + parent.wsIndex)
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        VerticalDivider {}

        Text {
            text: currentLayout
            color: colors.fg
            font.pixelSize: fontSize - 2
            font.family: fontFamily
            font.bold: true
            opacity: 0.7
        }

        Item {
            Layout.fillWidth: true
        }

        // Active Window
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

        // Stats
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
            color: colors.purple
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
    }
}
