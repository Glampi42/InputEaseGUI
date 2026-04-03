import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

// The model that contains the General Settings, DeviceRules, and all Devices
ListModel {
   // i18nc() cannot be assigned to a property of ListElement, have to add it in onCompleted
   Component.onCompleted: {
      append({
         section: "",
         name: i18nc("@item:inlistbox", "General Settings"),
         iconName: "configure"
      });
      append({
         section: "",
         name: i18nc("@item:inlistbox", "Device Rules"),
         iconName: "dialog-input-devices"
      });
      append({
         section: i18nc("@title:group", "Devices"),
         name: i18nc("@item:inlistbox", "Keyboard"),
         iconName: "input-keyboard"
      });
      append({
         section: i18nc("@title:group", "Devices"),
         name: i18nc("@item:inlistbox", "Mouse"),
         iconName: "input-mouse"
      });
      append({
         section: i18nc("@title:group", "Devices"),
         name: i18nc("@item:inlistbox", "Pointer"),
         iconName: "pointer"
      });
      append({
         section: i18nc("@title:group", "Devices"),
         name: i18nc("@item:inlistbox", "Touchpad"),
         iconName: "input-touchpad"
      });
      append({
         section: i18nc("@title:group", "Devices"),
         name: i18nc("@item:inlistbox", "Touchscreen"),
         iconName: "input-touchscreen"
      });
   }
}
