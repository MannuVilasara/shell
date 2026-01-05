import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Core
import qs.Services
import qs.Widgets

Rectangle {
    id: wsContainer

    required property var colors
    required property string fontFamily
    required property int fontSize
    property var compositor: null
    property bool isNiri: compositor.detectedCompositor === "niri"
    property int activeWs: compositor.activeWorkspace
    property bool isSpecialOpen: compositor.isSpecialOpen
    readonly property int visibleCount: 5
    property int pageCount: Math.max(20, Math.ceil((compositor.workspaceCount || 10) / visibleCount), Math.ceil(activeWs / visibleCount))

    function resolveIcon(className) {
        if (!className || className.length === 0)
            return "";

        const original = className;
        const normalized = className.toLowerCase();
        if (Quickshell.iconPath(original, true).length > 0)
            return original;

        if (Quickshell.iconPath(normalized, true).length > 0)
            return normalized;

        const dashed = normalized.replace(/\s+/g, "-");
        if (Quickshell.iconPath(dashed, true).length > 0)
            return dashed;

        const ext = original.split(".").pop().toLowerCase();
        if (Quickshell.iconPath(ext, true).length > 0)
            return ext;

        return "";
    }

    function changeWorkspace(wsId) {
        compositor.changeWorkspace(wsId);
    }

    function changeWorkspaceRelative(delta) {
        compositor.changeWorkspaceRelative(delta);
    }

    Layout.preferredHeight: 26
    Layout.preferredWidth: visibleCount * 26 + (visibleCount - 1) * 4 + 4
    color: Qt.rgba(0, 0, 0, 0.2)
    radius: height / 2
    clip: true

    ListView {
        id: pager

        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: false // Scroll via active workspace logic, not drag (optional)
        highlightMoveDuration: 400
        highlightMoveVelocity: -1 // velocity -1 means use duration
        model: pageCount
        currentIndex: Math.floor((activeWs - 1) / visibleCount)
        opacity: isSpecialOpen ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }

        }

        delegate: Item {
            property int pageIndex: index
            property int startWs: pageIndex * visibleCount + 1
            property int endWs: Math.min(startWs + visibleCount - 1, compositor.workspaceCount || (startWs + visibleCount - 1))
            property var pageOccupiedRanges: []

            function updatePageOccupied() {
                const ranges = [];
                let start = -1;
                for (let i = 0; i < visibleCount; i++) {
                    let wsId = startWs + i;
                    let occupied = compositor.isWorkspaceOccupied(wsId);
                    if (occupied) {
                        if (start === -1)
                            start = i;

                    } else if (start !== -1) {
                        ranges.push({
                            "start": start,
                            "end": i - 1
                        });
                        start = -1;
                    }
                }
                if (start !== -1)
                    ranges.push({
                    "start": start,
                    "end": visibleCount - 1
                });

                pageOccupiedRanges = ranges;
            }

            width: wsContainer.width
            height: wsContainer.height
            Component.onCompleted: updatePageOccupied()

            Connections {
                function onWindowListChanged() {
                    updatePageOccupied();
                }

                function onActiveWorkspaceChanged() {
                    updatePageOccupied();
                }

                target: compositor
            }

            Item {
                visible: !isNiri
                anchors.centerIn: wsRow
                width: wsRow.width
                height: 26
                z: 0

                Repeater {
                    model: pageOccupiedRanges

                    Rectangle {
                        height: 26
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.2)
                        opacity: 0.8
                        x: modelData.start * (26 + wsRow.spacing)
                        width: (modelData.end - modelData.start + 1) * 26 + (modelData.end - modelData.start) * wsRow.spacing
                    }

                }

            }

            Rectangle {
                id: highlight

                property int localIndex: activeWs - startWs
                property real itemWidth: 26
                property real spacing: 4
                property real targetX: (localIndex * (itemWidth + spacing)) + 2 // +2 for left margin offset
                property real animatedX1: targetX
                property real animatedX2: targetX

                opacity: (activeWs >= startWs && activeWs <= (startWs + visibleCount - 1)) ? 1 : 0
                visible: opacity > 0
                onTargetXChanged: {
                    animatedX1 = targetX;
                    animatedX2 = targetX;
                }
                x: Math.min(animatedX1, animatedX2)
                width: Math.abs(animatedX2 - animatedX1) + itemWidth
                height: 26
                radius: 13
                color: colors.accent

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }

                }

                Behavior on animatedX1 {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutSine
                    }

                }

                Behavior on animatedX2 {
                    NumberAnimation {
                        duration: 400 / 3 // One side moves faster to create stretch
                        easing.type: Easing.OutSine
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
                    model: visibleCount

                    Item {
                        property int wsId: startWs + index
                        property bool isActive: wsId === activeWs
                        property bool hasWindows: compositor.isWorkspaceOccupied(wsId)

                        width: 26
                        height: 26

                        Rectangle {
                            visible: Config.hideWorkspaceNumbers && (!hasWindows || Config.hideAppIcons)
                            anchors.centerIn: parent
                            width: (isActive || hasWindows) ? 6 : 4
                            height: width
                            radius: width / 2
                            color: isActive ? colors.bg : hasWindows ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.2)
                        }

                        Item {
                            property string iconSource: {
                                const win = compositor.focusedWindowForWorkspace(wsId);
                                return win ? Quickshell.iconPath(resolveIcon(win.class)) : "";
                            }

                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            visible: !Config.hideAppIcons && hasWindows && Config.hideWorkspaceNumbers && iconSource !== ""
                            layer.enabled: true

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                radius: width / 2
                                clip: true

                                IconImage {
                                    anchors.centerIn: parent
                                    width: parent.width
                                    height: parent.height
                                    source: parent.parent.iconSource
                                }

                            }

                            layer.effect: OpacityMask {

                                maskSource: Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 10
                                }

                            }

                        }

                        Text {
                            anchors.centerIn: parent
                            text: wsId
                            font.family: fontFamily
                            font.pixelSize: fontSize
                            font.bold: isActive
                            color: isActive ? colors.bg : hasWindows ? colors.accent : colors.subtext
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

    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true // Allow inner clicks to pass if needed, but clicks usually handled by inner items
        onWheel: (wheel) => {
            const step = wheel.angleDelta.y / 120;
            if (step !== 0)
                changeWorkspaceRelative(-step);

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

        Icon {
            anchors.centerIn: parent
            icon: Icons.star
            font.pixelSize: 18
            color: colors.bg
            font.bold: true
        }

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

    }

}
