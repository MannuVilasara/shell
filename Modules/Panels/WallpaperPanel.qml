import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Core
import qs.Services

PanelWindow {
    id: root
    
    required property var globalState
    
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    visible: globalState.wallpaperPanelOpen
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wallpaper-panel"
    WlrLayershell.exclusiveZone: -1
    
    color: "transparent"
    
    property string wallpaperPath: WallpaperService.defaultDirectory
    property int currentScreenIndex: 0
    property string filterText: ""

    Colors { id: theme }
    
    // Local state for filtered wallpapers
    property var wallpapersList: []
    property var filteredWallpapers: []
    property string currentWallpaper: ""
    
    // Update wallpapers list when service emits signal
    Connections {
        target: WallpaperService
        
        function onWallpaperChanged(screenName, path) {
            if (Quickshell.screens[currentScreenIndex] && 
                screenName === Quickshell.screens[currentScreenIndex].name) {
                updateWallpaperData();
            }
        }
        
        function onWallpaperListChanged(screenName, count) {
            if (Quickshell.screens[currentScreenIndex] && 
                screenName === Quickshell.screens[currentScreenIndex].name) {
                updateWallpaperData();
            }
        }
    }
    
    function updateWallpaperData() {
        if (Quickshell.screens[currentScreenIndex]) {
            var screenName = Quickshell.screens[currentScreenIndex].name;
            wallpapersList = WallpaperService.getWallpapersList(screenName);
            currentWallpaper = WallpaperService.getWallpaper(screenName);
            updateFiltered();
        }
    }
    
    function updateFiltered() {
        if (!filterText || filterText.trim().length === 0) {
            filteredWallpapers = wallpapersList;
            return;
        }
        
        var searchText = filterText.toLowerCase();
        var filtered = [];
        for (var i = 0; i < wallpapersList.length; i++) {
            var filename = wallpapersList[i].split('/').pop().toLowerCase();
            if (filename.indexOf(searchText) >= 0) {
                filtered.push(wallpapersList[i]);
            }
        }
        filteredWallpapers = filtered;
    }
    
    Connections {
        target: globalState
        function onWallpaperPanelOpenChanged() {
            if (globalState.wallpaperPanelOpen) {
                updateWallpaperData();
                searchInput.text = "";
                filterText = "";
            }
        }
    }
    
    // Full screen background with blur effect
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)
        opacity: globalState.wallpaperPanelOpen ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.05, 0, 0.13333, 0.06, 0.16666, 0.4, 0.20833, 0.82, 0.25, 1, 1, 1]
            }
        }
        
        // Click anywhere outside panel to close
        MouseArea {
            anchors.fill: parent
            onClicked: {
                globalState.wallpaperPanelOpen = false
            }
            enabled: globalState.wallpaperPanelOpen
        }
    }
    
    // Main panel - Dolphin-inspired design
    Rectangle {
        id: panelContent
        
        anchors.centerIn: parent
        
        width: Math.min(1100, parent.width - 100)
        height: Math.min(700, parent.height - 100)
        
        color: theme.bg
        radius: 12
        border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
        border.width: 1
        
        // Faster open animation
        opacity: globalState.wallpaperPanelOpen ? 1 : 0
        scale: globalState.wallpaperPanelOpen ? 1 : 0.97
        
        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: 500
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }
        }
        
        // Prevent clicks from propagating to background
        MouseArea {
            anchors.fill: parent
            onClicked: {}
            hoverEnabled: false
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // Header bar - Dolphin style
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.02)
                
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08)
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 16
                    
                    // Icon and title
                    RowLayout {
                        spacing: 12
                        
                        Text {
                            text: "󰋩"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 24
                            color: theme.purple
                        }
                        
                        Text {
                            text: "Wallpapers"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: theme.fg
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Action buttons
                    RowLayout {
                        spacing: 8
                        
                        // Refresh button
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 6
                            color: refreshArea.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08) : "transparent"
                            
                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: theme.fg
                            }
                            
                            MouseArea {
                                id: refreshArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperService.refreshWallpapersList()
                            }
                        }
                        
                        Rectangle {
                            width: 1
                            height: 24
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                        }
                        
                        // Close button
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 6
                            color: closeArea.containsMouse ? Qt.rgba(theme.red.r, theme.red.g, theme.red.b, 0.15) : "transparent"
                            
                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: closeArea.containsMouse ? theme.red : theme.fg
                                
                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                            
                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: globalState.wallpaperPanelOpen = false
                            }
                        }
                    }
                }
            }
            
            // Content area
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 20
                spacing: 16
                
                // Search bar - Dolphin style
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 6
                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.04)
                    border.color: searchInput.activeFocus ? theme.purple : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)
                    border.width: 1
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        
                        Text {
                            text: ""
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.5)
                        }
                        
                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            color: theme.fg
                            font.pixelSize: 13
                            selectByMouse: true
                            clip: true
                            
                            Text {
                                anchors.fill: parent
                                text: "Search wallpapers..."
                                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.4)
                                font.pixelSize: parent.font.pixelSize
                                visible: !parent.text && !parent.activeFocus
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onTextChanged: {
                                filterText = text;
                                updateFiltered();
                            }
                            
                            Keys.onEscapePressed: {
                                text = "";
                                focus = false;
                            }
                            
                            Keys.onDownPressed: {
                                if (wallpaperGrid.count > 0) {
                                    wallpaperGrid.forceActiveFocus();
                                    if (wallpaperGrid.currentIndex < 0) {
                                        wallpaperGrid.currentIndex = 0;
                                    }
                                }
                            }
                        }
                        
                        // Clear search button
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: clearArea.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1) : "transparent"
                            visible: searchInput.text !== ""
                            
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 12
                                color: theme.fg
                            }
                            
                            MouseArea {
                                id: clearArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: searchInput.text = ""
                            }
                        }
                    }
                }
                
                // Info bar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: filteredWallpapers.length + " items" + (filterText ? " · " + wallpapersList.length + " total" : "")
                        font.pixelSize: 12
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6)
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: wallpaperPath
                        font.pixelSize: 11
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.5)
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 300
                    }
                }
                
                // Wallpaper grid with buttery smooth scrolling
                GridView {
                    id: wallpaperGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    property int columns: 5
                    cellWidth: Math.floor(width / columns)
                    cellHeight: Math.floor(cellWidth * 0.65) + 60
                    
                    model: filteredWallpapers
                    clip: true
                    focus: true
                    keyNavigationEnabled: true
                    
                    // Optimized cache for smooth scrolling
                    cacheBuffer: cellHeight * 3
                    displayMarginBeginning: cellHeight * 2
                    displayMarginEnd: cellHeight * 2
                    
                    // Performance optimizations
                    reuseItems: true
                    
                    // Butter-smooth native scrolling
                    flickDeceleration: 5000
                    maximumFlickVelocity: 2500
                    boundsBehavior: Flickable.DragAndOvershootBounds
                    
                    // Smooth rebound animation
                    rebound: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 250
                            easing.type: Easing.OutQuad
                        }
                    }
                    
                    // Keyboard navigation
                    Keys.onReturnPressed: {
                        if (currentIndex >= 0 && currentIndex < filteredWallpapers.length) {
                            var path = filteredWallpapers[currentIndex];
                            var screenName = Quickshell.screens[currentScreenIndex] ? Quickshell.screens[currentScreenIndex].name : undefined;
                            WallpaperService.changeWallpaper(path, screenName);
                            globalState.wallpaperPanelOpen = false;
                        }
                    }
                    
                    Keys.onEscapePressed: {
                        globalState.wallpaperPanelOpen = false;
                    }
                    
                    Keys.onUpPressed: {
                        if (currentIndex < columns) {
                            searchInput.forceActiveFocus();
                        } else {
                            moveCurrentIndexUp();
                        }
                    }
                    
                    // Minimal scrollbar
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 6
                        anchors.right: parent.right
                        anchors.rightMargin: 2
                        
                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 
                                parent.pressed ? 0.4 : parent.hovered ? 0.3 : 0.2)
                            
                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                        }
                        
                        background: Rectangle {
                            color: "transparent"
                        }
                    }
                    
                    // Optimized delegate with minimal animations
                    delegate: Item {
                        id: delegateRoot
                        width: wallpaperGrid.cellWidth
                        height: wallpaperGrid.cellHeight
                        
                        required property string modelData
                        required property int index
                        
                        property string wallpaperPath: modelData
                        property string filename: wallpaperPath.split('/').pop()
                        property bool isSelected: (wallpaperPath === currentWallpaper)
                        property bool isCurrent: (wallpaperGrid.currentIndex === index)
                        
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 10
                            radius: 8
                            color: "transparent"
                            clip: true
                            
                            // Simple background - no animations
                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: {
                                    if (isSelected) return Qt.rgba(theme.green.r, theme.green.g, theme.green.b, 0.08)
                                    if (isCurrent) return Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.08)
                                    if (hoverArea.containsMouse) return Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.04)
                                    return "transparent"
                                }
                            }
                            
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 6
                                
                                // Image container
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 6
                                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.03)
                                    clip: true
                                    
                                    border.color: {
                                        if (isSelected) return theme.green
                                        if (isCurrent) return theme.purple
                                        return Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)
                                    }
                                    border.width: (isSelected || isCurrent) ? 2 : 1
                                    
                                    // Optimized image loading
                                    Image {
                                        id: wallpaperImage
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        source: "file://" + wallpaperPath
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        smooth: false  // Faster rendering
                                        cache: true
                                        sourceSize.width: 400  // Downsample for performance
                                        sourceSize.height: 300
                                        
                                        // Simple loading indicator
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 32
                                            height: 32
                                            radius: 16
                                            color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.8)
                                            visible: wallpaperImage.status === Image.Loading
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "󰔟"
                                                font.family: "Symbols Nerd Font"
                                                font.pixelSize: 18
                                                color: theme.purple
                                            }
                                        }
                                        
                                        // Error state
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 32
                                            height: 32
                                            radius: 16
                                            color: Qt.rgba(theme.red.r, theme.red.g, theme.red.b, 0.1)
                                            visible: wallpaperImage.status === Image.Error
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: ""
                                                font.family: "Symbols Nerd Font"
                                                font.pixelSize: 16
                                                color: theme.red
                                            }
                                        }
                                    }
                                    
                                    // Selected checkmark
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 6
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: theme.green
                                        visible: isSelected
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: ""
                                            font.family: "Symbols Nerd Font"
                                            font.pixelSize: 14
                                            color: "white"
                                        }
                                    }
                                }
                                
                                // Filename
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    text: filename
                                    color: theme.fg
                                    font.pixelSize: 11
                                    elide: Text.ElideMiddle
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                }
                            }
                            
                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    wallpaperGrid.currentIndex = index;
                                    var screenName = Quickshell.screens[currentScreenIndex] ? Quickshell.screens[currentScreenIndex].name : undefined;
                                    WallpaperService.changeWallpaper(wallpaperPath, screenName);
                                    globalState.wallpaperPanelOpen = false;
                                }
                            }
                        }
                    }
                    
                    // Empty state
                    Item {
                        anchors.fill: parent
                        visible: filteredWallpapers.length === 0 && !WallpaperService.scanning
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 16
                            
                            Text {
                                text: ""
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 64
                                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.2)
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: filterText ? "No matching wallpapers" : "No wallpapers found"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                color: theme.fg
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: filterText ? "Try a different search term" : "Add images to " + wallpaperPath
                                font.pixelSize: 12
                                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6)
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Scanning state
                    Item {
                        anchors.fill: parent
                        visible: WallpaperService.scanning
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 16
                            
                            Text {
                                text: "󰔟"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 48
                                color: theme.purple
                                Layout.alignment: Qt.AlignHCenter
                                
                                SequentialAnimation on rotation {
                                    running: WallpaperService.scanning
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0; to: 360; duration: 1000 }
                                }
                            }
                            
                            Text {
                                text: "Scanning wallpapers..."
                                font.pixelSize: 14
                                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.7)
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}