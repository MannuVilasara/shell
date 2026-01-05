import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core

Item {
    id: root

    required property var context

    PamAuth {
        id: auth

        onSuccess: lock.locked = false
    }

    Binding {
        target: root.context.appState
        property: "isLocked"
        value: lock.locked
    }

    WlSessionLock {
        id: lock

        LockScreen {
            lock: lock
            pam: auth
            colors: root.context.colors
        }

    }

    IpcHandler {
        function lock() {
            lock.locked = true;
        }

        target: "lock"
    }

}
