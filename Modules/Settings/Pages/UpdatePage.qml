import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Widgets

ColumnLayout {
    id: root
    
    property var context
    property var colors: context.colors
    
    // Model for incoming commits
    ListModel {
        id: commitsModel
    }

    property bool checking: false
    property bool updating: false
    property int commitCount: 0
    property string statusMessage: "Check for updates to see what's new."

    // Git Fetch Process
    Process {
        id: fetchProc
        command: ["git", "fetch", "origin"]
        workingDirectory: Quickshell.shellPath(".")
        
        stderr: SplitParser {
            onRead: (data) => root.statusMessage = "Git Error (" + Quickshell.shellPath(".") + "): " + data.trim()
        }

        onExited: (code, status) => {
            if (code === 0) {
                countProc.running = true;
            } else {
                root.checking = false;
                if (root.statusMessage.indexOf("Git Error") === -1) {
                     root.statusMessage = "Fetch failed (" + Quickshell.shellPath(".") + ") with code: " + code;
                }
            }
        }
    }

    // Git Count Process
    Process {
        id: countProc
        command: ["git", "rev-list", "--count", "HEAD..@{u}"]
        workingDirectory: Quickshell.shellPath(".")
        
        stdout: SplitParser {
            onRead: (data) => {
                var count = parseInt(data.trim());
                if (!isNaN(count)) {
                    root.commitCount = count;
                }
            }
        }
        
        stderr: SplitParser {
            onRead: (data) => root.statusMessage = "Count Error: " + data.trim()
        }
        
        onExited: (code) => {
            if (code !== 0) {
                root.checking = false;
                if (root.statusMessage.indexOf("Count Error") === -1)
                    root.statusMessage = "Count check failed code: " + code;
            } else {
                if (root.commitCount > 0) {
                    root.statusMessage = "Found " + root.commitCount + " updates. Fetching logs...";
                    commitsModel.clear();
                    logProc.running = true;
                } else {
                    root.checking = false;
                    root.statusMessage = "You are up to date. (Count: 0)";
                    commitsModel.clear();
                }
            }
        }
    }

    // Git Log Process
    Process {
        id: logProc
        // Format: hash|author|message
        command: ["git", "log", "HEAD..@{u}", "--pretty=format:%h|%an|%s"]
        workingDirectory: Quickshell.shellPath(".")
        
        stdout: SplitParser {
            onRead: (data) => {
                const lines = data.trim().split('\n');
                for (const line of lines) {
                    if (!line || line.trim() === "") continue;
                    const parts = line.split('|');
                    if (parts.length >= 3) {
                        commitsModel.append({
                            hash: parts[0],
                            author: parts[1],
                            message: parts.slice(2).join('|')
                        });
                    }
                }
            }
        }
        
        stderr: SplitParser {
            onRead: (data) => root.statusMessage = "Log Error: " + data.trim()
        }
        
        onExited: (code) => {
             root.checking = false;
             if (code !== 0) {
                 if (root.statusMessage.indexOf("Log Error") === -1)
                     root.statusMessage = "Log failed code: " + code;
             } else {
                 if (commitsModel.count > 0) {
                    root.statusMessage = root.commitCount + " new updates available.";
                 } else {
                    root.statusMessage = "Parsed 0 commits. (Count was " + root.commitCount + ")";
                 }
             }
        }
    }

    // Git Pull Process
    Process {
        id: pullProc
        command: ["git", "pull"]
        workingDirectory: Quickshell.shellPath(".")
        
        onExited: (code) => {
            root.updating = false;
            if (code === 0) {
                root.statusMessage = "Updated successfully! Restart recommended.";
                root.commitCount = 0;
                commitsModel.clear();
            } else {
                root.statusMessage = "Update failed. Check logs.";
            }
        }
    }
    
    spacing: 16

    Text {
        text: "Update"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }
    
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        color: colors.surface
        radius: 12
        border.width: 1
        border.color: Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.3)
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20
            
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 24
                color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.1)
                
                Text {
                    anchors.centerIn: parent
                    text: root.commitCount > 0 ? "󱧕" : "󰄬"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 24
                    color: colors.accent
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: root.checking ? "Checking..." : root.updating ? "Updating..." : root.statusMessage
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: colors.fg
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Text {
                    text: root.commitCount > 0 ? "Review the changes below before updating." : "Your shell is running the latest version."
                    font.pixelSize: 13
                    color: colors.muted
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            
            Button {
                text: root.commitCount > 0 ? "Update Now" : "Check for Updates"
                enabled: !root.checking && !root.updating
                
                contentItem: Text {
                    text: parent.text
                    color: colors.bg
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.Bold
                }

                background: Rectangle {
                    color: parent.enabled ? colors.accent : colors.muted
                    radius: 8
                }
                
                onClicked: {
                    if (root.commitCount > 0) {
                        root.updating = true;
                        pullProc.running = true;
                    } else {
                        root.checking = true;
                        fetchProc.running = true;
                        root.statusMessage = "Checking for updates...";
                    }
                }
                
                // Cursor
                HoverHandler {
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
        }
    }
    
    // Commits List
    
    Text {
        text: "Incoming Changes"
        font.pixelSize: 15
        font.weight: Font.Bold
        color: colors.fg
        visible: root.commitCount > 0
        Layout.topMargin: 8
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: root.commitCount > 0
        
        Repeater {
            model: commitsModel
            
            delegate: Rectangle {
                Layout.fillWidth: true
                height: 60
                color: colors.surface
                radius: 8
                border.width: 1
                border.color: Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.3)
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.1)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰊢"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: colors.fg
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Text {
                                text: model.message
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: colors.fg
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: model.hash
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                color: colors.muted
                            }
                        }
                        
                        Text {
                            text: "by " + model.author
                            font.pixelSize: 12
                            color: colors.muted
                        }
                    }
                }
            }
        }
    }
    
    Item {
        Layout.fillHeight: true
        visible: root.commitCount == 0
    }
}
