import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications

/**
 * A group of notifications from the same app.
 */
MouseArea {
    id: root
    property var notificationGroup
    property var notifications: notificationGroup?.notifications ?? []
    property int notificationCount: notifications.length
    property bool multipleNotifications: notificationCount > 1
    property bool expanded: false
    property bool popup: false
    property real padding: 10
    implicitHeight: background.implicitHeight

    function toggleExpanded() {
        root.expanded = !root.expanded;
    }

    hoverEnabled: true

    Rectangle {
        id: background
        anchors.fill: parent
        width: parent.width
        color: popup ? "#2a2a2a" : "#1a1a1a"
        radius: 12
        
        implicitHeight: root.expanded ? contentColumn.implicitHeight + padding * 2 : 80

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: padding
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                NotificationAppIcon {
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    image: root?.multipleNotifications ? "" : (notificationGroup?.notifications[0]?.image ?? "")
                    appIcon: root.notificationGroup?.appIcon ?? ""
                    summary: root.notificationGroup?.notifications[root.notificationCount - 1]?.summary ?? ""
                    urgency: root.notifications.some(n => n.urgency === NotificationUrgency.Critical) ? 
                        NotificationUrgency.Critical : NotificationUrgency.Normal
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            text: root.multipleNotifications ?
                                (notificationGroup?.appName ?? "") :
                                (notificationGroup?.notifications[0]?.summary ?? "")
                            color: "#E8EAF0"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }

                        Text {
                            horizontalAlignment: Text.AlignRight
                            text: notificationCount > 1 ? notificationCount + "" : ""
                            color: "#9BA3B8"
                            font.pixelSize: 11
                            visible: notificationCount > 1
                        }
                    }

                    Text {
                        visible: expanded
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        maximumLineCount: 3
                        text: notificationGroup?.notifications[0]?.body ?? ""
                        color: "#9BA3B8"
                        font.pixelSize: 12
                        opacity: expanded ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                NotificationGroupExpandButton {
                    Layout.alignment: Qt.AlignTop
                    count: root.notificationCount
                    expanded: root.expanded
                    onClicked: {
                        root.toggleExpanded()
                    }
                }
            }
        }
    }

    onClicked: {
        if (!root.expanded && root.multipleNotifications) {
            root.toggleExpanded()
        }
    }
}
