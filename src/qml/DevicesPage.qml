import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.delegates

Kirigami.ScrollablePage {
   ListView {
      id: devices_tree

      model: devices_model

      delegate: RoundedTreeDelegate {
         id: tree_delegate

         required property string nameRole
         required property bool isGestureRole

         contentItem: QQC.Label {
            text: nameRole
         }
      }
   }
}
