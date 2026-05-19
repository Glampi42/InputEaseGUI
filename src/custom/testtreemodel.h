#pragma once

#include <QAbstractItemModel>
#include <QList>
#include <QString>

struct TreeNode {
    explicit TreeNode(QString label, bool isFolder, TreeNode* parent = nullptr)
        : label(std::move(label)), isFolder(isFolder), parent(parent) {}
    ~TreeNode() { qDeleteAll(children); }

    QString label;
    bool isFolder;// false for normal entries (leaves), true for folders
    TreeNode* parent = nullptr;
    QList<TreeNode*> children;
};

/**
 * @brief The TestTreeModel is a dummy tree model to use for testing the UI
 */
class TestTreeModel : public QAbstractItemModel
{
    Q_OBJECT

    Q_PROPERTY(QModelIndex selectedItem READ qml_getSelectedItem WRITE qml_setSelectedItem NOTIFY selectedItemChanged FINAL)

public:
    explicit TestTreeModel(QObject* parent = nullptr);
    ~TestTreeModel() override;

    // QAbstractItemModel interface
    QModelIndex index(int row, int column, const QModelIndex &parent = {}) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    int rowCount(const QModelIndex &parent = {}) const override;
    int columnCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE bool canDropItem(const QModelIndex& sourceIndex, const QModelIndex& targetIndex, bool intoFolder) const;

    bool moveRows(const QModelIndex& sourceParent, int sourceRow, int count, const QModelIndex& destinationParent, int destinationChild) override;

    // Adds a child node under the given parent index (invalid = root)
    QModelIndex addItem(const QString& label, bool isFolder, const QModelIndex& parent = {});

    QModelIndex qml_getSelectedItem() { return nodeToIndex(m_selectedItem); }
    void qml_setSelectedItem(QModelIndex selectedIdx) {
        m_selectedItem = nodeFromIndex(selectedIdx);
        Q_EMIT selectedItemChanged();
    }

Q_SIGNALS:
    void selectedItemChanged();

private:
    TreeNode* nodeFromIndex(const QModelIndex& index) const;
    QModelIndex nodeToIndex(const TreeNode* node) const;

    TreeNode* m_root;

    TreeNode* m_selectedItem;
};
