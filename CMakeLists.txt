# Modified from original source code CMakeLists.txt
# Based on version number 1.2.0
# Master MQTT Cpp branch : https://github.com/eclipse/paho.mqtt.cpp.git
# Based on version number 1.3.8
# Master MQTT C branch : https://github.com/eclipse/paho.mqtt.c.git
# This project will build both C and Cpp together 
#**************************************************************************************************
CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
PROJECT("paho-mqtt-cpp" 
    VERSION "1.2.0"
    LANGUAGES C CXX)

SET(CMAKE_SCRIPTS "${CMAKE_SOURCE_DIR}/cmake")
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")

## --- C++11 build flags ---

SET(CMAKE_CXX_STANDARD 11)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)
SET(CMAKE_CXX_EXTENSIONS OFF)

# Generate position-independent code (-fPIC on UNIX)
SET(CMAKE_POSITION_INDEPENDENT_CODE ON)

# --- System Libraries ---

INCLUDE(GNUInstallDirs)

IF(WIN32)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE -DWIN32_LEAN_AND_MEAN -MD)
  SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
  SET(LIBS_SYSTEM ws2_32)
ELSEIF(UNIX)
  SET(LIBS_SYSTEM c stdc++)
ELSEIF(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  ADD_DEFINITIONS(-DOSX)
ENDIF()

## build options
ADD_DEFINITIONS(-DPAHO_BUILD_SHARED=1)
ADD_DEFINITIONS(-DHIGH_PERFORMANCE=1)

IF(PAHO_BUILD_DEB_PACKAGE)
  SET(CMAKE_INSTALL_DOCDIR share/doc/libpaho-mqtt)
ENDIF()

## --- Build directories ---

ADD_SUBDIRECTORY(src)
INCLUDE_DIRECTORIES(src)

# For the paho_mqtt_c module
LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
ADD_SUBDIRECTORY(cpp_src)
INCLUDE_DIRECTORIES(cpp_src)
add_subdirectory(cpp_src/samples)

# --- Default library for samples and unit tests ---

SET(PAHO_CPP_LIB paho-mqttpp3)
#**************************************************************************************************
# Only shared library is build using this CMake project
# Doc, Static, Samples, testing, cpack are not required for this project 