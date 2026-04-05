import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The secondary sidebar that is conditionally displayed next to the MainDrawer
Kirigami.Page {
    Kirigami.ColumnView.interactiveResizeEnabled: true
    Kirigami.ColumnView.preferredWidth: 200
    Kirigami.ColumnView.minimumWidth: 100
    Kirigami.ColumnView.maximumWidth: 200

    QQC.Label {
        text: "I'm Mr. Sidebar, look at me!"
    }
}
