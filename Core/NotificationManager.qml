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
    property bool ready: false
    property var globalState: null

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

    function removeById(idToRemove) {
        Logger.d("NotifMan", "Removing notification with ID:", idToRemove);
        for (var i = 0; i < activeNotifications.count; i++) {
            if (activeNotifications.get(i).notifId === idToRemove) {
                activeNotifications.remove(i);
                break;
            }
        }
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            if (item.notifId === idToRemove) {
                if (item.ref) {
                    try {
                        item.ref.dismiss();
                    } catch (e) {
                    }
                }
                notifications.remove(i);
                return ;
            }
        }
    }

    function removeSilent(idToRemove) {
        for (var i = 0; i < activeNotifications.count; i++) {
            if (activeNotifications.get(i).notifId === idToRemove) {
                activeNotifications.remove(i);
                break;
            }
        }
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).notifId === idToRemove) {
                notifications.remove(i);
                return ;
            }
        }
    }

    function activate(targetId) {
        Logger.d("NotifMan", "Activating notification with ID:", targetId);
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            if (item.notifId === targetId) {
                if (item.ref) {
                    try {
                        var nativeActions = item.ref.actions;
                        var defaultFound = false;
                        if (nativeActions) {
                            for (var k = 0; k < nativeActions.length; k++) {
                                if (nativeActions[k].id === "default") {
                                    nativeActions[k].invoke();
                                    defaultFound = true;
                                    break;
                                }
                            }
                        }
                        root.removeById(targetId);
                    } catch (e) {
                        Logger.w("NotifMan", "Failed to activate: " + e);
                    }
                }
                return ;
            }
        }
    }

    function invokeAction(targetId, actionId) {
        Logger.d("NotifMan", "Invoking action:", actionId, "for ID:", targetId);
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            if (item.notifId === targetId) {
                if (item.ref) {
                    try {
                        var nativeActions = item.ref.actions;
                        var actionInvoked = false;
                        if (nativeActions && nativeActions.length > 0) {
                            for (var k = 0; k < nativeActions.length; k++) {
                                var nativeAction = nativeActions[k];
                                var nativeId = "";
                                if (typeof nativeAction === 'string')
                                    nativeId = nativeAction.split('=')[0];
                                else if (nativeAction && typeof nativeAction === 'object')
                                    nativeId = nativeAction.identifier || nativeAction.key || nativeAction.id || "";
                                Logger.d("NotifMan", "Checking native action", k, "- ID:", nativeId, "against:", actionId);
                                if (nativeId === actionId) {
                                    Logger.d("NotifMan", "Found matching action. Invoking...");
                                    if (typeof nativeAction.invoke === 'function')
                                        nativeAction.invoke();
                                    else
                                        item.ref.invoke(actionId);
                                    actionInvoked = true;
                                    break;
                                }
                            }
                        }
                        if (!actionInvoked) {
                            Logger.w("NotifMan", "Action ID '" + actionId + "' not found. Trying direct invoke...");
                            item.ref.invoke(actionId);
                        }
                        if (actionId !== "default")
                            root.removeById(targetId);

                    } catch (e) {
                        Logger.w("NotifMan", "Failed to invoke action: " + e);
                    }
                }
                return ;
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        onTriggered: root.ready = true
    }

    Connections {
        function onIsLockedChanged() {
            root.activeNotifications.clear();
            root.popupVisible = false;
        }

        target: root.globalState
    }

    NotificationServer {
        id: server

        bodySupported: true
        imageSupported: true
        actionsSupported: true
        onNotification: (notification) => {
            notification.tracked = true;
            var uniqueId = root.notificationCounter++;
            var mappedActions = [];
            if (notification.actions) {
                for (var i = 0; i < notification.actions.length; i++) {
                    var act = notification.actions[i];
                    var safeId = "";
                    var safeLabel = "";
                    if (typeof act === 'string') {
                        var parts = act.split('=');
                        safeId = parts[0] || "";
                        safeLabel = parts.length > 1 ? parts.slice(1).join('=') : safeId;
                    } else if (act && typeof act === 'object') {
                        safeId = (act.identifier || act.key || act.id || "").toString();
                        safeLabel = (act.text || act.label || act.name || safeId).toString();
                    }
                    if (safeId)
                        mappedActions.push({
                        "id": safeId,
                        "label": safeLabel || safeId
                    });

                }
            }
            var entry = {
                "notifId": uniqueId,
                "ref": notification,
                "appName": (notification.appName !== undefined) ? String(notification.appName) : "System",
                "summary": (notification.summary !== undefined) ? String(notification.summary) : "",
                "body": (notification.body !== undefined) ? String(notification.body) : "",
                "appIcon": (notification.appIcon !== undefined) ? String(notification.appIcon) : "",
                "image": (notification.image !== undefined) ? String(notification.image) : "",
                "urgency": (notification.urgency !== undefined) ? Number(notification.urgency) : 0,
                "actions": mappedActions,
                "time": Qt.formatTime(new Date(), Config.use24HourFormat ? "HH:mm" : "hh:mm AP"),
                "expireTime": Date.now() + 5000
            };
            root.notifications.insert(0, entry);
            var isLocked = root.globalState ? root.globalState.isLocked : false;
            if (root.ready && !isLocked) {
                root.activeNotifications.insert(0, entry);
                root.popupVisible = true;
                popupTimer.restart();
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
