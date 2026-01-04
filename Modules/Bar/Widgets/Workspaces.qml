import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Core
import qs.Widgets
import qs.Services

Rectangle {
    id: wsContainer

    required property var colors
    required property string fontFamily
    required property int fontSize
    property var compositor: null

    property bool isNiri: compositor.detectedCompositor === "niri"

    property int activeWs:
        isNiri ? compositor.activeWorkspace
               : HyprlandData.focusedWorkspaceId

    property bool isSpecialOpen:
        isNiri
            ? compositor.isSpecialOpen
            : (HyprlandData.focusedMonitor
               && HyprlandData.focusedMonitor.lastIpcObject.specialWorkspace.name !== "")

    property int numWorkspaces:
        isNiri ? compositor.workspaceCount : 8

    Layout.preferredHeight: 26
    Layout.preferredWidth:
        numWorkspaces * 26 + (numWorkspaces - 1) * 4 + 4

    color: Qt.rgba(0, 0, 0, 0.2)
    radius: height / 2
    clip: true

    property var workspaceOccupied: []
    property var occupiedRanges: []

    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from(
            { length: numWorkspaces },
            (_, i) => HyprlandData.isWorkspaceOccupied(i + 1)
        )

        const ranges = []
        let start = -1

        for (let i = 0; i < workspaceOccupied.length; i++) {
            if (workspaceOccupied[i]) {
                if (start === -1)
                    start = i
            } else if (start !== -1) {
                if (i - 1 > start)
                    ranges.push({ start, end: i - 1 })
                start = -1
            }
        }

        if (start !== -1 && workspaceOccupied.length - 1 > start)
            ranges.push({ start, end: workspaceOccupied.length - 1 })

        occupiedRanges = ranges
    }

    Component.onCompleted: updateWorkspaceOccupied()

    Connections {
        target: Hyprland
        function onWindowListChanged() {
            updateWorkspaceOccupied()
        }
    }

    function resolveIcon(className) {
        if (!className || className.length === 0)
            return ""

        const original = className
        const normalized = className.toLowerCase()

        if (Quickshell.iconPath(original, true).length > 0)
            return original
        if (Quickshell.iconPath(normalized, true).length > 0)
            return normalized

        const dashed = normalized.replace(/\s+/g, "-")
        if (Quickshell.iconPath(dashed, true).length > 0)
            return dashed

        const ext = original.split(".").pop().toLowerCase()
        if (Quickshell.iconPath(ext, true).length > 0)
            return ext

        return ""
    }

    function isWorkspaceOccupied(wsId) {
        if (isNiri)
            return false
        return HyprlandData.isWorkspaceOccupied(wsId)
    }

    function changeWorkspace(wsId) {
        if (isNiri)
            compositor.changeWorkspace(wsId)
        else
            HyprlandData.dispatch("workspace " + wsId)
    }

    function changeWorkspaceRelative(delta) {
        if (isNiri) {
            compositor.changeWorkspaceRelative(delta)
        } else {
            const current = HyprlandData.focusedWorkspaceId
            const target = current + delta

            // Clamp to valid range (1..numWorkspaces)
            if (target >= 1 && target <= numWorkspaces) {
                HyprlandData.dispatch("workspace " + target)
            }
        }
    }


    MouseArea {
        anchors.fill: parent

        onWheel: wheel => {
            // Determine number of "steps" to move
            const step = wheel.angleDelta.y / 120  // 120 is standard delta for one notch
            if (step !== 0)
                changeWorkspaceRelative(-step)  // negative because scrolling up should go left
        }
    }


    Item {
        anchors.fill: parent
        opacity: isSpecialOpen ? 0 : 1

        Item {
            visible: !isNiri
            id: occupiedStretchLayer
            anchors.centerIn: wsRow
            width: wsRow.width
            height: 26
            z: 0

            Repeater {
                model: occupiedRanges

                Rectangle {
                    height: 26
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.2)
                    opacity: 0.8

                    x: modelData.start * (26 + wsRow.spacing)
                    width: (modelData.end - modelData.start + 1) * 26
                        + (modelData.end - modelData.start) * wsRow.spacing
                }
            }
        }

        Rectangle {
            id: highlight

            property int index: activeWs - 1
            property real itemWidth: 26
            property real spacing: 4

            /* target position */
            property real targetX: index * (itemWidth + spacing) + 2

            /* animated endpoints */
            property real animatedX1: targetX
            property real animatedX2: targetX

            onTargetXChanged: {
                animatedX1 = targetX
                animatedX2 = targetX
            }

            x: Math.min(animatedX1, animatedX2)
            width: Math.abs(animatedX2 - animatedX1) + itemWidth
            height: 26
            radius: 13
            color: colors.accent

            Behavior on animatedX1 {
                NumberAnimation {
                    duration: Animations.fast
                    easing.type: Animations.standardEasing
                }
            }

            Behavior on animatedX2 {
                NumberAnimation {
                    duration: Animations.slow
                    easing.type: Animations.standardEasing
                }
            }
        }


        Row {
            id: wsRow
            anchors.fill: parent
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            spacing: 4

            Repeater {
                model: numWorkspaces

                Item {
                    width: 26
                    height: 26

                    property int wsId: index + 1
                    property bool isActive: wsId === activeWs
                    property bool hasWindows: isWorkspaceOccupied(wsId)

                    Rectangle {
                        visible: Config.hideWorkspaceNumbers
                        anchors.centerIn: parent
                        width: (isActive || hasWindows) ? 6 : 4
                        height: width
                        radius: width / 2
                        color:
                            isActive
                                ? colors.bg
                                : hasWindows
                                    ? "#FFFFFF"
                                    : Qt.rgba(1, 1, 1, 0.2)
                    }

                    IconImage {
                        visible: !isNiri && Config.hideWorkspaceNumbers
                        implicitSize: 20
                        anchors.centerIn: parent
                        source: {
                            const win = HyprlandData.focusedWindowForWorkspace(wsId)
                            return win ? Quickshell.iconPath(resolveIcon(win.class)) : ""
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: wsId
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        font.bold: isActive
                        color:
                            isActive
                                ? colors.bg
                                : hasWindows
                                    ? colors.accent
                                    : colors.subtext
                        visible: !Config.hideWorkspaceNumbers
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: changeWorkspace(wsId)
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 26
        height: 26
        radius: 13
        color: colors.accent

        scale: isSpecialOpen ? 1 : 0.5
        opacity: isSpecialOpen ? 1 : 0

        Behavior on scale {
            NumberAnimation {
                duration: Animations.fast
                easing.type: Animations.standardEasing
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.fast
                easing.type: Animations.standardEasing
            }
        }

        Icon {
            anchors.centerIn: parent
            icon: Icons.star
            font.pixelSize: 18
            color: colors.bg
            font.bold: true
        }
    }

}
