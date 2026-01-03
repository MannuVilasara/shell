import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
    id: trayRoot

    property color borderColor: "#ffffff"
    property color itemHoverColor: "#89b4fa"
    property int iconSize: 16
    property var pinnedApps: []
    property var blacklist: []
    property bool hidePassive: false
    property var colors: null  // Theme colors to pass to context menu
    property var visibleItems: {
        var items = SystemTray.items.values || [];
        return items.filter((item) => {
            if (blacklist.some((name) => {
                return item.id.toLowerCase().includes(name.toLowerCase());
            }))
                return false;

            if (hidePassive && item.status === SystemTrayStatus.Passive)
                return false;

            return true;
        });
    }

    spacing: 6

    Connections {
        function onValuesChanged() {
            trayRoot.visibleItems = Qt.binding(() => {
                var items = SystemTray.items.values || [];
                return items.filter((item) => {
                    if (blacklist.some((name) => {
                        return item.id.toLowerCase().includes(name.toLowerCase());
                    }))
                        return false;

                    if (hidePassive && item.status === SystemTrayStatus.Passive)
                        return false;

                    return true;
                });
            });
        }

        target: SystemTray.items
    }

    Repeater {
        model: trayRoot.visibleItems

        Rectangle {
            Layout.preferredWidth: trayRoot.iconSize + 8
            Layout.preferredHeight: trayRoot.iconSize + 8
            radius: 4
            color: itemMouseArea.containsMouse ? Qt.rgba(itemHoverColor.r, itemHoverColor.g, itemHoverColor.b, 0.2) : "transparent"

            Image {
                id: trayIcon

                anchors.centerIn: parent
                width: trayRoot.iconSize
                height: trayRoot.iconSize
                source: modelData.icon || ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: status === Image.Ready || status === Image.Loading
            }

            Text {
                anchors.centerIn: parent
                text: trayIcon.status === Image.Error ? "?" : ""
                color: borderColor
                font.pixelSize: 10
                visible: trayIcon.status === Image.Error
            }

            MouseArea {
                id: itemMouseArea

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate();
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (modelData.hasMenu && modelData.menu) {
                            var pos = itemMouseArea.mapToGlobal(itemMouseArea.width / 2, itemMouseArea.height);
                            contextMenu.open(modelData.menu, pos.x, pos.y);
                        }
                    }
                }
            }

        }

    }

    TrayContextMenu {
        id: contextMenu

        Layout.preferredWidth: 0
        Layout.preferredHeight: 0
        colors: trayRoot.colors
    }

}
