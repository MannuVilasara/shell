import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications

Button {
    id: button
    property string buttonText: text
    property int urgency: NotificationUrgency.Normal

    implicitHeight: 34
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    leftPadding: 15
    rightPadding: 15

    background: Rectangle {
        radius: 8
        color: button.hovered ? (urgency == NotificationUrgency.Critical ? "#FF6B6B" : "#64B5F6") : 
               (urgency == NotificationUrgency.Critical ? "#FF8888" : "#90CAF9")
    }

    contentItem: Text {
        text: buttonText
        color: "#000"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 12
    }
}
