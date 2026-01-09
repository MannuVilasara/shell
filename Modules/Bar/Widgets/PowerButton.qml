import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Widgets

Rectangle {
    id: root

    required property var colors
    property string fontFamily: "Inter" // Fallback if not passed, but Bar passes it usually? Bar.qml didn't pass fontFamily/fontSize to PowerButton previously. I need to check Bar.qml if I can pass them.
    property int fontSize: 12

    Layout.preferredHeight: 30
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: innerLayout.implicitWidth + 8
    radius: height / 2
    color: "transparent"

    HoverHandler {
        id: hoverHandler
    }

    RowLayout {
        id: innerLayout

        anchors.centerIn: parent
        spacing: 0
        width: parent.width

        Item {
            Layout.preferredWidth: hoverHandler.hovered ? 8 : 4

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        Item {
            id: textContainer

            Layout.preferredWidth: hoverHandler.hovered ? textMetrics.width : 0
            Layout.preferredHeight: root.height
            clip: true

            Text {
                id: pwrText

                anchors.verticalCenter: parent.verticalCenter
                text: "Power"
                color: root.colors.fg
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
                font.bold: true
            }

            TextMetrics {
                id: textMetrics

                font: pwrText.font
                text: pwrText.text
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        Item {
            Layout.preferredWidth: hoverHandler.hovered ? 8 : 0

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: Qt.rgba(root.colors.red.r, root.colors.red.g, root.colors.red.b, 0.2)

            Icon {
                anchors.centerIn: parent
                icon: Icons.power
                color: root.colors.red
                font.pixelSize: root.fontSize
            }

        }

        Item {
            Layout.preferredWidth: 4
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Ipc.togglePowerMenu()
    }

}
