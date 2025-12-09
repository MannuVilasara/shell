import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects // Required for DropShadow
import Quickshell
import Quickshell.Wayland
import "../core"

PanelWindow {
    id: toast
    
    required property var manager

    // --- NEW COLOR PALETTE ---
    QtObject {
        id: theme
        readonly property color bg: "#1a1b26"
        readonly property color fg: "#a9b1d6"
        readonly property color muted: "#444b6a"
        readonly property color cyan: "#0db9d7"
        readonly property color purple: "#ad8ee6"
        readonly property color red: "#f7768e"
        readonly property color yellow: "#e0af68"
        readonly property color blue: "#7aa2f7"
    }

    // --- WINDOW SETUP ---
    visible: manager.popupVisible || content.opacity > 0
    
    width: 380
    height: content.height
    color: "transparent"

    anchors {
        top: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications-toast"
    WlrLayershell.exclusiveZone: -1 // Floats freely without reserving space
    
    // FIX: "Don't hide my bar"
    // We add enough top margin to clear the top bar (Assuming bar is ~50px)
    WlrLayershell.margins.top: 60   
    WlrLayershell.margins.right: 20

    // --- CONTENT ---
    Rectangle {
        id: content
        width: parent.width
        height: layout.implicitHeight + 32 
        
        radius: 12
        color: theme.bg // Main background
        
        // Border: Red if urgent, Muted (Grey/Blue) otherwise
        border.width: 1
        border.color: (manager.currentPopup?.urgency === 2) ? theme.red : theme.muted

        // Animation
        opacity: manager.popupVisible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        // Shadow
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#80000000" // 50% opacity black
            radius: 10
            samples: 16
            verticalOffset: 4
        }

        RowLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 16

            // --- ICON ---
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 8
                // Using 'muted' for the icon box to make it distinct but subtle
                color: theme.muted
                
                Image {
                    anchors.fill: parent
                    anchors.margins: 8
                    fillMode: Image.PreserveAspectFit
                    source: {
                        if (!manager.currentPopup) return ""
                        var src = manager.currentPopup.image || manager.currentPopup.appIcon || ""
                        if (src.indexOf("/") >= 0) return "file://" + src
                        if (src !== "") return "image://icon/" + src
                        return "" 
                    }
                    onStatusChanged: if (status === Image.Error) source = "image://icon/dialog-information"
                }
            }

            // --- TEXT ---
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4
                
                Text {
                    text: manager.currentPopup ? manager.currentPopup.summary : "Notification"
                    font.bold: true
                    font.pixelSize: 14
                    color: theme.fg // Main Text
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: manager.currentPopup ? manager.currentPopup.body : ""
                    font.pixelSize: 13
                    // Using 'muted' text would be too dark, so we use 'fg' with opacity or find a middle ground.
                    // Since we don't have a 'secondary' color in the new palette, we use 'fg' with transparency or 'purple'/'blue' for style.
                    // Let's stick to 'fg' but make it slightly smaller/regular weight (above). 
                    // Or we can use the 'muted' color if it's readable enough (check contrast). 
                    // #444b6a on #1a1b26 is low contrast. Let's use fg with opacity:
                    color: Qt.alpha(theme.fg, 0.7)
                    
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            
            // --- CLOSE BUTTON ---
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop
                color: closeMa.pressed ? theme.muted : "transparent"
                radius: 12

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    // Red on hover/press, muted otherwise
                    color: closeMa.pressed ? theme.red : theme.fg
                    opacity: closeMa.pressed ? 1 : 0.5
                    font.pixelSize: 12
                }

                MouseArea {
                    id: closeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: manager.closePopup()
                }
            }
        }
    }
}
