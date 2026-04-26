import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The page with the settings of a trigger/gesture
Kirigami.Page {
   id: root

   Kirigami.ColumnView.fillWidth: true
   Kirigami.ColumnView.minimumWidth: UIConstants.infoPane.minWidth

   padding: 0

   ColumnLayout {
      anchors.fill: parent

      QQC.TabBar {
         id: tabBar

         //---------------Keyboard navigation---------------DOWN
         activeFocusOnTab: true

         onActiveFocusChanged: {
            if (activeFocus)
               currentItem.forceActiveFocus(focusReason);
         }
         //---------------Keyboard navigation---------------UP

         Layout.fillWidth: true

         InfoPaneTabButton {
            tabBar:  tabBar

            text: "Tab 1"
            width: UIConstants.infoPane.minWidth / tabBar.count
         }
         InfoPaneTabButton {
            tabBar:  tabBar

            text: "Tab 2"
            width: UIConstants.infoPane.minWidth / tabBar.count
         }
         InfoPaneTabButton {
            tabBar:  tabBar

            text: "Tab three"
            width: UIConstants.infoPane.minWidth / tabBar.count
         }
      }

      QQC.Switch {
         focus: true

         text: "Trigger setting"
      }

      Item {
         Layout.fillHeight: true
      }
   }
}
