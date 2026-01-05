import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import qs.Widgets

ColumnLayout {
    property var context
    property var colors: context.colors

    spacing: 16

    Text {
        text: "Bar"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Floating Bar"
        sublabel: "Detach bar from screen edges"
        icon: "󰖲"
        active: Config.floatingBar
        colors: context.colors
        onActiveChanged: {
            if (Config.floatingBar !== active)
                Config.floatingBar = active;

        }
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Hide Workspace Numbers"
        sublabel: "Show dots instead of numbers for workspaces"
        icon: "󰍹"
        active: Config.hideWorkspaceNumbers
        colors: context.colors
        onActiveChanged: {
            if (Config.hideWorkspaceNumbers !== active)
                Config.hideWorkspaceNumbers = active;

        }
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "App Icons"
        sublabel: "Show application icons on workspace"
        icon: "󰅶" // Generic icon
        active: !Config.hideAppIcons
        enabled: Config.hideWorkspaceNumbers
        opacity: enabled ? 1 : 0.5
        colors: context.colors
        onActiveChanged: {
            if (active !== !Config.hideAppIcons)
                Config.hideAppIcons = !active;

        }
    }

    SettingItem {
        label: "Bar Position"
        sublabel: "Choose where the bar appears on screen"
        icon: "󰘻"
        colors: context.colors

        ComboBox {
            id: positionCombo

            Layout.preferredWidth: 120
            Layout.fillWidth: true
            model: ["Top", "Bottom"]
            currentIndex: {
                var pos = Config.barPosition.toLowerCase();
                if (pos === "top")
                    return 0;

                if (pos === "bottom")
                    return 1;

                return 0;
            }
            font.family: Config.fontFamily
            font.pixelSize: 14
            onActivated: {
                var positions = ["top", "bottom"];
                Config.barPosition = positions[currentIndex];
            }

            contentItem: Text {
                leftPadding: 12
                rightPadding: positionCombo.indicator.width + positionCombo.spacing
                text: positionCombo.displayText
                font: positionCombo.font
                color: colors.fg
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 150
                implicitHeight: 36
                color: positionCombo.pressed ? Qt.rgba(0, 0, 0, 0.3) : Qt.rgba(0, 0, 0, 0.2)
                border.color: positionCombo.activeFocus ? colors.accent : colors.border
                border.width: positionCombo.activeFocus ? 2 : 1
                radius: 8
            }

            indicator: Text {
                x: positionCombo.width - width - 12
                y: positionCombo.topPadding + (positionCombo.availableHeight - height) / 2
                text: "󰅀"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: colors.fg
            }

            popup: Popup {
                y: positionCombo.height + 4
                width: positionCombo.width
                implicitHeight: contentItem.implicitHeight
                padding: 4

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: positionCombo.popup.visible ? positionCombo.delegateModel : null
                    currentIndex: positionCombo.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator {
                    }

                }

                background: Rectangle {
                    color: colors.surface
                    border.color: colors.border
                    border.width: 1
                    radius: 8
                }

            }

            delegate: ItemDelegate {
                width: positionCombo.width - 8
                implicitHeight: 36
                highlighted: positionCombo.highlightedIndex === index

                contentItem: Text {
                    text: modelData
                    font: positionCombo.font
                    color: colors.fg
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                }

                background: Rectangle {
                    color: parent.highlighted ? colors.tile : "transparent"
                    radius: 6
                }

            }

        }

    }

}
