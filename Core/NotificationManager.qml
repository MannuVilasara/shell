import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property ListModel notifications
    property var currentPopup: null
    property bool popupVisible: false
    property int notificationCounter: 0

    function closePopup() {
        popupVisible = false;
    }

    function clearHistory() {
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            if (item.ref)
                item.ref.dismiss();

        }
        notifications.clear();
        popupVisible = false;
    }

    function removeAtIndex(index) {
        var item = notifications.get(index);
        if (item && item.ref)
            item.ref.dismiss();

        notifications.remove(index);
    }

    function removeById(notifId) {
        console.log("Removing notification with ID:", notifId);
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            console.log("  Checking index", i, "ID:", item.id);
            if (item.id === notifId) {
                console.log("  Found! Removing...");
                if (item.ref)
                    item.ref.dismiss();

                notifications.remove(i);
                return ;
            }
        }
        console.log("  Not found!");
    }

    function removeByRef(notificationRef) {
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).ref === notificationRef) {
                notifications.remove(i);
                break;
            }
        }
    }

    NotificationServer {
        id: server

        bodySupported: true
        imageSupported: true
        actionsSupported: true
        onNotification: (notification) => {
            notification.tracked = true;
            var uniqueId = root.notificationCounter++;
            root.notifications.insert(0, {
                "id": uniqueId,
                "ref": notification,
                "appName": notification.appName,
                "summary": notification.summary,
                "body": notification.body,
                "appIcon": notification.appIcon,
                "image": notification.image,
                "urgency": notification.urgency,
                "time": Qt.formatTime(new Date(), "hh:mm")
            });
            console.log("Notification added:", notification.summary, "ID:", uniqueId, "Total count:", root.notifications.count);
            root.currentPopup = notification;
            root.popupVisible = true;
            popupTimer.restart();
            notification.closed.connect(() => {
                root.removeById(notification);
                if (root.currentPopup === notification)
                    root.popupVisible = false;

            });
        }
    }

    Timer {
        id: popupTimer

        interval: 5000
        onTriggered: root.popupVisible = false
    }

    notifications: ListModel {
    }

}
