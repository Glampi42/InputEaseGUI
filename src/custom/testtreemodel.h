#pragma once

#include <QAbstractItemModel>
#include <QList>
#include <QString>

struct TreeNode {
    explicit TreeNode(QString label, TreeNode* parent = nullptr)
        : label(std::move(label)), parent(parent) {}
    ~TreeNode() { qDeleteAll(children); }

    QString label;
    TreeNode* parent = nullptr;
    QList<TreeNode*> children;
};

/**
 * @brief The TestTreeModel is a dummy tree model to use for testing the UI
 */
class TestTreeModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    explicit TestTreeModel(QObject* parent = nullptr);
    ~TestTreeModel() override;

    // QAbstractItemModel interface
    QModelIndex index(int row, int column,
                      const QModelIndex &parent = {}) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    int rowCount(const QModelIndex &parent = {}) const override;
    int columnCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index,
                  int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Adds a child node under the given parent index (invalid = root)
    QModelIndex addItem(const QString& label, const QModelIndex& parent = {});

private:
    TreeNode* nodeFromIndex(const QModelIndex& index) const;

    TreeNode* m_root;
};
