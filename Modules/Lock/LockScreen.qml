import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.Core
import qs.Services
import "Cards"
import "Components"

WlSessionLockSurface {
    id: root

    required property var lock
    required property var pam
    required property var colors
    // Animation properties
    property bool expanded: Config.disableLockAnimation
    property real expandedWidth: Math.min(width - 60, 920)
    property real expandedHeight: Math.min(height - 80, 480)
    property real collapsedSize: 120

    color: "transparent"

    // Notifications
    ListModel {
        id: notifications
    }

    NotificationServer {
        id: server

        bodySupported: true
        imageSupported: true
        onNotification: (n) => {
            n.tracked = true;
            notifications.insert(0, {
                "summary": n.summary || "Notification",
                "body": n.body || "",
                "appName": n.appName || "",
                "appIcon": n.appIcon || "",
                "time": Qt.formatTime(new Date(), "hh:mm")
            });
        }
    }

    // Background Container
    Item {
        id: bg

        anchors.fill: parent
        opacity: Config.disableLockAnimation ? 1 : 0

        // Blurred window preview background (Default) - matches Caelestia's pattern
        ScreencopyView {
            id: screencopyBg
            anchors.fill: parent
            captureSource: root.screen
            visible: !Config.lockScreenCustomBackground
            layer.enabled: true

            layer.effect: FastBlur {
                radius: Config.disableLockBlur ? 0 : 48
            }
        }

        // Wallpaper Background (Custom)
        Image {
            anchors.fill: parent
            source: Config.lockScreenCustomBackground ? ("file://" + WallpaperService.getWallpaper(root.screen.name)) : ""
            fillMode: Image.PreserveAspectCrop
            visible: Config.lockScreenCustomBackground
            layer.enabled: visible

            layer.effect: FastBlur {
                radius: Config.disableLockBlur ? 0 : 64
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

                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Bento grid content (visible when expanded)
        Item {
            id: bentoContent

            anchors.fill: parent
            anchors.margins: 12
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : 0.8

            RowLayout {
                anchors.fill: parent
                spacing: 12
                visible: root.expanded

                // LEFT COLUMN
                ColumnLayout {
                    Layout.preferredWidth: (parent.width - 24) * 0.3
                    Layout.fillHeight: true
                    spacing: 12

                    ClockCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colors: root.colors
                    }

                    MusicCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 130
                        colors: root.colors
                    }
                }

                // CENTER COLUMN
                ColumnLayout {
                    Layout.preferredWidth: (parent.width - 24) * 0.4
                    Layout.fillHeight: true
                    spacing: 12

                    SystemInfoCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colors: root.colors
                    }

                    PasswordCard {
                        id: passwordCard
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        colors: root.colors
                        pam: root.pam
                    }
                }

                // RIGHT COLUMN
                ColumnLayout {
                    Layout.preferredWidth: (parent.width - 24) * 0.3
                    Layout.fillHeight: true
                    spacing: 12

                    SystemStatsCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        colors: root.colors
                    }

                    NotificationsCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colors: root.colors
                        notifications: notifications
                    }
                }
            }

            Behavior on opacity {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on width {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 1.02
            }
        }

        Behavior on height {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 1.02
            }
        }

        Behavior on radius {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Behavior on border.width {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 200
            }
        }
    }

    // INIT ANIMATION
    SequentialAnimation {
        id: initAnim

        running: !Config.disableLockAnimation

        // Phase 1: Background + overlay fade in
        ParallelAnimation {
            NumberAnimation {
                target: bg
                property: "opacity"
                to: 1
                duration: 400
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: overlay
                property: "opacity"
                to: 0.45
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

        // Phase 2: Lock box appears with scale + rotation
        ParallelAnimation {
            NumberAnimation {
                target: morphContainer
                property: "scale"
                from: 0
                to: 1
                duration: 450
                easing.type: Easing.OutBack
                easing.overshoot: 1.3
            }

            NumberAnimation {
                target: morphContainer
                property: "rotation"
                from: -180
                to: 0
                duration: 450
                easing.type: Easing.OutBack
            }
        }

        // Brief pause
        PauseAnimation {
            duration: 250
        }

        // Phase 3: Expand to bento grid
        ScriptAction {
            script: root.expanded = true
        }
    }
}
