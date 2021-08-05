# paho.mqtt.cpp.lib
## Paho MQTT Cpp Shared library and Data_publish Sample application
- based on the Eclipse Paho MQTT C source code version 1.3.8
- based on the Eclipse Paho MQTT Cpp source code version 1.2.0
- Modified to build ONLY the shared library using CMake tools
- Build C libraries are copied to 'pahomqtt.c.dir' folder
- OpenSSL is NOT used

## Folder Structure
- pahomqtt.c.dir
  - include
  - posix64_libs
  - wind64_libs

## Windows build
- Compiled using Visual Studio 2019

## Linux build
- run `posix_build_paho_mqtt_cpp.sh` script to build for Linux OS  

## TODO
- Raspberry Pi build
