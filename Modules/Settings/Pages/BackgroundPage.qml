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
        text: "Background"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    SettingItem {
        label: "Wallpaper Directory"
        sublabel: "Path to wallpaper folder"
        icon: "󰸉"
        colors: context.colors

        TextField {
            Layout.preferredWidth: 350
            text: Config.wallpaperDirectory
            font.pixelSize: 13
            color: colors.fg
            background: null
            horizontalAlignment: TextInput.AlignRight
            onEditingFinished: {
                if (text !== "")
                    Config.wallpaperDirectory = text;
            }
        }
    }

    SettingItem {
        label: "Wallpaper Panel"
        sublabel: "Browse and select wallpapers"
        icon: "󰋩"
        colors: context.colors

        Button {
            id: panelBtn
            Layout.preferredWidth: 160
            Layout.preferredHeight: 42
            
            onClicked: context.appState.toggleWallpaperPanel()


            scale: down ? 0.96 : hovered ? 1.02 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            background: Rectangle {
                radius: 12
                color: panelBtn.down ? Qt.darker(colors.accent, 1.1) : 
                       panelBtn.hovered ? Qt.lighter(colors.accent, 1.1) : 
                       colors.accent
                

                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            contentItem: RowLayout {
                spacing: 8
                anchors.centerIn: parent
                
                
                Text {
                    text: "󰋩"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: colors.bg 
                }
                
                
                Text {
                    text: "Open Gallery"
                    font.family: Config.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    color: colors.bg 
                }
            }
            
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.NoButton
            }
        }
    }
}