import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core
import qs.Services

PanelWindow {
    id: root

    required property var globalState
    property bool internalOpen: false
    
    // Data Properties
    property int currentScreenIndex: 0
    property string wallpaperPath: WallpaperService.defaultDirectory
    property var wallpapersList: []
    property string currentWallpaper: ""

    // --- Logic ---
    function updateWallpaperData() {
        if (Quickshell.screens[currentScreenIndex]) {
            var screenName = Quickshell.screens[currentScreenIndex].name;
            wallpapersList = WallpaperService.getWallpapersList(screenName);
            currentWallpaper = WallpaperService.getWallpaper(screenName);
        }
    }

    // --- Window Config ---
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    visible: false
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "wallpaper-panel"
    WlrLayershell.exclusiveZone: -1

    // --- State Management ---
    Connections {
        target: globalState
        function onWallpaperPanelOpenChanged() {
            if (globalState.wallpaperPanelOpen) {
                root.visible = true;
                openTimer.restart();
                updateWallpaperData();
                
                // Scroll to current
                var idx = wallpapersList.indexOf(currentWallpaper);
                if (idx !== -1) {
                    wallpaperListView.currentIndex = idx;
                    wallpaperListView.positionViewAtIndex(idx, ListView.Center);
                }
            } else {
                internalOpen = false;
                closeTimer.restart();
            }
        }
    }

    Connections {
        target: WallpaperService
        function onWallpaperChanged(screenName, path) {
            if (Quickshell.screens[currentScreenIndex] && screenName === Quickshell.screens[currentScreenIndex].name)
                updateWallpaperData();
        }
        function onWallpaperListChanged(screenName, count) {
            if (Quickshell.screens[currentScreenIndex] && screenName === Quickshell.screens[currentScreenIndex].name)
                updateWallpaperData();
        }
    }

    Timer { id: openTimer; interval: 10; onTriggered: root.internalOpen = true }
    Timer { id: closeTimer; interval: 350; onTriggered: root.visible = false }

    Colors { id: theme }

    // --- Backdrop ---
    MouseArea {
        anchors.fill: parent
        onClicked: globalState.wallpaperPanelOpen = false
        z: -1
        
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: root.internalOpen ? 0.3 : 0
            Behavior on opacity { NumberAnimation { duration: 350 } }
        }
    }

    // --- Sliding Panel Container ---
    Item {
        id: slideContainer
        
        height: 260
        width: parent.width * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        
        // Slide up animation
        transform: Translate {
            y: root.internalOpen ? 0 : slideContainer.height
            Behavior on y {
                NumberAnimation { 
                    duration: 350
                    easing.type: Easing.OutCubic
                }
            }
        }

        // --- Upward Shadow ---
        Rectangle {
            id: shadowSource
            anchors.fill: mainPanel
            anchors.topMargin: 8
            radius: 20
            color: "black"
            visible: false
        }
        DropShadow {
            anchors.fill: mainPanel
            source: shadowSource
            horizontalOffset: 0
            verticalOffset: -8
            radius: 24
            samples: 32
            color: Qt.rgba(0, 0, 0, 0.4)
            transparentBorder: true
        }

        // --- Main Panel ---
        Rectangle {
            id: mainPanel
            anchors.fill: parent
            color: "transparent"
            clip: true
            
            // Background with rounded top corners only
            Rectangle {
                id: panelBackground
                anchors.fill: parent
                color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.98)
                radius: 20
                
                // Cover bottom corners to make them square
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 20
                    color: parent.color
                }
            }
            
            // Border on top and sides only
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: 20
                border.width: 1
                border.color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.25)
                
                // Hide bottom border completely
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 3
                    color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.98)
                }
            }

            // --- Horizontal Scrollable Wallpaper List ---
            ListView {
                id: wallpaperListView
                anchors.fill: parent
                anchors.margins: 24
                anchors.topMargin: 20
                anchors.bottomMargin: 20
                
                orientation: ListView.Horizontal
                spacing: 4
                clip: true
                topMargin: 4
                bottomMargin: 4
                leftMargin: 4
                rightMargin: 4
                
                model: wallpapersList
                
                // Calculate to show 3 items at once
                property real itemWidth: (width - (spacing * 2)) / 3
                
                keyNavigationEnabled: true
                focus: true
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 300
                preferredHighlightBegin: itemWidth + spacing
                preferredHighlightEnd: itemWidth * 2 + spacing
                highlightRangeMode: ListView.StrictlyEnforceRange
                
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds
                
                // Enter key to set wallpaper
                Keys.onReturnPressed: {
                    if (currentItem && wallpapersList[currentIndex]) {
                        WallpaperService.changeWallpaper(wallpapersList[currentIndex], undefined);
                    }
                }
                Keys.onEnterPressed: {
                    if (currentItem && wallpapersList[currentIndex]) {
                        WallpaperService.changeWallpaper(wallpapersList[currentIndex], undefined);
                    }
                }
                
                // Highlight indicator
                highlight: Rectangle {
                    radius: 18
                    color: "transparent"
                    border.width: 3
                    border.color: theme.accent
                    z: 10
                    
                    Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }

                delegate: Item {
                    id: delegateRoot
                    required property string modelData
                    required property int index
                    
                    property bool isSelected: (modelData === currentWallpaper)
                    property bool isHovered: itemMouse.containsMouse
                    property bool isCurrent: ListView.isCurrentItem
                    
                    width: wallpaperListView.itemWidth
                    height: wallpaperListView.height - 8  // Full height minus padding
                    
                    // Thumbnail Card
                    Rectangle {
                        id: card
                        anchors.centerIn: parent
                        
                        // Center item gets full width, side items get 70% width, all get full height
                        width: isCurrent ? parent.width : parent.width * 0.70
                        height: parent.height
                        
                        radius: 16
                        color: theme.bg
                        
                        border.width: isSelected ? 4 : (isCurrent ? 3 : (isHovered ? 2 : 0))
                        border.color: isSelected ? theme.accent : (isCurrent ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.7) : Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.4))
                        
                        Behavior on border.width { NumberAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        
                        scale: isHovered ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        
                        // Reduce opacity for side wallpapers
                        opacity: isCurrent ? 1.0 : 0.65
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                        
                        // Wallpaper Image
                        Image {
                            id: img
                            anchors.fill: parent
                            anchors.margins: border.width
                            
                            readonly property string fileName: modelData.split('/').pop()
                            readonly property string thumbSource: "file://" + WallpaperService.previewDirectory + "/" + fileName
                            readonly property string originalSource: "file://" + modelData
                            
                            source: thumbSource
                            sourceSize.width: 400
                            sourceSize.height: 280
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                            
                            opacity: status === Image.Ready ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 250 } }
                            
                            onStatusChanged: {
                                if (status === Image.Error && source !== originalSource)
                                    source = originalSource;
                            }
                            
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: img.width
                                    height: img.height
                                    radius: 14
                                }
                            }
                        }
                        
                        // Selected overlay
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.15)
                            visible: isSelected
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: 48
                                height: 48
                                radius: 24
                                color: theme.accent
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 24
                                    color: theme.bg
                                    font.bold: true
                                }
                            }
                        }
                        
                        // Loading placeholder
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.3)
                            visible: img.status === Image.Loading
                            
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 32
                                color: theme.subtext
                                opacity: 0.5
                                
                                SequentialAnimation on rotation {
                                    loops: Animation.Infinite
                                    running: parent.visible
                                    NumberAnimation { from: 0; to: 360; duration: 1000 }
                                }
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                wallpaperListView.currentIndex = index;
                                WallpaperService.changeWallpaper(modelData, undefined);
                            }
                        }
                    }
                }

                // Hidden scrollbar
                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }
            }
        }
    }
}
