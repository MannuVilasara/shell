import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Modules.Notifications
import qs.Widgets

ColumnLayout {
    id: root

    required property var notifManager
    required property var theme

    width: 320
    spacing: 0
    clip: true

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 44
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8

            Text {
                text: "Notifications"
                color: theme.text
                font.pixelSize: 14
                font.bold: true
            }

            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: theme.surface
                border.width: 1
                border.color: theme.border
                visible: root.notifManager.notifications.count > 0

                Text {
                    anchors.centerIn: parent
                    text: root.notifManager.notifications.count
                    color: theme.subtext
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 28
                height: 28
                radius: 8
                color: clearMouse.containsMouse ? theme.urgent : "transparent"
                visible: root.notifManager.notifications.count > 0

                Text {
                    anchors.centerIn: parent
                    text: "󰃤" // Trash icon
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: clearMouse.containsMouse ? theme.bg : theme.subtext
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.notifManager.clearHistory()
                }

                Behavior on color { ColorAnimation { duration: 150 } }
            }

        }

    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: theme.border
        opacity: 0.5
        Layout.bottomMargin: 8
    }

    ListView {
        id: notifList

        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight > 0 ? contentHeight : 110, 300)
        clip: true
        spacing: 10
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { property: "y"; from: -20; duration: 200; easing.type: Easing.OutQuad }
        }

        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: 200 }
            NumberAnimation { property: "x"; to: 300; duration: 200; easing.type: Easing.InQuad }
        }

        displaced: Transition {
            NumberAnimation { property: "y"; duration: 200; easing.type: Easing.OutQuad }
        }

        model: root.notifManager.notifications

        Column {
            anchors.centerIn: parent
            visible: parent.count === 0
            spacing: 8
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "󰂛" 
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: theme.disabled || "#4C4F5A"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No new notifications"
                color: theme.muted
                font.pixelSize: 12
            }
        }

        delegate: NotificationItem {
            width: ListView.view.width
            notifId: model.notifId 
            summary: model.summary || ""
            body: model.body || ""
            image: model.image || ""
            appIcon: model.appIcon || ""
            appName: model.appName || ""
            time: model.time || ""
            actions: model.actions || []
            theme: root.theme
            onRemoveRequested: root.notifManager.removeById(notifId)
            onClicked: root.notifManager.activate(notifId)
            onActionClicked: (actionId) => root.notifManager.invokeAction(notifId, actionId)
        }

    }

}