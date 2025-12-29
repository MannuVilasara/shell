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
        if (visible)
            eventHandler.forceActiveFocus();

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
        Keys.onPressed: (event) => {
            const key = event.text.toUpperCase();
            for (let i = 0; i < buttonsModel.count; i++) {
                if (buttonsModel.get(i).shortcut === key) {
                    runCommand(buttonsModel.get(i).command);
                    event.accepted = true;
                    return ;
                }
            }
        }
    }

    ListModel {
        id: buttonsModel

        ListElement {
            name: "Lock"
            icon: "󰌾"
            command: "quickshell ipc -c mannu call lock lock"
            shortcut: "L"
        }

        ListElement {
            name: "Suspend"
            icon: "󰒲"
            command: "systemctl suspend"
            shortcut: "S"
        }

        ListElement {
            name: "Reload"
            icon: "󰑓"
            command: "pkill qs && qs -c mannu &"
            shortcut: "D"
        }

        ListElement {
            name: "Reboot"
            icon: "󰑓"
            command: "systemctl reboot"
            shortcut: "R"
        }

        ListElement {
            name: "Power Off"
            icon: "󰐥"
            command: "systemctl poweroff"
            shortcut: "P"
        }

        ListElement {
            name: "Log Out"
            icon: "󰍃"
            command: "loginctl terminate-user $USER"
            shortcut: "X"
        }

    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.isOpen ? 0.4 : 0

        MouseArea {
            anchors.fill: parent
            onClicked: globalState.powerMenuOpen = false
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }

        }

    }

    Rectangle {
        id: panel

        anchors.centerIn: parent
        width: 380
        height: 400
        radius: 24
        color: root.colors.bg
        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.85

        Repeater {
            model: buttonsModel.count

            Rectangle {
                x: 20
                y: 30 + index * 58
                width: 340
                height: 50
                radius: 12
                color: root.currentIndex === index ? root.colors.accent : "transparent"

                Text {
                    x: 16
                    y: (parent.height - height) / 2
                    text: buttonsModel.get(index).icon
                    font.pixelSize: 20
                    font.family: "Symbols Nerd Font"
                    color: root.currentIndex === index ? root.colors.bg : root.colors.text
                    opacity: root.currentIndex === index ? 1 : 0.7

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

                Text {
                    x: 60
                    y: (parent.height - height) / 2
                    text: buttonsModel.get(index).name
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: root.currentIndex === index ? root.colors.bg : root.colors.text

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                Text {
                    x: parent.width - 40
                    y: (parent.height - height) / 2
                    text: buttonsModel.get(index).shortcut
                    font.pixelSize: 13
                    color: root.currentIndex === index ? root.colors.bg : root.colors.text
                    opacity: root.currentIndex === index ? 0.8 : 0.5

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.currentIndex = index
                    onClicked: root.runCommand(buttonsModel.get(index).command)
                    cursorShape: Qt.PointingHandCursor
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
            }

        }

    }

}
