#pragma once

#include <kdescendantsproxymodel.h>
#include <qqmlintegration.h>

/**
 * @brief The DevicesProxyModel class converts the DevicesTreeModel into a flat list and adds QML functionality such as to expand/collapse children.
 */
class DevicesProxyModel : public KDescendantsProxyModel
{
    Q_OBJECT

public:
    explicit DevicesProxyModel(QObject* parent = nullptr);

    /**
     * @brief Expands the device item to show the gestures that were assigned to it.
     * @param proxyRow The index of the device item in the list.
     */
    Q_INVOKABLE void expand(int proxyRow);

    /**
     * @brief Collapses the device item to hide the gestures that were assigned to it.
     * @param proxyRow The index of the device item in the list.
     */
    Q_INVOKABLE void collapse(int proxyRow);
};
