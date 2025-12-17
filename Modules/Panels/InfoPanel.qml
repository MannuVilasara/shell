import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Core

PanelWindow {
    id: root
    
    required property var globalState
    
    anchors { top: true; left: true; right: true; bottom: true }
    visible: globalState.infoPanelOpen
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "info-panel"
    WlrLayershell.exclusiveZone: -1
    
    color: "transparent"
    
    Colors { id: theme }
    
    // --- 1. Backdrop Dimmer ---
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, globalState.infoPanelOpen ? 0.5 : 0)
        opacity: globalState.infoPanelOpen ? 1 : 0
        
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
    }
    
    // --- Click outside to close ---
    MouseArea {
        anchors.fill: parent
        enabled: globalState.infoPanelOpen
        onClicked: globalState.infoPanelOpen = false
        z: 0
    }
    
    // --- 2. Main Glass Panel Container ---
    Rectangle {
        id: panelContent
        z: 1
        
        // Premium Entrance Animation: Slide + Springy Bounce
        x: globalState.infoPanelOpen ? 20 : -500 // Start off-screen
        anchors.verticalCenter: parent.verticalCenter // Center vertically
        
        width: 440 // Slightly wider
        height: 800 // Slightly taller
        
        // Deep Glass Aesthetic
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.94)
        radius: 36 // More rounded corners
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 2
        
        clip: true
        
        opacity: globalState.infoPanelOpen ? 1 : 0
        scale: globalState.infoPanelOpen ? 1 : 0.85
        
        // Spring Easing for entrance
        Behavior on x { NumberAnimation { duration: 700; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
        Behavior on opacity { NumberAnimation { duration: 400 } }
        Behavior on scale { NumberAnimation { duration: 700; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }

        // --- Prevent clicks from propagating to the background dimmer area ---
        MouseArea { anchors.fill: parent; onClicked: {} }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20
            
            // --- 3. Staggered Header ---
            RowLayout {
                id: header
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                spacing: 15

                // Staggered fade and slide down
                opacity: globalState.infoPanelOpen ? 1 : 0
                Layout.topMargin: globalState.infoPanelOpen ? 0 : 30
                
                Behavior on opacity { NumberAnimation { duration: 500 } } 
                Behavior on Layout.topMargin { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
                
                // Bongo Cat Avatar (FIXED: Removed MultiEffect, uses high-contrast colors)
                Rectangle {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    radius: 20
                    color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.25) // Brighter background
                    border.color: theme.purple
                    border.width: 1.5
                    clip: true
                    
                    // Removed: layer.effect: MultiEffect {...} which was causing the error
                    
                    AnimatedImage {
                        anchors.fill: parent
                        source: "../../public/bongo-cat-transparent.gif"
                        fillMode: Image.PreserveAspectFit
                        playing: globalState.infoPanelOpen
                    }
                }
                
                // Greeting Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    Text {
                        text: "Hello, Admin! 👋"
                        color: theme.fg
                        font.pixelSize: 18
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        font.letterSpacing: -0.5
                    }
                    
                    Text {
                        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.65)
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
                
                // Live Clock
                Text {
                    text: Qt.formatTime(new Date(), "hh:mm AP")
                    color: theme.green
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                    font.bold: true
                }
            }
            
            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1.5
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                radius: 0.75
            }
            
            // --- 4. Animated Navigation Tabs (Pill Style) ---
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                spacing: 8
                
                // Staggered fade in
                opacity: globalState.infoPanelOpen ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 500 } }

                Repeater {
                    model: [
                        { icon: "󰃰", name: "Home" },
                        { icon: "󰝚", name: "Music" },
                        { icon: "󰖐", name: "Weather" },
                        { icon: "󰍛", name: "System" },
                    ]
                    
                    Rectangle {
                        required property int index
                        required property var modelData
                        
                        property bool isActive: contentStack.currentIndex === index
                        
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: 14
                        
                        // Active color transition
                        color: isActive ? 
                               theme.purple : 
                               tabArea.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1) :
                               "transparent"
                        
                        border.color: isActive ? theme.purple : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.15)
                        border.width: isActive ? 2 : 1.5
                        
                        // Hover/Press feedback
                        scale: tabArea.pressed ? 0.95 : tabArea.containsMouse ? 1.05 : 1.0
                        
                        Behavior on color { ColorAnimation { duration: 250 } }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: modelData.icon
                                color: isActive ? theme.bg : theme.purple
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 18
                            }
                            
                            Text {
                                text: modelData.name
                                color: isActive ? theme.bg : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.8)
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                        
                        MouseArea {
                            id: tabArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: contentStack.currentIndex = index
                        }
                    }
                }
            }
            
            // --- 5. Content Stack ---
            StackLayout {
                id: contentStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0
                
                CalendarTab { theme: theme }
                MusicTab { theme: theme }
                WeatherTab { theme: theme }
                SystemTab { theme: theme }
                
                // Transition for content changes
                states: [
                    State {
                        name: "loaded"; when: true
                        PropertyChanges { target: contentStack.currentItem; opacity: 1; y: 0 }
                    }
                ]
                transitions: [
                    Transition {
                        from: "*"; to: "loaded"
                        SequentialAnimation {
                            PropertyAnimation { target: contentStack.currentTransitionItem; property: "opacity"; to: 0; duration: 100 }
                            
                            ParallelAnimation {
                                PropertyAnimation { target: contentStack.currentItem; property: "opacity"; to: 1; duration: 400 }
                                PropertyAnimation { target: contentStack.currentItem; property: "y"; from: 20; to: 0; duration: 400; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                ]
            }
        }
    }
    
    // --- COMPONENT: Calendar Tab (Home/Calendar View) ---
    component CalendarTab: Item {
        required property var theme
        ColumnLayout {
            anchors.fill: parent; spacing: 12
            
            // Current Date Display (Retained)
            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.15) }
                    GradientStop { position: 1.0; color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.1) }
                }
                border.color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.22)
                border.width: 1.5
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 3
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "dddd")
                        color: theme.purple
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "MMMM d, yyyy")
                        color: theme.fg
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }

            // Calendar Grid Container
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true; radius: 18
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.05)
                border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 12
                    
                    // Month Navigation (Simplified)
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: Qt.formatDate(new Date(), "MMMM yyyy")
                            color: theme.fg; font.pixelSize: 18; font.bold: true
                        }
                    }
                    
                    // Day Headers
                    GridLayout {
                        Layout.fillWidth: true; columns: 7; rowSpacing: 5; columnSpacing: 5
                        Repeater {
                            model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                            Text {
                                Layout.fillWidth: true; text: modelData
                                font.pixelSize: 11; font.bold: true
                                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.5)
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                    
                    // Calendar Days
                    GridLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true; columns: 7; rowSpacing: 8; columnSpacing: 8
                        Repeater {
                            model: 35
                            Rectangle {
                                required property int index
                                Layout.fillWidth: true; Layout.fillHeight: true; radius: 10
                                
                                property int dayNumber: {
                                    var today = new Date()
                                    var firstDay = new Date(today.getFullYear(), today.getMonth(), 1)
                                    var startDay = firstDay.getDay()
                                    return index - startDay + 1
                                }
                                
                                property bool isCurrentMonth: dayNumber > 0 && dayNumber <= new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).getDate()
                                property bool isToday: isCurrentMonth && dayNumber === new Date().getDate()
                                
                                color: isToday ? theme.purple : 
                                       dayArea.containsMouse && isCurrentMonth ? Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.15) : 
                                       "transparent"
                                
                                // Enhanced Press Effect
                                scale: dayArea.pressed && isCurrentMonth ? 0.85 : 1.0
                                
                                Behavior on color { ColorAnimation { duration: 180 } }
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: isCurrentMonth ? dayNumber : ""
                                    font.pixelSize: 14; font.bold: isToday
                                    color: isToday ? theme.bg : isCurrentMonth ? theme.fg : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.3)
                                }
                                
                                MouseArea {
                                    id: dayArea
                                    anchors.fill: parent
                                    hoverEnabled: isCurrentMonth
                                    cursorShape: isCurrentMonth ? Qt.PointingHandCursor : Qt.ArrowCursor
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // --- COMPONENT: Music Tab (Animated Vinyl & Visualizer) ---
    component MusicTab: Item {
        required property var theme
        ColumnLayout {
            anchors.fill: parent; spacing: 25
            Item { Layout.fillHeight: true; Layout.preferredHeight: 20 }
            
            // Animated Vinyl Record
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 280; height: 280; radius: 140
                color: "#111111" // Dark vinyl color
                border.color: theme.purple; border.width: 4
                
                // Inner center with visualizer
                Rectangle {
                    anchors.centerIn: parent; width: 100; height: 100; radius: 50
                    color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.9);
                    border.color: theme.purple; border.width: 2
                    
                    Text { anchors.centerIn: parent; text: "󰝚"; font.pixelSize: 36; color: theme.purple; opacity: 0.8 }

                    // Animated Visualizer Bars
                    Row {
                        anchors.centerIn: parent; spacing: 4
                        Repeater {
                            model: 12
                            Rectangle {
                                width: 4; height: 20; radius: 2; color: theme.purple; opacity: 0.7
                                SequentialAnimation on height {
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 10; to: 60; duration: 400 + index*40; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 60; to: 10; duration: 400 + index*40; easing.type: Easing.InOutSine }
                                }
                            }
                        }
                    }
                }

                // Spinning Animation
                RotationAnimation on rotation {
                    from: 0; to: 360; duration: 12000; loops: Animation.Infinite; running: true
                }
            }
            
            // Song Info
            ColumnLayout {
                Layout.fillWidth: true; spacing: 4; Layout.alignment: Qt.AlignHCenter
                Text { text: "Dream State"; color: theme.fg; font.pixelSize: 20; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                Text { text: "Lofi Beats Study Session"; color: theme.purple; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter }
            }
            
            // Progress Bar (with dynamic width simulation)
            ColumnLayout {
                Layout.fillWidth: true; spacing: 6
                Rectangle {
                    Layout.fillWidth: true; height: 6; radius: 3; color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                    Rectangle {
                        width: parent.width * 0.45 // Simulated progress
                        height: parent.height; radius: parent.radius; color: theme.purple
                        Behavior on width { NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad } }
                        // Simulate progress moving
                        SequentialAnimation on width {
                            loops: Animation.Infinite
                            running: true
                            NumberAnimation { from: parent.width * 0.45; to: parent.width * 0.46; duration: 2000 }
                            NumberAnimation { from: parent.width * 0.46; to: parent.width * 0.45; duration: 2000 }
                        }
                    }
                }
            }

            // Controls with Hover Lift
            RowLayout {
                Layout.alignment: Qt.AlignHCenter; spacing: 30
                Repeater {
                    model: [ { i: "󰒮", s: 26 }, { i: "󰐊", s: 36 }, { i: "󰒭", s: 26 } ]
                    Rectangle {
                        property bool isPlayButton: index === 1
                        width: isPlayButton ? 70 : 54; height: width; radius: width/2
                        color: isPlayButton ? theme.purple : ma.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.15) : "transparent"
                        border.color: isPlayButton ? "transparent" : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.2)
                        border.width: 1.5
                        
                        scale: ma.pressed ? 0.9 : ma.containsMouse ? 1.1 : 1.0
                        
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.i; font.family: "Symbols Nerd Font"
                            font.pixelSize: modelData.s; color: isPlayButton ? theme.bg : theme.fg
                        }
                        
                        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                    }
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
    
    // --- COMPONENT: Weather Tab ---
    component WeatherTab: Item {
        required property var theme
        ColumnLayout {
            anchors.fill: parent; spacing: 18
            
            // Current Weather Card
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 120; radius: 20
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.25) }
                    GradientStop { position: 1.0; color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.2) }
                }
                border.color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.35)
                border.width: 1.5
                
                RowLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 18
                    
                    Text {
                        text: "󰖐"
                        font.family: "Symbols Nerd Font"; font.pixelSize: 60
                        color: theme.fg
                        // Continuous, subtle swaying animation
                        SequentialAnimation on rotation {
                            running: true; loops: Animation.Infinite
                            NumberAnimation { from: -8; to: 8; duration: 2500; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 8; to: -8; duration: 2500; easing.type: Easing.InOutQuad }
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "24°C"
                            color: theme.fg
                            font.pixelSize: 32
                            font.bold: true
                        }
                        
                        Text {
                            text: "Partly Cloudy"
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.8)
                            font.pixelSize: 14
                        }
                        
                        Text {
                            text: "📍 Your Location"
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6)
                            font.pixelSize: 12
                        }
                    }
                }
            }
            
            // Weather Details Grid
            GridLayout {
                Layout.fillWidth: true; columns: 2; rowSpacing: 12; columnSpacing: 12
                
                Repeater {
                    model: [
                        { icon: "󰖎", label: "Humidity", value: "45%" },
                        { icon: "󰖝", label: "Wind", value: "12 km/h" },
                        { icon: "󰖒", label: "Pressure", value: "1012 hPa" },
                        { icon: "󰖕", label: "UV Index", value: "Moderate" }
                    ]
                    
                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true; height: 75; radius: 16
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.05)
                        border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 12; spacing: 10
                            
                            Text {
                                text: modelData.icon; font.family: "Symbols Nerd Font"
                                font.pixelSize: 30; color: theme.purple
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                
                                Text {
                                    text: modelData.label; font.pixelSize: 11
                                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6)
                                }
                                
                                Text {
                                    text: modelData.value; font.pixelSize: 16; font.bold: true
                                    color: theme.fg
                                }
                            }
                        }
                    }
                }
            }
            
            // 5-Day Forecast
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true; radius: 18
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.05)
                border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 14; spacing: 8
                    
                    Text { text: "5-Day Forecast"; font.pixelSize: 16; font.bold: true; color: theme.fg }
                    
                    Repeater {
                        model: [
                            { day: "Mon", icon: "󰖐", low: "18°", high: "24°" },
                            { day: "Tue", icon: "󰖕", low: "19°", high: "25°" },
                            { day: "Wed", icon: "󰖑", low: "17°", high: "22°" },
                            { day: "Thu", icon: "󰖐", low: "20°", high: "26°" },
                            { day: "Fri", icon: "󰖎", low: "18°", high: "23°" }
                        ]
                        
                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            Layout.maximumHeight: 36
                            radius: 10
                            color: forecastArea.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08) : "transparent"
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 10
                                
                                Text { Layout.preferredWidth: 40; text: modelData.day; font.pixelSize: 14; color: theme.fg }
                                
                                Text { text: modelData.icon; font.family: "Symbols Nerd Font"; font.pixelSize: 20; color: theme.purple }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text { text: modelData.low; font.pixelSize: 12; color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6) }
                                
                                Text { text: modelData.high; font.pixelSize: 14; font.bold: true; color: theme.fg }
                            }
                            
                            MouseArea {
                                id: forecastArea
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    }
    
    // --- COMPONENT: System Tab (Animated Progress Bars) ---
    component SystemTab: Item {
        required property var theme
        
        ColumnLayout {
            anchors.fill: parent; spacing: 18
            
            // System Status Card 
            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.15) }
                    GradientStop { position: 1.0; color: Qt.rgba(theme.green.r, theme.green.g, theme.green.b, 0.1) }
                }
                border.color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.22)
                border.width: 1.5
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "System Status"
                            font.pixelSize: 16
                            font.bold: true
                            color: theme.fg
                        }
                        
                        Text {
                            text: "Everything running smoothly!"
                            font.pixelSize: 13
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.7)
                        }
                        
                        RowLayout {
                            spacing: 6
                            
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: theme.green
                                
                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1.0; to: 0.3; duration: 1000 }
                                    NumberAnimation { from: 0.3; to: 1.0; duration: 1000 }
                                }
                            }
                            
                            Text {
                                text: "All systems operational"
                                font.pixelSize: 12
                                color: theme.green
                                font.bold: true
                            }
                        }
                    }
                }
            }
            
            // System Stats Grid (Enhanced with Continuous Progress Animation)
            GridLayout {
                Layout.fillWidth: true; columns: 2; rowSpacing: 12; columnSpacing: 12
                
                Repeater {
                    model: [
                        { icon: "󰻠", label: "CPU Usage", progress: 0.45, color: theme.blue, value: "45%" },
                        { icon: "󰍛", label: "Memory", progress: 0.62, color: theme.purple, value: "8.2 GB" },
                        { icon: "󰋊", label: "Disk", progress: 0.78, color: theme.green, value: "234 GB" },
                        { icon: "󰓅", label: "Network", progress: 0.35, color: theme.yellow, value: "12 MB/s" }
                    ]
                    
                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true; height: 100; radius: 16
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.05)
                        border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                        border.width: 1
                        
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 14; spacing: 8
                            
                            RowLayout {
                                Layout.fillWidth: true; spacing: 8
                                Text {
                                    text: modelData.icon; font.family: "Symbols Nerd Font"
                                    font.pixelSize: 24; color: modelData.color
                                }
                                Text {
                                    Layout.fillWidth: true; text: modelData.label
                                    font.pixelSize: 12; font.bold: true
                                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.7)
                                }
                            }
                            
                            Text {
                                text: modelData.value; font.pixelSize: 16; font.bold: true; color: theme.fg
                            }
                            
                            // Animated Progress Bar
                            Rectangle {
                                Layout.fillWidth: true; height: 6; radius: 3
                                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                                
                                Rectangle {
                                    id: progressBar
                                    height: parent.height; radius: parent.radius
                                    color: modelData.color
                                    
                                    // Simulated continuous/live update
                                    property real targetWidth: parent.width * modelData.progress
                                    width: targetWidth
                                    
                                    Behavior on width { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
                                    
                                    // Subtle pulsing animation (for 'live' feel)
                                    SequentialAnimation on targetWidth {
                                        loops: Animation.Infinite
                                        running: true
                                        NumberAnimation { to: parent.width * (modelData.progress + 0.02); duration: 1500; easing.type: Easing.InOutQuad }
                                        NumberAnimation { to: parent.width * modelData.progress; duration: 1500; easing.type: Easing.InOutQuad }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Quick Actions (Enhanced with Hover Lift)
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true; radius: 18
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.05)
                border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 14; spacing: 10
                    
                    Text { text: "Quick Actions"; font.pixelSize: 16; font.bold: true; color: theme.fg }
                    
                    GridLayout {
                        Layout.fillWidth: true; columns: 2; rowSpacing: 10; columnSpacing: 10
                        
                        Repeater {
                            model: [
                                { icon: "󰐥", label: "Lock", color: theme.red },
                                { icon: "󰜉", label: "Power", color: theme.blue },
                                { icon: "󰁯", label: "Settings", color: theme.purple },
                                { icon: "󰌍", label: "Terminal", color: theme.green }
                            ]
                            
                            Rectangle {
                                required property var modelData
                                Layout.fillWidth: true; height: 50; radius: 12
                                color: actionArea.containsMouse ? Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.15) : "transparent"
                                border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.15)
                                border.width: 1.5
                                
                                // Hover Lift Effect
                                scale: actionArea.pressed ? 0.95 : actionArea.containsMouse ? 1.03 : 1.0
                                
                                Behavior on color { ColorAnimation { duration: 170 } }
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                                
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 12; spacing: 10
                                    
                                    Text {
                                        text: modelData.icon; font.family: "Symbols Nerd Font"
                                        font.pixelSize: 22; color: modelData.color
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true; text: modelData.label
                                        font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; color: theme.fg
                                    }
                                }
                                
                                MouseArea {
                                    id: actionArea
                                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- NEW COMPONENT: Notes Tab (Simple To-Do List) ---
    // component NotesTab: Item {
    //     required property var theme
        
    //     // Mock State for To-Do List
    //     ListModel {
    //         id: todoModel
    //         ListElement { task: "Fix QML transition bugs"; done: true }
    //         ListElement { task: "Review latest Git commits"; done: false }
    //         ListElement { task: "Deploy new quickshell panel"; done: false }
    //         ListElement { task: "Buy more bongo snacks"; done: true }
    //         ListElement { task: "Integrate more system metrics"; done: false }
    //         ListElement { task: "Design better weather forecast cards"; done: false }
    //     }
        
    //     // ColumnLayout {
    //     //     anchors.fill: parent; spacing: 18
            
    //     //     Text { text: "Focus Tasks"; font.pixelSize: 20; font.bold: true; color: theme.fg }

    //     //     // // To-Do List Area
    //     //     // Rectangle {
    //     //     //     Layout.fillWidth: true; Layout.fillHeight: true; radius: 18
    //     //     //     color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.05)
    //     //     //     border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
    //     //     //     border.width: 1
                
    //     //     //     Flickable {
    //     //     //         anchors.fill: parent; anchors.margins: 12
    //     //     //         contentHeight: listContent.implicitHeight
    //     //     //         clip: true
                    
    //     //     //         ColumnLayout {
    //     //     //             id: listContent
    //     //     //             Layout.fillWidth: true; spacing: 12
                        
    //     //     //             Repeater {
    //     //     //                 model: todoModel
                            
    //     //     //                 Rectangle {
    //     //     //                     required property int index
    //     //     //                     required property var model
                                
    //     //     //                     Layout.fillWidth: true; height: 55; radius: 14
    //     //     //                     color: ma.containsMouse ? Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.1) : 
    //     //     //                            model.done ? Qt.rgba(theme.green.r, theme.green.g, theme.green.b, 0.08) : "transparent"
    //     //     //                     border.color: model.done ? theme.green : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.15)
    //     //     //                     border.width: 1.5
                                
    //     //     //                     Behavior on color { ColorAnimation { duration: 150 } }

    //     //     //                     RowLayout {
    //     //     //                         anchors.fill: parent; anchors.margins: 10
    //     //     //                         spacing: 12
                                    
    //     //     //                         // Status Circle/Icon
    //     //     //                         Text {
    //     //     //                             text: model.done ? "✓" : "○"
    //     //     //                             font.pixelSize: 22
    //     //     //                             font.family: "Symbols Nerd Font"
    //     //     //                             color: model.done ? theme.green : theme.purple
    //     //     //                         }
                                    
    //     //     //                         Text {
    //     //     //                             Layout.fillWidth: true
    //     //     //                             font.pixelSize: 15
    //     //     //                             font.bold: true
    //     //     //                             color: model.done ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.5) : theme.fg
    //     //     //                             // Strikethrough effect
    //     //     //                             textFormat: Text.RichText
    //     //     //                             // FIX: Ensure 'text' property is set only once
    //     //     //                             text: model.done ? "<s>" + model.task + "</s>" : model.task
    //     //     //                         }
                                    
    //     //     //                         // Delete/Close Icon
    //     //     //                         Text {
    //     //     //                             text: "󰅙"
    //     //     //                             font.family: "Symbols Nerd Font"
    //     //     //                             font.pixelSize: 16
    //     //     //                             color: ma.containsMouse ? theme.red : Qt.rgba(theme.red.r, theme.red.g, theme.red.b, 0.6)
    //     //     //                             opacity: ma.containsMouse ? 1 : 0.5
    //     //     //                             Behavior on opacity { NumberAnimation { duration: 150 } }
    //     //     //                             MouseArea {
    //     //     //                                 anchors.fill: parent
    //     //     //                                 onClicked: todoModel.remove(index)
    //     //     //                             }
    //     //     //                         }
    //     //     //                     }
                                
    //     //     //                     MouseArea {
    //     //     //                         id: ma
    //     //     //                         anchors.fill: parent
    //     //     //                         hoverEnabled: true
    //     //     //                         cursorShape: Qt.PointingHandCursor
    //     //     //                         onClicked: {
    //     //     //                             // Toggle completion status if not clicking the delete button area
    //     //     //                             if (mouse.x < parent.width - 40) {
    //     //     //                                 todoModel.set(index, "done", !model.done)
    //     //     //                             }
    //     //     //                         }
    //     //     //                     }
    //     //     //                 }
    //     //     //             }
    //     //     //         }
    //     //     //     }
    //     //     // }
    //     // }
    // }
}