import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: root
    required property int count
    required property bool expanded

    implicitHeight: 28
    implicitWidth: Math.max(contentItem.implicitWidth + 10, 30)

    background: Rectangle {
        radius: 14
        color: root.hovered ? "#2a2a2a" : "#1a1a1a"
    }

    contentItem: RowLayout {
        spacing: 4
        anchors.centerIn: parent

        Text {
            Layout.leftMargin: 4
            visible: root.count > 1
            text: root.count
            font.pixelSize: 12
            color: "#E8EAF0"
        }

        Text {
            text: expanded ? "▼" : "▶"
            font.pixelSize: 12
            color: "#9BA3B8"

            Behavior on rotation {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
