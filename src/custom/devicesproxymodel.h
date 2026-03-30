#pragma once

#include <kdescendantsproxymodel.h>
#include <qqmlintegration.h>

#include "iedevice.h"
#include "iegesture.h"
#include "devicestreemodel.h"

/**
 * @brief The DevicesProxyModel class converts the DevicesTreeModel into a flat list and adds QML interface such as to expand/collapse children.
 */
class DevicesProxyModel : public KDescendantsProxyModel
{
    Q_OBJECT

    Q_PROPERTY(bool selectedGeneralSettings READ qml_getSelectedGeneralSettings WRITE qml_setSelectedGeneralSettings NOTIFY selectedGeneralSettingsChanged)
    Q_PROPERTY(int selectedDevice READ qml_getSelectedDevice WRITE qml_setSelectedDevice NOTIFY selectedDeviceChanged)
    Q_PROPERTY(int selectedGesture READ qml_getSelectedGesture WRITE qml_setSelectedGesture NOTIFY selectedGestureChanged)

public:
    explicit DevicesProxyModel(QObject* parent = nullptr);

    bool qml_getSelectedGeneralSettings();
    void qml_setSelectedGeneralSettings(bool selected);

    int qml_getSelectedDevice();
    void qml_setSelectedDevice(int proxyIdx);

    int qml_getSelectedGesture();
    void qml_setSelectedGesture(int proxyIdx);

    /**
     * @brief Expands the device item to show the gestures that were assigned to it.
     * @param proxyIdx The index of the device item in the flattened tree.
     */
    Q_INVOKABLE void expand(int proxyIdx);

    /**
     * @brief Collapses the device item to hide the gestures that were assigned to it.
     * @param proxyIdx The index of the device item in the flattened tree.
     */
    Q_INVOKABLE void collapse(int proxyIdx);

Q_SIGNALS:
    void selectedDeviceChanged(int newProxyIdx);
    void selectedGestureChanged(int newProxyIdx);
    void selectedGeneralSettingsChanged(bool newSelected);

private:
    /**
     * @brief Calculates the index of this device in the flattened tree.
     * @param device
     * @return The index
     */
    int calculateIndex(const IEDevice* device) const;
    /**
     * @brief Calculates the index of this gesture in the flattened tree.
     * @param gesture
     * @return The index
     */
    int calculateIndex(const IEGesture* gesture) const;

    DevicesTreeModel& srcTree() { return static_cast<DevicesTreeModel&>(*sourceModel()); }
};
