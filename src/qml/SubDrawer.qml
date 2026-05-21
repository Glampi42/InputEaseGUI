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

   //--------------------Drag & Drop state--------------------DOWN
   // Shared drag state. Written by the active DragHandler; read by the overlay visuals.
   QtObject {
      id: dragState
      property bool   active:         false
      property int    sourceRow:      -1
      property string label:          ""// label to be displayed on the floating drag item
      // cursor position in dragOverlay coordinates
      property real   cursorX:        0
      property real   cursorY:        0
      // resolved drop target
      property int    dropRow:        -1
      property bool   dropIntoFolder: false
      // indicator line geometry in dragOverlay coordinates
      property real   indicatorX:     0
      property real   indicatorY:     0
      property real   indicatorW:     0
   }

   // Returns the index of the last visible child of the specified folder.
   function findLastChild(/*QModelIndex*/ folderIdx) {
      var item = treeView.itemAtIndex(folderIdx)

      if (!item.hasChildren)
         return item;

      for (var i = treeView.model.rowCount(folderIdx) - 1; i > -1; i--) {
         var childIdx = treeView.model.index(i, 0, folderIdx);
         if (treeView.itemAtIndex(childIdx) && treeView.itemAtIndex(childIdx).visible)
            return findLastChild(childIdx);
      }

      return item;// all children are not visible
   }

   // Returns true in case this item or its parent folder is being dragged.
   function isBeingDragged(/*QModelIndex*/ itemIdx) {
      if (treeView.rowAtIndex(itemIdx) === dragState.sourceRow)
         return true;

      if (!treeView.model.parent(itemIdx).valid)
         return false;

      return isBeingDragged(treeView.model.parent(itemIdx));
   }

   // Saves the target row where the item should be dropped.
   // Called from each delegate's DragHandler.onCentroidChanged.
   // cursorYInTree: the cursor's Y coordinate in treeView viewport coord. space.
   function updateDropTarget(cursorYInTree) {
      var contentY = cursorYInTree + treeView.contentY// convert to content space

      var foundRow   = -1
      var intoFolder = false

      for (var r = 0; r < treeView.rows; r++) {
         var item = treeView.itemAtIndex(treeView.index(r, 0))
         if (!item)
            continue;

         if (item.isFolder) {
            if (contentY < item.y + item.height * 0.2) {
               // Cursor is in the top third → insert before this row
               foundRow   = r
               intoFolder = false
               break

            } else if (contentY < item.y + item.height * 0.8) {
               // Cursor is in the middle third -> insert as last element of this folder
               foundRow   = r
               intoFolder = true
               break
            } else if (contentY < item.y + item.height) {
               // Cursor is in the bottom third -> insert below this row
               foundRow   = r + 1
               intoFolder = false
               break
            }
         }
         else {
            if (contentY < item.y + item.height * 0.5) {
               // Cursor is in the top half → insert before this row
               foundRow   = r
               intoFolder = false
               break

            } else if (contentY < item.y + item.height) {
               // Cursor is in the bottom half -> insert below this row
               foundRow   = r + 1
               intoFolder = false
               break
            }
         }
      }

      if (foundRow < 0) {
         // below all rows → append at the end
         foundRow   = treeView.rows
         intoFolder = false
      }

      var foundIdx = treeView.index(foundRow, 0);
      var sourceIdx = treeView.index(dragState.sourceRow, 0);
      // ---- Gather all drop targets that don't move the item (e.g. dropping the item to one of its children) ----
      if(
            foundRow === dragState.sourceRow ||// if dropping above source item

            (treeView.model.parent(foundIdx) === treeView.model.parent(sourceIdx) &&
             foundIdx.row === sourceIdx.row + 1 && !intoFolder) ||// if dropping below source item

            isBeingDragged(treeView.model.parent(foundIdx)) ||// if dropping into source item/one of its children

            (!intoFolder && !treeView.model.parent(foundIdx).valid && !treeView.model.parent(sourceIdx).valid &&
             foundRow === treeView.rows && sourceIdx.row === treeView.model.rowCount() - 1)// if dropping last item at the end of the treeView (edge case)
         ) {
         foundRow = dragState.sourceRow;// all cases above are equivalent to not moving the item, so dropRow = sourceRow
         intoFolder = false;
      }

      dragState.dropRow        = foundRow;
      dragState.dropIntoFolder = intoFolder;

      // ---- Compute indicator line position (in dragOverlay coordinates) ----
      var vpY   = 0
      var depth = 0

      if (intoFolder) {
         // line appears below the last visible item of the folder
         var fi = findLastChild(treeView.index(foundRow, 0))
         if (fi) {
            vpY   = fi.y + fi.height + Kirigami.Units.smallSpacing / 2 - treeView.contentY
            depth = treeView.itemAtIndex(treeView.index(foundRow, 0)).depth + 1  // indent one level deeper than the folder
         }
      } else if (foundRow >= treeView.rows) {
         // line appears below the last visible row
         var li = treeView.itemAtIndex(treeView.index(treeView.rows - 1, 0))
         if (li) {
            vpY   = li.y + li.height + Kirigami.Units.smallSpacing / 2 - treeView.contentY
            depth = li.depth
         }
      } else {
         // line appears above the target row
         var ti = treeView.itemAtIndex(treeView.index(foundRow, 0))
         if (ti) {
            vpY   = ti.y - Kirigami.Units.smallSpacing / 2 - treeView.contentY
            depth = ti.depth
         }
      }

      // mirror the delegate's leftInset indentation formula:
      var indentPx = 1 + Kirigami.Units.smallSpacing + depth * Kirigami.Units.iconSizes.smallMedium
      var mapped   = treeView.mapToItem(dragOverlay, indentPx, vpY)
      dragState.indicatorX = mapped.x
      dragState.indicatorY = mapped.y
      dragState.indicatorW = dragOverlay.width - mapped.x
   }
   //--------------------Drag & Drop state--------------------UP

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

         // a TreeView steals tab navigation per default to move between the children, this undoes it
         Keys.onTabPressed: event => {
            nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason);
            event.accepted = true;
         }
         Keys.onBacktabPressed: event => {
            nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason);
            event.accepted = true;
         }

         onActiveFocusChanged: {
            if (activeFocus && !selectionModel.currentIndex.valid) {
               selectionModel.setCurrentIndex(treeView.index(0, 0), ItemSelectionModel.ClearAndSelect);
            }
         }

         Keys.onReturnPressed: selectCurrentItem()
         Keys.onEnterPressed: selectCurrentItem()

         function selectCurrentItem() {
            const currentIndex = treeView.index(treeView.currentRow, treeView.currentColumn);
            if (!currentIndex)
               return;

            treeView.model.selectedItem = currentIndex;
         }
         //---------------------Keyboard navigation---------------------UP

         model: testTreeModel
         selectionModel: ItemSelectionModel {
            model: treeView.model
         }

         topMargin: Kirigami.Units.smallSpacing
         bottomMargin: Kirigami.Units.largeSpacing
         rowSpacing: Kirigami.Units.smallSpacing

         delegate: QQC.ItemDelegate {
            id: delegate

            activeFocusOnTab: false

            // Checks whether this item is the last item at a given targetDepth.
            function isLastAtDepth(targetDepth) {
               if (!delegate.isTreeNode)
                  return false;

               if (delegate.hasChildren && delegate.expanded)
                  return false;

               var idx = delegate.itemIndex;
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

            required property bool isFolder

            property var/*QModelIndex*/ itemIndex: treeView.index(row, column)

            property bool currentlyDragged: dragState.active && isBeingDragged(itemIndex)
            property bool _draggedThisPress: false

            highlighted: treeView.model.selectedItem === itemIndex
            down: pressed && !_draggedThisPress
            background.opacity: treeView.activeFocus ? 1 : 0.7
            focus: !dragState.active ?
                     delegate.current && treeView.activeFocus ://FIXME this flickers when an item is expanded/collapsed
                     !currentlyDragged && dragState.dropIntoFolder && dragState.dropRow === row

            hoverEnabled: !dragState.active

            // dim source row while dragging
            opacity: currentlyDragged ? 0.35 : 1.0

            onPressed: _draggedThisPress = false

            onClicked: {
               treeView.model.selectedItem = itemIndex;
               treeView.selectionModel.setCurrentIndex(itemIndex, ItemSelectionModel.NoUpdate);
               treeView.forceActiveFocus();
            }

            onDoubleClicked: {
               treeView.toggleExpanded(delegate.row);
            }

            DragHandler {
               id: dragHandler

               // target: null → the handler tracks the drag but never moves any Item
               target: null
               dragThreshold: 8

               onActiveChanged: {
                  if (active) {
                     dragState.active    = true
                     dragState.sourceRow = delegate.row
                     dragState.label     = model.display
                     dragState.dropRow   = -1

                     _draggedThisPress = true
                  } else {
                     // drag released: commit the drop
                     treeView.model.moveItem(treeView.index(dragState.sourceRow, 0), treeView.index(dragState.dropRow, 0), dragState.dropIntoFolder);

                     dragState.active         = false
                     dragState.sourceRow      = -1
                     dragState.dropRow        = -1
                     dragState.dropIntoFolder = false
                  }
               }

               onCentroidChanged: {
                  if (!active)
                     return;

                  var sp = centroid.scenePosition;
                  // Update badge position (in dragOverlay coordinates)
                  var inOverlay = dragOverlay.mapFromGlobal(sp.x, sp.y);
                  dragState.cursorX = inOverlay.x;
                  dragState.cursorY = inOverlay.y;
                  // Update drop target + indicator line geometry
                  var inTree = treeView.mapFromGlobal(sp.x, sp.y);
                  root.updateDropTarget(inTree.y);
               }
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

                        implicitHeight: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 3
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
                     if (treeView.model.selectedItem === delegate.itemIndex) {// if this is the selected device
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

                  // dedicated input area for the arrow
                  MouseArea {
                     id: arrowArea

                     anchors.fill: parent
                     hoverEnabled: !dragState.active
                     onClicked: {
                        treeView.toggleExpanded(delegate.row);
                        // make the expanded/collapsed entry current/focused entry:
                        treeView.selectionModel.setCurrentIndex(delegate.itemIndex, ItemSelectionModel.NoUpdate);
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

                  visible: isTreeNode && delegate.isFolder

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

   //--------------------Drag & Drop overlay visuals--------------------DOWN
   Item {
      id: dragOverlay

      anchors.fill: parent
      z: 999

      // drop indicator line
      Rectangle {
         visible: dragState.active && dragState.dropRow !== -1 && dragState.dropRow !== dragState.sourceRow

         x:       dragState.indicatorX + 4
         y:       dragState.indicatorY - 1
         width:   dragState.indicatorW - 4
         height:  2
         radius:  1
         color: Kirigami.Theme.highlightColor

         // round cap at the left end
         Rectangle {
            width:  8
            height: 8
            radius: 4
            color: Kirigami.Theme.highlightColor
            anchors {
               left:           parent.left
               leftMargin:     -4
               verticalCenter: parent.verticalCenter
            }
         }
      }

      // drag badge: icon + label that follows the cursor
      Item {
         visible: dragState.active
         x:       dragState.cursorX + 14
         y:       dragState.cursorY - height * 0.5

         width:  badgeIcon.implicitWidth
                 + Kirigami.Units.smallSpacing
                 + badgeLabel.implicitWidth
                 + Kirigami.Units.smallSpacing * 3
         height: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2

         Rectangle {
            anchors.fill: parent
            color:   Kirigami.Theme.highlightColor
            opacity: 0.92
            radius:  Kirigami.Units.cornerRadius
         }

         Kirigami.Icon {
            id: badgeIcon
            source: "list-drag-handle"
            implicitWidth:  Kirigami.Units.iconSizes.small
            implicitHeight: Kirigami.Units.iconSizes.small
            anchors {
               left:           parent.left
               leftMargin:     Kirigami.Units.smallSpacing
               verticalCenter: parent.verticalCenter
            }
         }

         QQC.Label {
            id: badgeLabel
            text:            dragState.label
            color:           Kirigami.Theme.highlightedTextColor
            elide:           Text.ElideRight
            maximumLineCount: 1
            anchors {
               left:           badgeIcon.right
               leftMargin:     Kirigami.Units.smallSpacing
               right:          parent.right
               rightMargin:    Kirigami.Units.smallSpacing
               verticalCenter: parent.verticalCenter
            }
         }
      }
   }
   //--------------------Drag & Drop overlay visuals--------------------UP
}
