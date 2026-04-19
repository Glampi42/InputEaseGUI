import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// main window
Kirigami.ApplicationWindow {
   id: root

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

   width: UIConstants.global.window_width
   height: UIConstants.global.window_height
   visible: true

   title: i18nc("@title:window", "Input Ease GUI")

   // the main toolbar with buttons that adjust their function based on the selected item
   // header: MainToolbar {}

   globalDrawer: MainDrawer { id: mainDrawer }

   Component.onCompleted: {
      pageStack.globalToolBar.style = Kirigami.ApplicationHeaderStyle.ToolBar;

      pageStack.push(generalSettingsInfoPane);// general settings open initially

      mainDrawer.focusListView();
   }

   // the window width at which the view switches between multi-column view and single-column view
   property int criticalWidth: mainDrawer.width + UIConstants.subDrawer.minWidth + UIConstants.infoPane.minWidth

   pageStack {
      // this property is basically only used by the InfoPanes and serves as their minimumWidth
      //(idk why it doesn't use their Kirigami.ColumnView.minimumWidth property instead, but okay)
      defaultColumnWidth: UIConstants.infoPane.minWidth

      // show both the SubDrawer and the info page if wide enough, only one page at a time otherwise
      columnView.columnResizeMode: (width > criticalWidth) ? Kirigami.ColumnView.DynamicColumns : Kirigami.ColumnView.SingleColumn
      globalToolBar.canContainHandles: true
      globalToolBar {
         style: Kirigami.ApplicationHeaderStyle.ToolBar
         showNavigationButtons: pageStack.currentIndex === 0 ? Kirigami.ApplicationHeaderStyle.ShowForwardButton : Kirigami.ApplicationHeaderStyle.ShowBackButton
      }
   }

   //-----------------Pushing/popping Kirigami.Pages-----------------DOWN
   Kirigami.PagePool {
      id: pagePool
   }

   readonly property var subDrawerPage: pagePool.loadPage(Qt.resolvedUrl("SubDrawer.qml"))
   readonly property var generalSettingsInfoPane: pagePool.loadPage(Qt.resolvedUrl("GeneralSettingsInfoPane.qml"))
   readonly property var deviceRulesInfoPane: pagePool.loadPage(Qt.resolvedUrl("DeviceRulesInfoPane.qml"))
   readonly property var triggerInfoPane: pagePool.loadPage(Qt.resolvedUrl("TriggerInfoPane.qml"))

   Connections {
      target: mainDrawerModel

      function onSelectedItemChanged() {
         switch (mainDrawerModel.selectedItem) {
         case 0:// General Settings
            pageStack.removePage(subDrawerPage);
            pageStack.removePage(deviceRulesInfoPane);
            pageStack.removePage(triggerInfoPane);

            if (!containsPage(generalSettingsInfoPane))
               pageStack.push(generalSettingsInfoPane);
            break;
         case 1:// Device Rules
            pageStack.removePage(generalSettingsInfoPane);
            pageStack.removePage(triggerInfoPane);

            if (!containsPage(subDrawerPage))
               insertPage(0, subDrawerPage);// MainDrawer doesn't count for the page count, that's why insert index 0
            if (!containsPage(deviceRulesInfoPane))
               pageStack.push(deviceRulesInfoPane);
            break;
         default:
            // A specific device
            if (mainDrawerModel.selectedItem < 0)
               break;// just in case

            pageStack.removePage(generalSettingsInfoPane);
            pageStack.removePage(deviceRulesInfoPane);

            if (!containsPage(subDrawerPage))
               insertPage(0, subDrawerPage);
            if (!containsPage(triggerInfoPane))
               pageStack.push(triggerInfoPane);
            break;
         }
      }
   }

   // Returns true if the pageStack contains the page, false otherwise
   function containsPage(page) {
      for (let i = 0; i < pageStack.depth; i++) {
         if (pageStack.get(i) === page) {
            return true;
         }
      }

      return false;
   }

   // Tries to insert the page at pos into the pageStack; pushes it if the pos is larger than pageStack.depth
   function insertPage(pos, page) {
      if (pageStack.depth > pos) {
         pageStack.insertPage(pos, page);
      } else {
         pageStack.push(page);
      }
   }
   //-----------------Pushing/popping Kirigami.Pages-----------------UP
}
