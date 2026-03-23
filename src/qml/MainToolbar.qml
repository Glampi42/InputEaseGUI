import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

import me.glampi.inputeasegui 1.0

Rectangle {
   Kirigami.Theme.colorSet: Kirigami.Theme.Header
   Kirigami.Theme.inherit: false
   color: Kirigami.Theme.backgroundColor

   implicitHeight: header_row.implicitHeight + Kirigami.Units.smallSpacing*2
   implicitWidth: header_row.implicitWidth + Kirigami.Units.smallSpacing*2

   RowLayout {
      id: header_row

      spacing: 0

      anchors.fill: parent
      anchors.margins: Kirigami.Units.smallSpacing

      Kirigami.ActionToolBar {
         id: main_toolbar_left

         alignment: main_page.layout_alignment
         Layout.fillWidth: false
         Layout.minimumWidth: visibleWidth

         actions: [
            Kirigami.Action {
               text: i18nc("@action:intoolbar create new arbitrary item", "New")
               icon.name: "list-add"

               Kirigami.Action {
                  text: i18nc("@action:intoolbar", "New gesture…")
                  icon.name: "document-new"
               }

               Kirigami.Action {
                  id: new_device_action

                  text: i18nc("@action:intoolbar", "New device")
                  icon.name: "input-keyboard"
               }
            },
            Kirigami.Action {
               separator: true
            },
            Kirigami.Action {
               text: i18nc("@action:intoolbar", "Move Up")
               icon.name: "go-up"
            },
            Kirigami.Action {
               text: i18nc("@action:intoolbar", "Move Down")
               icon.name: "go-down"
            },
            Kirigami.Action {
               separator: true
            },
            Kirigami.Action {
               text: StandardActions.delete_action.text
               icon.name: StandardActions.delete_action.iconName
               tooltip: i18nc("@info:tooltip", "Delete selected item")
            }
         ]
      }

      // spacer
      Item {
         Layout.fillWidth: true
         Layout.fillHeight: true
      }

      Kirigami.ActionToolBar {
         id: main_toolbar_right

         alignment: main_page.layout_alignment_reverse
         Layout.fillWidth: false
         Layout.minimumWidth: visibleWidth

         actions: [
            Kirigami.Action {
               text: StandardActions.save.text
               icon.name: StandardActions.save.iconName
               tooltip: i18nc("@info:tooltip", "Save changes to the config file")
            },
            Kirigami.Action {
               text: i18nc("@action:intoolbar", "GoTo Config")
               icon.name: "go-parent-folder"
               tooltip: i18nc("@info:tooltip", "Open folder containing the config file")
            }
         ]
      }
   }
}
