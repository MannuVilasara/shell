import "../Components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

BentoCard {
    id: root

    required property var colors
    required property var pam
    property alias inputField: inputField

    cardColor: "#1e1e2e"
    borderColor: inputField.activeFocus ? root.colors.accent : root.colors.border

    Timer {
        id: cursorTimer

        interval: 500
        running: true
        repeat: true
        onTriggered: cursor.visible = !cursor.visible
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8
        width: parent.width - 32

        Text {
            text: Quickshell.env("USER") + "@" + (hostnameProc.hostname || "arch") + ":~$ auth"
            color: root.colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            Layout.alignment: Qt.AlignLeft
            visible: true
        }

        Process {
            id: hostnameProc

            property string hostname: ""

            command: ["cat", "/etc/hostname"]
            running: true

            stdout: SplitParser {
                onRead: (data) => {
                    return hostnameProc.hostname = data.trim();
                }
            }

        }

        RowLayout {
            spacing: 0

            Text {
                text: "> "
                color: root.colors.secondary // Pink/Purple prompt
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                font.bold: true
            }

            Row {
                spacing: 0

                Repeater {
                    model: dotModel

                    Text {
                        id: dotText

                        text: "•"
                        color: root.colors.fg
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 20
                        font.bold: true
                        scale: 0
                        opacity: 0
                        Component.onCompleted: entryAnim.start()

                        ParallelAnimation {
                            id: entryAnim

                            NumberAnimation {
                                target: dotText
                                property: "opacity"
                                to: 1
                                duration: 150
                            }

                            NumberAnimation {
                                target: dotText
                                property: "scale"
                                to: 1
                                duration: 150
                                easing.type: Easing.OutBack
                            }

                        }

                    }

                }

            }

            Rectangle {
                id: cursor

                Layout.preferredWidth: 2
                Layout.preferredHeight: 20
                color: root.colors.fg
                visible: true
            }

        }

        Text {
            id: statusText

            text: ""
            color: root.colors.urgent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: true
            visible: text !== ""
            Layout.topMargin: 4
        }

    }

    TextInput {
        id: inputField

        anchors.fill: parent
        color: "transparent"
        cursorVisible: false
        selectionColor: "transparent"
        selectedTextColor: "transparent"
        focus: true
        Component.onCompleted: forceActiveFocus()
        onTextChanged: {
            while (dotModel.count < text.length)dotModel.append({
            })
            while (dotModel.count > text.length)dotModel.remove(dotModel.count - 1)
        }
        onAccepted: {
            if (text.length > 0) {
                root.pam.submit(text);
                statusText.text = "authenticating...";
                statusText.color = root.colors.subtext;
                text = "";
            }
        }

        cursorDelegate: Item {
        }

    }

    Connections {
        function onFailure() {
            statusText.text = "ACCESS DENIED";
            statusText.color = root.colors.urgent;
            shakeAnim.start();
            resetTimer.start();
        }

        function onError() {
            statusText.text = "SYSTEM ERROR";
            statusText.color = root.colors.urgent;
            shakeAnim.start();
            resetTimer.start();
        }

        target: root.pam
    }

    Timer {
        id: resetTimer

        interval: 2000
        onTriggered: {
            statusText.text = "";
        }
    }

    ListModel {
        id: dotModel
    }

    SequentialAnimation {
        id: shakeAnim

        loops: 3

        NumberAnimation {
            target: shakeTransform
            property: "x"
            from: 0
            to: 10
            duration: 50
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: shakeTransform
            property: "x"
            from: 10
            to: -10
            duration: 50
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: shakeTransform
            property: "x"
            from: -10
            to: 0
            duration: 50
            easing.type: Easing.InOutQuad
        }

    }

    transform: Translate {
        id: shakeTransform
    }

}
