#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QString>

#include "maindraweritem.h"

/**
 * @brief The MainDrawerModel class generates the model used by MainDrawer.qml.
 */
class MainDrawerModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int selectedItem READ qml_getSelectedItem WRITE qml_setSelectedItem NOTIFY selectedItemChanged)

public:
    enum Roles {
        Name = Qt::UserRole + 1,
        IconName = Qt::UserRole + 2,
        Section = Qt::UserRole + 3,
        // add further roles here and mirror them in roleNames() & data()
    };
    Q_ENUM(Roles)

    explicit MainDrawerModel(QObject* parent = nullptr);
    ~MainDrawerModel() override;

    // QAbstractListModel interface
    int rowCount(const QModelIndex& /*parent = {}*/) const override { return  m_items.count(); }
    QVariant data(const QModelIndex& index,
                  int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    /**
     * @brief Constructs the QModelIndex pointing to the specified item.
     */
    QModelIndex modelIndexFromPtr(MainDrawerItem* item) const { return index(itemIndex(item), 0); }
    /**
     * @brief Returns the pointer pointing to the item at the specified modelIndex.
     */
    MainDrawerItem* modelIndexToPtr(const QModelIndex& modelIndex) const { return m_items.at(modelIndex.row()); }

    MainDrawerItem* getSelectedItem() { return m_selectedItem; }
    void setSelectedItem(MainDrawerItem* item) {
        m_selectedItem = item;

        Q_EMIT selectedItemChanged();
    }

    int qml_getSelectedItem() {
        return itemIndex(m_selectedItem);
    }

    void qml_setSelectedItem(int itemIdx) {
        m_selectedItem = m_items.at(itemIdx);

        Q_EMIT selectedItemChanged();
    }

Q_SIGNALS:
    void selectedItemChanged();

private:
    /**
     * @return The index of the item.
     */
    int itemIndex(const MainDrawerItem* item) const { return m_items.indexOf(item); }

    QList<MainDrawerItem*> m_items;

    MainDrawerItem* m_selectedItem;
};