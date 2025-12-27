import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root
    property var notificationObject
    property bool expanded: false
    property bool onlyNotification: false
    property real padding: onlyNotification ? 0 : 12
    
    // Backward compatibility properties
    property int notifId: 0
    property string summary: ""
    property string body: ""
    property string image: ""
    property string appIcon: ""
    property var theme

    signal removeRequested()

    implicitHeight: background.implicitHeight

    function destroyWithAnimation(left = false) {
        destroyAnimation.left = left;
        destroyAnimation.running = true;
    }

    // Fallback function to handle both notification object and simple properties
    function getImageSource() {
        var source = ""
        var img = notificationObject ? (notificationObject.image || image) : image
        var icon = notificationObject ? (notificationObject.appIcon || appIcon) : appIcon
        
        if (img !== "") {
            return img.startsWith("file://") ? img : "file://" + img
        }
        if (icon !== "") {
            return icon.startsWith("file://") ? icon : "image://icon/" + icon
        }
        return ""
    }

    function getSummaryText() {
        return notificationObject ? (notificationObject.summary || "") : summary
    }

    function getBodyText() {
        return notificationObject ? (notificationObject.body || "") : body
    }

    function getUrgency() {
        return notificationObject ? (notificationObject.urgency || NotificationUrgency.Normal) : NotificationUrgency.Normal
    }

    SequentialAnimation {
        id: destroyAnimation
        property bool left: true
        running: false

        NumberAnimation {
            target: background.anchors
            property: "leftMargin"
            to: (root.width + 20) * (destroyAnimation.left ? -1 : 1)
            duration: 300
            easing.type: Easing.OutCubic
        }
        onFinished: {
            if (notificationObject && notificationObject.notificationId) {
                Notifications.discardNotification(notificationObject.notificationId);
            } else if (notifId > 0) {
                removeRequested()
            }
        }
    }

    Rectangle {
        id: background
        width: parent.width
        anchors.left: parent.left
        radius: 12
        anchors.leftMargin: 0

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        color: {
            if (expanded && !onlyNotification) {
                return getUrgency() == NotificationUrgency.Critical ?
                    "#f5a5a5" : "#2a2a2a"
            }
            return "#1A1D24"
        }

        border.width: 1
        border.color: {
            if (getUrgency() == NotificationUrgency.Critical) {
                return Qt.rgba(255, 100, 100, 0.3)
            }
            return Qt.rgba(100, 200, 255, 0.15)
        }

        implicitHeight: expanded ? contentColumn.implicitHeight + padding * 2 : 80
        
        Behavior on implicitHeight {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: padding
            spacing: 8

            RowLayout {
                id: summaryRow
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    color: {
                        if (getUrgency() == NotificationUrgency.Critical) {
                            return Qt.rgba(255, 100, 100, 0.2)
                        }
                        return Qt.rgba(100, 200, 255, 0.2)
                    }
                    radius: 10
                    Layout.alignment: Qt.AlignTop

                    Image {
                        id: notifIcon
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: getImageSource()
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰂚"
                        font.pixelSize: 24
                        font.family: "Symbols Nerd Font"
                        color: "#70727C"
                        visible: !notifIcon.visible
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: getSummaryText()
                        color: "#E8EAF0"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        maximumLineCount: expanded ? 3 : 1
                        Layout.fillWidth: true
                    }

                    Text {
                        text: expanded ? getBodyText() : ""
                        color: "#9BA3B8"
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        Layout.fillWidth: true
                        visible: text !== ""
                        opacity: expanded ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignTop
                    color: closeArea.containsMouse ? Qt.rgba(255, 100, 100, 0.2) : "transparent"
                    radius: 10

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.pixelSize: 16
                        font.family: "Symbols Nerd Font"
                        color: closeArea.containsMouse ? "#FF6B6B" : "#70727C"
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (notificationObject && notificationObject.notificationId) {
                                root.destroyWithAnimation()
                            } else if (notifId > 0) {
                                removeRequested()
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            MouseArea {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                visible: expanded
                hoverEnabled: true

                Text {
                    anchors.centerIn: parent
                    text: "Click to collapse"
                    color: parent.containsMouse ? "#64B5F6" : "#9BA3B8"
                    font.pixelSize: 12
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                onClicked: {
                    root.expanded = false
                }
            }
        }
    }

    MouseArea {
        anchors.fill: background
        enabled: !expanded
        onClicked: {
            root.expanded = true
        }
    }
}
