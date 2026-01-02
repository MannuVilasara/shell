import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: root

    property bool isOpen: false
    required property var globalState
    required property Colors colors
    property int currentIndex: 0
    readonly property int boxWidth: 300
    readonly property int itemHeight: 48
    readonly property int itemSpacing: 4
    readonly property int headerHeight: 40

    function runCommand(cmd) {
        if (cmd.includes("$USER"))
            cmd = cmd.replace("$USER", Quickshell.env("USER"));

        console.log("PowerMenu: Executing command:", cmd);
        Quickshell.execDetached(["sh", "-c", cmd]);
        globalState.powerMenuOpen = false;
    }

    color: "transparent"
    visible: isOpen
    implicitWidth: Screen.width
    implicitHeight: Screen.height
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "matte-power-menu"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    mask: isOpen ? fullMask : emptyMask
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

    Region {
        id: fullMask

        regions: [
            Region {
                x: 0
                y: 0
                width: root.width
                height: root.height
            }
        ]
    }

    Region {
        id: emptyMask

        regions: []
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

    // Transparent click-to-dismiss area (no dark overlay)
    MouseArea {
        anchors.fill: parent
        onClicked: globalState.powerMenuOpen = false
    }

    // Centered floating panel
    Rectangle {
        id: panel

        property int contentHeight: headerHeight + buttonsModel.count * (itemHeight + itemSpacing) + 24

        width: root.boxWidth
        height: contentHeight
        anchors.centerIn: parent
        radius: 16
        color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.95)
        clip: true
        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.9
        layer.enabled: root.isOpen

        // Panel header
        Text {
            id: headerText
            x: 16
            y: 12
            text: "Power Menu"
            font.pixelSize: 14
            font.weight: Font.Bold
            color: root.colors.text
            opacity: 0.6
        }

        // Smooth-moving highlight
        Rectangle {
            id: highlight

            function getYForIndex(idx) {
                return headerHeight + idx * (root.itemHeight + root.itemSpacing);
            }

            x: 12
            y: getYForIndex(root.currentIndex)
            width: panel.width - 24
            height: root.itemHeight
            radius: 10
            color: root.colors.accent

            Behavior on y {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutBack
                    easing.overshoot: 0.8
                }
            }
        }

        // Button items
        Column {
            id: buttonColumn
            x: 12
            y: headerHeight
            width: panel.width - 24
            spacing: root.itemSpacing

            Repeater {
                model: buttonsModel

                Item {
                    width: buttonColumn.width
                    height: root.itemHeight

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 14

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.icon
                            font.pixelSize: 18
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
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.name
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: root.currentIndex === index ? root.colors.bg : root.colors.text

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        Item {
                            width: parent.width - 130
                            height: 1
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.shortcut
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: root.currentIndex === index ? root.colors.bg : root.colors.text
                            opacity: root.currentIndex === index ? 0.8 : 0.4

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
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.currentIndex = index
                        onClicked: root.runCommand(model.command)
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 24
            samples: 25
            color: "#60000000"
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }
    }

}
