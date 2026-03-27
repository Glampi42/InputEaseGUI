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

    // Dynamic mutation API
    void addRootItem(IEDevice* item);
    void addChildItem(IEDevice* parentItem, IEGesture* child);

private:
    /**
     * @brief DevicesTreeModel::deviceRow
     * @param device
     * @return The row of the device in the device tree.
     */
    int deviceRow(const IEDevice* device) const;
    /**
     * @brief Calculates the index of this device in the tree.
     * @param device
     * @return The index
     */
    int calculateIndex(const IEDevice* device) const;
    /**
     * @brief Calculates the index of this gesture in the tree.
     * @param gesture
     * @return The index
     */
    int calculateIndex(const IEGesture* gesture) const;

    QList<IEDevice*> m_devices;
};