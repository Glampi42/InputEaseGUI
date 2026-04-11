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

#include "custom/maindrawermodel.h"
#include "yaml_stuff/configmanager.h"
#include "custom/testtreemodel.h"

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

    ConfigManager config;
    engine.rootContext()->setContextProperty(QStringLiteral("config"), &config);

    MainDrawerModel* model = new MainDrawerModel(&app);
    engine.rootContext()->setContextProperty(QStringLiteral("mainDrawerModel"), model);

    TestTreeModel* testModel = new TestTreeModel(&app);

    auto a = testModel->addItem(QStringLiteral("Root A"));
    auto a1 = testModel->addItem(QStringLiteral("Child A.1"), a);
    testModel->addItem(QStringLiteral("Such a loooooooooooooooooooooooooooooooooong child"), a1);
    testModel->addItem(QStringLiteral("Child A.2"), a);

    auto b = testModel->addItem(QStringLiteral("Root B"));
    testModel->addItem(QStringLiteral("A very useful gesture"), b);
    testModel->addItem(QStringLiteral("Another useful gesture"), b);
    auto b1 = testModel->addItem(QStringLiteral("Child B... does anyone care?"), b);
    testModel->addItem(QStringLiteral("Yet another gesture"), b1);
    testModel->addItem(QStringLiteral("Yet another gesture 2"), b1);

    testModel->addItem(QStringLiteral("Swipe gesture #4"));
    testModel->addItem(QStringLiteral("Swipe gesture #5"));
    testModel->addItem(QStringLiteral("Swipe gesture #6"));

    engine.rootContext()->setContextProperty(QStringLiteral("testTreeModel"), testModel);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule("me.glampi.inputeasegui", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // things to run after the QML component tree is instantiated:
    config.load();

    return app.exec();
}
