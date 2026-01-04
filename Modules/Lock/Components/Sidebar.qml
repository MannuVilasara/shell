import "../Components"
import QtQuick
import QtQuick.Layouts
import Quickshell

BentoCard {
    id: root

    required property var colors

    function execute(cmd) {
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    cardColor: colors.surface
    borderColor: colors.border
    radius: 30

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24

        Repeater {
            model: [{
                "icon": "󰐥",
                "cmd": "systemctl poweroff"
            }, {
                "icon": "󰜉",
                "cmd": "systemctl reboot"
            }, {
                "icon": "󰗽",
                "cmd": "loginctl terminate-user $USER"
            }]

            delegate: Text {
                text: modelData.icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 22
                color: root.colors.muted
                Layout.alignment: Qt.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.execute(modelData.cmd)
                    onEntered: parent.color = root.colors.accent
                    onExited: parent.color = root.colors.muted
                }

            }

        }

    }

}
