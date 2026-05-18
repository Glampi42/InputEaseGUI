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

    auto a = testModel->addItem(QStringLiteral("Root A"), true);
    auto a1 = testModel->addItem(QStringLiteral("A specific folder"), true, a);
    testModel->addItem(QStringLiteral("Such a loooooooooooooooooooooooooooooooooong gesture"), false, a1);
    testModel->addItem(QStringLiteral("Not-so-specific gesture"), false, a);

    auto b = testModel->addItem(QStringLiteral("Root B"), true);
    testModel->addItem(QStringLiteral("A very useful gesture"), false, b);
    testModel->addItem(QStringLiteral("Another useful gesture"), false, b);
    auto b1 = testModel->addItem(QStringLiteral("I-forgot-this folder"), true, b);
    testModel->addItem(QStringLiteral("Yet another gesture"), false, b1);
    testModel->addItem(QStringLiteral("Empty folder"), true, b1);

    testModel->addItem(QStringLiteral("Swipe gesture #4"), false);
    testModel->addItem(QStringLiteral("Swipe gesture #5"), false);
    testModel->addItem(QStringLiteral("Swipe gesture #6"), false);

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
