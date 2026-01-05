import QtQuick

Rectangle {
    id: root

    property color cardColor: "transparent"
    property color borderColor: "gray"

    color: Qt.rgba(0.1, 0.1, 0.1, 0.9) // Force dark background opacity
    radius: 16
    border.width: 0
    border.color: borderColor
}
