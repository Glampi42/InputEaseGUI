import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The secondary sidebar that is conditionally displayed next to the MainDrawer
Kirigami.Page {
    Kirigami.ColumnView.preferredWidth: UIConstants.subDrawer.width
    Kirigami.ColumnView.maximumWidth: UIConstants.subDrawer.width
    Kirigami.ColumnView.minimumWidth: UIConstants.subDrawer.width

    property int preferredWidth: Kirigami.ColumnView.preferredWidth

    QQC.Label {
        text: "I'm Mr. Sidebar, look at me!"
    }
}
