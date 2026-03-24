#include "standardactions.h"
#include <KStandardActions>

StandardActions::StandardActions(QObject *parent) : QObject(parent)
{
    auto* action = KStandardActions::save(
        this, &StandardActions::dummy_signal, this);
    m_save = new QmlAction(action, this);

    action = KStandardActions::deleteFile(
        this, &StandardActions::dummy_signal, this);
    m_delete_action = new QmlAction(action, this);
}