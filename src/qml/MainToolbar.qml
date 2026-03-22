import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

import me.glampi.inputeasegui 1.0

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
        },
        Kirigami.Action {
            displayComponent: Kirigami.Separator {
                implicitHeight: parent.height
            }
        },
        Kirigami.Action {
            text: StandardActions.save.text
            icon.name: StandardActions.save.iconName
        },
        Kirigami.Action {
            displayComponent: Kirigami.Separator {
                implicitHeight: parent.height
            }
        },
        Kirigami.Action {
            text: StandardActions.delete_action.text
            icon.name: StandardActions.delete_action.iconName
        }
    ]
}
