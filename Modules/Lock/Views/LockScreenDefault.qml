import "../Cards"
import "../Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Core
import qs.Services

Item {
    id: root

    required property var colors
    required property var pam
    required property var notifications
    property bool expanded: Config.disableLockAnimation
    property real expandedWidth: Math.min(width - 60, 920)
    property real expandedHeight: Math.min(height - 80, 480)
    property real collapsedSize: 120
    property alias inputField: passwordCard.inputField

    Item {
        anchors.fill: parent

        Loader {
            anchors.fill: parent
            sourceComponent: Config.lockScreenCustomBackground ? wallpaperComponent : screencopyComponent
        }

        Component {
            id: screencopyComponent

            ScreencopyView {
                anchors.fill: parent
                captureSource: Quickshell.screens[0]
                layer.enabled: true

                layer.effect: FastBlur {
                    radius: Config.disableLockBlur ? 0 : 48
                }

            }

        }

        Component {
            id: wallpaperComponent

            Image {
                anchors.fill: parent
                source: "file://" + WallpaperService.getWallpaper(Quickshell.screens[0].name)
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true

                layer.effect: FastBlur {
                    radius: Config.disableLockBlur ? 0 : 64
                    transparentBorder: false
                }

            }

        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: Config.disableLockAnimation ? 0.45 : 0

            NumberAnimation on opacity {
                from: 0
                to: 0.45
                duration: 400
                easing.type: Easing.OutQuad
                running: !Config.disableLockAnimation
            }

        }

    }

    Rectangle {
        id: morphContainer

        anchors.centerIn: parent
        width: root.expanded ? root.expandedWidth : root.collapsedSize
        height: root.expanded ? root.expandedHeight : root.collapsedSize
        color: root.expanded ? "transparent" : Qt.rgba(root.colors.surface.r, root.colors.surface.g, root.colors.surface.b, 0.9)
        radius: root.expanded ? 20 : 30
        border.width: 0
        border.color: root.colors.accent
        scale: Config.disableLockAnimation ? 1 : 0
        rotation: Config.disableLockAnimation ? 0 : -180

        SequentialAnimation {
            running: !Config.disableLockAnimation

            ParallelAnimation {
                NumberAnimation {
                    target: morphContainer
                    property: "scale"
                    from: 0.5
                    to: 1
                    duration: 600
                    easing.type: Easing.OutExpo
                }

                NumberAnimation {
                    target: morphContainer
                    property: "rotation"
                    from: -45
                    to: 0
                    duration: 600
                    easing.type: Easing.OutExpo
                }

            }

            ScriptAction {
                script: root.expanded = true
            }

        }

        Image {
            anchors.centerIn: parent
            source: SvgIcons.logo
            sourceSize.width: 64
            sourceSize.height: 64
            opacity: root.expanded ? 0 : 1
            scale: root.expanded ? 0.5 : 1
            fillMode: Image.PreserveAspectFit

            Behavior on opacity {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutSine
                }

            }

            Behavior on scale {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutSine
                }

            }

        }

        Item {
            anchors.fill: parent
            anchors.margins: 12
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : 0.9

            RowLayout {
                anchors.fill: parent
                spacing: 16
                visible: root.expanded

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: 16
                    columnSpacing: 16

                    ProfileCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colors: root.colors
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 16

                        SystemStatsCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredHeight: 120 // Reduced to fit
                            colors: root.colors
                        }

                        ClockCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredHeight: 120 // Reduced to fit
                            colors: root.colors
                        }

                    }

                    MusicCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colors: root.colors
                    }

                    QuoteCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: 200 // Shorter than top row
                        colors: root.colors
                    }

                    WeatherCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: 200
                        colors: root.colors
                    }

                    PasswordCard {
                        id: passwordCard

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: 200
                        colors: root.colors
                        pam: root.pam
                    }

                }

                Sidebar {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 60
                    colors: root.colors
                }

            }

            Behavior on opacity {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutExpo
                }

            }

            Behavior on scale {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutExpo
                }

            }

        }

        Behavior on width {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 600
                easing.type: Easing.OutExpo
            }

        }

        Behavior on height {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 600
                easing.type: Easing.OutExpo
            }

        }

        Behavior on radius {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 400
            }

        }

        Behavior on border.width {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 200
            }

        }

    }

}
