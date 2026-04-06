import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.delegates

// The leftmost collapsible sidebar where the General Settings, Device Rules and all Devices are displayed
Kirigami.OverlayDrawer {
   id: root

   modal: false// display on the same layer with the rest of the pages, not on top
   drawerOpen: true
   handleVisible: false// hide the default collapse/expand floating button

   //--------------------Collapsing/expanding functionality--------------------DOWN
   property bool sidebarCollapsed: false
   property bool animateWidth: true// whether the sidebar width change should be animated or not; should be true initially

   function toggleSidebar() {
      if (sidebarCollapsed) {
         preferredSize = _private.maxWidth;

         sidebarCollapsed = false;
      } else {
         preferredSize = _private.minWidth;

         sidebarCollapsed = true;
      }
   }

   interactiveResizeEnabled: true
   minimumSize: _private.minWidth
   maximumSize: _private.maxWidth
   onInteractiveResizingChanged: {
      animateWidth = !interactiveResizing;

      if (!interactiveResizing && sidebarCollapsed) {
         preferredSize = _private.minWidth;
      }
   }
   preferredSize: _private.targetWidth
   onPreferredSizeChanged: {
      if (!interactiveResizing)
         return;// ignore all resizing done with the resize button/automatically

      if (width > _private.collapseWidth) {
         sidebarCollapsed = false;
      } else {
         sidebarCollapsed = true;
      }
   }

   Behavior on preferredSize {
      enabled: animateWidth

      NumberAnimation {
         duration: Kirigami.Units.longDuration
         easing.type: Easing.InOutQuad
      }
   }
   //--------------------Collapsing/expanding functionality--------------------UP

   Kirigami.Theme.colorSet: Kirigami.Theme.View
   Kirigami.Theme.inherit: false

   padding: 0

   contentItem: ColumnLayout {
      spacing: 0

      // the header with a collapse button and a global search field
      QQC.ToolBar {
         Layout.fillWidth: true

         padding: Kirigami.Units.smallSpacing

         RowLayout {
            anchors.fill: parent

            spacing: Kirigami.Units.smallSpacing

            QQC.Button {
               id: collapseButton

               // this size matches that of the icons in the ListView below when they are collapsed (big)
               implicitHeight: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
               implicitWidth:  Kirigami.Units.iconSizes.medium + Kirigami.Units.smallSpacing * 2

               flat: true

               icon.name: root.sidebarCollapsed ? "sidebar-expand-left" : "sidebar-collapse-left"
               icon.height: Kirigami.Units.iconSizes.smallMedium
               icon.width: Kirigami.Units.iconSizes.smallMedium

               QQC.ToolTip.visible: hovered
               QQC.ToolTip.text: root.sidebarCollapsed ? i18nc("@info:tooltip", "Open sidebar") : i18nc("@info:tooltip", "Close sidebar")
               QQC.ToolTip.delay: Kirigami.Units.toolTipDelay

               onClicked: toggleSidebar()
               Keys.onReturnPressed: toggleSidebar()
            }

            Kirigami.SearchField {
               id: searchbar

               visible: !root.sidebarCollapsed
               Layout.fillWidth: true
               // Layout.fillHeight: true

               Keys.onDownPressed: {
                  listView.forceActiveFocus();
                  listView.currentIndex = 0;
               }

               // TODO make it functional
            }
         }
      }

      QQC.ScrollView {
         Layout.fillHeight: true
         Layout.fillWidth: true

         ListView {
            id: listView

            //---------------------Keyboard navigation---------------------DOWN
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
            //---------------------Keyboard navigation---------------------UP

            topMargin: Kirigami.Units.smallSpacing
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

               // height: Kirigami.Units.smallSpacing + Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing
               width: ListView.view?.width ?? 0

               contentItem: RowLayout {
                  Kirigami.Icon {
                     id: listDelegateIcon

                     source: iconNameRole
                     implicitWidth:  Kirigami.Units.iconSizes.smallMedium
                     implicitHeight: implicitWidth
                  }

                  QQC.Label {
                     visible: !root.sidebarCollapsed
                     Layout.fillWidth: true

                     elide: LayoutMirroring.enabled ? Text.ElideLeft : Text.ElideRight

                     text: nameRole
                  }
               }

               QQC.ToolTip {
                  visible: hovered && root.sidebarCollapsed
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
                     to: Kirigami.Units.smallSpacing*2 + Kirigami.Units.iconSizes.medium
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
                     to: Kirigami.Units.smallSpacing*2 + Kirigami.Units.iconSizes.smallMedium
                     duration: Kirigami.Units.shortDuration
                     easing.type: Easing.InOutCubic
                  }
               }
            }
         }
      }
   }

   QtObject {
      id: _private

      property int targetWidth: root.sidebarCollapsed ? minWidth : maxWidth
      readonly property int maxWidth: UIConstants.mainDrawer.maxWidth
      readonly property int collapseWidth: UIConstants.mainDrawer.collapseWidth// the sidebar will collapse when it goes below this width
      readonly property int minWidth: UIConstants.mainDrawer.minWidth
   }
}
