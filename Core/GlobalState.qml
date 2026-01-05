import QtQuick

QtObject {
    id: root

    property bool launcherOpen: false
    property bool clipboardOpen: false
    property bool sidePanelOpen: false
    property bool wallpaperPanelOpen: false
    property bool powerMenuOpen: false
    property bool infoPanelOpen: false
    property bool settingsOpen: false
    property bool isLocked: false

    signal requestSidePanelMenu(string menu)
    signal requestInfoPanelTab(int tabIndex)

    function toggleLauncher() {
        if (launcherOpen) {
            launcherOpen = false;
        } else {
            closeAll();
            launcherOpen = true;
        }
    }

    function toggleSettings() {
        if (settingsOpen) {
            settingsOpen = false;
        } else {
            closeAll();
            settingsOpen = true;
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

    function toggleWallpaperPanel() {
        if (wallpaperPanelOpen) {
            wallpaperPanelOpen = false;
        } else {
            closeAll();
            wallpaperPanelOpen = true;
        }
    }

    function togglePowerMenu() {
        if (powerMenuOpen) {
            powerMenuOpen = false;
        } else {
            closeAll();
            powerMenuOpen = true;
        }
    }

    function toggleInfoPanel() {
        if (infoPanelOpen) {
            infoPanelOpen = false;
        } else {
            closeAll();
            infoPanelOpen = true;
        }
    }

    function closeAll() {
        launcherOpen = false;
        clipboardOpen = false;
        sidePanelOpen = false;
        wallpaperPanelOpen = false;
        powerMenuOpen = false;
        infoPanelOpen = false;
        settingsOpen = false;
    }

}
