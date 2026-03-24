add_executable(inputeasegui_start)

ecm_add_qml_module(inputeasegui_start
    URI
    me.glampi.inputeasegui
)

target_sources(inputeasegui_start
    PRIVATE
    main.cpp
    helpers/qmlaction.h
    helpers/qmlaction.cpp
    helpers/standardactions.h
    helpers/standardactions.cpp
)

ecm_target_qml_sources(inputeasegui_start
    SOURCES
    Main.qml
    qml/DevicesPage.qml
    qml/MainToolbar.qml
)

target_link_libraries(inputeasegui_start
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::QuickControls2
    Qt6::Widgets
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
    KF6::ConfigCore
    KF6::ConfigGui
)

install(TARGETS inputeasegui_start ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})