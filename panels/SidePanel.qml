import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../core"
import "../notifications"

PanelWindow {
    id: root

    // --- DEPENDENCIES ---
    required property var globalState
    required property var notifManager

    readonly property int topBarHeight: 50

    // --- THEME ---
    QtObject {
        id: theme
        property color bg: "#1a1b26"       
        property color surface: "#24283b" 
        property color border: "#414868"
        property color text: "#c0caf5"     
        property color accent: "#7aa2f7"   
        property color secondary: "#9aa5ce" 
        property color urgent: "#f7768e"   
    }

    // --- WINDOW SETUP ---
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    // Only visible when open or animating
    visible: globalState.sidePanelOpen || slideAnim.running || slideTranslate.x < content.width

    // LAYER SHELL CONFIG
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "matte-dashboard"
    WlrLayershell.exclusiveZone: -1 
    
    // FIX 1: KEYBOARD FOCUS
    // "OnDemand" allows us to request focus. "None" blocked all keys.
    WlrLayershell.keyboardFocus: WlrLayershell.KeyboardFocus.OnDemand

    // FIX 2: ESCAPE KEY HANDLER
    // We must ensure 'root' has focus to catch this key.
    Keys.onEscapePressed: {
        globalState.sidePanelOpen = false
    }

    // FIX 3: FORCE FOCUS LOGIC
    // When panel opens, we grab focus so Escape works immediately.
    Connections {
        target: globalState
        function onSidePanelOpenChanged() {
            if (globalState.sidePanelOpen) {
                // Wait one frame for visibility to apply, then force focus
                requestFocusTimer.start()
            }
        }
    }

    Timer {
        id: requestFocusTimer
        interval: 10
        repeat: false
        onTriggered: {
            root.forceActiveFocus()
        }
    }

    // --- DIMMER (BACKGROUND) ---
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: globalState.sidePanelOpen ? 0.3 : 0
        Behavior on opacity { NumberAnimation { duration: 350 } }
        
        // FIX 4: MOUSE CATCHER
        // This MouseArea covers the whole screen *behind* the panel.
        // It catches clicks to close the panel, fixing the "dead input" feel.
        MouseArea {
            anchors.fill: parent
            onClicked: globalState.sidePanelOpen = false
        }
    }

    // --- MAIN CONTENT PANEL ---
    Rectangle {
        id: content
        width: 400
        
        // Layout
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: root.topBarHeight + 15
        anchors.bottomMargin: 15
        anchors.rightMargin: 15

        // Styles
        color: theme.bg
        radius: 16
        border.width: 1
        border.color: theme.border
        clip: true

        // Ensure clicks inside the panel don't close it
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true // Prevents clicks passing through to the dimmer
        }

        // Animation
        transform: Translate {
            id: slideTranslate
            x: globalState.sidePanelOpen ? 0 : (content.width + 50)
            Behavior on x {
                SpringAnimation {
                    id: slideAnim
                    spring: 2; damping: 0.25; epsilon: 0.5; mass: 1
                }
            }
        }

        // --- CONTENT LAYOUT ---
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 24

            // === HEADER ===
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Item {
                    Layout.preferredWidth: 54; Layout.preferredHeight: 54
                    Image {
                        id: avatar
                        anchors.fill: parent
                        source: "file://" + Quickshell.env("HOME") + "/.face"
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                        onStatusChanged: if (status === Image.Error) source = "../assets/avatar.jpg"
                    }
                    Rectangle { id: mask; anchors.fill: parent; radius: 14; visible: false }
                    OpacityMask { anchors.fill: parent; source: avatar; maskSource: mask }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text { 
                        text: Quickshell.env("USER"); 
                        color: theme.text; font.bold: true; font.pixelSize: 20 
                        font.capitalization: Font.Capitalize
                    }
                    Text { 
                        text: "Matte Shell • " + Qt.formatTime(new Date(), "hh:mm"); 
                        color: theme.secondary; font.pixelSize: 13 
                    }
                }

                MatteButton {
                    Layout.preferredWidth: 44; Layout.preferredHeight: 44
                    icon: "⏻"
                    accentColor: theme.urgent
                    onClicked: console.log("Logout Clicked")
                }
            }

            // === TOGGLES ===
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 12; columnSpacing: 12
                MatteToggle { label: "Wi-Fi"; icon: "▼"; active: true; Layout.fillWidth: true }
                MatteToggle { label: "Bluetooth"; icon: "✶"; active: true; Layout.fillWidth: true }
                MatteToggle { label: "DND"; icon: "☾"; active: false; Layout.fillWidth: true }
                MatteToggle { label: "Mic"; icon: "🎙"; active: true; Layout.fillWidth: true }
            }

            // === SLIDERS (FIXED) ===
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16
                // Note: Layout.fillWidth is now inside the component definition below
                MatteSlider { icon: "🕪"; value: 0.65; accentColor: theme.accent }
                MatteSlider { icon: "☀"; value: 0.8; accentColor: theme.secondary }
            }

            // === NOTIFICATIONS ===
            Rectangle { Layout.fillWidth: true; height: 1; color: theme.surface }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10
                
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "NOTIFICATIONS"; color: theme.secondary; font.bold: true; font.pixelSize: 11 }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Clear"
                        color: theme.urgent; font.bold: true; font.pixelSize: 11
                        visible: notifManager.notifications.count > 0
                        MouseArea { anchors.fill: parent; onClicked: notifManager.clearHistory() }
                    }
                }

                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 8
                    model: notifManager.notifications

                    Text {
                        visible: parent.count === 0
                        text: "All caught up"
                        anchors.centerIn: parent
                        color: theme.surface
                        font.bold: true; font.pixelSize: 16
                    }

                    // FIX 5: ROBUST DELEGATE
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 70
                        color: theme.surface
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            // Icon Wrapper
                            Rectangle {
                                Layout.preferredWidth: 40; Layout.preferredHeight: 40
                                color: theme.bg; radius: 6
                                Image {
                                    anchors.centerIn: parent; width: 24; height: 24
                                    fillMode: Image.PreserveAspectFit
                                    source: {
                                        var src = image || appIcon || ""
                                        if (src.indexOf("/") >= 0) return "file://" + src
                                        if (src !== "") return "image://icon/" + src
                                        return ""
                                    }
                                }
                            }

                            // Text
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                Text { text: summary; color: theme.text; font.bold: true; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
                                Text { text: body; color: theme.secondary; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                            }

                            // Close Button Wrapper
                            Rectangle {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                color: closeArea.pressed ? "#414868" : "transparent"
                                radius: 12
                                
                                Text { 
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: theme.secondary 
                                }
                                
                                MouseArea {
                                    id: closeArea
                                    anchors.fill: parent
                                    onClicked: {
                                        // Safer removal
                                        if (typeof notifManager.removeById === "function") {
                                            notifManager.removeById(model.id)
                                        } else {
                                            notifManager.removeAtIndex(index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- REUSABLE COMPONENTS ---

    component MatteButton: Rectangle {
        property string icon: ""; property color accentColor: theme.text; signal clicked()
        color: tapHandler.pressed ? theme.surface : "transparent"
        radius: 8; border.width: 1; border.color: theme.surface
        Text { anchors.centerIn: parent; text: icon; color: accentColor; font.pixelSize: 18 }
        TapHandler { id: tapHandler; onTapped: clicked() }
    }

    component MatteToggle: Rectangle {
        property string label: ""; property string icon: ""; property bool active: false
        height: 60; radius: 12; color: active ? theme.accent : theme.surface
        RowLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12
            Text { text: icon; font.pixelSize: 20; color: active ? theme.bg : theme.text }
            Text { text: label; font.bold: true; font.pixelSize: 14; color: active ? theme.bg : theme.text; Layout.fillWidth: true }
        }
        TapHandler { onTapped: active = !active }
    }

    component MatteSlider: Rectangle {
        property string icon: ""; property real value: 0.5; property color accentColor: theme.accent
        
        // FIX: Ensure it has width in Layouts
        Layout.fillWidth: true 
        
        height: 48; color: theme.surface; radius: 12; clip: true
        Rectangle { height: parent.height; width: parent.width * value; color: accentColor; radius: 12 }
        Text {
            anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter
            text: icon; color: (value > 0.15) ? theme.bg : theme.text; font.pixelSize: 16
        }
        MouseArea {
            anchors.fill: parent
            onPositionChanged: (mouse) => { parent.value = Math.max(0, Math.min(1, mouse.x / width)) }
            onPressed: (mouse) => { parent.value = Math.max(0, Math.min(1, mouse.x / width)) }
        }
    }
}