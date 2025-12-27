import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: root

    property bool isOpen: false
    required property var globalState
    required property Colors colors
    property int currentIndex: 0

    function runCommand(cmd) {
        if (cmd.includes("$USER"))
            cmd = cmd.replace("$USER", Quickshell.env("USER"));

        console.log("PowerMenu: Executing command:", cmd);
        Quickshell.execDetached(["sh", "-c", cmd]);
        globalState.powerMenuOpen = false;
    }

    color: "transparent"
    visible: isOpen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "matte-power-menu"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    onVisibleChanged: {
        if (visible) {
            eventHandler.forceActiveFocus();
            currentIndex = 0;
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    FocusScope {
        id: eventHandler

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: globalState.powerMenuOpen = false
        Keys.onUpPressed: {
            currentIndex = (currentIndex - 1 + buttonsModel.count) % buttonsModel.count;
        }
        Keys.onDownPressed: {
            currentIndex = (currentIndex + 1) % buttonsModel.count;
        }
        Keys.onReturnPressed: {
            runCommand(buttonsModel.get(currentIndex).command);
        }
    }

    ListModel {
        id: buttonsModel

        ListElement {
            name: "Lock"
            icon: "󰌾"
            command: "quickshell ipc -c mannu call lock lock"
        }

        ListElement {
            name: "Suspend"
            icon: "󰒲"
            command: "systemctl suspend"
        }

        ListElement {
            name: "Reload"
            icon: "󰜉"
            command: "systemctl restart display-manager"
        }

        ListElement {
            name: "Reboot"
            icon: "󰜉"
            command: "systemctl reboot"
        }

        ListElement {
            name: "Power Off"
            icon: "󰐥"
            command: "systemctl poweroff"
        }

        ListElement {
            name: "Log Out"
            icon: "󰍃"
            command: "loginctl terminate-user $USER"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: isOpen ? 0.35 : 0

        MouseArea {
            anchors.fill: parent
            onClicked: globalState.powerMenuOpen = false
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        id: menuPanel
        anchors.centerIn: parent
        width: 320
        height: Math.min(buttonsModel.count * 62 + 24, 420)
        radius: 18
        antialiasing: true
        color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.95)
        opacity: isOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutQuad
            }
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 8
            radius: 24
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.5)
        }

        Column {
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 6

            ListView {
                id: menuList
                width: parent.width
                height: parent.height
                model: buttonsModel
                currentIndex: root.currentIndex
                interactive: false

                delegate: Item {
                    width: menuList.width
                    height: 56

                    required property string name
                    required property string icon
                    required property string command
                    required property int index

                    property bool isSelected: root.currentIndex === index
                    property bool isHovered: mouseArea.containsMouse

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        antialiasing: true
                        color: {
                            if (isSelected) {
                                return root.colors.accent
                            } else if (isHovered) {
                                return Qt.rgba(root.colors.surface.r, root.colors.surface.g, root.colors.surface.b, 0.6)
                            }
                            return "transparent"
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 180
                                easing.type: Easing.OutQuad
                            }
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 16
                                rightMargin: 16
                            }
                            spacing: 14

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: icon
                                font.pixelSize: 24
                                font.family: "Symbols Nerd Font Mono"
                                color: isSelected ? root.colors.bg : root.colors.text
                                antialiasing: true
                                smooth: true
                                renderType: Text.QtRendering

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 180
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: name
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                font.family: "monospace"
                                color: isSelected ? root.colors.bg : root.colors.text
                                antialiasing: true

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 180
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }

                            Item { width: 1; height: 1 }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: ["L", "S", "D", "R", "P", "X"][index]
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: isSelected ? root.colors.bg : Qt.rgba(root.colors.text.r, root.colors.text.g, root.colors.text.b, 0.5)
                                antialiasing: true

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 180
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.currentIndex = index
                            onClicked: root.runCommand(command)
                        }
                    }

                    transform: Scale {
                        origin.x: width / 2
                        origin.y: height / 2
                        xScale: isSelected ? 1.02 : 1.0
                        yScale: isSelected ? 1.02 : 1.0

                        Behavior on xScale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutExpo
                            }
                        }

                        Behavior on yScale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutExpo
                            }
                        }
                    }
                }
            }
        }
    }
}
