import "./Pages" as Pages
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Core
import qs.Services
import qs.Widgets

FloatingWindow {
    id: root

    required property var context
    property var colors: context.colors
    property int windowWidth: 800
    property int windowHeight: 550
    property string activePage: "General"
    property bool sidebarCollapsed: false

    visible: context.appState.settingsOpen
    onVisibleChanged: {
        if (!visible)
            context.appState.settingsOpen = false;

    }
    implicitWidth: windowWidth
    implicitHeight: windowHeight
    // Title for hyprland/window rules
    // Quickshell FloatingWindow title property:
    title: "Settings"
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: colors.bg
        radius: 16
        border.width: 1
        border.color: colors.border
        clip: true

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // --- Sidebar ---
            Rectangle {
                Layout.preferredWidth: sidebarCollapsed ? 80 : 240
                Layout.fillHeight: true
                color: Qt.rgba(0, 0, 0, 0.3)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    // Toggle Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅁"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 20
                            color: colors.muted
                            rotation: sidebarCollapsed ? -90 : 90

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: 200
                                }

                            }

                        }

                        TapHandler {
                            onTapped: sidebarCollapsed = !sidebarCollapsed
                            cursorShape: Qt.PointingHandCursor
                        }

                    }

                    // Header / Config File
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: 24
                        color: colors.accent

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: sidebarCollapsed ? 0 : 12

                            Text {
                                text: "󰐏"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 18
                                color: colors.bg
                            }

                            Text {
                                text: "Config file"
                                color: colors.bg
                                font.pixelSize: 14
                                font.bold: true
                                visible: !sidebarCollapsed
                                opacity: sidebarCollapsed ? 0 : 1
                            }

                        }

                        TapHandler {
                            onTapped: Qt.openUrlExternally("file://" + Config.configPath)
                            cursorShape: Qt.PointingHandCursor
                        }

                    }

                    Item {
                        height: 12
                        width: 1
                    }

                    SidebarItem {
                        label: "General"
                        icon: "󰒓"
                        page: "General"
                    }

                    SidebarItem {
                        label: "Bar"
                        icon: "󰛡"
                        page: "Bar"
                    }

                    SidebarItem {
                        label: "Background"
                        icon: "󰸉"
                        page: "Background"
                    }

                    SidebarItem {
                        label: "Lock Screen"
                        icon: "󰌾"
                        page: "LockScreen"
                    }

                    SidebarItem {
                        label: "Interface"
                        icon: "󰏇"
                        page: "Interface"
                    }

                    SidebarItem {
                        label: "Services"
                        icon: "󰒋"
                        page: "Services"
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    // Navigation Items
                    component SidebarItem: Rectangle {
                        property string label
                        property string icon
                        property string page
                        property bool isActive: root.activePage === page

                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 12
                        color: isActive ? Qt.rgba(colors.surface.r, colors.surface.g, colors.surface.b, 0.8) : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: sidebarCollapsed ? 0 : 16
                            // Removed conflicting horizontalCenter anchor
                            spacing: sidebarCollapsed ? 0 : 16

                            Text {
                                text: icon
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 18
                                color: isActive ? colors.accent : colors.muted
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                Layout.fillWidth: sidebarCollapsed
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                text: label
                                color: isActive ? colors.fg : colors.muted
                                font.pixelSize: 14
                                font.weight: isActive ? Font.Bold : Font.Normal
                                visible: !sidebarCollapsed
                                opacity: sidebarCollapsed ? 0 : 1
                            }

                            Item {
                                Layout.fillWidth: true
                                visible: !sidebarCollapsed
                            }

                        }

                        TapHandler {
                            onTapped: root.activePage = page
                            cursorShape: Qt.PointingHandCursor
                        }

                        HoverHandler {
                            id: hover

                            cursorShape: Qt.PointingHandCursor
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: colors.surface
                            opacity: hover.hovered && !isActive ? 0.3 : 0
                            radius: 12
                        }

                    }

                }

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }

                }

            }

            // --- Content Area ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                // Close Button (Fixed Top Right)
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    width: 32
                    height: 32
                    radius: 16
                    color: closeHover.containsMouse ? colors.surface : "transparent"
                    z: 100

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: colors.muted
                    }

                    TapHandler {
                        onTapped: context.appState.settingsOpen = false
                        cursorShape: Qt.PointingHandCursor
                    }

                    HoverHandler {
                        id: closeHover

                        cursorShape: Qt.PointingHandCursor
                    }

                }

                ScrollView {
                    anchors.fill: parent
                    anchors.topMargin: 20 // Space for close button
                    clip: true
                    contentWidth: availableWidth

                    Loader {
                        anchors.fill: parent
                        anchors.margins: 32
                        source: {
                            switch (root.activePage) {
                            case "General":
                                return "Pages/GeneralPage.qml";
                            case "Bar":
                                return "Pages/BarPage.qml";
                            case "Background":
                                return "Pages/BackgroundPage.qml";
                            case "LockScreen":
                                return "Pages/LockScreenPage.qml";
                            case "Interface":
                                return "Pages/InterfacePage.qml";
                            case "Services":
                                return "Pages/ServicesPage.qml";
                            default:
                                return "Pages/GeneralPage.qml";
                            }
                        }
                        onLoaded: {
                            item.context = context; // Inject context
                        }
                    }

                }

            }

        }

    }

}
