import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import qs.Core
import qs.Services
import qs.Widgets
import Qt5Compat.GraphicalEffects

Rectangle {
    id: barRoot

    required property Colors colors
    required property string fontFamily
    required property int fontSize
    required property string kernelVersion
    required property int cpuUsage
    required property int memUsage
    required property int diskUsage
    required property int volumeLevel
    required property string activeWindow
    required property string currentLayout
    required property string time
    property bool floating: true
    

    property bool trayOpen: false

    property var volumeService
    property var networkService
    property var globalState
    

    property var battery: UPower.displayDevice
    property real batteryPercent: battery && battery.percentage !== undefined ? battery.percentage * 100 : 0
    property bool batteryCharging: battery && battery.state === UPowerDeviceState.Charging
    property bool batteryFull: battery && battery.state === UPowerDeviceState.FullyCharged
    property bool batteryReady: battery && battery.ready && battery.percentage !== undefined

    anchors.fill: parent
    color: colors.bg
    radius: floating ? 12 : 0
    border.color: colors.muted
    border.width: floating ? 1 : 0

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: colors.muted
        visible: !parent.floating
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        // 1. Logo
        Rectangle {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: height / 2
            color: "transparent"

            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: "../../Assets/arch.svg"
                fillMode: Image.PreserveAspectFit
                opacity: 0.9
            }
        }

        VerticalDivider { }

        // 2. Workspace Switcher
        Rectangle {
            id: wsContainer

            Layout.preferredWidth: 150
            Layout.preferredHeight: 26
            color: Qt.rgba(0, 0, 0, 0.2)
            radius: height / 2
            clip: true

            MouseArea {
                anchors.fill: parent
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0)
                        Hyprland.dispatch("workspace -1");
                    else
                        Hyprland.dispatch("workspace +1");
                }
            }

            ListView {
                id: wsList

                anchors.fill: parent
                orientation: ListView.Horizontal
                spacing: 4
                interactive: false
                currentIndex: (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id - 1 : 0)
                model: 999

                delegate: Item {
                    property int wsIndex: index + 1
                    property var workspace: Hyprland.workspaces.values.find((ws) => {
                        return ws.id === wsIndex;
                    }) ?? null
                    property bool isActive: wsList.currentIndex === index
                    property bool hasWindows: workspace !== null

                    height: wsList.height
                    width: indicator.width

                    Rectangle {
                        id: indicator

                        anchors.centerIn: parent
                        height: 16
                        width: parent.isActive ? 32 : 16
                        radius: height / 2
                        color: (parent.isActive || parent.hasWindows) ? colors.accent : "transparent"
                        border.color: (!parent.isActive && !parent.hasWindows) ? colors.muted : "transparent"
                        border.width: (!parent.isActive && !parent.hasWindows) ? 2 : 0

                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.2
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Hyprland.dispatch("workspace " + parent.wsIndex)
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        VerticalDivider { }

        // 3. Keyboard Layout
        Text {
            text: currentLayout
            color: colors.fg
            font.pixelSize: fontSize - 2
            font.family: fontFamily
            font.bold: true
            opacity: 0.7
        }

        VerticalDivider { }

        // 4. Unique Music Widget (Spinning Vinyl)
        Rectangle {
            id: mediaWidget

            property bool showInfo: false
            property bool hasMedia: MprisService.title !== ""
            property real componentsOpacity: showInfo ? 1 : 0
            
            Layout.preferredHeight: 28 // Slightly taller for better look
            Layout.preferredWidth: showInfo ? Math.min(mediaContent.implicitWidth + 36, 300) : 28
            radius: 14 // Fully rounded
            
            color: showInfo ? Qt.rgba(0, 0, 0, 0.4) : "transparent"
            border.color: colors.accent
            border.width: (showInfo || MprisService.isPlaying) ? 1 : 0
            clip: true

            Behavior on Layout.preferredWidth { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on border.width { NumberAnimation { duration: 200 } }

            // Interaction Handler
            MouseArea {
                id: mediaMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        globalState.requestInfoPanelTab(1)
                    } else if (mouse.button === Qt.RightButton) {
                        parent.showInfo = !parent.showInfo
                    }
                }
            }

            // 1. Spinning Vinyl (Art)
            Item {
                id: vinylContainer
                
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                
                // Rotation Logic
                RotationAnimation on rotation {
                    from: 0; to: 360
                    duration: 4000
                    loops: Animation.Infinite
                    running: MprisService.isPlaying
                }

                // Art Ring
                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "#1a1a1a"
                    border.color: colors.accent
                    border.width: 1
                    
                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: MprisService.artUrl !== "" ? MprisService.artUrl : "../../Assets/arch.svg" // Fallback
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: 20; height: 20; radius: 10
                            }
                        }
                    }
                    
                    // Center hole
                    Rectangle {
                        width: 6; height: 6
                        radius: 3
                        color: "#2a2a2a"
                        anchors.centerIn: parent
                        border.color: "#000000"
                        border.width: 1
                    }
                }
            }

            // 2. Expanded Content
            RowLayout {
                id: mediaContent
                
                anchors.left: vinylContainer.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
                
                opacity: mediaWidget.componentsOpacity
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                // Info (Single Line)
                Text {
                    text: {
                        let t = MprisService.title !== "" ? MprisService.title : "No Media";
                        let a = MprisService.artist;
                        if (a !== "" && a !== "Unknown Artist") return t + " • " + a;
                        return t;
                    }
                    font.family: fontFamily
                    font.pixelSize: fontSize - 1
                    font.bold: true
                    color: colors.fg
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.maximumWidth: 160
                    Layout.alignment: Qt.AlignVCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Item { Layout.fillWidth: true }

        // 5. Active Window Title
        InfoPill {
            visible: activeWindow !== ""
            Layout.maximumWidth: 400
            border.width: 0
            color: Qt.rgba(0, 0, 0, 0.2)

            Text {
                text: activeWindow
                color: colors.fg
                font.pixelSize: fontSize - 1
                font.family: fontFamily
                font.bold: true
                elide: Text.ElideMiddle
                Layout.maximumWidth: 360
            }
        }

        Item { Layout.fillWidth: true }

        
        RowLayout {
            visible: SystemTray.items.values.length > 0
            spacing: 2 

            
            Rectangle {
                clip: true
                height: 26
                radius: height / 2
                color: Qt.rgba(0, 0, 0, 0.2) 
                border.color: colors.muted
                border.width: 1

                
                Layout.preferredWidth: trayOpen ? (trayInner.implicitWidth + 16) : 0
                Layout.rightMargin: trayOpen ? 4 : 0
                opacity: trayOpen ? 1 : 0


                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 350; easing.type: Easing.OutQuart }
                }
                Behavior on Layout.rightMargin {
                    NumberAnimation { duration: 350; easing.type: Easing.OutQuart }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }


                RowLayout {
                    id: trayInner
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Tray {
                        borderColor: "transparent" 
                        itemHoverColor: colors.accent
                        iconSize: 16
                    }
                }
            }


            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: height / 2
                color: trayOpen ? colors.accent : "transparent"
                border.color: colors.muted
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "" 
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: trayOpen ? colors.bg : colors.fg
                    

                    rotation: trayOpen ? 180 : 0 
                    Behavior on rotation {
                        NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                    }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: barRoot.trayOpen = !barRoot.trayOpen
                    
                    onEntered: parent.border.color = colors.accent
                    onExited: parent.border.color = colors.muted
                }
                
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }
            }
        }

        VerticalDivider { 
            visible: SystemTray.items.values.length > 0 
        }

        // 6. System Stats
        InfoPill {
            RowLayout {
                spacing: 6

                Text {
                    text: ""
                    color: colors.blue
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: fontSize + 2
                    Layout.alignment: Qt.AlignBaseline
                }

                Text {
                    id: tCpu
                    text: cpuUsage + "%"
                    color: colors.fg
                    font.pixelSize: fontSize - 1
                    font.family: fontFamily
                    Layout.alignment: Qt.AlignBaseline
                }
            }

            VerticalDivider { Layout.preferredHeight: 10 }

            RowLayout {
                spacing: 6

                Text {
                    text: ""
                    color: colors.red
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: fontSize + 2
                    Layout.alignment: Qt.AlignBaseline
                }

                Text {
                    id: tRam
                    text: memUsage + "%"
                    color: colors.fg
                    font.pixelSize: fontSize - 1
                    font.family: fontFamily
                    Layout.alignment: Qt.AlignBaseline
                }
            }
        }

        // 7. Network
        InfoPill {
            visible: networkService

            RowLayout {
                spacing: 6

                Text {
                    text: networkService.wifiEnabled ? "󰖩" : "󰖪"
                    color: networkService.wifiEnabled ? colors.purple : colors.muted
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: fontSize + 2
                    Layout.alignment: Qt.AlignBaseline
                }

                Text {
                    id: tNet
                    text: networkService.wifiEnabled ? (networkService.active ? networkService.active.ssid : "Disconnected") : "Off"
                    color: colors.fg
                    font.pixelSize: fontSize - 1
                    font.family: fontFamily
                    font.bold: true
                    Layout.maximumWidth: 150
                    elide: Text.ElideRight
                    Layout.alignment: Qt.AlignBaseline
                }
            }

            TapHandler {
                onTapped: globalState.requestSidePanelMenu("wifi")
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }

        // 8. Volume
        InfoPill {
            RowLayout {
                spacing: 6

                Text {
                    text: volumeService ? volumeService.icon : "󰕾"
                    color: colors.yellow
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: fontSize + 2
                    Layout.alignment: Qt.AlignBaseline
                    Behavior on text { enabled: false }
                }

                Text {
                    id: tVol
                    text: (volumeService && volumeService.muted) ? "MUT" : (volumeLevel + "%")
                    color: (volumeService && volumeService.muted) ? colors.red : colors.fg
                    font.pixelSize: fontSize - 1
                    font.family: fontFamily
                    font.bold: true
                    Layout.alignment: Qt.AlignBaseline
                }
            }

            TapHandler {
                onTapped: {
                    if (volumeService) volumeService.toggleMute();
                }
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            WheelHandler {
                onWheel: (wheel) => {
                    if (!volumeService) return;
                    if (wheel.angleDelta.y > 0) volumeService.increaseVolume();
                    else volumeService.decreaseVolume();
                }
            }
        }

        // 9. Battery
        InfoPill {
            visible: batteryReady

            RowLayout {
                spacing: 6

                Text {
                    text: BatteryService.getIcon(batteryPercent, batteryCharging, batteryReady)
                    color: BatteryService.getStateColor(batteryPercent, batteryCharging, batteryFull)
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: fontSize + 2
                    Layout.alignment: Qt.AlignBaseline
                }

                Text {
                    text: Math.round(batteryPercent) + "%"
                    color: colors.fg
                    font.pixelSize: fontSize - 1
                    font.family: fontFamily
                    font.bold: true
                    Layout.alignment: Qt.AlignBaseline
                }
            }

            TapHandler {
                onTapped: {
                    console.log("Battery: " + Math.round(batteryPercent) + "% - " + 
                               (batteryCharging ? "Charging" : batteryFull ? "Full" : "Discharging"))
                    if (battery.timeToEmpty > 0) {
                        console.log("Time to empty: " + BatteryService.formatTime(battery.timeToEmpty))
                    }
                    if (battery.timeToFull > 0) {
                        console.log("Time to full: " + BatteryService.formatTime(battery.timeToFull))
                    }
                }
            }
        }

        // 10. Clock
        Rectangle {
            Layout.preferredHeight: 26
            Layout.preferredWidth: clockText.implicitWidth + 24
            radius: height / 2
            color: colors.accent

            Text {
                id: clockText
                anchors.centerIn: parent
                text: time
                color: colors.bg
                font.pixelSize: fontSize - 1
                font.family: fontFamily
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: globalState.toggleSettings()
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
            }
        }

        // 11. Power Menu
        Rectangle {
            Layout.preferredHeight: 26
            Layout.preferredWidth: 26
            radius: height / 2
            color: "transparent"
            border.color: colors.muted
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "⏻"
                font.pixelSize: 16
                font.family: "Symbols Nerd Font"
                color: colors.red
            }

            Process {
                id: powerMenuIpcProcess
                command: ["quickshell", "ipc", "-c", "mannu", "call", "powermenu", "toggle"]
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: parent.color = Qt.rgba(colors.red.r, colors.red.g, colors.red.b, 0.2)
                onExited: parent.color = "transparent"
                onClicked: powerMenuIpcProcess.running = true
            }
        }
    }


    component VerticalDivider: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 14
        Layout.alignment: Qt.AlignVCenter
        color: colors.muted
        opacity: 0.5
    }

    component InfoPill: Rectangle {
        default property alias content: innerLayout.data

        Layout.preferredHeight: 26
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: innerLayout.implicitWidth + 20
        radius: height / 2
        color: "transparent"
        border.color: colors.muted
        border.width: 1

        RowLayout {
            id: innerLayout
            anchors.centerIn: parent
            spacing: 8
        }
    }
}