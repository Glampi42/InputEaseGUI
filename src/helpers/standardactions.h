#pragma once
#include <QObject>
#include "qmlaction.h"

/**
 * @brief A singleton class that passes the actions from KStandardActions to QML files.
 */
class StandardActions : public QObject {
    Q_OBJECT
    Q_PROPERTY(QmlAction* save READ save CONSTANT)
    Q_PROPERTY(QmlAction* delete_action READ delete_action CONSTANT)
public:
    explicit StandardActions(QObject *parent = nullptr);
    QmlAction* save() const { return m_save; }
    QmlAction* delete_action() const { return m_delete_action; }

Q_SIGNALS:
    void moveToTrashTriggered();

private:
    QmlAction *m_save = nullptr;
    QmlAction *m_delete_action = nullptr;
};