import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    required property var colors
    required property string fontFamily
    required property int fontSize
    required property var volumeService
    required property int volumeLevel

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
                id: volumeText

                anchors.verticalCenter: parent.verticalCenter
                text: (volumeService && volumeService.muted) ? "MUT" : (volumeLevel + "%")
                color: (volumeService && volumeService.muted) ? root.colors.red : root.colors.fg
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
                font.bold: true
            }

            TextMetrics {
                id: textMetrics

                font: volumeText.font
                text: volumeText.text
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
            color: (volumeService && volumeService.muted) ? Qt.rgba(root.colors.red.r, root.colors.red.g, root.colors.red.b, 0.2) : Qt.rgba(root.colors.yellow.r, root.colors.yellow.g, root.colors.yellow.b, 0.2)

            Icon {
                anchors.centerIn: parent
                icon: volumeService ? volumeService.icon : Icons.volumeHigh
                color: (volumeService && volumeService.muted) ? root.colors.red : root.colors.yellow
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
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (volumeService)
                volumeService.toggleMute();

        }
        onWheel: (wheel) => {
            if (!volumeService)
                return ;

            if (wheel.angleDelta.y > 0)
                volumeService.increaseVolume(0.02);
            else
                volumeService.decreaseVolume(0.02);
        }
    }

}
