import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.delegates

Kirigami.ScrollablePage {
   leftPadding: 0
   rightPadding: 0
   topPadding: 0
   bottomPadding: 0

   Kirigami.Theme.colorSet: Kirigami.Theme.View

   ColumnLayout {
      anchors.fill: parent
      anchors.margins: 0

      spacing: 0

      RoundedItemDelegate {
         Layout.fillWidth: true

         text: i18nc("@item:inmenu", "General Settings")
         icon.name: "configure"
      }

      Item {
         implicitHeight: Kirigami.Units.largeSpacing
      }

      Kirigami.Heading {
         leftPadding: Kirigami.Units.smallSpacing * 2

         text: i18nc("@title:menu", "Devices & Gestures")
      }

      Item {
         implicitHeight: Kirigami.Units.smallSpacing
      }

      Kirigami.Separator {
         Layout.fillWidth: true
      }

      ListView {
         id: devices_tree

         Layout.fillWidth: true
         Layout.fillHeight: true

         model: devices_model

         delegate: RoundedItemDelegate {
            id: tree_delegate

            required property int index
            required property bool kDescendantExpanded

            required property string nameRole
            required property bool isGestureRole

            text: nameRole

            leftInset: isGestureRole ? 20 : Kirigami.Units.smallSpacing
            leftPadding: leftInset + Kirigami.Units.smallSpacing

            onClicked: {
               if (!isGestureRole) {
                  // const role = devices_model.roleForName("kDescendantIsExpanded");
                  // devices_model.setData(devices_model.index(tree_delegate.index, 0), !kDescendantExpanded, role);

                  // const srcIdx = devices_model.mapToSource(devices_model.index(tree_delegate.index, 0));
                  // if (kDescendantExpanded)
                  //    devices_model.collapseSourceIndex(srcIdx);
                  // else
                  //    devices_model.expandSourceIndex(srcIdx);

                  if (kDescendantExpanded)
                     devices_model.collapse(tree_delegate.index)
                  else
                     devices_model.expand(tree_delegate.index)
               }
            }

            Kirigami.Icon {
               anchors.right: parent.right
               anchors.rightMargin: Kirigami.Units.smallSpacing*2
               anchors.verticalCenter: parent.verticalCenter

               visible: !tree_delegate.isGestureRole
               source: "arrow-right"
               width: Kirigami.Units.iconSizes.small
               height: width
               isMask: true

               rotation: tree_delegate.kDescendantExpanded ? 90 : 0
               Behavior on rotation {
                  NumberAnimation {
                     duration: Kirigami.Units.shortDuration
                     easing.type: Easing.InOutCubic
                  }
               }
            }
         }
      }
   }
}
