import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Rectangle {
    id: root
    property string appIcon: ""
    property string summary: ""
    property int urgency: NotificationUrgency.Normal
    property bool isUrgent: urgency === NotificationUrgency.Critical
    property string image: ""

    width: 38
    height: 38
    radius: 10

    color: isUrgent ? Qt.rgba(255, 100, 100, 0.2) : Qt.rgba(100, 200, 255, 0.2)

    Image {
        id: notifImage
        anchors.fill: parent
        source: root.image
        fillMode: Image.PreserveAspectCrop
        cache: false
        antialiasing: true
        asynchronous: true
        visible: root.image !== "" && status === Image.Ready

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: notifImage.width
                height: notifImage.height
                radius: root.radius
            }
        }
    }

    Image {
        id: appIconImg
        anchors.centerIn: parent
        width: 28
        height: 28
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: {
            if (root.appIcon === "") return ""
            if (root.appIcon.startsWith("/") || root.appIcon.startsWith("file://"))
                return root.appIcon.startsWith("file://") ? root.appIcon : "file://" + root.appIcon
            return "image://icon/" + root.appIcon
        }
        visible: root.image === "" && status === Image.Ready
    }

    Text {
        anchors.centerIn: parent
        text: {
            if (root.summary.toLowerCase().includes("update")) return "󰇚"
            if (root.summary.toLowerCase().includes("message")) return "󰭹"
            if (root.summary.toLowerCase().includes("alarm")) return "󰔔"
            if (root.isUrgent) return "⚠"
            return "󰂚"
        }
        font.pixelSize: 20
        font.family: "Symbols Nerd Font"
        color: root.isUrgent ? "#FF6464" : "#64B5F6"
        visible: root.image === "" && appIconImg.status !== Image.Ready
    }
}
