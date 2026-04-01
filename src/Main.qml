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

      //-------------General properties-------------DOWN
      // Qt.LeftToRight for English, Qt.RightToLeft for Arabic
      property int text_alignment: Qt.application.layoutDirection
      property int text_alignment_reverse: Qt.application.layoutDirection === Qt.LeftToRight ? Qt.RightToLeft : Qt.LeftToRight

      // Qt.AlignLeft for English, Qt.AlignRight for Arabic
      property int layout_alignment: !LayoutMirroring.enabled ? Qt.AlignLeft : Qt.AlignRight
      property int layout_alignment_reverse: !LayoutMirroring.enabled ? Qt.AlignRight : Qt.AlignLeft
      //-------------General properties-------------UP

      //-------------DevicesPage properties-------------DOWN
      property int deviceInset: Kirigami.Units.smallSpacing
      property int devicePadding: deviceInset + Kirigami.Units.smallSpacing
      property int gestureInset: Kirigami.Units.smallSpacing * 3 + Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
      property int gesturePadding: gestureInset + Kirigami.Units.smallSpacing
      //-------------DevicesPage properties-------------UP

      padding: 0

      //-------------------Error pop-ups-------------------DOWN
      // FATAL — dismiss exits the app, no background dismiss
      Kirigami.PromptDialog {
         id: fatalErrorDialog
         title: i18nc("@title:window", "Critical Error")
         property string message: ""
         subtitle: message
         standardButtons: Kirigami.Dialog.Close
         closePolicy: QQC.Popup.NoAutoClose

         onRejected: Qt.quit()
      }

      // NON-FATAL — dismiss keeps app open, no background dismiss
      Kirigami.PromptDialog {
         id: errorDialog
         title: i18nc("@title:window", "Error")
         property string message: ""
         subtitle: message
         standardButtons: Kirigami.Dialog.Close
         closePolicy: QQC.Popup.NoAutoClose

         onRejected: errorDialog.close()
      }

      // CORRUPT CONFIG — clear config or exit the app, no background dismiss
      Kirigami.PromptDialog {
         id: corruptConfigDialog
         title: i18nc("@title:window", "Config File Corrupted")
         property string message: ""
         subtitle: message
         standardButtons: Kirigami.Dialog.Yes | Kirigami.Dialog.No
         closePolicy: QQC.Popup.NoAutoClose

         onAccepted: {
            yesNoDialog.ask(i18nc("@title:window yes/no pop-up", "Clear the config?"),
                            i18nc("@info subtitle of a yes/no pop-up", "This action cannot be undone."),
            function (confirmed) {
               if (confirmed) {
                  config.clear();
               } else {
                  Qt.quit();
               }
            });
         }
         onRejected: Qt.quit()
      }

      // YES/NO confirmation dialog
      // usage: yesNoDialog.ask("Delete file?", "This action cannot be undone.",
      // function(confirmed) { if(confirmed) { file.delete(); } else { file.dontDelete(); } })
      Kirigami.PromptDialog {
         id: yesNoDialog
         standardButtons: Kirigami.Dialog.Yes | Kirigami.Dialog.No

         property string _title: ""
         property string _subtitle: ""
         property var callback: null

         title: _title
         subtitle: _subtitle

         function ask(__title, __subtitle, __callback) {
            _title = __title;
            _subtitle = __subtitle;
            callback = __callback;
            open();
         }

         onAccepted: if (callback)
            callback(true)
         onRejected: if (callback)
            callback(false)
      }

      Connections {
         target: config
         function onFatalError(message) {
            fatalErrorDialog.message = message;
            fatalErrorDialog.open();
         }
         function onError(message) {
            errorDialog.message = message;
            errorDialog.open();
         }
         function onConfigCorrupted(message) {
            corruptConfigDialog.message = message;
            corruptConfigDialog.open();
         }
         // function onAppNotFound() {
         //     fatalErrorDialog.message = "InputActions is not installed or could not be found."
         //     fatalErrorDialog.open()
         // }
      }
      //-------------------Error pop-ups-------------------UP

      QQC.SplitView {
         id: split

         anchors.fill: parent
         orientation: ListView.Horizontal

         // page with the devices
         DevicesPage {
            // at minimalWidth, one can still see what item is selected
            QQC.SplitView.minimumWidth: main_page.gesturePadding
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
