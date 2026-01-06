import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "Views" as Views
import qs.Core
import qs.Modules.Notifications
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    required property var globalState
    required property var notifManager
    required property var volumeService
    required property var bluetoothService
    required property Colors colors
    property alias theme: theme
    readonly property int peekWidth: 10
    readonly property int boxWidth: 320
    property bool forcedOpen: false
    property bool controlOpen: false
    property bool notifOpen: false

    property string currentMenu: ""

    property bool anyOpen: controlOpen || notifOpen || forcedOpen

    function show() {
        controlOpen = true;
        notifOpen = true;
        forcedOpen = true;
    }

    function hide() {
        controlOpen = false;
        notifOpen = false;
        forcedOpen = false;
        menuLoader.active = false;
    }

    function getX(open) {
        return open ? (root.width - root.boxWidth - 20) : (root.width - root.peekWidth);
    }

    function toggleMenu(menu) {
        if (menu === "" || root.currentMenu === menu) {
            menuLoader.active = false;
            root.currentMenu = "";
        } else {
            root.currentMenu = menu;
            menuLoader.active = true;
            root.controlOpen = true; // Ensure control panel opens
        }
    }

    implicitWidth: Screen.width
    implicitHeight: Screen.height
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    mask: (root.controlOpen || root.notifOpen || root.forcedOpen) ? fullMask : splitMask

    anchors {
        top: true
        bottom: true
        right: true
    }

    Region {
        id: fullMask

        regions: [
            Region {
                x: 0
                y: 0
                width: root.width
                height: root.height
            }
        ]
    }

    Region {
        id: splitMask

        regions: [
            Region {
                x: controlBox.x
                y: controlBox.y
                width: controlBox.width
                height: controlBox.height
            },
            Region {
                x: notifBox.x
                y: notifBox.y
                width: notifBox.width
                height: notifBox.height
            },
            Region {
                x: root.width - root.peekWidth
                y: controlBox.y
                width: root.peekWidth
                height: controlBox.height
            },
            Region {
                x: root.width - root.peekWidth
                y: notifBox.y
                width: root.peekWidth
                height: notifBox.height
            },
            Region {
                x: controlBox.x
                y: controlBox.y + controlBox.height
                width: controlBox.width
                height: 12 // Spacing
            },
            Region {
                x: root.width - root.peekWidth
                y: controlBox.y + controlBox.height
                width: root.peekWidth
                height: 12
            }
        ]
    }

    QtObject {
        id: theme

        property color bg: root.colors.bg
        property color surface: root.colors.surface
        property color border: root.colors.border
        property color text: root.colors.text
        property color subtext: root.colors.subtext
        property color secondary: root.colors.secondary
        property color muted: root.colors.muted
        property color urgent: root.colors.urgent
        property color accent: root.colors.accent
        property color accentActive: root.colors.accentActive
        property color tileActive: root.colors.tileActive
        property color iconMuted: root.colors.iconMuted
        property int borderRadius: 16
        property int contentMargins: 16
        property int spacing: 12
    }

    Connections {
        function onRequestSidePanelMenu(menu) {
            if (root.currentMenu === menu && root.controlOpen) {
                toggleMenu(menu); // This will close it if same menu
                if (root.currentMenu === "") root.controlOpen = false;
            } else {
                toggleMenu(menu);
            }
        }

        target: globalState
    }

    MouseArea {
        anchors.fill: parent
        z: -100
        enabled: root.controlOpen || root.notifOpen || root.forcedOpen
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            root.hide();
            root.toggleMenu("");
        }
    }

    Rectangle {
        id: controlBox

        width: root.boxWidth
        height: contentCol.height + 32
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        x: root.getX(root.controlOpen || menuLoader.active || root.forcedOpen)
        radius: 16
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
        clip: true 
        layer.enabled: root.controlOpen || menuLoader.active || root.forcedOpen

        Column {
            id: contentCol

            width: parent.width - 32
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Views.ControlBoxContent {
                id: controlContent

                width: parent.width
                globalState: root.globalState
                theme: root.theme
                notifManager: root.notifManager
                onRequestWifiMenu: toggleMenu("wifi")
                onRequestBluetoothMenu: toggleMenu("bluetooth")
                onRequestPowerMenu: root.globalState.powerMenuOpen = true
                volumeService: root.volumeService
                bluetoothService: root.bluetoothService
            }

            Loader {
                id: menuLoader

                width: parent.width
                active: false
                visible: active
                sourceComponent: {
                    if (root.currentMenu === "wifi")
                        return wifiComp;

                    if (root.currentMenu === "bluetooth")
                        return btComp;

                    return null;
                }
                onLoaded: {
                    item.opacity = 0;
                    fadeIn.start();
                }

                NumberAnimation {
                    id: fadeIn

                    target: menuLoader.item
                    property: "opacity"
                    to: 1
                    duration: 200
                }

            }

        }

        HoverHandler {
            id: controlHandler
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            hoverEnabled: true // Allow hover, but consume clicks
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => mouse.accepted = true
        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
        }

        Behavior on x {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

        Behavior on height {
             NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

    }

    Component {
        id: wifiComp

        Views.WifiView {
            theme: root.theme
            globalState: root.globalState
            onBackRequested: toggleMenu("") // Close
        }

    }

    Component {
        id: btComp

        Views.BluetoothView {
            theme: root.theme
            globalState: root.globalState
            bluetoothService: root.bluetoothService
            onBackRequested: toggleMenu("") // Close
        }

    }

    Rectangle {
        id: notifBox

        property int maxAvailableHeight: root.height - controlBox.height - 40 - 20 

        width: root.boxWidth
        anchors.bottom: controlBox.top
        anchors.bottomMargin: 12
        height: Math.min(Math.max(100, maxAvailableHeight), notifContent.implicitHeight + 32)
        x: root.getX(root.notifOpen || root.forcedOpen)
        radius: 16
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
        layer.enabled: root.notifOpen || root.forcedOpen

        Views.NotificationBoxContent {
            id: notifContent

            anchors.fill: parent
            anchors.margins: 16
            theme: theme
            notifManager: root.notifManager
        }

        HoverHandler {
            id: notifHandler
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            hoverEnabled: true // Allow hover, but consume clicks
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => mouse.accepted = true
        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
        }

        Behavior on x {
             NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

        Behavior on height {
             NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

    }

    Rectangle {
        color: "transparent"
        x: parent.width - root.peekWidth
        y: controlBox.y
        width: root.peekWidth
        height: controlBox.height

        HoverHandler {
            id: controlPeekHandler
        }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.controlOpen = !root.controlOpen
        }

    }

    Rectangle {
        color: "transparent"
        x: parent.width - root.peekWidth
        y: notifBox.y
        width: root.peekWidth
        height: notifBox.height

        HoverHandler {
            id: notifPeekHandler
        }
        
         MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.notifOpen = !root.notifOpen
        }

    }

}
