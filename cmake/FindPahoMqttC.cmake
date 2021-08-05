# Modified from original source code FindPahoMqttC.cmake
# Based on version number 1.2.0
# Master branch : https://github.com/eclipse/paho.mqtt.cpp.git
# Only shared libraries are used
#**************************************************************************************************

# find the Paho MQTT C library
SET(_PAHO_MQTT_C_LIB_NAME paho-mqtt3a)

FIND_LIBRARY(PAHOMQTT_C_LIBS_DIR NAMES ${_PAHO_MQTT_C_LIB_NAME})
unset(_PAHO_MQTT_C_LIB_NAME)
find_path(PAHOMQTT_C_INCLUDE_DIR NAMES MQTTAsync.h)

add_library(PahoMqttC::PahoMqttC UNKNOWN IMPORTED)

set_target_properties(PahoMqttC::PahoMqttC PROPERTIES
  IMPORTED_LOCATION "${PAHOMQTT_C_LIBS_DIR}/${PAHOMQTT_C_3ALIB}"
  INTERFACE_INCLUDE_DIRECTORIES "${PAHOMQTT_C_INCLUDE_DIR}"
  IMPORTED_LINK_INTERFACE_LANGUAGES "C")

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(PahoMqttC
  REQUIRED_VARS PAHOMQTT_C_LIBS_DIR PAHOMQTT_C_INCLUDE_DIR)
