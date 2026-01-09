import "../Cards"
import "../Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services

Item {
    id: root

    required property var colors
    required property var pam
    property alias inputField: musicPwd.inputField
    property bool hasMedia: MprisService.title !== ""
    property bool isPlaying: MprisService.isPlaying

    function formatTime(seconds) {
        let m = Math.floor(seconds / 60);
        let s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    SequentialAnimation {
        id: entryAnim

        running: true

        NumberAnimation {
            target: backgroundLayer
            property: "opacity"
            from: 0
            to: 1
            duration: 800
            easing.type: Easing.OutQuad
        }

        ParallelAnimation {
            NumberAnimation {
                target: artWrapper
                property: "scale"
                from: 0.8
                to: 1
                duration: 600
                easing.type: Easing.OutBack
            }

            NumberAnimation {
                target: artWrapper
                property: "opacity"
                from: 0
                to: 1
                duration: 400
                easing.type: Easing.OutQuad
            }

            SequentialAnimation {
                PauseAnimation {
                    duration: 150
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: rightDashboard
                        property: "y"
                        from: rightDashboard.y + 40
                        to: rightDashboard.y
                        duration: 600
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: rightDashboard
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 500
                        easing.type: Easing.OutQuad
                    }

                }

            }

            SequentialAnimation {
                PauseAnimation {
                    duration: 300
                }

                NumberAnimation {
                    target: footer
                    property: "anchors.bottomMargin"
                    from: -50
                    to: 60
                    duration: 600
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    target: footer
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                    easing.type: Easing.OutQuad
                }

            }

        }

    }

    Item {
        id: backgroundLayer

        property string currentArt: MprisService.artUrl

        anchors.fill: parent
        opacity: 0
        onCurrentArtChanged: {
            if (currentArt === "")
                return ;

            if (bgImg1.opacity > 0) {
                bgImg2.source = currentArt;
                crossfadeTo2.start();
            } else {
                bgImg1.source = currentArt;
                crossfadeTo1.start();
            }
        }
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            color: "#050505"
        }

        Image {
            anchors.fill: parent
            source: Config.lockScreenCustomBackground ? ("file://" + WallpaperService.getWallpaper(Quickshell.screens[0].name)) : ""
            fillMode: Image.PreserveAspectCrop
            visible: MprisService.artUrl === ""
            opacity: 0.5
        }

        Image {
            id: bgImg1

            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            visible: opacity > 0
            asynchronous: true
        }

        Image {
            id: bgImg2

            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            visible: opacity > 0
            opacity: 0
            asynchronous: true
        }

        ParallelAnimation {
            id: crossfadeTo2

            NumberAnimation {
                target: bgImg2
                property: "opacity"
                to: 1
                duration: 1200
            }

            NumberAnimation {
                target: bgImg1
                property: "opacity"
                to: 0
                duration: 1200
            }

        }

        ParallelAnimation {
            id: crossfadeTo1

            NumberAnimation {
                target: bgImg1
                property: "opacity"
                to: 1
                duration: 1200
            }

            NumberAnimation {
                target: bgImg2
                property: "opacity"
                to: 0
                duration: 1200
            }

        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#30000000"
                }

                GradientStop {
                    position: 1
                    color: "#D0000000"
                }

            }

        }

        layer.effect: FastBlur {
            radius: 90
            transparentBorder: false
        }

    }

    Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1

                Item {
                    id: artWrapper

                    width: Math.min(parent.width * 0.75, 480)
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 30
                    opacity: 0
                    visible: root.hasMedia
                    scale: root.isPlaying ? 1 : 0.95

                    Rectangle {
                        anchors.fill: parent
                        radius: 32
                        color: "#151515"
                        layer.enabled: true

                        Image {
                            anchors.fill: parent
                            source: MprisService.artUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            layer.enabled: true

                            layer.effect: OpacityMask {

                                maskSource: Rectangle {
                                    width: artWrapper.width
                                    height: artWrapper.height
                                    radius: 32
                                }

                            }

                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 32
                            border.color: "#20FFFFFF"
                            border.width: 1
                            color: "transparent"

                            gradient: Gradient {
                                orientation: Gradient.Vertical

                                GradientStop {
                                    position: 0
                                    color: "#15FFFFFF"
                                }

                                GradientStop {
                                    position: 1
                                    color: "#00000000"
                                }

                            }

                        }

                        layer.effect: DropShadow {
                            transparentBorder: true
                            radius: 50
                            samples: 32
                            color: "#80000000"
                            verticalOffset: 20
                        }

                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 1500
                            easing.type: Easing.InOutSine
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1

                ColumnLayout {
                    id: rightDashboard

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    width: Math.min(parent.width - 60, 420)
                    spacing: 40
                    opacity: 0

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8

                            Text {
                                text: {
                                    let d = new Date();
                                    let h = d.getHours();
                                    if (!Config.use24HourFormat)
                                        h = h % 12 || 12;

                                    return h.toString().padStart(2, '0');
                                }
                                font.family: "StretchPro"
                                font.pixelSize: 100
                                font.weight: Font.Black
                                color: "#FFFFFF"
                                layer.enabled: true

                                layer.effect: Glow {
                                    radius: 16
                                    color: "#20FFFFFF"
                                }

                            }

                            Text {
                                text: ":"
                                font.family: "StretchPro"
                                font.pixelSize: 100
                                font.weight: Font.Black
                                color: root.colors.accent
                                Layout.bottomMargin: 12
                                opacity: 0.8
                            }

                            Text {
                                text: Qt.formatTime(new Date(), "mm")
                                font.family: "StretchPro"
                                font.pixelSize: 100
                                font.weight: Font.Black
                                color: "#FFFFFF"
                                layer.enabled: true

                                layer.effect: Glow {
                                    radius: 16
                                    color: "#20FFFFFF"
                                }

                            }

                        }

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: dateRow.implicitWidth + 40
                            height: 40
                            radius: 20
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.color: Qt.rgba(1, 1, 1, 0.1)
                            border.width: 1

                            Row {
                                id: dateRow

                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    text: Qt.formatDate(new Date(), "dddd").toUpperCase()
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: root.colors.accent
                                }

                                Rectangle {
                                    width: 1
                                    height: 12
                                    color: "#60FFFFFF"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: Qt.formatDate(new Date(), "MMMM d")
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: "#DDDDDD"
                                }

                            }

                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentCol.implicitHeight + 48
                        radius: 28
                        color: Qt.rgba(0, 0, 0, 0.4)
                        border.color: Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1
                        visible: root.hasMedia
                        layer.enabled: true

                        ColumnLayout {
                            id: contentCol

                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 0

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: MprisService.title || "No Media"
                                    font.family: Config.fontFamily
                                    font.pixelSize: 26
                                    font.weight: Font.Bold
                                    color: "#FFFFFF"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    text: MprisService.artist || "Unknown Artist"
                                    font.family: Config.fontFamily
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                    color: "#AAAAAA"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                            }

                            Item {
                                Layout.preferredHeight: 48
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.maximumWidth: parent.width * 0.9
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 12

                                Text {
                                    text: root.formatTime(MprisService.position)
                                    color: "white"
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                }

                                Item {
                                    id: progressContainer

                                    property bool seeking: false
                                    property real seekValue: 0
                                    property bool seekingCooldown: false

                                    function seekTo(mouseX) {
                                        var pos = Math.max(0, Math.min(mouseX / width, 1));
                                        seekValue = pos * MprisService.length;
                                    }

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 24

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 6
                                        radius: 3
                                        color: "#40ffffff"

                                        Rectangle {
                                            width: {
                                                var len = MprisService.length > 0 ? MprisService.length : 1;
                                                var pos = (progressContainer.seeking || progressContainer.seekingCooldown) ? progressContainer.seekValue : MprisService.position;
                                                var w = (pos / len) * parent.width;
                                                return Math.max(0, Math.min(w, parent.width));
                                            }
                                            height: parent.height
                                            radius: 3
                                            color: root.colors.accent

                                            Behavior on width {
                                                NumberAnimation {
                                                    duration: 200
                                                    easing.type: Easing.OutCubic
                                                }

                                            }

                                        }

                                    }

                                    Rectangle {
                                        id: progressHandle

                                        x: {
                                            var len = MprisService.length > 0 ? MprisService.length : 1;
                                            var pos = (progressContainer.seeking || progressContainer.seekingCooldown) ? progressContainer.seekValue : MprisService.position;
                                            var xPos = (pos / len) * (parent.width - width);
                                            return Math.max(0, Math.min(xPos, parent.width - width));
                                        }
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 12
                                        height: 24
                                        radius: 6
                                        color: root.colors.accent

                                        Behavior on x {
                                            NumberAnimation {
                                                duration: 200
                                                easing.type: Easing.OutCubic
                                            }

                                        }

                                    }

                                    Timer {
                                        id: seekCooldownTimer

                                        interval: 1000 // 1 second grace period for player to update
                                        repeat: false
                                        onTriggered: {
                                            progressContainer.seekingCooldown = false;
                                        }
                                    }

                                    Binding {
                                        target: progressContainer
                                        property: "seekValue"
                                        value: MprisService.position
                                        when: !progressContainer.seeking && !progressContainer.seekingCooldown
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: (mouse) => {
                                            seekCooldownTimer.stop();
                                            progressContainer.seekingCooldown = false;
                                            progressContainer.seekTo(mouse.x);
                                            progressContainer.seeking = true;
                                        }
                                        onPositionChanged: (mouse) => {
                                            if (progressContainer.seeking)
                                                progressContainer.seekTo(mouse.x);

                                        }
                                        onReleased: {
                                            if (progressContainer.seeking) {
                                                MprisService.setPosition(progressContainer.seekValue);
                                                progressContainer.seeking = false;
                                                progressContainer.seekingCooldown = true;
                                                seekCooldownTimer.restart();
                                            }
                                        }
                                    }

                                }

                                Text {
                                    text: root.formatTime(MprisService.length)
                                    color: "white"
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                }

                            }

                            Item {
                                Layout.preferredHeight: 12
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 32

                                Item {
                                    implicitWidth: 32
                                    implicitHeight: 32

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰒮" // Previous icon
                                        font.family: "Symbols Nerd Font"
                                        color: "white"
                                        font.pixelSize: 24
                                        opacity: prevMouse.containsMouse ? 1 : 0.8
                                    }

                                    MouseArea {
                                        id: prevMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: MprisService.previous()
                                    }

                                }

                                Rectangle {
                                    implicitWidth: 64
                                    implicitHeight: 64
                                    radius: 20
                                    color: root.colors.accent

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.isPlaying ? "󰏤" : "󰐊"
                                        font.family: "Symbols Nerd Font"
                                        color: root.colors.bg
                                        font.pixelSize: 28
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: MprisService.playPause()
                                        onPressed: parent.scale = 0.95
                                        onReleased: parent.scale = 1
                                    }

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 100
                                        }

                                    }

                                }

                                Item {
                                    implicitWidth: 32
                                    implicitHeight: 32

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰒭" // Next icon
                                        font.family: "Symbols Nerd Font"
                                        color: "white"
                                        font.pixelSize: 24
                                        opacity: nextMouse.containsMouse ? 1 : 0.8
                                    }

                                    MouseArea {
                                        id: nextMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: MprisService.next()
                                    }

                                }

                            }

                        }

                        layer.effect: DropShadow {
                            transparentBorder: true
                            radius: 24
                            color: "#40000000"
                            verticalOffset: 8
                        }

                    }

                }

            }

        }

    }

    Item {
        id: footer

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: 60
        height: 120
        z: 20
        opacity: 0

        PasswordCard {
            id: musicPwd

            anchors.centerIn: parent
            width: 380
            height: 110
            colors: root.colors
            pam: root.pam
            visible: true
            opacity: 1
            cardColor: Qt.rgba(0, 0, 0, 0.75)
            borderColor: Qt.rgba(1, 1, 1, 0.1)
        }

    }

}
