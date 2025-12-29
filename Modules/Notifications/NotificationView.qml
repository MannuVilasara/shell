import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

Rectangle {
    id: root

    required property var manager

    color: "transparent"
    clip: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 10

            Text {
                text: "Notifications"
                font.pixelSize: 18
                font.bold: true
                color: "#cdd6f4"
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: 70
                Layout.preferredHeight: 28
                radius: 6
                color: clearMouse.pressed ? "#f38ba8" : "#313244"

                Text {
                    anchors.centerIn: parent
                    text: "Clear"
                    color: clearMouse.pressed ? "#11111b" : "#cdd6f4"
                    font.bold: true
                    font.pixelSize: 12
                }

                MouseArea {
                    id: clearMouse

                    anchors.fill: parent
                    onClicked: manager.clearHistory()
                }

            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: manager.notifications.count === 0

            Text {
                anchors.centerIn: parent
                text: "No new notifications"
                color: "#585b70"
                font.pixelSize: 16
            }

        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: manager.notifications.count > 0
            spacing: 10
            clip: true
            model: manager.notifications

            delegate: Rectangle {
                width: ListView.view.width
                height: 80
                radius: 12
                color: "#313244" // Surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        color: "#45475a" // Surface1 (Placeholder color)
                        radius: 8

                        Image {
                            anchors.fill: parent
                            anchors.margins: 4 // Add padding inside the box
                            fillMode: Image.PreserveAspectFit
                            source: {
                                var src = image || appIcon || "";
                                if (src.indexOf("/") >= 0)
                                    return "file://" + src;

                                if (src !== "")
                                    return "image://icon/" + src;

                                return ""; // Returns empty if no icon
                            }
                        }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: appName || "System"
                                color: "#a6adc8" // Subtext0
                                font.bold: true
                                font.pixelSize: 10
                                font.capitalization: Font.AllUppercase
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: time || "now"
                                color: "#a6adc8"
                                font.pixelSize: 10
                            }

                        }

                        Text {
                            text: summary
                            color: "#cdd6f4" // Text
                            font.bold: true
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: body
                            color: "#bac2de" // Subtext1
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            maximumLineCount: 1
                        }

                    }

                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        Layout.alignment: Qt.AlignVCenter
                        radius: 13
                        color: closeMouse.containsMouse ? "#45475a" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: closeMouse.pressed ? "#f38ba8" : "#6c7086" // Red on press, else overlay
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: closeMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (typeof manager.removeById === "function")
                                    manager.removeById(model.id);
                                else
                                    manager.removeAtIndex(index);
                            }
                        }

                    }

                }

            }

        }

    }

}
