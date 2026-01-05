import "../Components"
import QtQuick
import QtQuick.Layouts

BentoCard {
    id: root

    required property var colors
    required property var notifications

    cardColor: colors.surface
    borderColor: colors.border

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Notifications"
                color: root.colors.fg
                font.pixelSize: 11
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: root.notifications.count > 0 ? root.notifications.count.toString() : ""
                color: root.colors.accent
                font.pixelSize: 10
                font.bold: true
                visible: root.notifications.count > 0
            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: root.colors.border
            opacity: 0.4
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4
                visible: root.notifications.count === 0

                Text {
                    text: "󰂚"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 28
                    color: root.colors.muted
                    opacity: 0.35
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "All caught up"
                    color: root.colors.muted
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignHCenter
                }

            }

            ListView {
                anchors.fill: parent
                model: root.notifications
                spacing: 6
                visible: root.notifications.count > 0
                clip: true

                delegate: Rectangle {
                    required property int index
                    required property string summary
                    required property string body
                    required property string appName
                    required property string time

                    width: ListView.view ? ListView.view.width : 100
                    height: 50
                    radius: 8
                    color: Qt.rgba(root.colors.surface.r, root.colors.surface.g, root.colors.surface.b, 0.8)
                    border.width: 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            radius: 8
                            color: Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.2)

                            Text {
                                anchors.centerIn: parent
                                text: "󰍡"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 14
                                color: root.colors.accent
                            }

                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: summary
                                color: root.colors.fg
                                font.pixelSize: 10
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Text {
                                text: body || appName
                                color: Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.7)
                                font.pixelSize: 9
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                        }

                        Text {
                            text: time
                            color: root.colors.muted
                            font.pixelSize: 8
                            Layout.alignment: Qt.AlignTop
                        }

                    }

                }

            }

        }

    }

}
