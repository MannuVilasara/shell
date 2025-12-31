import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Core
import qs.Services
import Quickshell.Services.Notifications

WlSessionLockSurface {
    id: root

    required property var lock
    required property var pam
    required property var colors

    color: "black"

    // Animation properties
    property bool expanded: Config.disableLockAnimation
    property real expandedWidth: Math.min(width - 60, 920)
    property real expandedHeight: Math.min(height - 80, 480)
    property real collapsedSize: 120

    // Notifications
    ListModel { id: notifications }

    // Local system services (avoid Context singleton to prevent crashes)
    CpuService { id: cpuService }
    MemService { id: memService }

    NotificationServer {
        id: server
        bodySupported: true
        imageSupported: true
        onNotification: (n) => {
            n.tracked = true
            notifications.insert(0, {
                summary: n.summary || "Notification",
                body: n.body || "",
                appName: n.appName || "",
                appIcon: n.appIcon || "",
                time: Qt.formatTime(new Date(), "hh:mm")
            })
        }
    }

    // Background Container
    Item {
        id: bg
        anchors.fill: parent
        opacity: Config.disableLockAnimation ? 1 : 0

        // Blurred window preview background (Default)
        ScreencopyView {
            anchors.fill: parent
            // Only capture when this view is definitely visible to save resources
            captureSource: visible ? root.screen : null
            visible: !Config.lockScreenCustomBackground
            layer.enabled: visible && bg.opacity > 0 && !Config.disableLockBlur

            layer.effect: FastBlur {
                radius: 48
                transparentBorder: true
            }
        }


        // Wallpaper Background (Custom)
        Image {
            anchors.fill: parent
            source: Config.lockScreenCustomBackground ? ("file://" + WallpaperService.getWallpaper(root.screen.name)) : ""
            fillMode: Image.PreserveAspectCrop
            visible: Config.lockScreenCustomBackground
            
            layer.enabled: visible && bg.opacity > 0 && !Config.disableLockBlur
            layer.effect: FastBlur {
                radius: 48
                transparentBorder: true
            }
        }
    }

    // Dark overlay
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "#000000"
        opacity: Config.disableLockAnimation ? 0.45 : 0
    }

    // Morphing container - starts as lock icon, expands to bento grid
    Rectangle {
        id: morphContainer
        anchors.centerIn: parent
        
        // Animated dimensions
        width: root.expanded ? root.expandedWidth : root.collapsedSize
        height: root.expanded ? root.expandedHeight : root.collapsedSize
        
        color: Qt.rgba(root.colors.surface.r, root.colors.surface.g, root.colors.surface.b, 0.9)
        radius: root.expanded ? 20 : 30
        border.width: root.expanded ? 0 : 2
        border.color: root.colors.accent
        
        scale: Config.disableLockAnimation ? 1 : 0
        rotation: Config.disableLockAnimation ? 0 : -180
        
        Behavior on width {
            enabled: !Config.disableLockAnimation
            NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1.02 }
        }
        Behavior on height {
            enabled: !Config.disableLockAnimation
            NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1.02 }
        }
        Behavior on radius {
            enabled: !Config.disableLockAnimation
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        Behavior on border.width {
            enabled: !Config.disableLockAnimation
            NumberAnimation { duration: 200 }
        }

        // Lock icon (visible when collapsed)
        Text {
            id: lockIcon
            anchors.centerIn: parent
            text: "󰌾"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 48
            color: root.colors.accent
            opacity: root.expanded ? 0 : 1
            scale: root.expanded ? 0.5 : 1
            
            Behavior on opacity {
                enabled: !Config.disableLockAnimation
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            Behavior on scale {
                enabled: !Config.disableLockAnimation
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }

        // Bento grid content (visible when expanded)
        Item {
            id: bentoContent
            anchors.fill: parent
            anchors.margins: 12
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : 0.8
            
            Behavior on opacity {
                enabled: !Config.disableLockAnimation
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
            Behavior on scale {
                enabled: !Config.disableLockAnimation
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 12
                visible: root.expanded

                // LEFT COLUMN
                ColumnLayout {
                    Layout.preferredWidth: (parent.width - 24) * 0.30
                    Layout.fillHeight: true
                    spacing: 12

                    // Clock Card (Binary Clock - BCD Format)
                    BentoCard {
                        id: clockCard
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        cardColor: root.colors.surface
                        borderColor: root.colors.border

                        property int hours: new Date().getHours()
                        property int minutes: new Date().getMinutes()
                        property int seconds: new Date().getSeconds()

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: {
                                var now = new Date()
                                clockCard.hours = now.getHours()
                                clockCard.minutes = now.getMinutes()
                                clockCard.seconds = now.getSeconds()
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 16

                            // BCD Binary display (6 columns)
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 6

                                // Hours (H1: 2 bits, H2: 4 bits)
                                RowLayout {
                                    spacing: 4
                                    BinaryColumn { value: Math.floor(clockCard.hours / 10); bits: 2; dotSize: 10; activeColor: root.colors.accent }
                                    BinaryColumn { value: clockCard.hours % 10; bits: 4; dotSize: 10; activeColor: root.colors.accent }
                                }

                                // Separator
                                Rectangle { width: 2; height: 60; radius: 1; color: root.colors.border; opacity: 0.4 }

                                // Minutes (M1: 3 bits, M2: 4 bits)
                                RowLayout {
                                    spacing: 4
                                    BinaryColumn { value: Math.floor(clockCard.minutes / 10); bits: 3; dotSize: 10; activeColor: root.colors.secondary }
                                    BinaryColumn { value: clockCard.minutes % 10; bits: 4; dotSize: 10; activeColor: root.colors.secondary }
                                }

                                // Separator
                                Rectangle { width: 2; height: 60; radius: 1; color: root.colors.border; opacity: 0.4 }

                                // Seconds (S1: 3 bits, S2: 4 bits)
                                RowLayout {
                                    spacing: 4
                                    BinaryColumn { value: Math.floor(clockCard.seconds / 10); bits: 3; dotSize: 10; activeColor: root.colors.tertiary }
                                    BinaryColumn { value: clockCard.seconds % 10; bits: 4; dotSize: 10; activeColor: root.colors.tertiary }
                                }
                            }

                            // Digital time below
                            Text {
                                text: clockCard.hours.toString().padStart(2, '0') + ":" + clockCard.minutes.toString().padStart(2, '0') + ":" + clockCard.seconds.toString().padStart(2, '0')
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                font.family: "JetBrainsMono Nerd Font"
                                color: root.colors.fg
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // Date
                            Text {
                                text: Qt.formatDate(new Date(), "ddd, MMM d")
                                font.pixelSize: 11
                                color: root.colors.muted
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Music Card
                    BentoCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 130
                        cardColor: root.colors.surface
                        borderColor: root.colors.border
                        clip: true

                        // Blurred album art background
                        Image {
                            anchors.fill: parent
                            source: MprisService.artUrl
                            fillMode: Image.PreserveAspectCrop
                            visible: MprisService.artUrl !== ""
                            opacity: 0.2
                            layer.enabled: visible
                            layer.effect: FastBlur { radius: 32 }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                // Album art with rounded corners
                                Rectangle {
                                    Layout.preferredWidth: 64
                                    Layout.preferredHeight: 64
                                    radius: 12
                                    color: Qt.rgba(0, 0, 0, 0.3)
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: MprisService.artUrl
                                        fillMode: Image.PreserveAspectCrop
                                        visible: MprisService.artUrl !== ""
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰎈"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 28
                                        color: root.colors.muted
                                        visible: MprisService.artUrl === ""
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 2

                                    Item { Layout.fillHeight: true }

                                    Text {
                                        text: MprisService.title || "No Media Playing"
                                        color: root.colors.fg
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: MprisService.artist || "Unknown Artist"
                                        color: root.colors.muted
                                        font.pixelSize: 11
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Item { Layout.fillHeight: true }
                                }
                            }

                            // Playback controls centered
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 24

                                Text {
                                    text: "󰒮"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 18
                                    color: root.colors.fg
                                    opacity: 0.8

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -8
                                        onClicked: MprisService.previous()
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onEntered: parent.opacity = 1
                                        onExited: parent.opacity = 0.8
                                    }
                                }

                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 18
                                    color: root.colors.accent

                                    Text {
                                        anchors.centerIn: parent
                                        text: MprisService.isPlaying ? "󰏤" : "󰐊"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 18
                                        color: root.colors.bg
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: MprisService.playPause()
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }

                                Text {
                                    text: "󰒭"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 18
                                    color: root.colors.fg
                                    opacity: 0.8

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -8
                                        onClicked: MprisService.next()
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onEntered: parent.opacity = 1
                                        onExited: parent.opacity = 0.8
                                    }
                                }
                            }
                        }
                    }
                }

                // CENTER COLUMN
                ColumnLayout {
                    Layout.preferredWidth: (parent.width - 24) * 0.40
                    Layout.fillHeight: true
                    spacing: 12

                    // System Info Card (Neofetch)
                    BentoCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        cardColor: root.colors.surface
                        borderColor: root.colors.border

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 24

                            // Arch Logo
                            Text {
                                text: "󰣇"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 100
                                color: root.colors.accent
                            }

                            // System info column
                            ColumnLayout {
                                spacing: 5

                                // User@Host header
                                Text {
                                    text: Quickshell.env("USER") + "@archbtw"
                                    font.weight: Font.Bold
                                    font.pixelSize: 16
                                    color: root.colors.accent
                                    font.family: "JetBrainsMono Nerd Font"
                                    Layout.bottomMargin: 4
                                }

                                // Separator line
                                Rectangle {
                                    Layout.preferredWidth: 180
                                    Layout.preferredHeight: 2
                                    color: root.colors.subtext
                                    opacity: 0.4
                                    Layout.bottomMargin: 4
                                }

                                // System info rows
                                Repeater {
                                    model: [
                                        { label: "OS", value: "Arch Linux", icon: "", color: root.colors.blue },
                                        { label: "Host", value: "archbtw", icon: "", color: root.colors.purple },
                                        { label: "Kernel", value: "6.18.2-arch2-1", icon: "", color: root.colors.green },
                                        { label: "Uptime", value: "3 hours", icon: "", color: root.colors.yellow },
                                        { label: "Shell", value: "zsh", icon: "", color: root.colors.orange },
                                        { label: "WM", value: "Hyprland", icon: "", color: root.colors.red }
                                    ]

                                    RowLayout {
                                        required property var modelData
                                        spacing: 10

                                        Text {
                                            text: modelData.icon
                                            color: modelData.color
                                            font.family: "Symbols Nerd Font"
                                            font.pixelSize: 13
                                        }

                                        Text {
                                            text: modelData.label + ":"
                                            color: modelData.color
                                            font.weight: Font.Bold
                                            font.pixelSize: 13
                                            font.family: "JetBrainsMono Nerd Font"
                                        }

                                        Text {
                                            text: modelData.value
                                            color: root.colors.fg
                                            font.pixelSize: 13
                                            font.family: "JetBrainsMono Nerd Font"
                                        }
                                    }
                                }

                                // Color palette
                                RowLayout {
                                    spacing: 5
                                    Layout.topMargin: 8

                                    Repeater {
                                        model: [root.colors.red, root.colors.green, root.colors.yellow, root.colors.blue, root.colors.purple, root.colors.teal]
                                        Rectangle {
                                            required property color modelData
                                            width: 22
                                            height: 11
                                            radius: 2
                                            color: modelData
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Password Card
                    BentoCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        cardColor: root.colors.surface
                        borderColor: inputField.activeFocus ? root.colors.accent : root.colors.border

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            width: parent.width - 32

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 10

                                Rectangle {
                                    width: 44; height: 44; radius: 22
                                    color: root.colors.surface
                                    border.width: 2; border.color: root.colors.accent

                                    Image {
                                        id: avatarImg
                                        anchors.fill: parent; anchors.margins: 2
                                        source: "file://" + Quickshell.env("HOME") + "/.face"
                                        fillMode: Image.PreserveAspectCrop
                                        layer.enabled: status === Image.Ready
                                        layer.effect: OpacityMask { maskSource: Rectangle { width: avatarImg.width; height: avatarImg.height; radius: width / 2 } }
                                    }

                                    Text { anchors.centerIn: parent; text: "󰀄"; font.family: "Symbols Nerd Font"; font.pixelSize: 20; color: root.colors.muted; visible: avatarImg.status !== Image.Ready }
                                }

                                Text { text: Quickshell.env("USER") || "User"; color: root.colors.fg; font.pixelSize: 13; font.bold: true }
                            }

                            Rectangle {
                                Layout.fillWidth: true; height: 36; radius: 18
                                color: Qt.rgba(0, 0, 0, 0.35)
                                border.width: 1; border.color: inputField.activeFocus ? root.colors.accent : "transparent"

                                TextInput {
                                    id: inputField
                                    property int shakeOffset: 0
                                    anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                                    verticalAlignment: TextInput.AlignVCenter; horizontalAlignment: TextInput.AlignHCenter
                                    color: root.colors.fg; font.pixelSize: 13; font.letterSpacing: 3
                                    echoMode: TextInput.Password; passwordCharacter: "●"
                                    focus: true
                                    Component.onCompleted: forceActiveFocus()
                                    onAccepted: { if (text.length > 0) { root.pam.submit(text); text = "" } }
                                    x: anchors.leftMargin + shakeOffset

                                    Text { anchors.centerIn: parent; text: "Enter password"; color: root.colors.muted; font.pixelSize: 11; visible: !parent.text && !parent.activeFocus }

                                    SequentialAnimation {
                                        id: shakeAnim
                                        loops: 2
                                        PropertyAnimation { target: inputField; property: "shakeOffset"; to: 8; duration: 40 }
                                        PropertyAnimation { target: inputField; property: "shakeOffset"; to: -8; duration: 40 }
                                        PropertyAnimation { target: inputField; property: "shakeOffset"; to: 0; duration: 40 }
                                    }

                                    Connections {
                                        target: root.pam
                                        function onFailure() {
                                            shakeAnim.start()
                                            inputField.color = root.colors.urgent
                                            failTimer.start()
                                        }
                                        function onError() {
                                            shakeAnim.start()
                                            inputField.color = root.colors.urgent
                                            failTimer.start()
                                        }
                                    }

                                    Timer {
                                        id: failTimer
                                        interval: 1000
                                        onTriggered: inputField.color = root.colors.fg
                                    }
                                }
                            }
                        }
                    }
                }

                // RIGHT COLUMN
                ColumnLayout {
                    Layout.preferredWidth: (parent.width - 24) * 0.30
                    Layout.fillHeight: true
                    spacing: 12

                    // System Stats Card (Enhanced)
                    BentoCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        cardColor: root.colors.surface
                        borderColor: root.colors.border

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 10

                            // Header
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    width: 22
                                    height: 22
                                    radius: 6
                                    color: Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.2)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰒋"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 12
                                        color: root.colors.accent
                                    }
                                }

                                Text {
                                    text: "System"
                                    color: root.colors.fg
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }

                            // Large CPU & RAM rings
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 8

                                // CPU
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "transparent"

                                    Canvas {
                                        id: cpuCanvas
                                        anchors.centerIn: parent
                                        width: 70
                                        height: 70

                                        property real progress: cpuService.usage / 100
                                        onProgressChanged: requestPaint()

                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.reset()
                                            var cx = width / 2, cy = height / 2, r = 28, lw = 6
                                            ctx.beginPath()
                                            ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                                            ctx.strokeStyle = Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.15)
                                            ctx.lineWidth = lw
                                            ctx.stroke()
                                            ctx.beginPath()
                                            ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * progress))
                                            ctx.strokeStyle = root.colors.accent
                                            ctx.lineCap = "round"
                                            ctx.lineWidth = lw
                                            ctx.stroke()
                                        }

                                        Component.onCompleted: requestPaint()
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 0

                                        Text {
                                            text: cpuService.usage + "%"
                                            color: root.colors.fg
                                            font.pixelSize: 14
                                            font.bold: true
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        Text {
                                            text: "CPU"
                                            color: root.colors.accent
                                            font.pixelSize: 9
                                            font.bold: true
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }

                                // RAM
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "transparent"

                                    Canvas {
                                        id: ramCanvas
                                        anchors.centerIn: parent
                                        width: 70
                                        height: 70

                                        property real progress: memService.usage / 100
                                        onProgressChanged: requestPaint()

                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.reset()
                                            var cx = width / 2, cy = height / 2, r = 28, lw = 6
                                            ctx.beginPath()
                                            ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                                            ctx.strokeStyle = Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.15)
                                            ctx.lineWidth = lw
                                            ctx.stroke()
                                            ctx.beginPath()
                                            ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * progress))
                                            ctx.strokeStyle = root.colors.secondary
                                            ctx.lineCap = "round"
                                            ctx.lineWidth = lw
                                            ctx.stroke()
                                        }

                                        Component.onCompleted: requestPaint()
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 0

                                        Text {
                                            text: memService.usage + "%"
                                            color: root.colors.fg
                                            font.pixelSize: 14
                                            font.bold: true
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        Text {
                                            text: "RAM"
                                            color: root.colors.secondary
                                            font.pixelSize: 9
                                            font.bold: true
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Notifications Card
                    BentoCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        cardColor: root.colors.surface
                        borderColor: root.colors.border

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "Notifications"
                                    color: root.colors.fg
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: notifications.count > 0 ? notifications.count.toString() : ""
                                    color: root.colors.accent
                                    font.pixelSize: 10
                                    font.bold: true
                                    visible: notifications.count > 0
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: root.colors.border
                                opacity: 0.4
                            }

                            // Notification list or empty state
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                // Empty state
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    visible: notifications.count === 0

                                    Text {
                                        text: "󰂚"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 28
                                        color: root.colors.muted
                                        opacity: 0.35
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Text {
                                        text: "All caught up"
                                        color: root.colors.muted
                                        font.pixelSize: 10
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }

                                // Notification list
                                ListView {
                                    anchors.fill: parent
                                    model: notifications
                                    spacing: 6
                                    visible: notifications.count > 0
                                    clip: true

                                    delegate: Rectangle {
                                        required property int index
                                        required property string summary
                                        required property string body
                                        required property string appName
                                        required property string time
                                        width: ListView.view ? ListView.view.width : 100
                                        height: 50
                                        radius: 8
                                        color: Qt.rgba(root.colors.surface.r, root.colors.surface.g, root.colors.surface.b, 0.8)
                                        border.width: 1
                                        border.color: Qt.rgba(root.colors.border.r, root.colors.border.g, root.colors.border.b, 0.3)

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 8

                                            Rectangle {
                                                Layout.preferredWidth: 30
                                                Layout.preferredHeight: 30
                                                radius: 8
                                                color: Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.2)

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "󰍡"
                                                    font.family: "Symbols Nerd Font"
                                                    font.pixelSize: 14
                                                    color: root.colors.accent
                                                }
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2

                                                Text {
                                                    text: summary
                                                    color: root.colors.fg
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 1
                                                }

                                                Text {
                                                    text: body || appName
                                                    color: Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.7)
                                                    font.pixelSize: 9
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 1
                                                }
                                            }

                                            Text {
                                                text: time
                                                color: root.colors.muted
                                                font.pixelSize: 8
                                                Layout.alignment: Qt.AlignTop
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // INIT ANIMATION
    SequentialAnimation {
        id: initAnim
        running: !Config.disableLockAnimation

        // Phase 1: Background + overlay fade in
        ParallelAnimation {
            NumberAnimation { target: bg; property: "opacity"; to: 1; duration: 400; easing.type: Easing.OutQuad }
            NumberAnimation { target: overlay; property: "opacity"; to: 0.45; duration: 400; easing.type: Easing.OutQuad }
        }

        // Phase 2: Lock box appears with scale + rotation
        ParallelAnimation {
            NumberAnimation { target: morphContainer; property: "scale"; from: 0; to: 1; duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.3 }
            NumberAnimation { target: morphContainer; property: "rotation"; from: -180; to: 0; duration: 450; easing.type: Easing.OutBack }
        }

        // Brief pause
        PauseAnimation { duration: 250 }

        // Phase 3: Expand to bento grid
        ScriptAction { script: root.expanded = true }
    }

    // Reusable components
    component BentoCard: Rectangle {
        property color cardColor: "transparent"
        property color borderColor: "gray"
        color: Qt.rgba(cardColor.r, cardColor.g, cardColor.b, 0.45)
        radius: 16
        border.width: 1
        border.color: borderColor
    }

    component ProgressRing: Item {
        property real progress: 0.5
        property color ringColor: "white"
        property color bgColor: "gray"
        property string label: ""
        property color textColor: "white"
        property color mutedColor: "gray"

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d"); ctx.reset()
                var cx = width / 2, cy = height / 2, r = 18, lw = 4
                ctx.beginPath(); ctx.arc(cx, cy, r, 0, 2 * Math.PI); ctx.strokeStyle = Qt.rgba(bgColor.r, bgColor.g, bgColor.b, 0.2); ctx.lineWidth = lw; ctx.stroke()
                ctx.beginPath(); ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * progress)); ctx.strokeStyle = ringColor; ctx.lineCap = "round"; ctx.lineWidth = lw; ctx.stroke()
            }
            Component.onCompleted: requestPaint()
        }

        ColumnLayout {
            anchors.centerIn: parent; spacing: 0
            Text { text: Math.round(progress * 100) + "%"; color: textColor; font.pixelSize: 9; font.bold: true; Layout.alignment: Qt.AlignHCenter }
            Text { text: label; color: mutedColor; font.pixelSize: 7; Layout.alignment: Qt.AlignHCenter }
        }
    }

    // Binary column for BCD clock
    component BinaryColumn: Column {
        property int value: 0
        property int bits: 4
        property real dotSize: 10
        property color activeColor: "white"

        spacing: dotSize * 0.4
        Layout.alignment: Qt.AlignBottom

        Repeater {
            model: bits

            Rectangle {
                required property int index
                property int bitIndex: (bits - 1) - index
                property bool isActive: (value >> bitIndex) & 1

                width: dotSize
                height: dotSize
                radius: dotSize / 2
                // Safe color access to prevent crashes if activeColor is somehow invalid
                color: isActive ? activeColor : (activeColor ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.2) : "transparent")

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
        }
    }
}
