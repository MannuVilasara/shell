import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    anchors.fill: parent

    // Active wallpaper source
    property string source: ""
    property Image currentImage: img1

    // --- 1. PREP: Ensure Directory Exists ---
    // We still need this because FileView won't create folders for us.
    Process {
        id: dirCreator
        command: ["mkdir", "-p", Quickshell.env("HOME") + "/.cache/mannu"]
        running: true
    }

    // --- 2. STORAGE: FileView with JsonAdapter ---
    FileView {
        id: wallpaperCache
        path: Quickshell.env("HOME") + "/.cache/mannu/wallpaper.json"

        // Use the JsonAdapter as documented
        adapter: JsonAdapter {
            id: wallpaperAdapter
            // This property maps to the JSON key "path"
            property string path: ""
        }

        // LOAD: When file is read, update the UI
        onLoaded: {
            if (wallpaperAdapter.path && wallpaperAdapter.path !== "") {
                console.log("[Wallpaper] Loaded:", wallpaperAdapter.path);
                root.source = wallpaperAdapter.path;
            }
        }
    }

    // --- 3. LOGIC: Update & Save ---
    onSourceChanged: {
        // A. Visual Double-Buffering
        if (source === "") {
            currentImage = null;
        } else {
            var nextImage = (currentImage === img1) ? img2 : img1;
            nextImage.source = root.source;
        }

        // B. Save to Disk using Native API
        // We ensure the directory process has started at least once
        if (source !== "") {
            // 1. Update the Adapter's internal property
            wallpaperAdapter.path = source;

            // 2. Commit the Adapter to disk
            // This function takes the properties of JsonAdapter and writes them to the file.
            wallpaperCache.writeAdapter();
        }
    }

    // --- 4. File Picker ---
    Process {
        id: pickerProcess
        command: ["kdialog", "--title", "Select Wallpaper", "--getopenfilename", ".", "image/jpeg image/png image/webp image/svg+xml"]
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim();
                if (output !== "") {
                    // This triggers onSourceChanged -> which updates Adapter -> which calls writeAdapter()
                    root.source = "file://" + output;
                }
            }
        }
    }

    // --- 5. IPC Handler ---
    IpcHandler {
        target: "wallpaper"
        function setWallpaper() {
            pickerProcess.running = true;
        }
    }
    // --- 6. Visuals (Placeholder & Images) ---
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        visible: root.source === ""
        z: 10
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            Text {
                text: "☹"
                font.pixelSize: 64
                color: "#f38ba8"
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: "Wallpaper missing?"
                color: "#cdd6f4"
                font.bold: true
                font.pixelSize: 24
            }
            Rectangle {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 40
                radius: 20
                color: mouseArea.pressed ? "#cba6f7" : "#313244"
                Text {
                    anchors.centerIn: parent
                    text: "Select via Dolphin"
                    color: "#cdd6f4"
                    font.bold: true
                }
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pickerProcess.running = true
                }
            }
        }
    }

    Image {
        id: img1
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: (root.currentImage === img1) ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }
        onStatusChanged: if (status === Image.Ready && root.currentImage !== img1 && source == root.source)
            root.currentImage = img1
    }

    Image {
        id: img2
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: (root.currentImage === img2) ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }
        onStatusChanged: if (status === Image.Ready && root.currentImage !== img2 && source == root.source)
            root.currentImage = img2
    }
}
