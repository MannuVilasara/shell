import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Rectangle {
    id: root

    required property var manager

    color: "transparent"
    clip: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 10

            StyledText {
                text: Translation.tr("Notifications")
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: Font.Bold
                color: Appearance.colors.colOnLayer1
                Layout.fillWidth: true
            }

            RippleButton {
                Layout.preferredWidth: 70
                Layout.preferredHeight: 28
                buttonRadius: Appearance.rounding.small
                colBackground: Appearance.colors.colLayer3
                colBackgroundHover: Appearance.colors.colLayer3Hover
                colRipple: Appearance.colors.colLayer3Active
                text: Translation.tr("Clear")

                onClicked: {
                    Notifications.clearHistory()
                }

                contentItem: StyledText {
                    text: Translation.tr("Clear")
                    color: Appearance.colors.colOnLayer3
                    font.bold: true
                    font.pixelSize: Appearance.font.pixelSize.small
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Notifications.appNameList.length === 0

            StyledText {
                anchors.centerIn: parent
                text: Translation.tr("No new notifications")
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.normal
            }
        }

        NotificationListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Notifications.appNameList.length > 0
            popup: false
        }
    }
}

