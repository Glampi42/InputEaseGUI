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

         highlighted: devices_tree.model.selectedGeneralSettings

         text: i18nc("@item:inmenu", "General Settings")
         icon.name: "configure"

         onClicked: {
            devices_tree.model.selectedGeneralSettings = true;
         }
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
            required property bool isLastGestureRole

            text: nameRole
            highlighted: isGestureRole ? devices_tree.model.selectedGesture === index : devices_tree.model.selectedDevice === index

            leftInset: isGestureRole ? main_page.gestureInset : main_page.deviceInset
            leftPadding: isGestureRole ? main_page.gesturePadding : main_page.devicePadding

            onClicked: {
               if (!isGestureRole) {
                  devices_tree.model.selectedDevice = index;
               } else {
                  devices_tree.model.selectedGesture = index;
               }
            }

            onDoubleClicked: {
               if (!isGestureRole) {
                  if (kDescendantExpanded)
                     devices_model.collapse(tree_delegate.index);
                  else
                     devices_model.expand(tree_delegate.index);
               }
            }

            // --- Branch symbol like in a tree view (gestures only) ------------------------
            Item {
               anchors.left: parent.left
               anchors.leftMargin: Kirigami.Units.smallSpacing * 3
               anchors.verticalCenter: parent.verticalCenter
               visible: tree_delegate.isGestureRole
               width: Kirigami.Units.iconSizes.small
               height: parent.height

               // Vertical line (full height for T-pipe, half height for L-pipe)
               Rectangle {
                  x: parent.width / 2 - 0.5 // -0.5 to compensate for the 1px width (the T-pipe and the devices' arrow button should align)
                  width: 1
                  height: tree_delegate.isLastGestureRole ? parent.height / 2 : parent.height

                  color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast)

                  anchors.top: parent.top
               }

               // Horizontal stub
               Rectangle {
                  x: parent.width / 2 - 0.5
                  y: parent.height / 2
                  width: parent.width / 2
                  height: 1

                  color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, Kirigami.Theme.frameContrast)
               }
            }

            // --- Collapse/expand arrow (devices only) -------------------------------------
            Rectangle {
               id: arrow_button

               anchors.left: parent.left
               anchors.leftMargin: Kirigami.Units.smallSpacing * 2
               anchors.verticalCenter: parent.verticalCenter
               visible: !tree_delegate.isGestureRole

               // Slightly larger than the icon so the outline has a small margin
               width: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing * 2
               height: width
               radius: Kirigami.Units.smallSpacing

               color: arrowArea.containsPress ? Kirigami.Theme.highlightColor : "transparent"
               border.color: Kirigami.Theme.highlightColor
               border.width: arrowArea.containsMouse ? 1 : 0

               // the actual arrow
               Kirigami.Icon {
                  anchors.centerIn: parent
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

               // Dedicated input area for the arrow.
               // hoverEnabled drives the outline via containsMouse.
               // By accepting the mouse press (Qt default), it prevents
               // the event from reaching the parent delegate's button
               // handler, so onClicked on the delegate will not fire.
               MouseArea {
                  id: arrowArea
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                     if (tree_delegate.kDescendantExpanded)
                        devices_model.collapse(tree_delegate.index);
                     else
                        devices_model.expand(tree_delegate.index);
                  }
               }
            }
         }

         //-----------------Collapse/expand animations-----------------DOWN
         add: Transition {
            NumberAnimation {
               property: "opacity"
               from: 0
               to: 1
               duration: Kirigami.Units.longDuration
               easing.type: Easing.InOutCubic
            }
            NumberAnimation {
               property: "height"
               from: 0
               duration: Kirigami.Units.longDuration
               easing.type: Easing.InOutCubic
            }
         }

         remove: Transition {
            PropertyAction {
               property: "highlighted"
               value: false
            }
            NumberAnimation {
               property: "opacity"
               to: 0
               duration: Kirigami.Units.shortDuration
               easing.type: Easing.InOutCubic
            }
            NumberAnimation {
               property: "height"
               to: 0
               duration: Kirigami.Units.shortDuration
               easing.type: Easing.InOutCubic
            }
         }

         displaced: Transition {
            NumberAnimation {
               property: "y"
               duration: Kirigami.Units.longDuration
               easing.type: Easing.InOutCubic
            }
         }
         //-----------------Collapse/expand animations-----------------UP
      }
   }
}
