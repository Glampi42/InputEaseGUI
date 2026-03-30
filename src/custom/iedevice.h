#pragma once

#include <QAbstractItemModel>
#include <QList>
#include <QString>

#include "iegesture.h"

/**
 * @brief This class holds the properties of an input device that has some gestures assigned to it.
 */
class IEDevice
{
public:
    explicit IEDevice(const QString &name) : m_name(name) {}
    ~IEDevice() { qDeleteAll(m_gestures); }

    QString name() const { return m_name; }

    // gestures are referred to as "children" here because of the tree structure in DevicesPage.qml
    int childCount() const { return m_gestures.size(); }
    IEGesture* childAt(int row) const { return m_gestures.at(row); }
    const QList<IEGesture*> &children() const { return m_gestures; }
    void addChild(IEGesture* child) { m_gestures.append(child); }

    int gestureIndex(IEGesture* gesture) const { return m_gestures.indexOf(gesture); }

private:
    QString m_name;
    QList<IEGesture*> m_gestures;
};
