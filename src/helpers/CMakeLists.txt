add_library(inputeasegui_helpers)

ecm_add_qml_module(inputeasegui_helpers
    URI "me.glampi.inputeasegui.helpers"
    GENERATE_PLUGIN_SOURCE
)

# put .qml source files here
# ecm_target_qml_sources(inputeasegui_helpers
#     SOURCES

# )

target_sources(inputeasegui_helpers
    PRIVATE
    qmlaction.h
    qmlaction.cpp
    standardactions.h
    standardactions.cpp
)

target_link_libraries(inputeasegui_helpers
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

ecm_finalize_qml_module(inputeasegui_helpers)

install(TARGETS inputeasegui_helpers ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
