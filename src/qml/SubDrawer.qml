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

   Kirigami.Theme.colorSet: Kirigami.Theme.View
   Kirigami.Theme.inherit: false

   //--------------------Shrink-when-not-enough-space functionality--------------------DOWN
   property int _preferredWidth: Math.max(Kirigami.ColumnView.minimumWidth, Math.min(userSetWidth, applicationWindow().pageStack.availableWidth - UIConstants.infoPane.minWidth))
   property real userSetWidth: UIConstants.subDrawer.initialWidth// the width the user sets by dragging the right edge of the SubDrawer
   property bool ignoreResizing: false

   // Explanation: the Kirigami.ColumnView.preferredWidth property is rebinded to an arbitrary value when the user drags the handle.
   // _preferredWidth keeps track of the current _actual_ preferredWidth of the SubDrawer, and we keep it in sync with Kirigami.ColumnView.preferredWidth.
   on_PreferredWidthChanged: {
      ignoreResizing = true;
      Kirigami.ColumnView.preferredWidth = _preferredWidth;
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

      focus: true

      anchors.fill: parent

      TreeView {
         id: treeView

         clip: true
         reuseItems: false// disable item pooling

         alternatingRows: false

         //---------------------Keyboard navigation---------------------DOWN
         focus: true
         activeFocusOnTab: true

         onActiveFocusChanged: {
            if (activeFocus && !selectionModel.currentIndex.valid) {
               selectionModel.setCurrentIndex(treeView.index(0, 0), ItemSelectionModel.ClearAndSelect);
            }
         }

         Keys.onTabPressed: event => {
            if (applicationWindow().pageStack.depth > 1) {
               event.accepted = true;
               applicationWindow().pageStack.get(1).forceActiveFocus(Qt.TabFocusReason);
            }
         }
         Keys.onBacktabPressed: event => {
            event.accepted = true;
            applicationWindow().globalDrawer.forceActiveFocus(Qt.BacktabFocusReason);
         }

         Keys.onReturnPressed: selectCurrentItem()
         Keys.onEnterPressed: selectCurrentItem()

         function selectCurrentItem() {
            const currentIndex = treeView.index(treeView.currentRow, treeView.currentColumn);
            if (!currentIndex)
               return;

            testTreeModel.selectedItem = currentIndex;
         }
         //---------------------Keyboard navigation---------------------UP

         model: testTreeModel
         selectionModel: ItemSelectionModel {
            model: testTreeModel
         }

         topMargin: Kirigami.Units.smallSpacing
         bottomMargin: Kirigami.Units.largeSpacing
         rowSpacing: Kirigami.Units.smallSpacing

         //--------------------Animating collapsing/expanding--------------------DOWN
         // needs to happen here instead of using onExpandedChanged() in the delegate,
         // because that is unreliable (TreeView sometimes rebuilds delegates completely)
         onExpanded: function (_row, _depth) {
            Qt.callLater(function () {// treeView.index doesn't resolve if called right away
               var expandedDelegate = treeView.itemAtIndex(treeView.index(_row, 0));
               expandedDelegate.indicatorAnimation.restart();
            });
         }
         onCollapsed: function (_row, _depth) {
            Qt.callLater(function () {
               var collapsedDelegate = treeView.itemAtIndex(treeView.index(_row, 0));
               collapsedDelegate.indicatorAnimation.restart();
            });
         }
         //--------------------Animating collapsing/expanding--------------------UP

         delegate: QQC.ItemDelegate {
            id: delegate

            // Checks whether this item is the last item at a given targetDepth.
            function isLastAtDepth(targetDepth) {
               if (!delegate.isTreeNode)
                  return false;

               if (delegate.hasChildren && delegate.expanded)
                  return false;

               var idx = treeView.index(delegate.row, delegate.column);
               var siblingCount = treeView.model.rowCount(treeView.model.parent(idx));

               var stepsUp = delegate.depth - targetDepth;
               // go recursively through this item's parents
               for (var i = 0; i < stepsUp; i++) {
                  if (idx.row !== siblingCount - 1) {
                     return false;// if not last item at this depth, it won't be last item at any lower depth
                  }

                  idx = treeView.model.parent(idx);
                  siblingCount = treeView.model.rowCount(treeView.model.parent(idx));
               }

               return true;
            }

            //----------------Spacing setup----------------DOWN
            implicitWidth: Math.max(leftPadding + contentItem.implicitWidth + rightPadding, scrollView.availableWidth)
            implicitHeight: Kirigami.Units.smallSpacing + Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing

            leftInset: 1 + Kirigami.Units.smallSpacing + (depth * Kirigami.Units.iconSizes.smallMedium)// +1 because of the page separator line (I'm a perfectionist, okay?)
            rightInset: Kirigami.Units.smallSpacing
            topInset: 0
            bottomInset: 0
            leftPadding: 1 + Kirigami.Units.smallSpacing + Kirigami.Units.smallSpacing
            rightPadding: rightInset + Kirigami.Units.smallSpacing
            topPadding: 0
            bottomPadding: 0
            //----------------Spacing setup----------------UP

            // Assigned to by TreeView:
            required property TreeView treeView
            required property bool isTreeNode
            required property bool expanded
            required property bool hasChildren
            required property int depth
            required property int row
            required property int column
            required property bool current

            property var/*QModelIndex*/ itemIndex: treeView.index(row, column)

            property Animation indicatorAnimation: NumberAnimation {//FIXME the arrow jumps to the end position for a single frame before the animation (probably same reason as the flicker below)
               target: indicatorIcon
               property: "rotation"
               from: expanded ? 0 : 90
               to: expanded ? 90 : 0
               duration: Kirigami.Units.shortDuration
               easing.type: Easing.InOutCubic
            }

            highlighted: testTreeModel.selectedItem === itemIndex
            background.opacity: treeView.activeFocus ? 1 : 0.6
            focus: delegate.current && treeView.activeFocus//FIXME this flickers when an item is expanded/collapsed

            onClicked: {
               testTreeModel.selectedItem = itemIndex;
               treeView.selectionModel.setCurrentIndex(treeView.index(delegate.row, delegate.column), ItemSelectionModel.NoUpdate);
               treeView.forceActiveFocus();
            }

            onDoubleClicked: {
               treeView.toggleExpanded(delegate.row);
            }

            contentItem: RowLayout {
               id: rowLayout

               spacing: 0

               // tree indentation bars
               Repeater {
                  model: delegate.depth

                  Item {
                     id: treeBranch

                     required property int index

                     implicitHeight: Kirigami.Units.iconSizes.smallMedium
                     implicitWidth: Kirigami.Units.iconSizes.smallMedium

                     // vertical bar
                     Kirigami.Separator {
                        x: parent.width / 2 - 0.5
                        y: 0 - Kirigami.Units.smallSpacing * 2

                        implicitHeight: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 3.5
                     }

                     // horizontal bar
                     Kirigami.Separator {
                        visible: delegate.isLastAtDepth(treeBranch.index)

                        x: parent.width / 2 - 0.5
                        y: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 1.5 - 0.5

                        implicitWidth: Kirigami.Units.iconSizes.smallMedium / 2 + 0.5
                     }
                  }
               }

               // collapse/expand arrow
               Rectangle {
                  id: collapseExpandBtn

                  visible: isTreeNode && hasChildren

                  Kirigami.Theme.colorSet: Kirigami.Theme.Selection
                  Kirigami.Theme.inherit: false

                  Layout.alignment: Qt.AlignVCenter

                  implicitWidth: Kirigami.Units.iconSizes.smallMedium
                  implicitHeight: Kirigami.Units.iconSizes.smallMedium
                  radius: Kirigami.Units.cornerRadius

                  color: {
                     if (testTreeModel.selectedItem === delegate.itemIndex) {// if this is the selected device
                        (arrowArea.containsMouse && !arrowArea.containsPress) ? Kirigami.Theme.activeBackgroundColor : "transparent";
                     } else {
                        arrowArea.containsPress ? Kirigami.Theme.highlightColor : "transparent";
                     }
                  }

                  border.color: Kirigami.Theme.highlightColor
                  border.width: arrowArea.containsMouse ? 1 : 0

                  // the actual arrow
                  Kirigami.Icon {
                     id: indicatorIcon

                     anchors.centerIn: parent

                     source: "arrow-right"
                     width: Kirigami.Units.iconSizes.small
                     height: Kirigami.Units.iconSizes.small

                     rotation: delegate.expanded ? 90 : 0
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
                        treeView.toggleExpanded(delegate.row);
                        // make the expanded/collapsed entry current/focused entry:
                        treeView.selectionModel.setCurrentIndex(treeView.index(delegate.row, delegate.column), ItemSelectionModel.NoUpdate);
                        treeView.forceActiveFocus();
                     }

                     onDoubleClicked: {
                        // nothing; this prevents double-clicks from collapsing/expanding the items twice in a row
                     }
                  }
               }

               // folder icon for trigger groups
               Kirigami.Icon {
                  id: folderIcon

                  visible: isTreeNode && hasChildren//TODO other visibility condition

                  source: "document-open-folder"
                  implicitWidth: Kirigami.Units.iconSizes.smallMedium
                  implicitHeight: Kirigami.Units.iconSizes.smallMedium
               }

               // separator
               Item {
                  implicitWidth: Kirigami.Units.smallSpacing
               }

               QQC.Label {
                  id: label

                  Layout.alignment: Qt.AlignVCenter
                  Layout.fillWidth: true

                  text: model.display
               }
            }
         }
      }
   }
}
