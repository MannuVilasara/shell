import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

Rectangle {
    property int notifId: 0
    property string summary: ""
    property string body: ""
    property string image: ""
    property string appIcon: ""
    property var theme

    signal removeRequested()

    width: ListView.view ? ListView.view.width : 400
    implicitHeight: Math.max(80, mainLayout.implicitHeight + 32)
    height: implicitHeight
    color: theme ? theme.surface : "#252932"
    radius: 12

    RowLayout {
        id: mainLayout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            color: (theme && theme.tile) ? theme.tile : "#2F333D"
            radius: 8
            Layout.alignment: Qt.AlignTop

            Image {
                id: notifIcon

                anchors.centerIn: parent
                width: 24
                height: 24
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: {
                    var img = image || "";
                    var icon = appIcon || "";
                    if (img !== "") {
                        if (img.startsWith("/") || img.startsWith("file://"))
                            return img.startsWith("file://") ? img : "file://" + img;

                    }
                    if (icon !== "") {
                        if (icon.startsWith("/") || icon.startsWith("file://"))
                            return icon.startsWith("file://") ? icon : "file://" + icon;

                        return "image://icon/" + icon;
                    }
                    return "";
                }
                visible: status === Image.Ready
                cache: false
            }

            Text {
                anchors.centerIn: parent
                text: "󰂚"
                font.pixelSize: 24
                font.family: "Symbols Nerd Font"
                color: theme ? theme.iconMuted : "#70727C"
                visible: !notifIcon.visible
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Layout.alignment: Qt.AlignTop

            Text {
                text: summary
                color: theme ? theme.text : "#E8EAF0"
                font.pixelSize: 14
                font.weight: Font.Medium
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2
                Layout.fillWidth: true
            }

            Text {
                text: body
                color: theme ? theme.secondary : "#9BA3B8"
                font.pixelSize: 13
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 3
                Layout.fillWidth: true
                visible: text !== ""
            }

        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignTop
            color: closeArea.containsMouse ? ((theme && theme.tile) ? theme.tile : "#2F333D") : "transparent"
            radius: 12

            Text {
                anchors.centerIn: parent
                text: "󰅖"
                font.pixelSize: 14
                font.family: "Symbols Nerd Font"
                color: theme ? theme.secondary : "#9BA3B8"
            }

            MouseArea {
                id: closeArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Logger.d("NotifItem", "Close clicked for ID:", notifId);
                    removeRequested();
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

    }

}
