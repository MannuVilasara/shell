import QtQuick
import Quickshell
import qs.Services

Item {
    id: root
    anchors.fill: parent

    property string source: ""
    property string screenName: screen ? screen.name : ""

    // Listen for wallpaper changes
    Connections {
        target: WallpaperService
        
        function onWallpaperChanged(changedScreenName, path) {
            if (changedScreenName === screenName) {
                console.log("[Wallpaper] Changed for", screenName, "to", path)
                setWallpaper(path)
            }
        }
    }
    
    // Load initial wallpaper
    Connections {
        target: WallpaperService
        
        function onIsInitializedChanged() {
            if (WallpaperService.isInitialized && root.source === "") {
                loadInitialWallpaper()
            }
        }
    }
    
    Component.onCompleted: {
        if (WallpaperService.isInitialized) {
            loadInitialWallpaper()
        }
    }
    
    function loadInitialWallpaper() {
        var wp = WallpaperService.getWallpaper(screenName)
        if (wp && wp !== "") {
            console.log("[Wallpaper] Loading initial for", screenName, ":", wp)
            setWallpaper(wp)
        }
    }
    
    function setWallpaper(path) {
        var newSource = "file://" + path
        if (newSource === root.source) return
        
        console.log("[Wallpaper] Setting wallpaper to:", newSource)
        root.source = newSource
        
        // Force complete recreation of the image component
        wallpaperLoader.sourceComponent = undefined
        wallpaperLoader.sourceComponent = wallpaperComponent
    }

    // Placeholder when no wallpaper
    Rectangle {
        anchors.fill: parent
        color: "#1a1b26"
        visible: root.source === "" || wallpaperLoader.item?.status === Image.Error
    }

    // Use Loader to force recreation of Image component
    Loader {
        id: wallpaperLoader
        anchors.fill: parent
        sourceComponent: wallpaperComponent
    }
    
    Component {
        id: wallpaperComponent
        
        Image {
            id: wallpaperImage
            anchors.fill: parent
            source: root.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            
            onStatusChanged: {
                if (status === Image.Ready) {
                    console.log("[Wallpaper] Image loaded successfully:", source)
                } else if (status === Image.Loading) {
                    console.log("[Wallpaper] Image loading:", source)
                } else if (status === Image.Error) {
                    console.log("[Wallpaper] Failed to load image:", source, "error:", status)
                }
            }
        }
    }
}
