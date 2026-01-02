import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Core
import qs.Services

Item {
    id: root

    required property var theme
    property real cpuUsage: 0
    property real memUsage: 0
    property real memUsed: 0
    property real memTotal: 0
    property real diskUsage: 0
    property real diskFree: 0
    property var cpuHistory: []
    property int maxHistory: 40
    property int updateTick: 0

    implicitWidth: 440
    implicitHeight: 420

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            cpuHistory.push(cpuUsage);
            if (cpuHistory.length > maxHistory)
                cpuHistory.shift();

            cpuHistoryChanged();
            updateTick++;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Text {
            text: "System Monitor"
            font.bold: true
            font.pixelSize: 20
            color: theme.fg
            Layout.leftMargin: 4
            opacity: 0.9
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            radius: 16
            color: Qt.rgba(0, 0, 0, 0.3)
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.margins: 16

                    Item {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24

                        Text {
                            anchors.centerIn: parent
                            text: "󰻠"
                            font.family: "Symbols Nerd Font"
                            color: theme.urgent
                            font.pixelSize: 20
                        }

                    }

                    Text {
                        text: "CPU"
                        color: theme.fg
                        font.bold: true
                        font.pixelSize: 14
                        opacity: 0.8
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: Math.round(root.cpuUsage) + "%"
                        color: theme.fg
                        font.bold: true
                        font.pixelSize: 24
                    }

                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Shape {
                        id: cpuGraph

                        anchors.fill: parent
                        anchors.bottomMargin: 8
                        layer.enabled: true
                        layer.samples: 4

                        ShapePath {
                            strokeWidth: 1
                            strokeColor: Qt.rgba(1, 1, 1, 0.05)
                            fillColor: "transparent"
                            strokeStyle: ShapePath.DashLine
                            dashPattern: [4, 4]
                            startX: 0
                            startY: cpuGraph.height * 0.25

                            PathLine {
                                x: cpuGraph.width
                                y: cpuGraph.height * 0.25
                            }

                            PathMove {
                                x: 0
                                y: cpuGraph.height * 0.5
                            }

                            PathLine {
                                x: cpuGraph.width
                                y: cpuGraph.height * 0.5
                            }

                            PathMove {
                                x: 0
                                y: cpuGraph.height * 0.75
                            }

                            PathLine {
                                x: cpuGraph.width
                                y: cpuGraph.height * 0.75
                            }

                        }

                        ShapePath {
                            strokeWidth: 0
                            strokeColor: "transparent"
                            startX: 0
                            startY: cpuGraph.height

                            PathPolyline {
                                path: {
                                    var _ = root.updateTick;
                                    var p = [];
                                    var w = cpuGraph.width;
                                    var h = cpuGraph.height;
                                    if (w <= 0 || h <= 0)
                                        return [];

                                    var step = w / (Math.max(2, maxHistory - 1));
                                    for (var i = 0; i < cpuHistory.length; i++) {
                                        var x = i * step;
                                        var val = cpuHistory[i];
                                        var y = h - (val / 100 * h);
                                        p.push(Qt.point(x, y));
                                    }
                                    if (p.length > 0) {
                                        p.push(Qt.point((cpuHistory.length - 1) * step, h));
                                        p.push(Qt.point(0, h));
                                    }
                                    return p;
                                }
                            }

                            fillGradient: LinearGradient {
                                x1: 0
                                y1: 0
                                x2: 0
                                y2: cpuGraph.height

                                GradientStop {
                                    position: 0
                                    color: Qt.rgba(theme.urgent.r, theme.urgent.g, theme.urgent.b, 0.5)
                                }

                                GradientStop {
                                    position: 1
                                    color: "transparent"
                                }

                            }

                        }

                        ShapePath {
                            strokeWidth: 3
                            strokeColor: theme.urgent
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            joinStyle: ShapePath.RoundJoin
                            startX: 0
                            startY: cpuGraph.height

                            PathPolyline {
                                path: {
                                    var _ = root.updateTick;
                                    var p = [];
                                    var w = cpuGraph.width;
                                    var h = cpuGraph.height;
                                    if (w <= 0 || h <= 0)
                                        return [];

                                    var step = w / (Math.max(2, maxHistory - 1));
                                    for (var i = 0; i < cpuHistory.length; i++) {
                                        var x = i * step;
                                        var val = cpuHistory[i];
                                        var y = h - (val / 100 * h);
                                        p.push(Qt.point(x, y));
                                    }
                                    return p;
                                }
                            }

                        }

                    }

                }

            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            spacing: 16

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 16
                color: Qt.rgba(0, 0, 0, 0.3)
                border.color: Qt.rgba(1, 1, 1, 0.1)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "RAM"
                            color: theme.fg
                            font.bold: true
                            font.pixelSize: 14
                            opacity: 0.8
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Shape {
                            anchors.centerIn: parent
                            width: 100
                            height: 100

                            ShapePath {
                                strokeWidth: 10
                                strokeColor: Qt.rgba(1, 1, 1, 0.1)
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap

                                PathAngleArc {
                                    centerX: 50
                                    centerY: 50
                                    radiusX: 45
                                    radiusY: 45
                                    startAngle: 135
                                    sweepAngle: 270
                                }

                            }

                            ShapePath {
                                strokeWidth: 10
                                strokeColor: theme.accent
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap

                                PathAngleArc {
                                    centerX: 50
                                    centerY: 50
                                    radiusX: 45
                                    radiusY: 45
                                    startAngle: 135
                                    sweepAngle: 270 * (root.memUsage / 100)
                                }

                            }

                        }

                        Column {
                            anchors.centerIn: parent

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Math.round(root.memUsage) + "%"
                                color: theme.fg
                                font.bold: true
                                font.pixelSize: 20
                            }

                        }

                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            var used = (root.memUsed / 1024 / 1024 / 1024).toFixed(1);
                            var total = (root.memTotal / 1024 / 1024 / 1024).toFixed(1);
                            return used + " / " + total + " GB";
                        }
                        color: theme.subtext
                        font.pixelSize: 12
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 16
                color: Qt.rgba(0, 0, 0, 0.3)
                border.color: Qt.rgba(1, 1, 1, 0.1)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "󰋊"
                            font.family: "Symbols Nerd Font"
                            color: theme.green
                            font.pixelSize: 16
                        }

                        Text {
                            text: "Disk"
                            color: theme.fg
                            font.bold: true
                            font.pixelSize: 14
                            opacity: 0.8
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Free Space"
                                color: theme.fg
                                opacity: 0.5
                                font.pixelSize: 12
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: {
                                    var val = root.diskFree;
                                    if (val > 1024 * 1024 * 1024 * 1024)
                                        return (val / (1024 * 1024 * 1024 * 1024)).toFixed(1) + " TB";

                                    if (val > 1024 * 1024 * 1024)
                                        return (val / (1024 * 1024 * 1024)).toFixed(1) + " GB";

                                    return (val / (1024 * 1024)).toFixed(0) + " MB";
                                }
                                color: theme.fg
                                font.pixelSize: 24
                                font.bold: true
                            }

                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 8
                        radius: 4
                        color: Qt.rgba(1, 1, 1, 0.1)

                        Rectangle {
                            height: parent.height
                            width: parent.width * (root.diskUsage / 100)
                            radius: 4
                            color: theme.green
                        }

                    }

                }

            }

        }

    }

}
