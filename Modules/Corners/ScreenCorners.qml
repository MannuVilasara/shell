import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: screenCorners

    property var context

    visible: !context.activeWindow.isFullscreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:screenCorners"
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    property int barHeight: {
        switch (context.config.barSize) {
            case "compact": return 35;
            case "expanded": return 50;
            default: return 40;
        }
    }

    Behavior on barHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    property int cornerSize: 25
    property bool topActive: !context.config.floatingBar && context.config.barPosition === "top"
    property bool bottomActive: !context.config.floatingBar && context.config.barPosition === "bottom"

    RoundCorner {
        id: topLeft
        property real verticalSnap: 0

        size: cornerSize
        anchors.left: parent.left
        state: topActive ? "active" : ""
        anchors.top: parent.top
        anchors.topMargin: barHeight * verticalSnap
        corner: RoundCorner.CornerEnum.TopLeft
        color: context.colors.bg

        states: State {
            name: "active"
            PropertyChanges { target: topLeft; anchors.leftMargin: 0; verticalSnap: 1 }
        }
        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction { target: topLeft; property: "verticalSnap"; value: 0 }
                    PauseAnimation { duration: 300 }
                    PropertyAction { target: topLeft; property: "verticalSnap"; value: 1 }
                    PropertyAction { target: topLeft; property: "anchors.leftMargin"; value: -cornerSize }
                    NumberAnimation { target: topLeft; property: "anchors.leftMargin"; to: 0; duration: 200; easing.type: Easing.OutQuad }
                }
            }
        ]
        anchors.leftMargin: 0
    }

    RoundCorner {
        id: topRight
        property real verticalSnap: 0

        size: cornerSize
        anchors.right: parent.right
        state: topActive ? "active" : ""
        anchors.top: parent.top
        anchors.topMargin: barHeight * verticalSnap
        corner: RoundCorner.CornerEnum.TopRight
        color: context.colors.bg

        states: State {
            name: "active"
            PropertyChanges { target: topRight; anchors.rightMargin: 0; verticalSnap: 1 }
        }
        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction { target: topRight; property: "verticalSnap"; value: 0 }
                    PauseAnimation { duration: 300 }
                    PropertyAction { target: topRight; property: "verticalSnap"; value: 1 }
                    PropertyAction { target: topRight; property: "anchors.rightMargin"; value: -cornerSize }
                    NumberAnimation { target: topRight; property: "anchors.rightMargin"; to: 0; duration: 200; easing.type: Easing.OutQuad }
                }
            }
        ]
        anchors.rightMargin: 0
    }

    RoundCorner {
        id: bottomLeft
        property real verticalSnap: 0

        size: cornerSize
        anchors.left: parent.left
        state: bottomActive ? "active" : ""
        anchors.bottom: parent.bottom
        anchors.bottomMargin: barHeight * verticalSnap
        corner: RoundCorner.CornerEnum.BottomLeft
        color: context.colors.bg

        states: State {
            name: "active"
            PropertyChanges { target: bottomLeft; anchors.leftMargin: 0; verticalSnap: 1 }
        }
        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction { target: bottomLeft; property: "verticalSnap"; value: 0 }
                    PauseAnimation { duration: 300 }
                    PropertyAction { target: bottomLeft; property: "verticalSnap"; value: 1 }
                    PropertyAction { target: bottomLeft; property: "anchors.leftMargin"; value: -cornerSize }
                    NumberAnimation { target: bottomLeft; property: "anchors.leftMargin"; to: 0; duration: 200; easing.type: Easing.OutQuad }
                }
            }
        ]
        anchors.leftMargin: 0
    }

    RoundCorner {
        id: bottomRight
        property real verticalSnap: 0

        size: cornerSize
        anchors.right: parent.right
        state: bottomActive ? "active" : ""
        anchors.bottom: parent.bottom
        anchors.bottomMargin: barHeight * verticalSnap
        corner: RoundCorner.CornerEnum.BottomRight
        color: context.colors.bg

        states: State {
            name: "active"
            PropertyChanges { target: bottomRight; anchors.rightMargin: 0; verticalSnap: 1 }
        }
        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction { target: bottomRight; property: "verticalSnap"; value: 0 }
                    PauseAnimation { duration: 300 }
                    PropertyAction { target: bottomRight; property: "verticalSnap"; value: 1 }
                    PropertyAction { target: bottomRight; property: "anchors.rightMargin"; value: -cornerSize }
                    NumberAnimation { target: bottomRight; property: "anchors.rightMargin"; to: 0; duration: 200; easing.type: Easing.OutQuad }
                }
            }
        ]
        anchors.rightMargin: 0
    }

    mask: Region {
        item: null
    }

}
