include(../../defaults.pri)

QT -= qt core gui

CONFIG   -= app_bundle
CONFIG += c++17 console

LIBS += -L../../src -lKitsunemimiHanamiPolicies

LIBS += -L../../../libKitsunemimiCommon/src -lKitsunemimiCommon
LIBS += -L../../../libKitsunemimiCommon/src/debug -lKitsunemimiCommon
LIBS += -L../../../libKitsunemimiCommon/src/release -lKitsunemimiCommon
INCLUDEPATH += ../../../libKitsunemimiCommon/include

LIBS += -L../../../libKitsunemimiArgs/src -lKitsunemimiArgs
LIBS += -L../../../libKitsunemimiArgs/src/debug -lKitsunemimiArgs
LIBS += -L../../../libKitsunemimiArgs/src/release -lKitsunemimiArgs
INCLUDEPATH += ../../../libKitsunemimiArgs/include

LIBS += -L../../../libKitsunemimiIni/src -lKitsunemimiIni
LIBS += -L../../../libKitsunemimiIni/src/debug -lKitsunemimiIni
LIBS += -L../../../libKitsunemimiIni/src/release -lKitsunemimiIni
INCLUDEPATH += ../../../libKitsunemimiIni/include

LIBS += -L../../../libKitsunemimiConfig/src -lKitsunemimiConfig
LIBS += -L../../../libKitsunemimiConfig/src/debug -lKitsunemimiConfig
LIBS += -L../../../libKitsunemimiConfig/src/release -lKitsunemimiConfig
INCLUDEPATH += ../../../libKitsunemimiConfig/include

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
