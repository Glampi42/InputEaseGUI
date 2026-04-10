import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The page with the settings of a trigger/gesture
Kirigami.Page {
    Kirigami.ColumnView.fillWidth: true
    Kirigami.ColumnView.minimumWidth: UIConstants.infoPane.minWidth

    QQC.Switch {
        text: "Trigger setting"
    }
}
