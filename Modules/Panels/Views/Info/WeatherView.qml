import "../../../../Services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

ColumnLayout {
    id: root

    // Required property: pass your theme object when calling this component
    required property var theme

    spacing: 16

    // --- Main Weather Card ---
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 140
        radius: 24
        border.color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.2)
        border.width: 1
        clip: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 24

            // Weather Icon (Large)
            Item {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: WeatherService.icon
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 64
                    color: theme.accent
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.1)
                }

            }

            // Text Info
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                Text {
                    text: WeatherService.temperature
                    color: theme.fg
                    font.bold: true
                    font.pixelSize: 42
                }

                Text {
                    text: WeatherService.conditionText
                    color: theme.subtext
                    font.pixelSize: 14
                    font.capitalization: Font.Capitalize
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Location Row
                RowLayout {
                    Layout.topMargin: 6
                    spacing: 6

                    Text {
                        text: ""
                        color: theme.blue
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 12
                    }

                    Text {
                        text: WeatherService.city
                        color: theme.subtext
                        font.pixelSize: 12
                        font.bold: true
                        opacity: 0.9
                    }

                }

            }

        }

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.15)
            }

            GradientStop {
                position: 1
                color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.15)
            }

        }

    }

    // --- Details Grid ---
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 12
        columnSpacing: 12

        WeatherDetailItem {
            icon: "󰖎"
            label: "Humidity"
            value: WeatherService.humidity
            iconTint: theme.blue
        }

        WeatherDetailItem {
            icon: "󰖝"
            label: "Wind"
            value: WeatherService.wind
            iconTint: theme.cyan
        }

        WeatherDetailItem {
            icon: "󰖒"
            label: "Pressure"
            value: WeatherService.pressure
            iconTint: theme.green
        }

        WeatherDetailItem {
            icon: "󰖕"
            label: "UV Index"
            value: WeatherService.uvIndex
            iconTint: theme.yellow
        }

    }

    // --- Weekly Forecast Section (Horizontal Square Cards) ---
    ColumnLayout {
        Layout.fillWidth: true
        Layout.topMargin: 12
        spacing: 12

        Text {
            text: "5-Day Forecast"
            color: theme.fg
            font.bold: true
            font.pixelSize: 15
            opacity: 0.9
            Layout.leftMargin: 4
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: WeatherService.forecastModel

                Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 110 // Height to create a square-ish aspect ratio
                    radius: 16
                    color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.4)
                    border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08)
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        // Day Name
                        Text {
                            text: modelData.day
                            color: theme.subtext
                            font.pixelSize: 13
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // Weather Icon
                        Text {
                            text: modelData.icon
                            font.family: "Symbols Nerd Font"
                            color: theme.accent
                            font.pixelSize: 28
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // Temperature Range
                        Text {
                            text: modelData.max + " / " + modelData.min
                            color: theme.fg
                            font.pixelSize: 12
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                    }

                }

            }

        }

    }

    // --- Reusable Detail Component ---
    component WeatherDetailItem: Rectangle {
        property string icon
        property string label
        property string value
        property color iconTint: theme.accent

        Layout.fillWidth: true
        Layout.preferredHeight: 70
        radius: 16
        color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.4)
        border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 12
                color: Qt.rgba(iconTint.r, iconTint.g, iconTint.b, 0.15)

                Text {
                    anchors.centerIn: parent
                    text: icon
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: iconTint
                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: label
                    color: theme.subtext
                    font.pixelSize: 11
                    opacity: 0.8
                }

                Text {
                    text: value
                    color: theme.fg
                    font.pixelSize: 14
                    font.bold: true
                }

            }

        }

    }

}
