#pragma once
#include <QObject>
#include <QAction>

/**
 * @brief Class for wrapping the standard actions from KStandardActions for use in QML files.
 */
class QmlAction : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString text     READ text     NOTIFY changed)
    Q_PROPERTY(QString iconName READ iconName NOTIFY changed)
    Q_PROPERTY(bool enabled     READ enabled  WRITE setEnabled NOTIFY changed)
public:
    explicit QmlAction(QAction* action, QObject* parent = nullptr);

    QString text()     const { return m_action->text(); }
    QString iconName() const { return m_action->icon().name(); } // works for fromTheme icons
    bool    enabled()  const { return m_action->isEnabled(); }
    void setEnabled(bool e)  { m_action->setEnabled(e); }

    Q_INVOKABLE void trigger() { m_action->trigger(); }

Q_SIGNALS:
    void changed();
    void triggered();

private:
    QAction* m_action;
};