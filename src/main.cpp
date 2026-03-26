#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QQuickStyle>
#include <QStandardItemModel>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <KIconTheme>
#include <KDescendantsProxyModel>

int main(int argc, char *argv[])
{
    //-----------------General settings-----------------DOWN
    KIconTheme::initTheme();
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("inputeasegui");
    QApplication::setOrganizationName(QStringLiteral("Glampi"));
    QApplication::setOrganizationDomain(QStringLiteral("glampi.me"));
    QApplication::setApplicationName(QStringLiteral("Input Ease GUI"));
    QApplication::setDesktopFileName(QStringLiteral("me.glampi.inputeasegui"));

    QApplication::setStyle(QStringLiteral("breeze"));
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }
    //-----------------General settings-----------------UP

    QQmlApplicationEngine engine;

    //-----------------Setting up devices menu-----------------DOWN
    auto* source_model = new QStandardItemModel;
    source_model->appendRow(new QStandardItem(QStringLiteral("Root A")));
    source_model->appendRow(new QStandardItem(QStringLiteral("Root B")));
    source_model->appendRow(new QStandardItem(QStringLiteral("Root C")));

    // auto* model = new KDescendantsProxyModel(&app);
    // model->setSourceModel(source_model);

    engine.rootContext()->setContextProperty(QStringLiteral("devices_model"), source_model);
    //-----------------Setting up devices menu-----------------UP

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule("me.glampi.inputeasegui", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
