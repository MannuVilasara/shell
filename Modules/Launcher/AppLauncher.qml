import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: root

    required property Colors colors
    required property GlobalState globalState
    property string query: ""
    property var filteredApps: {
        var apps = DesktopEntries.applications.values;
        var q = query.toLowerCase().trim();
        if (q === "")
            return [];

        var matches = apps.filter((app) => {
            if (app.noDisplay)
                return false;

            return app.name.toLowerCase().includes(q);
        });
        matches.sort((a, b) => {
            var nameA = a.name.toLowerCase();
            var nameB = b.name.toLowerCase();
            if (nameA === q && nameB !== q)
                return -1;

            if (nameB === q && nameA !== q)
                return 1;

            var startA = nameA.startsWith(q);
            var startB = nameB.startsWith(q);
            if (startA && !startB)
                return -1;

            // A wins
            if (!startA && startB)
                return 1;

            // B wins
            return nameA.localeCompare(nameB);
        });
        return matches;
    }

    visible: globalState.launcherOpen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"
    onVisibleChanged: {
        if (visible) {
            query = "";
            input.text = "";
            input.forceActiveFocus();
            appList.currentIndex = 0;
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Shortcut {
        sequence: "Escape"
        onActivated: globalState.closeAll()
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: globalState.closeAll()
    }

    Rectangle {
        id: mainContainer

        width: 480
        anchors.centerIn: parent
        height: 60 + (appList.count > 0 ? Math.min(appList.count * 44, 350) : 0)
        color: colors.bg
        border.color: colors.muted
        border.width: 1
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "🔎"
                        font.pixelSize: 18
                        color: colors.purple
                    }

                    TextField {
                        id: input

                        Layout.fillWidth: true
                        background: null
                        color: colors.fg
                        font.pixelSize: 18
                        font.bold: true
                        placeholderText: "Search..."
                        placeholderTextColor: colors.muted
                        verticalAlignment: TextInput.AlignVCenter
                        onTextChanged: {
                            root.query = text;
                            appList.currentIndex = 0;
                        }
                        Keys.onDownPressed: appList.incrementCurrentIndex()
                        Keys.onUpPressed: appList.decrementCurrentIndex()
                        Keys.onReturnPressed: {
                            if (appList.count > 0) {
                                appList.model[appList.currentIndex].execute();
                                globalState.launcherOpen = false;
                            }
                        }
                    }

                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: colors.muted
                    visible: appList.count > 0
                    opacity: 0.5
                }

            }

            ListView {
                id: appList

                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: count > 0
                model: root.filteredApps
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    width: appList.width
                    height: 44
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: appList.currentIndex = index
                        onClicked: {
                            modelData.execute();
                            globalState.launcherOpen = false;
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 6
                        color: ListView.isCurrentItem ? Qt.rgba(colors.muted.r, colors.muted.g, colors.muted.b, 0.3) : "transparent"

                        Rectangle {
                            width: 3
                            height: 20
                            radius: 2
                            color: colors.cyan
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            visible: parent.parent.ListView.isCurrentItem
                        }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 16
                        spacing: 12

                        Image {
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            fillMode: Image.PreserveAspectFit
                            source: {
                                if (modelData.icon.indexOf("/") !== -1)
                                    return "file://" + modelData.icon;

                                return "image://icon/" + modelData.icon;
                            }
                        }

                        Text {
                            text: modelData.name
                            color: ListView.isCurrentItem ? colors.purple : colors.fg
                            font.bold: true
                            font.pixelSize: 14
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "↵"
                            color: colors.muted
                            font.pixelSize: 14
                            visible: ListView.isCurrentItem
                        }

                    }

                }

            }

        }

        Behavior on height {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuart
            }

        }

    }

}
