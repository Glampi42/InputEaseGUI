import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The page with the general settings
Kirigami.Page {
    Kirigami.ColumnView.fillWidth: true
    Kirigami.ColumnView.minimumWidth: UIConstants.infoPane.minWidth

    QQC.Switch {
        text: "General setting"
    }
}
