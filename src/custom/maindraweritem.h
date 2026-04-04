#pragma once

#include <qstring.h>

/**
 * @brief The MainDrawerItem is the item used in the MainDrawerModel.
 */
class MainDrawerItem
{
public:
    MainDrawerItem(QString _name, QString _iconName, QString _section) : m_name(_name), m_iconName(_iconName), m_section(_section) {}

    QString name() { return m_name; }
    QString iconName() { return m_iconName; }
    QString section() { return m_section; }

private:
    const QString m_name;
    const QString m_iconName;
    const QString m_section;
};