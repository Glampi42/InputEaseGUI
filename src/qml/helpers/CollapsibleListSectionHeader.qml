import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The same as Kirigami.ListSectionHeader, but when the text === "", it shows just the separator
QQC.ItemDelegate {
    id: listSection

    default property alias _contents: rowLayout.data

    hoverEnabled: false

    activeFocusOnTab: false

    icon {
        width: Kirigami.Units.iconSizes.smallMedium
        height: Kirigami.Units.iconSizes.smallMedium
    }

    // we do not need a background
    background: Item {}

    topPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing

    Accessible.role: Accessible.Heading

    contentItem: RowLayout {
        id: rowLayout
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: listSection.icon.width
            implicitHeight: listSection.icon.height
            color: listSection.icon.color
            source: listSection.icon.name.length > 0 ? listSection.icon.name : listSection.icon.source
            visible: valid
        }
        Kirigami.Heading {
            id: _heading

            Layout.maximumWidth: rowLayout.width
            Layout.alignment: Qt.AlignVCenter

            visible: listSection.text !== ""

            opacity: 0.75
            level: 5
            type: Kirigami.Heading.Primary
            text: listSection.text
            elide: Text.ElideRight

            // we override the Primary type's font weight (DemiBold) for Bold for contrast with small text
            font.weight: Font.Bold

            Accessible.ignored: true
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: _heading.implicitHeight
            Layout.alignment: Qt.AlignVCenter
            Accessible.ignored: true

            Kirigami.Separator {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
