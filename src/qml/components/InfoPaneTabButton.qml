import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The TabButton used in InfoPanes
QQC.TabButton {
   id: root

   required property QQC.TabBar tabBar// reference to the parent TabBar

   //---------------Keyboard navigation---------------DOWN
   activeFocusOnTab: false

   Keys.onLeftPressed: {
      if (tabBar.currentIndex > 0) {
         tabBar.itemAt(tabBar.currentIndex - 1).forceActiveFocus(Qt.TabFocusReason);
         tabBar.currentIndex--;// don't switch the order, it only works like this (idk why)
      }
   }

   Keys.onRightPressed: {
      if (tabBar.currentIndex < tabBar.count - 1) {
         tabBar.itemAt(tabBar.currentIndex + 1).forceActiveFocus(Qt.TabFocusReason);
         tabBar.currentIndex++;// don't switch the order, it only works like this (idk why)
      }
   }

   onClicked: {

   }
   //---------------Keyboard navigation---------------UP
}
