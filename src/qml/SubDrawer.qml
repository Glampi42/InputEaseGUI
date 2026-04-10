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

      anchors.fill: parent

      TreeView {
         clip: true
         reuseItems: false// disable item pooling

         model: testTreeModel

         topMargin: Kirigami.Units.smallSpacing
         bottomMargin: Kirigami.Units.largeSpacing
         rowSpacing: Kirigami.Units.smallSpacing

         delegate: QQC.Pane {
            id: delegate

            hoverEnabled: true

            implicitWidth: Math.max(leftPadding + contentWidth + rightPadding, scrollView.availableWidth)
            implicitHeight: Kirigami.Units.smallSpacing + Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing

            leftInset: 1 + Kirigami.Units.smallSpacing// +1 because of the page separator line (I'm a perfectionist, okay?)
            rightInset: Kirigami.Units.smallSpacing
            topInset: 0
            bottomInset: 0
            leftPadding: leftInset + Kirigami.Units.smallSpacing
            rightPadding: rightInset + Kirigami.Units.smallSpacing
            topPadding: 0
            bottomPadding: 0

            readonly property real indentation: 20

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
            // property Animation indicatorAnimation: NumberAnimation {
            //    target: indicator
            //    property: "rotation"
            //    from: expanded ? 0 : 90
            //    to: expanded ? 90 : 0
            //    duration: 100
            //    easing.type: Easing.OutQuart
            // }
            // TableView.onPooled: indicatorAnimation.complete()
            // TableView.onReused: if (current)
            //    indicatorAnimation.start()
            onExpandedChanged: indicatorIcon.rotation = expanded ? 90 : 0

            background: Rectangle {
               id: background

               color: hovered ? Kirigami.Theme.hoverColor : Kirigami.Theme.backgroundColor
            }

            contentItem: RowLayout {
               id: rowLayout

               spacing: Kirigami.Units.smallSpacing

               // collapse/expand button
               QQC.Button {
                  id: collapseExpandBtn

                  Layout.alignment: Qt.AlignVCenter

                  implicitWidth: Kirigami.Units.iconSizes.smallMedium
                  implicitHeight: Kirigami.Units.iconSizes.smallMedium

                  padding: 0

                  visible: isTreeNode && hasChildren

                  Kirigami.Icon {
                     id: indicatorIcon

                     source: "go-next"
                     width: Kirigami.Units.iconSizes.smallMedium
                     height: Kirigami.Units.iconSizes.smallMedium
                  }

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

                  Layout.alignment: Qt.AlignVCenter
                  Layout.fillWidth: true

                  text: model.display
               }
            }
         }
      }
   }
}
