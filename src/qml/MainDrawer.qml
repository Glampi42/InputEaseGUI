import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.delegates

// The leftmost collapsible sidebar where the General Settings, Device Rules and all Devices are displayed
Kirigami.GlobalDrawer {
   id: root

   modal: false// display on the same layer with the rest of the pages, not on top
   drawerOpen: true
   handleVisible: false// hide the default collapse/expand floating button

   //--------------------Collapsing/expanding functionality--------------------DOWN
   property bool sidebarCollapsed: false

   function toggleSidebar() {
      if (sidebarCollapsed) {
         sidebarCollapseSeq.stop();
         sidebarExpandSeq.restart();

         sidebarCollapsed = false;
      } else {
         sidebarExpandSeq.stop();
         sidebarCollapseSeq.restart();

         sidebarCollapsed = true;
      }
   }

   interactiveResizeEnabled: true
   preferredSize: _private.maxWidth// initial width
   minimumSize: _private.minWidth
   maximumSize: _private.maxWidth

   onInteractiveResizingChanged: {
      if (!interactiveResizing && sidebarCollapsed) {
         // set drawer width to minWidth in case user released the handle close enough to minWidth (close enough == sidebarCollapsed is true)
         sidebarExpandSeq.stop();
         sidebarCollapseSeq.restart();
      }
   }
   property bool ignoreChange: false
   onPreferredSizeChanged: {
      if (ignoreChange)
         return;

      // clamp preferredSize to >= 1, because
      // when preferredSize is <= 0, MainDrawer expands😡
      if (preferredSize <= 0) {
         ignoreChange = true;
         preferredSize = 1;
         ignoreChange = false;
         return;
      }

      if (!interactiveResizing)
         return;

      if (width > _private.collapseWidth) {
         sidebarCollapsed = false;
      } else {
         sidebarCollapsed = true;
      }
   }

   SequentialAnimation {
      id: sidebarCollapseSeq

      ScriptAction {
         script: root.preferredSize = root.preferredSize// breaks binding, keeps current value
      }
      NumberAnimation {
         target: root
         property: "preferredSize"
         to: _private.minWidth
         duration: Kirigami.Units.longDuration
         easing.type: Easing.InOutQuad
      }

      onFinished: {
         // create binding to minWidth after the animation
         root.preferredSize = Qt.binding(() => _private.minWidth);
      }
   }

   SequentialAnimation {
      id: sidebarExpandSeq

      ScriptAction {
         script: root.preferredSize = root.preferredSize// breaks binding, keeps current value
      }
      NumberAnimation {
         target: root
         property: "preferredSize"
         to: _private.maxWidth
         duration: Kirigami.Units.longDuration
         easing.type: Easing.InOutQuad
      }

      onFinished: {
         // create binding to maxWidth after the animation
         root.preferredSize = Qt.binding(() => _private.maxWidth);
      }
   }
   //--------------------Collapsing/expanding functionality--------------------UP

   Kirigami.Theme.colorSet: Kirigami.Theme.View
   Kirigami.Theme.inherit: false

   showHeaderWhenCollapsed: true

   // the header with a collapse button and a global search field
   header: QQC.ToolBar {
      Layout.fillWidth: true

      padding: Kirigami.Units.smallSpacing

      RowLayout {
         anchors.fill: parent

         spacing: Kirigami.Units.smallSpacing

         QQC.Button {
            id: collapseButton

            // this size matches that of the icons in the ListView below when they are big
            implicitHeight: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
            implicitWidth: Kirigami.Units.iconSizes.medium + Kirigami.Units.smallSpacing * 2

            flat: true

            icon.name: root.sidebarCollapsed ? "sidebar-expand-left" : "sidebar-collapse-left"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            icon.width: Kirigami.Units.iconSizes.smallMedium

            QQC.ToolTip.visible: hovered
            QQC.ToolTip.text: root.sidebarCollapsed ? i18nc("@info:tooltip", "Open sidebar") : i18nc("@info:tooltip", "Close sidebar")
            QQC.ToolTip.delay: Kirigami.Units.toolTipDelay

            onClicked: toggleSidebar()
            Keys.onReturnPressed: toggleSidebar()
            Keys.onEnterPressed: toggleSidebar()

            //---------------------Keyboard navigation---------------------DOWN
            property Item previousFocusTarget: {
               if (applicationWindow().pageStack.depth > 0) {
                  return applicationWindow().pageStack.lastItem;
               }

               return listView;
            }

            Keys.onTabPressed: searchbar.visible ? searchbar.forceActiveFocus(Qt.TabFocusReason) : listView.forceActiveFocus(Qt.TabFocusReason)
            Keys.onBacktabPressed: previousFocusTarget.forceActiveFocus(Qt.BacktabFocusReason)
            //---------------------Keyboard navigation---------------------UP
         }

         Kirigami.SearchField {
            id: searchbar

            visible: !root.sidebarCollapsed
            Layout.fillWidth: true

            //---------------------Keyboard navigation---------------------DOWN
            Keys.onDownPressed: {
               listView.forceActiveFocus();
               listView.currentIndex = 0;
            }

            Keys.onTabPressed: listView.forceActiveFocus(Qt.TabFocusReason)
            Keys.onBacktabPressed: collapseButton.forceActiveFocus(Qt.BacktabFocusReason)
            //---------------------Keyboard navigation---------------------UP

            // TODO make it functional
         }
      }
   }

   content: QQC.ScrollView {
      id: scrollView

      property bool scrollbarVisible: QQC.ScrollBar.vertical.visible

      Layout.fillHeight: true
      Layout.fillWidth: true

      ListView {
         id: listView

         //---------------------Keyboard navigation---------------------DOWN
         property Item nextFocusTarget: {
            if (applicationWindow().pageStack.depth > 0) {
               return applicationWindow().pageStack.get(0);
            }

            return collapseButton;
         }

         activeFocusOnTab: true

         Keys.onReturnPressed: selectCurrentItem()
         Keys.onEnterPressed: selectCurrentItem()

         Keys.onUpPressed: {
            if (currentIndex === 0 && searchbar.visible)
               searchbar.forceActiveFocus();
            else
               decrementCurrentIndex();
         }

         function selectCurrentItem() {
            const d = currentItem;
            if (!d)
               return;

            mainDrawerModel.selectedItem = d.index;
         }

         Keys.onTabPressed: nextFocusTarget.forceActiveFocus(Qt.TabFocusReason)
         Keys.onBacktabPressed: searchbar.visible ? searchbar.forceActiveFocus(Qt.BacktabFocusReason) : collapseButton.forceActiveFocus(Qt.BacktabFocusReason)
         //---------------------Keyboard navigation---------------------UP

         topMargin: 0
         bottomMargin: Kirigami.Units.largeSpacing
         spacing: Kirigami.Units.smallSpacing

         model: mainDrawerModel

         section {
            property: "sectionRole"
            delegate: CollapsibleListSectionHeader {
               width: ListView.view.width

               text: root.sidebarCollapsed ? "" : section
            }
         }

         delegate: QQC.ItemDelegate {
            id: listDelegate

            required property int index
            required property string nameRole
            required property string iconNameRole

            topInset: 0
            topPadding: Kirigami.Units.smallSpacing
            bottomInset: 0
            bottomPadding: Kirigami.Units.smallSpacing
            leftInset: Kirigami.Units.smallSpacing
            rightInset: Kirigami.Units.smallSpacing

            highlighted: mainDrawerModel.selectedItem === index
            background.opacity: listView.activeFocus ? 1 : 0.6

            // height: Kirigami.Units.smallSpacing + Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing
            width: ListView.view?.width ?? 0

            contentItem: RowLayout {
               Kirigami.Icon {
                  id: listDelegateIcon

                  source: iconNameRole
                  implicitWidth: Kirigami.Units.iconSizes.smallMedium
                  implicitHeight: implicitWidth
               }

               QQC.Label {
                  id: delegateText

                  visible: !root.sidebarCollapsed
                  Layout.fillWidth: true

                  elide: LayoutMirroring.enabled ? Text.ElideLeft : Text.ElideRight

                  text: nameRole
               }
            }

            QQC.ToolTip {
               visible: hovered && (root.sidebarCollapsed || delegateText.truncated)
               text: nameRole
               delay: Kirigami.Units.toolTipDelay
            }

            onClicked: {
               mainDrawerModel.selectedItem = index;
               listView.currentIndex = index;
               listView.forceActiveFocus();
            }

            property bool _collapsed: sidebarCollapsed

            // to make the transition between smallMedium <-> medium icon sizes more smooth:
            on_CollapsedChanged: {
               if (_collapsed) {
                  iconExpandSeq.stop();
                  iconCollapseSeq.restart();
               } else {
                  iconCollapseSeq.stop();
                  iconExpandSeq.restart();
               }
            }

            // Collapse sequence: item height grows first, then icon expands
            SequentialAnimation {
               id: iconCollapseSeq

               NumberAnimation {
                  target: listDelegate
                  property: "height"
                  to: Kirigami.Units.smallSpacing * 2 + Kirigami.Units.iconSizes.medium
                  duration: Kirigami.Units.shortDuration
                  easing.type: Easing.InOutCubic
               }
               PropertyAction {
                  target: listDelegateIcon
                  property: "implicitWidth"
                  value: Kirigami.Units.iconSizes.medium
               }
            }

            // Expand sequence: icon shrinks first, then item height catches up
            SequentialAnimation {
               id: iconExpandSeq

               PropertyAction {
                  target: listDelegateIcon
                  property: "implicitWidth"
                  value: Kirigami.Units.iconSizes.smallMedium
               }
               NumberAnimation {
                  target: listDelegate
                  property: "height"
                  to: Kirigami.Units.smallSpacing * 2 + Kirigami.Units.iconSizes.smallMedium
                  duration: Kirigami.Units.shortDuration
                  easing.type: Easing.InOutCubic
               }
            }
         }
      }
   }

   QtObject {
      id: _private

      property int scrollbarWidth: scrollView.scrollbarVisible ? 21/*the width of the scrollbar*/ : 0

      readonly property int maxWidth: UIConstants.mainDrawer.maxWidth + scrollbarWidth
      readonly property int collapseWidth: UIConstants.mainDrawer.collapseWidth + scrollbarWidth// the sidebar will collapse when it goes below this width
      readonly property int minWidth: UIConstants.mainDrawer.minWidth + scrollbarWidth
   }
}
