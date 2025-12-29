import QtQuick
import Quickshell
import Quickshell.Services.Pam

QtObject {
    id: root

    property string buffer: ""
    property bool authenticating: false
    property PamContext pamCtx

    signal success()
    signal failure()
    signal error()

    function submit(password) {
        if (password === "")
            return ;

        console.log("[PamAuth] Starting authentication");
        buffer = password;
        authenticating = true;
        pamCtx.start();
    }

    pamCtx: PamContext {
        config: "passwd"
        onResponseRequiredChanged: {
            if (responseRequired) {
                respond(root.buffer);
                root.buffer = ""; // Clear buffer immediately
            }
        }
        onCompleted: (result) => {
            root.authenticating = false;
            if (result === PamResult.Success) {
                console.log("[PamAuth] Authentication success");
                root.success();
            } else {
                console.log("[PamAuth] Authentication failed with result:", result);
                if (result === PamResult.Error)
                    root.error();
                else
                    root.failure();
            }
        }
    }

}
