import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// main window
Kirigami.ApplicationWindow {
   id: root

   //-------------General properties-------------DOWN
   property int window_width: 800
   property int window_height: 500

   // Qt.LeftToRight for English, Qt.RightToLeft for Arabic
   property int text_alignment: Qt.application.layoutDirection
   property int text_alignment_reverse: Qt.application.layoutDirection === Qt.LeftToRight ? Qt.RightToLeft : Qt.LeftToRight

   // Qt.AlignLeft for English, Qt.AlignRight for Arabic
   property int layout_alignment: !LayoutMirroring.enabled ? Qt.AlignLeft : Qt.AlignRight
   property int layout_alignment_reverse: !LayoutMirroring.enabled ? Qt.AlignRight : Qt.AlignLeft
   //-------------General properties-------------UP

   //-------------------Pop-ups-------------------DOWN
   // FATAL — dismiss exits the app, no background dismiss
   Kirigami.PromptDialog {
      id: fatalErrorDialog
      title: i18nc("@title:window", "Critical Error")
      dialogType: Kirigami.PromptDialog.Error

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
      dialogType: Kirigami.PromptDialog.Error

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
      dialogType: Kirigami.PromptDialog.Warning

      property string message: ""
      subtitle: message

      standardButtons: Kirigami.Dialog.Yes | Kirigami.Dialog.No
      closePolicy: QQC.Popup.NoAutoClose

      onAccepted: {
         yesNoDialog.ask(i18nc("@title:window yes/no pop-up", "Clear the config?"), i18nc("@info subtitle of a yes/no pop-up", "This action cannot be undone."), function (confirmed) {
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
   //-------------------Pop-ups-------------------UP

   width: window_width
   height: window_height
   visible: true

   title: i18nc("@title:window", "Input Ease GUI")

   pageStack.columnView.columnResizeMode: Kirigami.ColumnView.DynamicColumns

   // the main toolbar with buttons that adjust their function based on the selected item
   // header: MainToolbar {}

   pageStack.leftSidebar: MainDrawer {}

   Component.onCompleted: {
      pageStack.globalToolBar.style = Kirigami.ApplicationHeaderStyle.None;

      pageStack.push(generalSettingsPage);// general settings open initially
   }

   //-----------------Pushing/popping Kirigami.Pages-----------------DOWN
   Kirigami.PagePool {
      id: pagePool
   }

   readonly property var subDrawerPage: pagePool.loadPage(Qt.resolvedUrl("SubDrawer.qml"))
   readonly property var generalSettingsPage: pagePool.loadPage(Qt.resolvedUrl("GeneralSettingsPage.qml"))
   readonly property var deviceRulesPage: pagePool.loadPage(Qt.resolvedUrl("DeviceRulesPage.qml"))
   readonly property var triggerSettingsPage: pagePool.loadPage(Qt.resolvedUrl("TriggerSettingsPage.qml"))

   Connections {
      target: mainDrawerModel

      function onSelectedItemChanged() {
         switch (mainDrawerModel.selectedItem) {
         case 0:// General Settings
            pageStack.removePage(subDrawerPage);
            pageStack.removePage(deviceRulesPage);
            pageStack.removePage(triggerSettingsPage);

            if(!containsPage(generalSettingsPage))
               pageStack.push(generalSettingsPage);
            break;
         case 1:// Device Rules
            pageStack.removePage(generalSettingsPage);
            pageStack.removePage(triggerSettingsPage);

            if(!containsPage(subDrawerPage))
               pageStack.push(subDrawerPage);
            if(!containsPage(deviceRulesPage))
               pageStack.push(deviceRulesPage);
            break;
         default:
            // A specific device
            if (mainDrawerModel.selectedItem < 0)
               break;// just in case

            pageStack.removePage(generalSettingsPage);
            pageStack.removePage(deviceRulesPage);

            if(!containsPage(subDrawerPage))
               pageStack.push(subDrawerPage);
            if(!containsPage(triggerSettingsPage))
               pageStack.push(triggerSettingsPage);
            break;
         }
      }
   }

   function containsPage(page) {
      for (let i = 0; i < pageStack.depth; i++) {
         if (pageStack.get(i) === page) {
            return true;
         }
      }

      return false;
   }
   //-----------------Pushing/popping Kirigami.Pages-----------------UP
}
