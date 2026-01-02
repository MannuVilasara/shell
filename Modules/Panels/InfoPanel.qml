
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "Views/Info" as InfoViews
import qs.Core
import qs.Services

PanelWindow {
    /*
    onHoveredChanged: {
        if (hovered && !Config.disableHover) {
            closeTimer.stop()
            isOpen = true
        }
    }
    */

    id: root

    property int currentTab: 0 // 0: Home, 1: Music, 2: Weather, 3: System
    property bool forcedOpen: false
    property bool hovered: infoHandler.hovered || peekHandler.hovered
    property bool isOpen: false
    readonly property int peekWidth: 10
    required property var globalState

    function getX(open) {

        return 0; // Unused
    }

    implicitWidth: Screen.width
    implicitHeight: Screen.height
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    mask: (root.isOpen || root.forcedOpen) ? fullMask : splitMask

    anchors {
        top: true
        bottom: true
        left: true
    }

    Colors {
        id: appColors
    }

    SystemInfoService {
        id: systemInfo
    }

    Region {
        id: fullMask

        regions: [
            Region {
                x: 0
                y: 0
                width: root.width
                height: root.height
            }
        ]
    }

    Region {
        id: splitMask

        regions: [
            // Peek region for Content Box (The visual hint)
             Region {
                x: 0
                y: contentBox.y
                width: root.peekWidth
                height: contentBox.height
            },
            // Open regions (if any part is visible during transition)
             Region {
                x: 0 // navBox.x might be negative, restrict to 0
                y: navBox.y
                width: Math.max(0, navBox.x + navBox.width)
                height: navBox.height
            },
            Region {
                x: 0
                y: contentBox.y
                width: Math.max(0, contentBox.x + contentBox.width)
                height: contentBox.height
            }
        ]
    }

    Timer {
        id: closeTimer

        interval: 100
        repeat: false
        running: false // !root.hovered && !root.forcedOpen && !Config.disableHover
        onTriggered: root.isOpen = false
    }

    MouseArea {
        anchors.fill: parent
        z: -100
        enabled: root.isOpen || root.forcedOpen
        onClicked: {
            root.isOpen = false;
            root.forcedOpen = false;
        }
    }

    Rectangle {
        id: navBox

        width: 64 
        height: navColumn.implicitHeight + 32
        
        anchors.verticalCenter: parent.verticalCenter
        
        // Logic:
        // Open: x = 20
        // Closed: Pushed behind? Maybe x = -width? Or x = -width - 20? 
        // If contentBox peeks at -width + peekWidth, navBox should be further left to be "behind" / hidden.
        x: (root.isOpen || root.forcedOpen) ? 20 : (-width - 20)
        
        radius: 16
        color: Qt.rgba(appColors.bg.r, appColors.bg.g, appColors.bg.b, 0.95)
        border.width: 1
        border.color: appColors.border
        clip: true
        layer.enabled: root.isOpen || root.forcedOpen || root.height > 0

        ColumnLayout {
            id: navColumn
            anchors.centerIn: parent
            spacing: 16

            Repeater {
                model: [{
                    "icon": "󰣇",
                    "index": 0
                }, {
                    "icon": "󰝚",
                    "index": 1
                }, {
                    "icon": "󰖐",
                    "index": 2
                }, {
                    "icon": "󰍛",
                    "index": 3
                }]

                Rectangle {
                    required property var modelData

                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: root.currentTab === modelData.index ? appColors.accent : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: root.currentTab === modelData.index ? appColors.bg : appColors.subtext
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.currentTab = modelData.index
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }
        
        HoverHandler {
            id: navHandler
        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
            visible: navBox.visible && navBox.opacity > 0
        }

        Behavior on x {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }
    }

    Rectangle {
        id: contentBox

        property int spacing: 16
        
        width: loader.width + (root.currentTab === 1 ? 0 : 32)
        height: loader.height + (root.currentTab === 1 ? 0 : 32)
        anchors.verticalCenter: parent.verticalCenter
        
        // Logic:
        // Open: x = 20 + navBox.width + spacing
        // Closed: Peeking from left. x = -width + peekWidth
        x: (root.isOpen || root.forcedOpen) ? (20 + navBox.width + spacing) : (-width + root.peekWidth)

        radius: 16
        color: Qt.rgba(appColors.bg.r, appColors.bg.g, appColors.bg.b, 0.95)
        border.width: 1
        border.color: appColors.border
        clip: true
        layer.enabled: root.isOpen || root.forcedOpen || root.height > 0

        Loader {
            id: loader

            anchors.centerIn: parent

            width: Math.min(item ? item.implicitWidth : 0, 800)
            height: item ? item.implicitHeight : 0
            sourceComponent: {
                switch (root.currentTab) {
                case 0:
                    return homeComp;
                case 1:
                    return musicComp;
                case 2:
                    return weatherComp;
                case 3:
                    return systemComp;
                }
            }
            onSourceComponentChanged: fadeAnim.restart()

            NumberAnimation {
                id: fadeAnim

                target: loader.item
                property: "opacity"
                from: 0
                to: 1
                duration: 300
            }
        }
        
        HoverHandler {
            id: infoHandler
        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
            visible: contentBox.visible && contentBox.opacity > 0
        }

        Behavior on x {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }
    }
    
    // Update Peek Handler to trigger on contentBox area
    Rectangle {
        color: "transparent"
        x: 0
        y: contentBox.y
        width: root.peekWidth
        height: contentBox.height
        
        HoverHandler {
            id: peekHandler
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.isOpen = true
        }
    }



    Component {
        id: homeComp

        InfoViews.HomeView {
            theme: appColors
            sysInfo: systemInfo
        }
    }

    Component {
        id: musicComp

        InfoViews.MusicView {
            theme: appColors
        }
    }

    Component {
        id: weatherComp

        InfoViews.WeatherView {
            theme: appColors
        }
    }

    Component {
        id: systemComp

        InfoViews.SystemView {
            theme: appColors
        }
    }

}
