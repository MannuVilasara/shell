import Quickshell
import qs.Core
import qs.Modules.Background
import qs.Modules.Bar
import qs.Modules.Corners
import qs.Modules.Lock
import qs.Modules.Overlays
import qs.Modules.Settings
import qs.Services

ShellRoot {
    id: root

    Context {
        id: ctx
    }

    Background {
    }

    Lock {
        context: ctx
    }

    ScreenCorners {
        context: ctx
    }

    Overlays {
        context: ctx
    }

    BarWindow {
        context: ctx
    }

    SettingsWindow {
        context: ctx
    }

}
