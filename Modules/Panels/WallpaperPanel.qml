import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core
import qs.Services

PanelWindow {
    id: root

    required property var globalState
    property bool internalOpen: false
    property string wallpaperPath: WallpaperService.defaultDirectory
    property int currentScreenIndex: 0
    property string filterText: ""
    property var wallpapersList: []
    property var filteredWallpapers: []
    property string currentWallpaper: ""

    function updateWallpaperData() {
        if (Quickshell.screens[currentScreenIndex]) {
            var screenName = Quickshell.screens[currentScreenIndex].name;
            wallpapersList = WallpaperService.getWallpapersList(screenName);
            currentWallpaper = WallpaperService.getWallpaper(screenName);
            updateFiltered();
        }
    }

    function updateFiltered() {
        if (!filterText || filterText.trim().length === 0) {
            filteredWallpapers = wallpapersList;
            return ;
        }
        var searchText = filterText.toLowerCase();
        var filtered = [];
        for (var i = 0; i < wallpapersList.length; i++) {
            var filename = wallpapersList[i].split('/').pop().toLowerCase();
            if (filename.indexOf(searchText) >= 0)
                filtered.push(wallpapersList[i]);

        }
        filteredWallpapers = filtered;
    }

    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "wallpaper-panel"
    WlrLayershell.exclusiveZone: -1
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Connections {
        function onWallpaperPanelOpenChanged() {
            if (globalState.wallpaperPanelOpen) {
                root.visible = true;
                openTimer.restart();
                updateWallpaperData();
                searchInput.text = "";
                filterText = "";
                // Select current wallpaper
                var idx = filteredWallpapers.indexOf(currentWallpaper);
                if (idx !== -1) {
                    wallpaperGrid.currentIndex = idx;
                    wallpaperGrid.positionViewAtIndex(idx, GridView.Center);
                }
                wallpaperGrid.forceActiveFocus();
            } else {
                internalOpen = false;
                closeTimer.restart();
            }
        }

        target: globalState
    }

    Timer {
        id: openTimer

        interval: 10
        onTriggered: root.internalOpen = true
    }

    Timer {
        id: closeTimer

        interval: 400
        onTriggered: root.visible = false
    }

    Colors {
        id: theme
    }

    Connections {
        function onWallpaperChanged(screenName, path) {
            if (Quickshell.screens[currentScreenIndex] && screenName === Quickshell.screens[currentScreenIndex].name)
                updateWallpaperData();

        }

        function onWallpaperListChanged(screenName, count) {
            if (Quickshell.screens[currentScreenIndex] && screenName === Quickshell.screens[currentScreenIndex].name)
                updateWallpaperData();

        }

        target: WallpaperService
    }

    MouseArea {
        anchors.fill: parent
        onClicked: globalState.wallpaperPanelOpen = false
        z: -1
    }

    Rectangle {
        id: panelContent

        property real offset: root.internalOpen ? 20 : -height

        width: Math.min(900, parent.width - 40)
        height: 500
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: offset
        color: theme.bg
        radius: 16
        border.color: theme.muted
        border.width: 1
        layer.enabled: true

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 40
                    height: 40
                    radius: 12
                    color: theme.tileActive

                    Text {
                        anchors.centerIn: parent
                        text: "󰋩"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: theme.accent
                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 12
                    color: theme.surface
                    border.color: searchInput.activeFocus ? theme.accent : theme.border
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: "🔎"
                            font.pixelSize: 14
                            color: theme.subtext
                        }

                        TextInput {
                            id: searchInput

                            Layout.fillWidth: true
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: 14
                            color: theme.text
                            selectByMouse: true
                            selectionColor: theme.accent
                            onTextChanged: {
                                filterText = text;
                                updateFiltered();
                            }
                            Keys.onDownPressed: {
                                if (wallpaperGrid.count > 0)
                                    wallpaperGrid.forceActiveFocus();

                            }
                            Keys.onEscapePressed: globalState.wallpaperPanelOpen = false

                            Text {
                                text: "Search wallpapers..."
                                color: theme.subtext
                                visible: !parent.text && !parent.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: 0.7
                                font.pixelSize: 14
                            }

                        }

                        Text {
                            text: "✕"
                            color: theme.subtext
                            font.pixelSize: 12
                            visible: searchInput.text !== ""

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: searchInput.text = ""
                            }

                        }

                    }

                }

                Rectangle {
                    width: 40
                    height: 40
                    radius: 12
                    color: refreshArea.containsMouse ? theme.surface : "transparent"
                    border.color: theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        color: theme.text
                    }

                    MouseArea {
                        id: refreshArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            WallpaperService.refreshWallpapersList();
                            searchInput.forceActiveFocus();
                        }
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.border
                opacity: 0.5
            }

            GridView {
                id: wallpaperGrid

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: width / 4
                cellHeight: cellWidth * 0.65
                model: filteredWallpapers
                focus: true
                keyNavigationEnabled: true
                highlightFollowsCurrentItem: true
                Keys.onReturnPressed: {
                    if (currentIndex >= 0 && currentIndex < filteredWallpapers.length) {
                        WallpaperService.changeWallpaper(filteredWallpapers[currentIndex], undefined);
                        globalState.wallpaperPanelOpen = false;
                    }
                }
                Keys.onPressed: (event) => {
                    if (event.text === "/") {
                        searchInput.forceActiveFocus();
                        event.accepted = true;
                    }
                }
                Keys.onEscapePressed: globalState.wallpaperPanelOpen = false

                highlight: Rectangle {
                    color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.1)
                    radius: 8
                    border.color: theme.accent
                    border.width: 2
                    z: 5
                }

                delegate: Item {
                    required property string modelData
                    required property int index
                    property bool isSelected: (modelData === currentWallpaper)

                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 8
                        color: theme.surface
                        border.color: isSelected ? theme.accent : theme.border
                        border.width: isSelected ? 2 : 1

                        Image {
                            id: wImage

                            readonly property string fileName: modelData.split('/').pop()
                            readonly property string thumbSource: "file://" + WallpaperService.previewDirectory + "/" + fileName
                            readonly property string originalSource: "file://" + modelData

                            anchors.fill: parent
                            anchors.margins: 4
                            // Try thumbnail first, fallback to original
                            source: thumbSource
                            opacity: status === Image.Ready ? 1 : 0
                            onStatusChanged: {
                                if (status === Image.Error && source !== originalSource)
                                    source = originalSource;

                            }
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 300
                            sourceSize.height: 200
                            cache: true
                            smooth: true
                            layer.enabled: true

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutQuad
                                }

                            }

                            layer.effect: OpacityMask {

                                maskSource: Rectangle {
                                    width: wImage.width
                                    height: wImage.height
                                    radius: 6
                                }

                            }

                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            radius: 16
                            color: theme.accent
                            visible: isSelected

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: "Symbols Nerd Font"
                                color: theme.bg
                                font.pixelSize: 16
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                wallpaperGrid.currentIndex = index;
                                WallpaperService.changeWallpaper(modelData, undefined);
                                globalState.wallpaperPanelOpen = false;
                            }
                        }

                    }

                }

            }

            Text {
                visible: filteredWallpapers.length === 0
                text: "No wallpapers found"
                color: theme.subtext
                font.pixelSize: 16
                Layout.alignment: Qt.AlignCenter
            }

        }

        Behavior on offset {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutExpo
            }

        }

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
        }

    }

}
