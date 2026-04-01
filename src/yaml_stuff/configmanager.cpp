#include "configmanager.h"

#include <QCoreApplication>
#include <QDir>
#include <QDebug>
#include <fstream>
#include <KLocalizedString>

ConfigManager::ConfigManager(QObject* parent) : QObject(parent)
{
    m_configPath = QDir(QCoreApplication::applicationDirPath())
                       .filePath(QStringLiteral("../../../config/config.yaml"));
}

bool ConfigManager::load()
{
    QFile file(m_configPath);

    if (!file.exists()) {
        // create file if it doesn't exist:
        if (!file.open(QIODevice::WriteOnly)) {
            qWarning() << "Failed to create config at" << m_configPath;
            Q_EMIT fatalError(i18nc("@info error message; path to config comes next", "Failed to create the config file at\n") + m_configPath
                              + i18nc("@info error message 2nd line", "\nIs the write permission missing?"));

            return false;
        }

        file.close();
    }

    try {
        m_root = YAML::LoadFile(m_configPath.toStdString());
        return true;
    } catch (const YAML::ParserException& e) {
        qWarning() << "Failed to parse config:" << e.what();
        Q_EMIT configCorrupted(i18nc("@info error message", "The config file is corrupted or contains invalid content. Error message:\n") + QString::fromStdString(e.what())
                               + i18nc("@info error message 2nd line", "\n\nClear the config? This action will delete the previous config file from the disk."));

        return false;
    } catch (const YAML::Exception& e) {
        qWarning() << "Failed to load config:" << e.what();
        Q_EMIT fatalError(i18nc("@info error message; path to config comes next", "Failed to open the config file at\n") + m_configPath
                          + i18nc("@info error message 2nd line", "\nIs the read permission missing?"));

        return false;
    }
}

bool ConfigManager::save()
{
    try {
        std::ofstream fout(m_configPath.toStdString());
        if (!fout.is_open()) {
            qWarning() << "Failed to open config for writing at" << m_configPath;
            Q_EMIT error(i18nc("@info error message; path to config comes next", "Failed to open the config file for writing at\n") + m_configPath
                         + i18nc("@info error message 2nd line", "\nIs the read permission missing?"));

            return false;
        }
        fout << m_root;

        return true;
    } catch (const YAML::Exception& e) {
        qWarning() << "Failed to save config:" << e.what();
        Q_EMIT error(i18nc("@info error message; path to config comes next", "Failed to save changes to the config file at\n") + m_configPath
                     + i18nc("@info error message 2nd line", "\nIs the write permission missing?"));

        return false;
    }
}

bool ConfigManager::clear()
{
    QFile file(m_configPath);
    // QIODevice::Truncate option truncates the file to zero bytes on open
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "Failed to clear config at" << m_configPath;
        Q_EMIT fatalError(i18nc("@info error message; path to config comes next", "Failed to clear the config file at\n") + m_configPath
                          + i18nc("@info error message 2nd line", "\nIs the write permission missing?"));

        return false;
    }
    file.close();
    m_root = YAML::Node();

    return true;
}

// --- Accessors ---

QString ConfigManager::testString() const
{
    if (m_root["testString"])
        return QString::fromStdString(m_root["testString"].as<std::string>());

    return {};
}

void ConfigManager::setTestString(const QString& str)
{
    m_root["testString"] = str.toStdString();
}