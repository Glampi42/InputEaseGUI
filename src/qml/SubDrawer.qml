import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The secondary sidebar that is conditionally displayed next to the MainDrawer
Kirigami.Page {
   id: root

   Kirigami.ColumnView.interactiveResizeEnabled: true
   Kirigami.ColumnView.preferredWidth: _preferredWidth
   Kirigami.ColumnView.maximumWidth: UIConstants.subDrawer.maxWidth
   Kirigami.ColumnView.minimumWidth: UIConstants.subDrawer.minWidth

   //--------------------Shrink-when-not-enough-space functionality--------------------DOWN
   property int _preferredWidth: Math.max(Kirigami.ColumnView.minimumWidth,
                                                Math.min(userSetWidth, applicationWindow().pageStack.availableWidth - UIConstants.infoPane.minWidth))
   property real userSetWidth: UIConstants.subDrawer.initialWidth// the width the user sets by dragging the right edge of the SubDrawer
   property bool ignoreResizing: false

   // Explanation: the Kirigami.ColumnView.preferredWidth property is rebinded to an arbitrary value when the user drags the handle.
   // _preferredWidth keeps track of the current _actual_ preferredWidth of the SubDrawer, and we keep it in sync with Kirigami.ColumnView.preferredWidth.
   on_PreferredWidthChanged: {
      ignoreResizing = true;
      Kirigami.ColumnView.preferredWidth = _preferredWidth
      ignoreResizing = false;
   }

   Kirigami.ColumnView.onPreferredWidthChanged: {
      if (ignoreResizing) {
         return;
      }

      // user dragged the SubDrawer handle manually -> store new userSetWidth, clamp if necessary

      userSetWidth = Math.min(Kirigami.ColumnView.preferredWidth, Kirigami.ColumnView.maximumWidth);

      var availableWidth = applicationWindow().pageStack.availableWidth - UIConstants.infoPane.minWidth;
      var clampedWidth = Math.max(Kirigami.ColumnView.minimumWidth, Math.min(userSetWidth, availableWidth));
      if (Kirigami.ColumnView.preferredWidth !== clampedWidth) {
         ignoreResizing = true;
         Kirigami.ColumnView.preferredWidth = clampedWidth;
         ignoreResizing = false;
      }
   }
   //--------------------Shrink-when-not-enough-space functionality--------------------UP

   padding: 0

   QQC.ScrollView {
      id: scrollView

      anchors.fill: parent

      background: Rectangle {
         color: "gray"
      }

      TreeView {
         clip: true

         model: testTreeModel

         delegate: Item {
            implicitWidth: Math.max(padding + label.x + label.implicitWidth + padding, scrollView.availableWidth)
            implicitHeight: label.implicitHeight * 1.5

            readonly property real indentation: 20
            readonly property real padding: 5

            // Assigned to by TreeView:
            required property TreeView treeView
            required property bool isTreeNode
            required property bool expanded
            required property bool hasChildren
            required property int depth
            required property int row
            required property int column
            required property bool current

            // Rotate indicator when expanded by the user
            // (requires TreeView to have a selectionModel)
            property Animation indicatorAnimation: NumberAnimation {
               target: indicator
               property: "rotation"
               from: expanded ? 0 : 90
               to: expanded ? 90 : 0
               duration: 100
               easing.type: Easing.OutQuart
            }
            TableView.onPooled: indicatorAnimation.complete()
            TableView.onReused: if (current)
               indicatorAnimation.start()
            onExpandedChanged: indicator.rotation = expanded ? 90 : 0

            Rectangle {
               id: background
               anchors.fill: parent
               color: row === treeView.currentRow ? palette.highlight : "black"
               opacity: (treeView.alternatingRows && row % 2 !== 0) ? 0.3 : 0.1
            }

            QQC.Label {
               id: indicator
               x: padding + (depth * indentation)
               anchors.verticalCenter: parent.verticalCenter
               visible: isTreeNode && hasChildren
               text: "▶"

               TapHandler {
                  onSingleTapped: {
                     let index = treeView.index(row, column);
                     // treeView.selectionModel.setCurrentIndex(index, ItemSelectionModel.NoUpdate)
                     treeView.toggleExpanded(row);
                  }
               }
            }

            QQC.Label {
               id: label
               x: padding + (isTreeNode ? (depth + 1) * indentation : 0)
               anchors.verticalCenter: parent.verticalCenter
               width: parent.width - padding - x
               clip: true
               text: model.display
            }
         }
      }
   }
}
