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
    required property Colors colors
    readonly property var theme: colors
    property bool hovered: listHover.hovered

    WlrLayershell.margins.top: 60
    WlrLayershell.margins.right: 10
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications-toast"
    WlrLayershell.exclusiveZone: -1
    implicitWidth: 360
    implicitHeight: Math.min(contentList.contentHeight, 600) + 40
    color: "transparent"
    visible: manager.activeNotifications.count > 0

    anchors {
        top: true
        right: true
    }

    ListView {
        id: contentList

        anchors.fill: parent
        anchors.margins: 10
        spacing: 15
        model: manager.activeNotifications
        clip: false
        interactive: false 

        HoverHandler {
            id: listHover
        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { property: "y"; from: -50; duration: 200; easing.type: Easing.OutQuad }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; to: 0; duration: 300; easing.type: Easing.OutQuad }
                NumberAnimation { property: "scale"; to: 0.8; duration: 300; easing.type: Easing.OutQuad }
                NumberAnimation { property: "x"; to: 350; duration: 300; easing.type: Easing.InBack; easing.overshoot: 1.2 }
            }
        }

        displaced: Transition {
            NumberAnimation { property: "y"; duration: 200; easing.type: Easing.OutQuad }
        }

        delegate: Item {
            id: delegateRoot

            width: 320
            height: visible ? implicitHeight : 0 
            implicitHeight: mainLayout.implicitHeight + 24 + 16 
            visible: index < 3
            opacity: visible ? 1 : 0
            layer.enabled: true

            Rectangle {
                id: bgRect

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: mainLayout.implicitHeight + 24
                radius: 20
                color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
                border.width: 1
                border.color: urgency === 2 ? theme.urgent : Qt.rgba(theme.border.r, theme.border.g, theme.border.b, 0.5)

                Rectangle {
                    visible: index === 1 && manager.activeNotifications.count > 2
                    width: 24
                    height: 24
                    radius: 12
                    color: theme.accent
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: -8 
                    z: 10

                    Text {
                        anchors.centerIn: parent
                        text: "+" + (manager.activeNotifications.count - 2)
                        color: theme.bg
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (typeof notifId !== "undefined")
                            manager.removeById(notifId);
                    }

                    HoverHandler {
                        id: toastHandler
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                ColumnLayout {
                    id: mainLayout

                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignTop
                            radius: 12
                            color: theme.surface

                            Image {
                                id: imgDisplay
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                layer.enabled: true
                                source: {
                                    if (typeof image !== "undefined" && image && image.startsWith("/")) return "file://" + image;
                                    if (typeof image !== "undefined" && image && image.includes("://")) return image;
                                    if (typeof appIcon !== "undefined" && appIcon && appIcon.includes("/")) return "file://" + appIcon;
                                    if (typeof appIcon !== "undefined" && appIcon) return "image://icon/" + appIcon;
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

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                text: (typeof summary !== "undefined" ? summary : "Notification")
                                Layout.fillWidth: true
                                font.bold: true
                                font.pixelSize: 13
                                color: theme.text
                                elide: Text.ElideRight
                            }

                            Text {
                                text: (typeof body !== "undefined" ? body : "")
                                Layout.fillWidth: true
                                Layout.maximumHeight: 60
                                font.pixelSize: 12
                                color: theme.subtext
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 3
                                lineHeight: 1.1
                            }
                        }

                        
                        Item {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignTop

                            Canvas {
                                id: timerCanvas
                                property real progress: 0
                                anchors.fill: parent
                                onProgressChanged: requestPaint()
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    var cx = width / 2;
                                    var cy = height / 2;
                                    var r = (width / 2) - 2;
                                    var start = -Math.PI / 2;
                                    var end = start + (2 * Math.PI * progress);
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                                    ctx.strokeStyle = Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.1);
                                    ctx.lineWidth = 2;
                                    ctx.stroke();
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r, start, end, false);
                                    ctx.strokeStyle = (typeof urgency !== "undefined" && urgency === 2) ? theme.urgent : theme.accent;
                                    ctx.lineWidth = 2;
                                    ctx.stroke();
                                }
                                NumberAnimation on progress {
                                    from: 1
                                    to: 0
                                    duration: 5000
                                    running: true
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

                    
                    RowLayout {
                        property var actionList: (typeof actions !== "undefined") ? actions : null
                        visible: actionList && (
                             (typeof actionList.count === "number" && actionList.count > 0) || 
                             (typeof actionList.length === "number" && actionList.length > 0)
                        )
                        
                        Layout.fillWidth: true
                        Layout.leftMargin: 52 
                        spacing: 8

                        Repeater {
                            model: parent.actionList
                            
                            delegate: Rectangle {
                                id: actionBtn
                                
                                property string btnId: {
                                    if (typeof modelData !== "undefined" && modelData.id) return modelData.id;
                                    if (typeof id !== "undefined") return id; 
                                    return ""; 
                                }
                                property string btnLabel: {
                                    if (typeof modelData !== "undefined" && modelData.label) return modelData.label;
                                    if (typeof label !== "undefined") return label; 
                                    return btnId; 
                                }

                                Layout.preferredHeight: 30
                                Layout.fillWidth: true
                                Layout.maximumWidth: 120
                                color: actionHover.containsMouse ? Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.1) : theme.surface
                                radius: 8
                                border.width: 1
                                border.color: Qt.rgba(theme.border.r, theme.border.g, theme.border.b, 0.3)

                                Text {
                                    anchors.centerIn: parent
                                    text: btnLabel
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: theme.text
                                    elide: Text.ElideRight
                                    width: parent.width - 10
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                MouseArea {
                                    id: actionHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (typeof notifId !== "undefined")
                                            manager.invokeAction(notifId, actionBtn.btnId);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            layer.effect: DropShadow {
                transparentBorder: true
                radius: 12
                samples: 17
                color: "#60000000"
                verticalOffset: 4
                spread: 0
            }
        }
    }

    mask: Region {
        item: contentList
    }
}