#include "qmlaction.h"

QmlAction::QmlAction(QAction *action, QObject *parent)
    : QObject(parent), m_action(action)
{
    connect(action, &QAction::changed,   this, &QmlAction::changed);
    connect(action, &QAction::triggered, this, &QmlAction::triggered);
}