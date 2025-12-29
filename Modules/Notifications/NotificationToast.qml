import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: root

    required property var manager
    property string notifTitle: ""
    property string notifBody: ""
    property string notifIcon: ""
    property string notifImage: ""
    property int notifUrgency: 1
    property bool showing: false
    property int displayTime: 6000
    required property Colors colors
    readonly property var theme: colors

    WlrLayershell.margins.top: 60
    WlrLayershell.margins.right: 10
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications-toast"
    WlrLayershell.exclusiveZone: -1
    implicitWidth: 340
    implicitHeight: content.implicitHeight + 20 // Padding for shadow
    color: "transparent"

    anchors {
        top: true
        right: true
    }

    Connections {
        function onPopupVisibleChanged() {
            if (manager.popupVisible && manager.currentPopup) {
                root.notifTitle = manager.currentPopup.summary || "Notification";
                root.notifBody = manager.currentPopup.body || "";
                root.notifIcon = manager.currentPopup.appIcon || "";
                root.notifImage = manager.currentPopup.image || "";
                root.notifUrgency = manager.currentPopup.urgency;
                root.showing = true;
                dismissTimer.restart();
                console.log("[Toast] New notification captured: " + root.notifTitle);
            }
        }

        target: manager
    }

    Timer {
        id: dismissTimer

        interval: root.displayTime
        onTriggered: root.showing = false
    }

    Item {
        id: content

        width: 320
        implicitHeight: mainLayout.implicitHeight + 24
        x: root.showing ? 0 : 350
        opacity: root.showing ? 1 : 0
        layer.enabled: true

        // Background
        Rectangle {
            id: bgRect
            property alias hovered: toastHandler.hovered

            anchors.fill: parent
            radius: 20
            color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
            border.width: 1
            border.color: root.notifUrgency === 2 ? theme.urgent : Qt.rgba(theme.border.r, theme.border.g, theme.border.b, 0.5)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    root.showing = false;
                    manager.closePopup();
                }

                HoverHandler {
                    id: toastHandler
                    cursorShape: Qt.PointingHandCursor
                }
            }
            
            RowLayout {
                id: mainLayout
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Icon / Image
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    radius: 12
                    color: theme.surface

                    Image {
                        id: imgDisplay
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        source: {
                            if (root.notifImage && root.notifImage.startsWith("/")) return "file://" + root.notifImage;
                            if (root.notifImage && root.notifImage.includes("://")) return root.notifImage;
                            if (root.notifIcon && root.notifIcon.includes("/")) return "file://" + root.notifIcon;
                            if (root.notifIcon) return "image://icon/" + root.notifIcon;
                            return "";
                        }
                        visible: status === Image.Ready
                        layer.effect: OpacityMask {
                            maskSource: Rectangle { width: 40; height: 40; radius: 12 }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰂚"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: theme.subtext
                        visible: !imgDisplay.visible
                    }
                }

                // Text Content
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        text: root.notifTitle
                        Layout.fillWidth: true
                        font.bold: true
                        font.pixelSize: 13
                        color: theme.text
                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.notifBody
                        Layout.fillWidth: true
                        Layout.maximumHeight: 40
                        font.pixelSize: 12
                        color: theme.subtext
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        lineHeight: 1.1
                    }
                }

                // Circular Timer + Close
                Item {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    Layout.alignment: Qt.AlignVCenter
                    
                    // Circular Progress
                    Canvas {
                        id: timerCanvas
                        anchors.fill: parent
                        property real progress: 0
                        
                        onProgressChanged: requestPaint()
                        
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            
                            var cx = width / 2;
                            var cy = height / 2;
                            var r = (width / 2) - 2;
                            var start = -Math.PI / 2;
                            var end = start + (2 * Math.PI * progress);
                            
                            // Background ring
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                            ctx.strokeStyle = Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.1);
                            ctx.lineWidth = 2;
                            ctx.stroke();
                            
                            // Progress arc
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, start, end, false);
                            ctx.strokeStyle = root.notifUrgency === 2 ? theme.urgent : theme.accent;
                            ctx.lineWidth = 2;
                            ctx.stroke();
                        }
                        
                        // We animate progress from 1.0 to 0.0
                        NumberAnimation on progress {
                            id: timerAnim
                            from: 1.0
                            to: 0.0
                            duration: root.displayTime
                            running: false
                        }
                        
                        Connections {
                             target: root
                             function onShowingChanged() {
                                 if (root.showing) {
                                     timerCanvas.progress = 1.0;
                                     timerAnim.restart();
                                 } else {
                                     timerAnim.stop();
                                 }
                             }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: theme.subtext
                        font.pixelSize: 10
                        opacity: 0.5
                    }
                }
            }
        }

        // Animations
        Behavior on x {
            SpringAnimation {
                spring: 3
                damping: 0.25
                epsilon: 0.25
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 12
            samples: 17
            color: "#60000000"
            verticalOffset: 4
            spread: 0.0
        }
    }

    mask: Region {
        item: content
    }

}
