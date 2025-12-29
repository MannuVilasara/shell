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
    WlrLayershell.margins.right: 20
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications-toast"
    WlrLayershell.exclusiveZone: -1
    implicitWidth: 380
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

        width: 360
        implicitHeight: mainLayout.implicitHeight + 32
        x: root.showing ? 0 : 400 // Slide out to right
        opacity: root.showing ? 1 : 0
        layer.enabled: true

        Rectangle {
            property alias hovered: toastHandler.hovered

            anchors.fill: parent
            radius: 16
            color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
            border.width: 1
            border.color: root.notifUrgency === 2 ? theme.urgent : theme.border

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                height: 2
                radius: 1
                color: root.notifUrgency === 2 ? theme.urgent : theme.accent
                width: parent.width - 32
                onVisibleChanged: {
                    if (visible) {
                        width = 328;
                        progressAnim.restart();
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.notifUrgency === 2 ? theme.urgent : theme.accent
                    visible: false // Just use parent for now or implement animation
                }

            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        root.showing = false; // Dismiss locally
                        manager.closePopup(); // Tell server we're done
                    } else {
                        root.showing = false;
                        manager.closePopup();
                    }
                }

                HoverHandler {
                    id: toastHandler

                    cursorShape: Qt.PointingHandCursor
                }

            }

            RowLayout {
                id: mainLayout

                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignTop
                    radius: 12
                    color: theme.surface

                    Image {
                        id: imgDisplay

                        anchors.fill: parent
                        anchors.margins: 0
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        source: {
                            if (root.notifImage.startsWith("/"))
                                return "file://" + root.notifImage;

                            if (root.notifImage.indexOf("://") !== -1)
                                return root.notifImage;

                            if (root.notifIcon.indexOf("/") !== -1)
                                return "file://" + root.notifIcon;

                            if (root.notifIcon !== "")
                                return "image://icon/" + root.notifIcon;

                            return "";
                        }
                        visible: status === Image.Ready

                        layer.effect: OpacityMask {

                            maskSource: Rectangle {
                                width: 48
                                height: 48
                                radius: 12
                            }

                        }

                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰂚"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 24
                        color: theme.subtext
                        visible: !imgDisplay.visible
                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: root.notifTitle
                        Layout.fillWidth: true
                        font.bold: true
                        font.pixelSize: 14
                        color: theme.text
                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.notifBody
                        Layout.fillWidth: true
                        Layout.maximumHeight: 60 // Limit height
                        font.pixelSize: 13
                        color: theme.subtext
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        maximumLineCount: 3
                    }

                }

                Rectangle {
                    Layout.alignment: Qt.AlignTop | Qt.AlignRight
                    width: 16
                    height: 16
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: theme.subtext
                        font.pixelSize: 10
                        opacity: 0.7
                    }

                }

            }

        }

        Behavior on x {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }

        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#60000000"
            verticalOffset: 4
        }

    }

    mask: Region {
        item: content
    }

}
