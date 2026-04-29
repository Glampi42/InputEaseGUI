#include "testtreemodel.h"

#include <algorithm>

TestTreeModel::TestTreeModel(QObject* parent)
    : QAbstractItemModel(parent)
    , m_root(new TreeNode(QStringLiteral("root")))
{
    m_selectedItem = nullptr;
}

TestTreeModel::~TestTreeModel()
{
    delete m_root;
}

QModelIndex TestTreeModel::index(int row, int column, const QModelIndex& parent) const
{
    if (!hasIndex(row, column, parent))
        return {};

    TreeNode* parentNode = nodeFromIndex(parent);
    if (row < 0 || row >= parentNode->children.size())
        return {};

    return createIndex(row, column, parentNode->children.at(row));
}

QModelIndex TestTreeModel::parent(const QModelIndex& child) const
{
    if (!child.isValid())
        return {};

    TreeNode* childNode = static_cast<TreeNode*>(child.internalPointer());
    TreeNode* parentNode = childNode->parent;

    if (!parentNode || parentNode == m_root)
        return {};

    TreeNode* grandParent = parentNode->parent;
    const int row = grandParent ? grandParent->children.indexOf(parentNode) : 0;
    return createIndex(row, 0, parentNode);
}

int TestTreeModel::rowCount(const QModelIndex& parent) const
{
    return nodeFromIndex(parent)->children.size();
}

int TestTreeModel::columnCount(const QModelIndex& /*parent*/) const
{
    return 1;
}

QModelIndex TestTreeModel::addItem(const QString& label, const QModelIndex& parent)
{
    TreeNode* parentNode = nodeFromIndex(parent);
    const int row = parentNode->children.size();

    beginInsertRows(parent, row, row);
    auto* node = new TreeNode(label, parentNode);
    parentNode->children.append(node);
    endInsertRows();

    return index(row, 0, parent);
}

bool TestTreeModel::moveRows(const QModelIndex& sourceParent, int sourceRow, int count, const QModelIndex& destinationParent, int destinationChild) {
    if(count > 1) return false;// we don't do that here

    TreeNode* sourceParentNode = nodeFromIndex(sourceParent);
    TreeNode* targetNode = sourceParentNode->children.at(sourceRow);
    TreeNode* newParentNode = nodeFromIndex(destinationParent);

    if(targetNode == nullptr || newParentNode->children.count() < destinationChild) {
        return false;// index mismatch
    }

    if(!beginMoveRows(sourceParent, sourceRow, sourceRow + count - 1, destinationParent, destinationChild)) {
        return false;// tried to move the item either to where it was already, or to one of its own children
    }

    sourceParentNode->children.removeAt(sourceRow);

    int insertIdx = std::max(0, std::min(destinationChild, (int) newParentNode->children.count()));
    newParentNode->children.insert(insertIdx, targetNode);
    targetNode->parent = newParentNode;

    endMoveRows();
    return true;
}

TreeNode* TestTreeModel::nodeFromIndex(const QModelIndex& index) const
{
    if (!index.isValid())
        return m_root;
    return static_cast<TreeNode*>(index.internalPointer());
}

QModelIndex TestTreeModel::nodeToIndex(const TreeNode* node) const
{
    if (!node || node == m_root)
        return {};

    int row = node->parent->children.indexOf(node);
    return createIndex(row, 0, node);
}

QVariant TestTreeModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid())
        return {};

    TreeNode* node = static_cast<TreeNode*>(index.internalPointer());

    switch (role) {
    case Qt::DisplayRole:
    case Qt::UserRole:
        return node->label;
    default:
        return {};
    }
}

QHash<int, QByteArray> TestTreeModel::roleNames() const
{
    return {
            { Qt::DisplayRole, "display" },
            { Qt::UserRole,    "label"   },
            };
}
