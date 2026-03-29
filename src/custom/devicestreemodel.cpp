#include "devicestreemodel.h"

// ---------------------------------------------------------------------------
// Construction / destruction
// ---------------------------------------------------------------------------

DevicesTreeModel::DevicesTreeModel(QObject* parent)
    : QAbstractItemModel(parent)
{}

DevicesTreeModel::~DevicesTreeModel()
{
    qDeleteAll(m_devices);
}

// ---------------------------------------------------------------------------
// Core QAbstractItemModel interface
// ---------------------------------------------------------------------------

QModelIndex DevicesTreeModel::index(int row, int column, const QModelIndex &parent) const
{
    if (!hasIndex(row, column, parent))
        return {};

    if (!parent.isValid()) {
        // Requesting a root-level index.
        // internalPointer == nullptr  →  this index represents a root item.
        return createIndex(row, column, nullptr);
    }

    // Requesting a child-level index.
    // internalPointer == parent RootItem*  →  this index represents a child.
    IEDevice* rootItem = m_devices.at(parent.row());
    return createIndex(row, column, rootItem);
}

QModelIndex DevicesTreeModel::parent(const QModelIndex &child) const
{
    if (!child.isValid())
        return {};

    auto* parentRoot = static_cast<IEDevice*>(child.internalPointer());

    // nullptr  →  child is a root item, its parent is the invisible root.
    if (!parentRoot)
        return {};

    // Non-null  →  child is a leaf; parent is the stored RootItem.
    return createIndex(deviceRow(parentRoot), 0, nullptr);
}

int DevicesTreeModel::rowCount(const QModelIndex &parent) const
{
    if (!parent.isValid())
        return m_devices.size();

    if (parent.column() > 0)
        return 0;

    // Only root-level items (internalPointer == nullptr) have children.
    if (parent.internalPointer() == nullptr)
        return m_devices.at(parent.row())->childCount();

    return 0; // leaf nodes have no children
}

int DevicesTreeModel::columnCount(const QModelIndex & /*parent*/) const
{
    return 1; // single-column tree for QML TreeView
}

QVariant DevicesTreeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};

    auto* parentRoot = static_cast<IEDevice*>(index.internalPointer());

    if (!parentRoot) {
        // ── Root item / device ────────────────────────────────────────────────────
        const IEDevice* item = m_devices.at(index.row());
        switch (role) {
        case Qt::DisplayRole:
        case Name:
            return item->name();

        case IsGesture:
            return false;

        case IsLastGesture:
            return false;

        default:
            return {};
        }
    }

    // ── Child (leaf) item / gesture ─────────────────────────────────────────────────
    const IEGesture* item = parentRoot->childAt(index.row());
    switch (role) {
    case Qt::DisplayRole:
    case Name:
        return item->name();

    case IsGesture:
        return true;

    case IsLastGesture:
        return index.row() == parentRoot->childCount() - 1;

    default:
        return {};
    }
}

QHash<int, QByteArray> DevicesTreeModel::roleNames() const
{
    return {
        {Name, "nameRole"},
        {IsGesture, "isGestureRole"},
        {IsLastGesture, "isLastGestureRole"},
    };
}

// ---------------------------------------------------------------------------
// Dynamic mutation API
// ---------------------------------------------------------------------------

void DevicesTreeModel::addRootItem(IEDevice* item)
{
    const int row = m_devices.size();
    beginInsertRows({}, row, row);
    m_devices.append(item);
    endInsertRows();
}

void DevicesTreeModel::addChildItem(IEDevice* parentItem, IEGesture* child)
{
    const int pRow = deviceRow(parentItem);
    if (pRow < 0)
        return;

    const QModelIndex parentIndex = createIndex(pRow, 0, nullptr);
    const int childRow = parentItem->childCount();
    beginInsertRows(parentIndex, childRow, childRow);
    parentItem->addChild(child);
    endInsertRows();
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------
int DevicesTreeModel::deviceRow(const IEDevice* device) const
{
    return m_devices.indexOf(device);
}