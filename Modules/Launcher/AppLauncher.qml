import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: root

    required property Colors colors
    required property GlobalState globalState
    property string query: ""
    property int currentIndex: 0
    
    // Fixed dimensions
    readonly property int panelWidth: 400
    readonly property int panelMaxHeight: 500
    readonly property int headerHeight: 56
    readonly property int itemHeight: 48
    readonly property int itemSpacing: 2

    // Usage tracking
    property var usageCounts: ({})
    readonly property string usageFilePath: Quickshell.env("HOME") + "/.cache/mannu/app-usage.json"

    function loadUsage() {
        usageFileReader.running = true;
    }

    function saveUsage() {
        usageFileWriter.running = true;
    }

    function incrementUsage(appId) {
        var counts = usageCounts;
        counts[appId] = (counts[appId] || 0) + 1;
        usageCounts = counts;
        saveUsage();
    }

    function getUsage(appId) {
        return usageCounts[appId] || 0;
    }

    Component.onCompleted: loadUsage()

    // File reader for usage data
    Process {
        id: usageFileReader
        command: ["cat", root.usageFilePath]
        running: false
        onExited: (code, status) => {
            if (code === 0 && stdout && stdout.trim()) {
                try {
                    root.usageCounts = JSON.parse(stdout);
                } catch (e) {
                    root.usageCounts = {};
                }
            }
        }
    }

    // File writer for usage data
    Process {
        id: usageFileWriter
        command: ["sh", "-c", "mkdir -p ~/.cache/mannu && cat > " + root.usageFilePath]
        running: false
        onStarted: {
            write(JSON.stringify(root.usageCounts));
            close();
        }
    }

    property var filteredApps: {
        var apps = DesktopEntries.applications.values;
        var q = query.toLowerCase().trim();

        // Filter out noDisplay apps
        var visible = apps.filter((app) => !app.noDisplay);

        // If no query, sort by usage (most used first), then alphabetically
        if (q === "") {
            visible.sort((a, b) => {
                var usageA = getUsage(a.id);
                var usageB = getUsage(b.id);
                if (usageA !== usageB)
                    return usageB - usageA; // Higher usage first
                return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
            });
            return visible;
        }

        // Filter by search query
        var matches = visible.filter((app) => {
            return app.name.toLowerCase().includes(q);
        });

        // Sort: usage first, then exact match, then starts with, then alphabetically
        matches.sort((a, b) => {
            var usageA = getUsage(a.id);
            var usageB = getUsage(b.id);
            // If both have usage, sort by usage
            if (usageA > 0 || usageB > 0) {
                if (usageA !== usageB)
                    return usageB - usageA;
            }
            
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
            if (!startA && startB)
                return 1;
            return nameA.localeCompare(nameB);
        });
        return matches;
    }

    visible: globalState.launcherOpen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusiveZone: -1
    color: "transparent"
    
    onVisibleChanged: {
        if (visible) {
            query = "";
            input.text = "";
            input.forceActiveFocus();
            currentIndex = 0;
            appList.positionViewAtBeginning();
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

        property int contentHeight: root.filteredApps.length === 0 ? 120 : appList.contentHeight + 16

        width: root.panelWidth
        height: Math.min(headerHeight + contentHeight, root.panelMaxHeight)
        anchors.centerIn: parent
        color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.95)
        radius: 16
        clip: true
        layer.enabled: true

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 24
            samples: 25
            color: "#50000000"
        }

        // Search header
        Rectangle {
            id: searchHeader
            width: parent.width
            height: root.headerHeight
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: "󰍉"
                    font.pixelSize: 18
                    font.family: "Symbols Nerd Font"
                    color: root.colors.accent
                }

                TextField {
                    id: input

                    Layout.fillWidth: true
                    background: null
                    color: root.colors.text
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    placeholderText: "Search applications..."
                    placeholderTextColor: root.colors.subtext
                    verticalAlignment: TextInput.AlignVCenter
                    onTextChanged: {
                        root.query = text;
                        root.currentIndex = 0;
                        appList.positionViewAtBeginning();
                    }
                    Keys.onDownPressed: {
                        if (root.currentIndex < root.filteredApps.length - 1)
                            root.currentIndex++;
                        appList.positionViewAtIndex(root.currentIndex, ListView.Contain);
                    }
                    Keys.onUpPressed: {
                        if (root.currentIndex > 0)
                            root.currentIndex--;
                        appList.positionViewAtIndex(root.currentIndex, ListView.Contain);
                    }
                    Keys.onReturnPressed: {
                        if (root.filteredApps.length > 0) {
                            var app = root.filteredApps[root.currentIndex];
                            root.incrementUsage(app.id);
                            app.execute();
                            globalState.launcherOpen = false;
                        }
                    }
                }

                Text {
                    text: root.filteredApps.length + " apps"
                    font.pixelSize: 11
                    color: root.colors.subtext
                    opacity: 0.7
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width - 24
                anchors.horizontalCenter: parent.horizontalCenter
                height: 1
                color: root.colors.border
                opacity: 0.3
            }
        }

        // App list container
        Item {
            id: listContainer
            anchors.top: searchHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 8

            // Smooth-moving highlight
            Rectangle {
                id: highlight
                
                visible: root.filteredApps.length > 0
                x: 4
                y: root.currentIndex * (root.itemHeight + root.itemSpacing) - appList.contentY
                width: listContainer.width - 8
                height: root.itemHeight
                radius: 10
                color: root.colors.accent
                z: 0

                Behavior on y {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.8
                    }
                }
            }

            ListView {
                id: appList

                anchors.fill: parent
                model: root.filteredApps
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                spacing: root.itemSpacing

                delegate: Item {
                    width: appList.width
                    height: root.itemHeight

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.currentIndex = index
                        onClicked: {
                            root.incrementUsage(modelData.id);
                            modelData.execute();
                            globalState.launcherOpen = false;
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Image {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            fillMode: Image.PreserveAspectFit
                            source: {
                                if (modelData.icon.indexOf("/") !== -1)
                                    return "file://" + modelData.icon;
                                return "image://icon/" + modelData.icon;
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.name
                                color: root.currentIndex === index ? root.colors.bg : root.colors.text
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                                elide: Text.ElideRight

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            Text {
                                text: modelData.comment || ""
                                color: root.currentIndex === index ? Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.7) : root.colors.subtext
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                visible: text !== ""

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }

                        Text {
                            text: "↵"
                            color: root.currentIndex === index ? root.colors.bg : root.colors.subtext
                            font.pixelSize: 12
                            opacity: root.currentIndex === index ? 0.8 : 0.4
                            visible: root.currentIndex === index
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }
            }

            // Empty state with animation
            Column {
                anchors.top: parent.top
                anchors.topMargin: 24
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                visible: root.filteredApps.length === 0

                // Animated emoji
                Text {
                    id: emptyIcon
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🤷"
                    font.pixelSize: 40

                    SequentialAnimation on y {
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 0
                            to: -6
                            duration: 800
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            from: -6
                            to: 0
                            duration: 800
                            easing.type: Easing.InOutSine
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No apps found"
                    color: root.colors.text
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    opacity: 0.6
                }
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 0.6
            }
        }
    }
}
