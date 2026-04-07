#include "maindrawermodel.h"

#include <KLocalizedString>

#include "maindraweritem.h"

// ---------------------------------------------------------------------------
// Construction / destruction
// ---------------------------------------------------------------------------

MainDrawerModel::MainDrawerModel(QObject* parent)
    : QAbstractListModel(parent)
{
    m_items = {
        new MainDrawerItem(i18nc("@item:inlistbox", "General Settings"), QStringLiteral("configure"),            QString()                        ),
        new MainDrawerItem(i18nc("@item:inlistbox", "Device Rules"),     QStringLiteral("dialog-input-devices"), QString()                        ),
        new MainDrawerItem(i18nc("@item:inlistbox", "Keyboard"),         QStringLiteral("input-keyboard"),       i18nc("@title:group", "Devices") ),
        new MainDrawerItem(i18nc("@item:inlistbox", "Mouse"),            QStringLiteral("input-mouse"),          i18nc("@title:group", "Devices") ),
        new MainDrawerItem(i18nc("@item:inlistbox", "Pointer"),          QStringLiteral("pointer"),              i18nc("@title:group", "Devices") ),
        new MainDrawerItem(i18nc("@item:inlistbox", "Touchpad"),         QStringLiteral("input-touchpad"),       i18nc("@title:group", "Devices") ),
        new MainDrawerItem(i18nc("@item:inlistbox", "Touchscreen"),      QStringLiteral("input-touchscreen"),    i18nc("@title:group", "Devices") ),
    };

    m_selectedItem = m_items[0];// general settings selected initially
}

MainDrawerModel::~MainDrawerModel()
{
    qDeleteAll(m_items);
}

// ---------------------------------------------------------------------------
// Core QAbstractItemModel interface
// ---------------------------------------------------------------------------

QVariant MainDrawerModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid())
        return {};

    MainDrawerItem* item = modelIndexToPtr(index);

    switch (role) {
    case Qt::DisplayRole:
    case Name:
        return item->name();

    case IconName:
        return item->iconName();

    case Section:
        return item->section();

    default:
        return {};
    }
}

QHash<int, QByteArray> MainDrawerModel::roleNames() const
{
    return {
        {Name, "nameRole"},
        {IconName, "iconNameRole"},
        {Section, "sectionRole"},
    };
}
