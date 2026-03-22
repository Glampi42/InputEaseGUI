// Includes relevant modules used by the QML
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// main window
Kirigami.ApplicationWindow {
    id: root

    property int window_width: 400
    property int window_height: 300

    width: root.window_width
    height: root.window_height
    visible: true

    // Window title
    // i18nc() makes a string translatable
    // and provides additional context for the translators
    title: i18nc("@title:window", "Input Ease GUI")

    Component.onCompleted: {
        pageStack.globalToolBar.style = Kirigami.ApplicationHeaderStyle.None
    }

    header: MainToolbar {}

    pageStack.initialPage: Kirigami.Page {
        id: main_page

        property int global_alignment: Qt.application.layoutDirection

        padding: 0

        QQC.SplitView {
            id: split

            anchors.fill: parent
            orientation: ListView.Horizontal

            // page with the devices
            DevicesPage {
                QQC.SplitView.minimumWidth: 50
                QQC.SplitView.preferredWidth: 0.3820*root.window_width // golden ratio
            }

            QQC.Frame {
                QQC.SplitView.minimumWidth: 50
                QQC.SplitView.preferredWidth: 0.6180*root.window_width // golden ratio

                QQC.Button {
                    text: "Another"
                }
            }
        }
    }
}