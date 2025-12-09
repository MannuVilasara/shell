import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    // --- Data Store ---
    property ListModel notifications: ListModel {}
    property var currentPopup: null
    property bool popupVisible: false

    // --- The Server ---
    NotificationServer {
        id: server
        // running: true  <-- REMOVED THIS LINE (It doesn't exist)
        
        // Capabilities
        bodySupported: true
        imageSupported: true
        actionsSupported: true

        onNotification: (notification) => {
            // 1. Keep it alive
            notification.tracked = true

            // 2. Add to History
            root.notifications.insert(0, {
                "ref": notification,
                "appName": notification.appName,
                "summary": notification.summary,
                "body": notification.body,
                "appIcon": notification.appIcon,
                "image": notification.image,
                "urgency": notification.urgency,
                "time": Qt.formatTime(new Date(), "hh:mm")
            })

            // 3. Show Popup
            root.currentPopup = notification
            root.popupVisible = true
            popupTimer.restart()

            // 4. Listen for External Close
            notification.closed.connect(() => {
                root.removeByRef(notification)
                if (root.currentPopup === notification) {
                    root.popupVisible = false
                }
            })
        }
    }

    // --- Popup Timer ---
    Timer {
        id: popupTimer
        interval: 5000
        onTriggered: root.popupVisible = false
    }

    function closePopup() {
        popupVisible = false
    }

    // --- History Management ---
    function clearHistory() {
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i)
            if (item.ref) item.ref.dismiss()
        }
        notifications.clear()
        popupVisible = false
    }

    function removeAtIndex(index) {
        var item = notifications.get(index)
        if (item && item.ref) {
            item.ref.dismiss()
        }
        notifications.remove(index)
    }

    function removeByRef(notificationRef) {
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).ref === notificationRef) {
                notifications.remove(i)
                break
            }
        }
    }
}