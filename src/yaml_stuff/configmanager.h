#pragma once

#include <QObject>
#include <yaml-cpp/yaml.h>

/**
 * @brief The ConfigManager class deals with reading and writing to the config file of InputActions.
 */
class ConfigManager : public QObject
{
    Q_OBJECT

public:
    explicit ConfigManager(QObject *parent = nullptr);

    bool load();
    bool save();
    Q_INVOKABLE bool clear();

    // Example typed accessors
    QString testString() const;
    void setTestString(const QString& str);

Q_SIGNALS:
    /**
     * @brief Emitted when the app can't run because of this error.
     * @param message
     */
    void fatalError(const QString& message);
    /**
     * @brief Emitted when something went wrong. The app can still run.
     * @param message
     */
    void error(const QString& message);
    /**
     * @brief Emitted when the config file can't be treated as a YAML file, f.e. due to wrong indentation.
     * @param message
     */
    void configCorrupted(const QString& message);

private:
    QString m_configPath;
    YAML::Node m_root;
};
