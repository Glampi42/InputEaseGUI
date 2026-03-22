import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

Kirigami.ActionToolBar {
    id: main_toolbar

    Kirigami.Theme.colorSet: Kirigami.Theme.Header
    Kirigami.Theme.inherit: false
    alignment: main_page.global_alignment

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }

    actions: [
        Kirigami.Action {
            text: "Test"
            icon.name: "search"
        }

    ]
}
