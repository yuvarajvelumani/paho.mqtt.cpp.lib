# Modified from original source code CMakeLists.txt
# Based on version number 1.2.0
# Master MQTT Cpp branch : https://github.com/eclipse/paho.mqtt.cpp.git
#**************************************************************************************************

FIND_PACKAGE(PahoMqttC REQUIRED)

# --- The headers ---
ADD_SUBDIRECTORY(mqtt)

## --- Library dependencies ---

SET (THREADS_PREFER_PTHREAD_FLAG ON)
FIND_PACKAGE(Threads REQUIRED)

## --- Use object library to optimize compilation ---

ADD_LIBRARY(paho-cpp-objs OBJECT
  async_client.cpp
  client.cpp
  connect_options.cpp
  create_options.cpp    
  disconnect_options.cpp
  iclient_persistence.cpp
  message.cpp
  properties.cpp
  response_options.cpp
  ssl_options.cpp
  string_collection.cpp
  subscribe_options.cpp
  token.cpp
  topic.cpp
  will_options.cpp
)

TARGET_INCLUDE_DIRECTORIES(paho-cpp-objs 
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
  PRIVATE 
    ${PAHOMQTT_C_INCLUDE_DIR}
    c_src
)

## create the shared library
ADD_LIBRARY(paho-mqttpp3 SHARED $<TARGET_OBJECTS:paho-cpp-objs> ${PROJECT_SOURCE_LIST})

## add dependencies to the shared library
ADD_DEPENDENCIES(paho-mqttpp3 paho-mqtt3a paho-mqtt3c Threads::Threads)
#TARGET_LINK_LIBRARIES(paho-mqttpp3
#  PRIVATE ${LIBS_SYSTEM}
#  PUBLIC PahoMqttC::PahoMqttC Threads::Threads)
TARGET_LINK_LIBRARIES(paho-mqttpp3 PUBLIC paho-mqtt3a paho-mqtt3c Threads::Threads)

TARGET_INCLUDE_DIRECTORIES(paho-mqttpp3 PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:include>
)

## set the shared library soname
SET_TARGET_PROPERTIES(paho-mqttpp3 PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_VERSION_MAJOR})

## install the shared library
INSTALL(TARGETS paho-mqttpp3 EXPORT PahoMqttCpp
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

IF (WIN32)
  # this is required for copying the files
  SET(PAHOMQTT_CPP_3LIBS "paho-mqttpp3.lib" "paho-mqttpp3.dll" CACHE INTERNAL "")
ELSEIF (UNIX)
  SET(PAHOMQTT_CPP_3LIBS "libpaho-mqttpp3.so" CACHE INTERNAL "")
ENDIF()