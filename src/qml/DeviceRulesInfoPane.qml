import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The page with the settings of a DeviceRule
Kirigami.Page {
    Kirigami.ColumnView.fillWidth: true
    Kirigami.ColumnView.minimumWidth: UIConstants.infoPane.minWidth

    Rectangle {
        anchors.fill: parent
        color: "blue"
    }

    QQC.Switch {
        text: "Device rule setting"
    }
}
