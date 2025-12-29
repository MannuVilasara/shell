import QtQuick
import qs.Core

Item {
    id: root

    property var config: Config
    property alias colors: colorsService
    property alias cpu: cpuService
    property alias os: osService
    property alias mem: memService
    property alias disk: diskService
    property alias time: timeService
    property alias volume: volumeService
    property alias activeWindow: activeWindowService
    property alias layout: layoutService
    property alias appState: appStateService
    property var network: NetworkService

    Colors {
        id: colorsService
    }

    CpuService {
        id: cpuService
    }

    OsService {
        id: osService
    }

    MemService {
        id: memService
    }

    DiskService {
        id: diskService
    }

    TimeService {
        id: timeService
    }

    ActiveWindowService {
        id: activeWindowService
    }

    LayoutService {
        id: layoutService
    }

    GlobalState {
        id: appStateService
    }

    VolumeService {
        id: volumeService
    }

}
