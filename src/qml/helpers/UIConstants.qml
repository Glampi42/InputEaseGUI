pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// UI-related constants used in .qml files throughout the project
QtObject {
   // constants used primarily by MainDrawer
   readonly property QtObject mainDrawer: QtObject {
      readonly property int maxWidth: Kirigami.Units.gridUnit * 13
      readonly property int collapseWidth: Kirigami.Units.gridUnit * 5// the sidebar will collapse when it goes below this width
      readonly property int minWidth: Kirigami.Units.smallSpacing * 2 + Kirigami.Units.iconSizes.medium + Kirigami.Units.smallSpacing * 2
   }

   // constants used primarily by SubDrawer
   readonly property QtObject subDrawer: QtObject {
      readonly property int width: Kirigami.Units.gridUnit * 13
   }

   // constants related to the pane that displays various info, such as: GeneralSettingsInfoPane, DeviceRulesInfoPane, TriggerInfoPane
   readonly property QtObject infoPane: QtObject {
      readonly property int minWidth: Kirigami.Units.gridUnit * 13
   }

   // global application constants
   readonly property QtObject global: QtObject {
      property int window_width: 800
      property int window_height: 500
   }
}
