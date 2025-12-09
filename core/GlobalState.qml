import QtQuick

QtObject {
    id: root

    // --- State Properties ---
    property bool launcherOpen: false
    property bool clipboardOpen: false
    property bool sidePanelOpen: false
    // --- Actions ---
    function toggleLauncher() {
        if (launcherOpen) {
            launcherOpen = false;
        } else {
            // Close others when opening launcher (Exclusive mode)
            closeAll();
            launcherOpen = true;
        }
    }

    function toggleClipboard() {
        if (clipboardOpen) {
            clipboardOpen = false;
        } else {
            closeAll();
            clipboardOpen = true;
        }
    }

    function toggleSidePanel() {
        if (sidePanelOpen) {
            sidePanelOpen = false;
        } else {
            closeAll();
            sidePanelOpen = true;
            
        }
    }

    function closeAll() {
        launcherOpen = false;
        clipboardOpen = false;
        sidePanelOpen = false;
    }
}
