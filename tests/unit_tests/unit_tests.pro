include(../../defaults.pri)

QT -= qt core gui

CONFIG   -= app_bundle
CONFIG += c++17 console

LIBS += -L../../src -lKitsunemimiHanamiPolicies

LIBS += -L../../../libKitsunemimiCommon/src -lKitsunemimiCommon
LIBS += -L../../../libKitsunemimiCommon/src/debug -lKitsunemimiCommon
LIBS += -L../../../libKitsunemimiCommon/src/release -lKitsunemimiCommon
INCLUDEPATH += ../../../libKitsunemimiCommon/include

LIBS += -L../../../libKitsunemimiHanamiCommon/src -lKitsunemimiHanamiCommon
LIBS += -L../../../libKitsunemimiHanamiCommon/src/debug -lKitsunemimiHanamiCommon
LIBS += -L../../../libKitsunemimiHanamiCommon/src/release -lKitsunemimiHanamiCommon
INCLUDEPATH += ../../../libKitsunemimiHanamiCommon/include

INCLUDEPATH += $$PWD

SOURCES += \
    main.cpp  \
    policy_test.cpp

HEADERS += \
    policy_test.h
