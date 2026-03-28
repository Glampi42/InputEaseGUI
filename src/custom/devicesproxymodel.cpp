#include "devicesproxymodel.h"

#include <kdescendantsproxymodel.h>

DevicesProxyModel::DevicesProxyModel(QObject* parent) : KDescendantsProxyModel(parent) {}

void DevicesProxyModel::expand(int proxyRow) {
    const QModelIndex proxyIdx = index(proxyRow, 0);
    expandSourceIndex(mapToSource(proxyIdx));
}

void DevicesProxyModel::collapse(int proxyRow) {
    const QModelIndex proxyIdx = index(proxyRow, 0);
    collapseSourceIndex(mapToSource(proxyIdx));
}
