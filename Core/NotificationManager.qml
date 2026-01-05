import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property ListModel notifications
    property var currentPopup: null
    property bool popupVisible: false
    property int notificationCounter: 0
    property ListModel activeNotifications

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
        Logger.d("NotifMan", "Removing notification with ID:", notifId);
        for (var i = 0; i < activeNotifications.count; i++) {
            if (activeNotifications.get(i).id === notifId) {
                activeNotifications.remove(i);
                break;
            }
        }
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            if (item.id === notifId) {
                Logger.d("NotifMan", "  Found! Dismissing and removing...");
                if (item.ref) {
                    try {
                        item.ref.dismiss();
                    } catch (e) {
                        Logger.w("NotifMan", "Failed to dismiss notification (already destroyed?): " + e);
                    }
                }
                notifications.remove(i);
                return ;
            }
        }
        Logger.d("NotifMan", "  Not found!");
    }

    function removeSilent(notifId) {
        for (var i = 0; i < activeNotifications.count; i++) {
            if (activeNotifications.get(i).id === notifId) {
                activeNotifications.remove(i);
                break;
            }
        }
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).id === notifId) {
                notifications.remove(i);
                return ;
            }
        }
    }

    function removeByRef(notificationRef) {
        for (var i = 0; i < activeNotifications.count; i++) {
            if (activeNotifications.get(i).ref === notificationRef) {
                activeNotifications.remove(i);
                break;
            }
        }
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).ref === notificationRef) {
                notifications.remove(i);
                break;
            }
        }
    }

    property bool ready: false

    property var globalState: null // Injected global state

    Timer {
        interval: 3000
        running: true
        onTriggered: root.ready = true
    }

    Connections {
        target: root.globalState
        function onIsLockedChanged() {
            root.activeNotifications.clear();
            root.popupVisible = false;
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
            var entry = {
                "id": uniqueId,
                "ref": notification,
                "appName": notification.appName,
                "summary": notification.summary,
                "body": notification.body,
                "appIcon": notification.appIcon,
                "image": notification.image,
                "urgency": notification.urgency,
                "time": Qt.formatTime(new Date(), "hh:mm"),
                "expireTime": Date.now() + 5000
            };
            root.notifications.insert(0, entry);
            
            var isLocked = root.globalState ? root.globalState.isLocked : false
            if (root.ready && !isLocked) {
                root.activeNotifications.insert(0, entry);
                root.popupVisible = true;
                popupTimer.restart(); // Ensure timer is running
            }
            notification.closed.connect(() => {
                root.removeSilent(uniqueId);
            });
        }
    }

    Timer {
        id: popupTimer

        interval: 1000
        repeat: true
        running: root.activeNotifications.count > 0
        onTriggered: {
            var now = Date.now();
            var kept = false;
            for (var i = root.activeNotifications.count - 1; i >= 0; i--) {
                var item = root.activeNotifications.get(i);
                if (now >= item.expireTime)
                    root.activeNotifications.remove(i);
                else
                    kept = true;
            }
            if (!kept)
                root.popupVisible = false;

        }
    }

    activeNotifications: ListModel {
    }

    notifications: ListModel {
    }

}
