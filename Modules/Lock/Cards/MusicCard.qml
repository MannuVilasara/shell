import "../Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import qs.Services

BentoCard {
    id: root

    required property var colors

    cardColor: colors.surface
    borderColor: colors.border
    layer.enabled: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 120

            Image {
                anchors.fill: parent
                source: MprisService.artUrl
                fillMode: Image.PreserveAspectCrop
                visible: MprisService.artUrl !== ""
                layer.enabled: true

                layer.effect: OpacityMask {
                    maskSource: artMask
                }

            }

            Rectangle {
                id: artMask

                anchors.fill: parent
                radius: 12
                visible: false
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height / 2
                visible: MprisService.artUrl !== ""
                layer.enabled: true

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "transparent"
                    }

                    GradientStop {
                        position: 1
                        color: Qt.rgba(0, 0, 0, 0.8)
                    }

                }

                layer.effect: OpacityMask {
                    maskSource: artMask
                }

            }

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: Qt.rgba(0, 0, 0, 0.2)
                visible: MprisService.artUrl === ""
                border.width: 0

                Text {
                    anchors.centerIn: parent
                    text: "󰎈"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 48
                    color: root.colors.muted
                }

            }

            ColumnLayout {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 12
                width: parent.width - 24
                spacing: 2

                Text {
                    text: MprisService.title || "No Media Playing"
                    color: "white"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    style: Text.Outline
                    styleColor: "black"
                }

                Text {
                    text: MprisService.artist || "Unknown Artist"
                    color: "white"
                    opacity: 0.8
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    style: Text.Outline
                    styleColor: "black"
                }

            }

        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24

            Text {
                text: "󰒮" // Prev icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32 // Larger
                color: root.colors.fg
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -12
                    onClicked: MprisService.previous()
                    cursorShape: Qt.PointingHandCursor
                }

            }

            Rectangle {
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                radius: 28
                color: root.colors.accent

                Text {
                    anchors.centerIn: parent
                    text: MprisService.isPlaying ? "󰏤" : "󰐊"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 24
                    color: root.colors.bg
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: MprisService.playPause()
                    cursorShape: Qt.PointingHandCursor
                }

            }

            Text {
                text: "󰒭" // Next icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32 // Larger
                color: root.colors.fg
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -12
                    onClicked: MprisService.next()
                    cursorShape: Qt.PointingHandCursor
                }

            }

        }

    }

    layer.effect: OpacityMask {

        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: 16
        }

    }

}
