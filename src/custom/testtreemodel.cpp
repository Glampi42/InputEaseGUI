#include "testtreemodel.h"

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
