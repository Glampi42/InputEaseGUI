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

#include "custom/devicestreemodel.h"
#include "custom/devicesproxymodel.h"

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
    auto* source_model = new DevicesTreeModel;
    auto* deviceA = new IEDevice(QStringLiteral("Root A"));
    source_model->addRootItem(deviceA);
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 1"), deviceA));
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 2"), deviceA));
    auto* deviceB = new IEDevice(QStringLiteral("Root B"));
    source_model->addRootItem(deviceB);
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 3"), deviceB));
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 4"), deviceB));
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 5"), deviceB));
    auto* deviceC = new IEDevice(QStringLiteral("Root C"));
    source_model->addRootItem(deviceC);
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 6"), deviceC));
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 7"), deviceC));
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 8"), deviceC));
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 9"), deviceC));
    source_model->addChildItem(new IEGesture(QStringLiteral("Child 42 lololol"), deviceC));

    auto* model = new DevicesProxyModel(&app);
    model->setSourceModel(source_model);

    engine.rootContext()->setContextProperty(QStringLiteral("devices_model"), model);
    //-----------------Setting up devices menu-----------------UP

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule("me.glampi.inputeasegui", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
