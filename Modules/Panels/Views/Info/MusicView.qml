import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services

Item {
    id: root

    required property var theme

    function formatTime(seconds) {
        let m = Math.floor(seconds / 60);
        let s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    implicitWidth: 400
    implicitHeight: MprisService.playerCount > 0 ? 480 : 300
    width: implicitWidth
    height: implicitHeight

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: cardBackground

        anchors.fill: parent
        radius: 16
        color: "#1a1a1a"
        border.width: 1
        border.color: theme.border
        layer.enabled: true

        Rectangle {
            id: playerSelector

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 12
            z: 10
            visible: MprisService.playerCount > 1
            width: playerNameLabel.implicitWidth + 24
            height: 26
            radius: 13
            color: Qt.rgba(1, 1, 1, 0.2)
            scale: 1

            Text {
                id: playerNameLabel

                anchors.centerIn: parent
                text: MprisService.currentPlayerName
                font.pixelSize: 11
                font.bold: true
                color: "white"
                opacity: 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }

                }

            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: playerSelector.scale = 0.9
                onReleased: playerSelector.scale = 1
                onClicked: MprisService.selectNextPlayer()
            }

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }

            }

        }

        Image {
            id: albumArt

            anchors.fill: parent
            source: MprisService.artUrl
            fillMode: Image.PreserveAspectCrop
            opacity: status === Image.Ready ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutQuad
                }

            }

        }

        // Content for when a player is active
        Item {
            id: activePlayerContent
            anchors.fill: parent
            visible: MprisService.playerCount > 0

            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0)
                end: Qt.point(0, parent.height)
                z: 2

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#40000000"
                    }

                    GradientStop {
                        position: 0.4
                        color: "#80000000"
                    }

                    GradientStop {
                        position: 1
                        color: "#e6000000"
                    }

                }

            }

            Item {
                id: visualizerContainer

                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 0
                width: parent.width
                height: parent.height * 0.5
                z: 3

                Binding {
                    target: CavaService
                    property: "running"
                    value: MprisService.isPlaying && root.visible && MprisService.playerCount > 0
                }

                Row {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 10
                    spacing: 6

                    Repeater {
                        id: visualizerRepeater

                        model: 32

                        Rectangle {
                            required property int index
                            property real val: {
                                var vals = CavaService.values;
                                if (!vals || vals.length === 0 || index >= vals.length)
                                    return 0;

                                return vals[index] || 0;
                            }

                            width: 6
                            height: 10 + (val * 50)
                            anchors.bottom: parent.bottom
                            color: root.theme.accent
                            opacity: 0.6
                            radius: 3

                            Behavior on height {
                                NumberAnimation {
                                    duration: 60
                                }

                            }

                        }

                    }

                }

            }

            ColumnLayout {
                id: contentColumn

                z: 4
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 60 // Move down a bit
                width: parent.width
                anchors.margins: 24
                spacing: 16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: MprisService.title || "No Media"
                        font.bold: true
                        font.pixelSize: 20
                        color: "white"
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: MprisService.artist || "Unknown Artist"
                        font.pixelSize: 14
                        color: "#cccccc" // Light gray for subtext
                        elide: Text.ElideRight
                    }

                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 32

                    Item {
                        width: 32
                        height: 32

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
                        width: 64
                        height: 64
                        radius: 20 // Rounded as user requested
                        color: theme.accent

                        Text {
                            anchors.centerIn: parent
                            text: MprisService.isPlaying ? "󰏤" : "󰐊"
                            font.family: "Symbols Nerd Font"
                            color: theme.bg // Contrast with accent
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
                        width: 32
                        height: 32

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
                                color: root.theme.accent

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
                            color: root.theme.accent

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

            }
        }

        // Empty state when no players are active
        Item {
            anchors.fill: parent
            visible: MprisService.playerCount === 0

            Image {
                anchors.fill: parent
                source: "file://" + WallpaperService.getWallpaper(Quickshell.screens[0].name)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.6
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Icons.music
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 64
                    color: theme.accent
                    opacity: 0.8
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No Media Playing"
                        font.bold: true
                        font.pixelSize: 18
                        color: "white"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Start a media player to see controls"
                        font.pixelSize: 14
                        color: "#dddddd"
                    }
                }
            }
        }

        layer.effect: OpacityMask {

            maskSource: Rectangle {
                width: cardBackground.width
                height: cardBackground.height
                radius: cardBackground.radius
                visible: false // Only used as mask source
            }

        }

    }

}
