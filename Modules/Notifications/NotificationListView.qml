pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications

ListView {
    id: root
    property bool popup: false

    spacing: 8
    clip: true

    model: Notifications.appNameList
    delegate: NotificationGroup {
        required property var modelData
        width: ListView.view.width
        notificationGroup: Notifications.groupsByAppName[modelData]
        popup: root.popup
    }
}
