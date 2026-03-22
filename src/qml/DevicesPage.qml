import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    QQC.Label {
        // Center label horizontally and vertically within parent object
        anchors.centerIn: parent
        text: i18n("Devices")
    }
}
