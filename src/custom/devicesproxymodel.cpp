#include "devicesproxymodel.h"

#include <kdescendantsproxymodel.h>

DevicesProxyModel::DevicesProxyModel(QObject* parent) : KDescendantsProxyModel(parent) {}

void DevicesProxyModel::expand(int proxyIdx) {
    const QModelIndex modelIdx = index(proxyIdx, 0);
    expandSourceIndex(mapToSource(modelIdx));
}

void DevicesProxyModel::collapse(int proxyIdx) {
    const QModelIndex modelIdx = index(proxyIdx, 0);
    collapseSourceIndex(mapToSource(modelIdx));
}

bool DevicesProxyModel::qml_getSelectedGeneralSettings() {
    return srcTree().getSelectedGeneralSettings();
}

void DevicesProxyModel::qml_setSelectedGeneralSettings(bool selected) {
    srcTree().setSelectedGeneralSettings(selected);
    srcTree().setSelectedDevice(nullptr);
    srcTree().setSelectedGesture(nullptr);

    Q_EMIT selectedGeneralSettingsChanged(selected);
    Q_EMIT selectedDeviceChanged(-1);
    Q_EMIT selectedGestureChanged(-1);
}

int DevicesProxyModel::qml_getSelectedDevice() {
    if(srcTree().getSelectedDevice() == nullptr)
        return -1;

    return mapFromSource(srcTree().modelIndexFromPtr(srcTree().getSelectedDevice())).row();
}

void DevicesProxyModel::qml_setSelectedDevice(int proxyIdx) {
    const QModelIndex modelIdx = index(proxyIdx, 0);

    srcTree().setSelectedGeneralSettings(false);
    srcTree().setSelectedDevice(srcTree().modelIndexToDevice(mapToSource(modelIdx)));
    srcTree().setSelectedGesture(nullptr);

    Q_EMIT selectedGeneralSettingsChanged(false);
    Q_EMIT selectedDeviceChanged(proxyIdx);
    Q_EMIT selectedGestureChanged(-1);
}

int DevicesProxyModel::qml_getSelectedGesture() {
    if(srcTree().getSelectedGesture() == nullptr)
        return -1;

    return mapFromSource(srcTree().modelIndexFromPtr(srcTree().getSelectedGesture())).row();
}

void DevicesProxyModel::qml_setSelectedGesture(int proxyIdx) {
    const QModelIndex modelIdx = index(proxyIdx, 0);

    srcTree().setSelectedGeneralSettings(false);
    srcTree().setSelectedDevice(nullptr);
    srcTree().setSelectedGesture(srcTree().modelIndexToGesture(mapToSource(modelIdx)));

    Q_EMIT selectedGeneralSettingsChanged(false);
    Q_EMIT selectedDeviceChanged(-1);
    Q_EMIT selectedGestureChanged(proxyIdx);
}