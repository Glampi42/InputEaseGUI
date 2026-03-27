#pragma once

#include <QAbstractItemModel>
#include <QList>
#include <QString>

class IEDevice;

/**
 * @brief This class contains the settings and properties of a gesture of some device.
 */
class IEGesture
{
public:
public:
    explicit IEGesture(const QString &name) : m_name(name) {}

    QString name() const { return m_name; }
    IEDevice* parentDevice() const {return m_parentDevice; }
    // other properties coming...

private:
    QString m_name;
    IEDevice* m_parentDevice;
};
