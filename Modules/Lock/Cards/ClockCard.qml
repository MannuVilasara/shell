import QtQuick
import QtQuick.Layouts
import "../Components"

BentoCard {
    id: root

    required property var colors

    property int hours: new Date().getHours()
    property int minutes: new Date().getMinutes()
    property int seconds: new Date().getSeconds()

    cardColor: colors.surface
    borderColor: colors.border

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            root.hours = now.getHours();
            root.minutes = now.getMinutes();
            root.seconds = now.getSeconds();
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        // BCD Binary display (6 columns)
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            // Hours (H1: 2 bits, H2: 4 bits)
            RowLayout {
                spacing: 6

                BinaryColumn {
                    value: Math.floor(root.hours / 10)
                    bits: 2
                    dotSize: 14
                    activeColor: root.colors.accent
                }

                BinaryColumn {
                    value: root.hours % 10
                    bits: 4
                    dotSize: 14
                    activeColor: root.colors.accent
                }
            }

            // Separator
            Rectangle {
                width: 2
                height: 80
                radius: 1
                color: root.colors.border
                opacity: 0.4
            }

            // Minutes (M1: 3 bits, M2: 4 bits)
            RowLayout {
                spacing: 6

                BinaryColumn {
                    value: Math.floor(root.minutes / 10)
                    bits: 3
                    dotSize: 14
                    activeColor: root.colors.secondary
                }

                BinaryColumn {
                    value: root.minutes % 10
                    bits: 4
                    dotSize: 14
                    activeColor: root.colors.secondary
                }
            }

            // Separator
            Rectangle {
                width: 2
                height: 80
                radius: 1
                color: root.colors.border
                opacity: 0.4
            }

            // Seconds (S1: 3 bits, S2: 4 bits)
            RowLayout {
                spacing: 6

                BinaryColumn {
                    value: Math.floor(root.seconds / 10)
                    bits: 3
                    dotSize: 14
                    activeColor: root.colors.teal
                }

                BinaryColumn {
                    value: root.seconds % 10
                    bits: 4
                    dotSize: 14
                    activeColor: root.colors.teal
                }
            }
        }

        // Digital time below
        Text {
            text: root.hours.toString().padStart(2, '0') + ":" + root.minutes.toString().padStart(2, '0') + ":" + root.seconds.toString().padStart(2, '0')
            font.pixelSize: 20
            font.weight: Font.Bold
            font.family: "JetBrainsMono Nerd Font"
            color: root.colors.fg
            Layout.alignment: Qt.AlignHCenter
        }

        // Date
        Text {
            text: Qt.formatDate(new Date(), "ddd, MMM d")
            font.pixelSize: 13
            color: root.colors.muted
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
