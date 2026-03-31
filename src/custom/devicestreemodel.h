#pragma once

#include <QAbstractItemModel>
#include <QList>
#include <QString>

#include "iedevice.h"
#include "iegesture.h"

/**
 * @brief The DevicesTreeModel class is used to store all devices and their gestures, as well as their settings.
 */
class DevicesTreeModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    enum Roles {
        Name = Qt::UserRole + 1,
        IsGesture = Qt::UserRole + 2,
        IsLastGesture = Qt::UserRole + 3,// whether the gesture is the last gesture of the device; this is used for the tree branch symbol correct display
        // add further roles here and mirror them in roleNames() / data()
    };
    Q_ENUM(Roles)

    explicit DevicesTreeModel(QObject* parent = nullptr);
    ~DevicesTreeModel() override;

    // QAbstractItemModel interface
    QModelIndex index(int row, int column,
                      const QModelIndex &parent = {}) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    int rowCount(const QModelIndex &parent = {}) const override;
    int columnCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index,
                  int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    /**
     * @brief Constructs the QModelIndex pointing to the specified device.
     * @param device
     * @return QModelIndex
     */
    QModelIndex modelIndexFromPtr(IEDevice* device);
    /**
     * @brief Constructs the QModelIndex pointing to the specified gesture.
     * @param gesture
     * @return QModelIndex
     */
    QModelIndex modelIndexFromPtr(IEGesture* gesture);
    /**
     * @brief Retrieves the pointer pointing to the specified device.
     * @param deviceIdx
     * @return Device ptr
     */
    IEDevice* modelIndexToDevice(QModelIndex deviceIdx);
    /**
     * @brief Retrieves the pointer pointing to the specified gesture.
     * @param gestureIdx
     * @return Gesture ptr
     */
    IEGesture* modelIndexToGesture(QModelIndex gestureIdx);

    // Dynamic mutation API
    void addRootItem(IEDevice* item);
    void addChildItem(IEGesture* child);

    bool getSelectedGeneralSettings() { return m_selectedGeneralSettings; }
    void setSelectedGeneralSettings(bool selected) { m_selectedGeneralSettings = selected; }
    IEDevice* getSelectedDevice() { return m_selectedDevice; }
    void setSelectedDevice(IEDevice* device) { m_selectedDevice = device; }
    IEGesture* getSelectedGesture() { return m_selectedGesture; }
    void setSelectedGesture(IEGesture* gesture) { m_selectedGesture = gesture; }

private:
    /**
     * @brief DevicesTreeModel::deviceIndex
     * @param device
     * @return The index of the device in the unflattened device tree.
     */
    int deviceIndex(const IEDevice* device) const { return m_devices.indexOf(device); }

    QList<IEDevice*> m_devices;

    bool m_selectedGeneralSettings;
    IEDevice* m_selectedDevice;
    IEGesture* m_selectedGesture;
};