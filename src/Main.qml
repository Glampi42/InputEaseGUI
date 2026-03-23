// Includes relevant modules used by the QML
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// main window
Kirigami.ApplicationWindow {
   id: root

   property int window_width: 800
   property int window_height: 500

   width: root.window_width
   height: root.window_height
   visible: true

   // Window title
   // i18nc() makes a string translatable
   // and provides additional context for the translators
   title: i18nc("@title:window", "Input Ease GUI")

   Component.onCompleted: {
      pageStack.globalToolBar.style = Kirigami.ApplicationHeaderStyle.None;
   }

   header: MainToolbar {}

   pageStack.initialPage: Kirigami.Page {
      id: main_page

      // Qt.LeftToRight for English, Qt.RightToLeft for Arabic
      property int text_alignment: Qt.application.layoutDirection
      property int text_alignment_reverse: Qt.application.layoutDirection === Qt.LeftToRight ? Qt.RightToLeft : Qt.LeftToRight

      // Qt.AlignLeft for English, Qt.AlignRight for Arabic
      property int layout_alignment: Qt.application.layoutDirection === Qt.LeftToRight ? Qt.AlignLeft : Qt.AlignRight
      property int layout_alignment_reverse: Qt.application.layoutDirection === Qt.LeftToRight ? Qt.AlignRight : Qt.AlignLeft

      padding: 0

      QQC.SplitView {
         id: split

         anchors.fill: parent
         orientation: ListView.Horizontal

         // page with the devices
         DevicesPage {
            QQC.SplitView.minimumWidth: 50
            QQC.SplitView.preferredWidth: 0.3820 * root.window_width // golden ratio
         }

         QQC.Frame {
            QQC.SplitView.minimumWidth: 50
            QQC.SplitView.preferredWidth: 0.6180 * root.window_width // golden ratio

            QQC.Button {
               text: "Another"
            }
         }
      }
   }
}
