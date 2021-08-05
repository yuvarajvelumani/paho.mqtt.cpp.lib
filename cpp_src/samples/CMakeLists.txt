# CMakeLists.txt
#
# CMake file for the Paho C++ sample applications.
#
#*******************************************************************************
# This is part of the Paho MQTT C++ client library.
#
# Copyright (c) 2016-2019
# 
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# and Eclipse Distribution License v1.0 which accompany this distribution.
# 
# The Eclipse Public License is available at
#   http://www.eclipse.org/legal/epl-v10.html
# and the Eclipse Distribution License is available at
#   http://www.eclipse.org/org/documents/edl-v10.php.
# 
# Contributors:
#   Guilherme Maciel Ferreira - initial version
#   Frank Pagliughi - Updates for new samples
#*******************************************************************************/

## Note: on OS X you should install XCode and the associated command-line tools

## --- Library dependencies ---

set (THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

## include directories
#include_directories(${CMAKE_CURRENT_SOURCE_DIR})

IF(WIN32)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE -DWIN32_LEAN_AND_MEAN -MD)
  SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
  SET(LIBS_SYSTEM ws2_32)
ELSEIF(UNIX)
  SET(LIBS_SYSTEM c stdc++)
ELSEIF(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  ADD_DEFINITIONS(-DOSX)
ENDIF()

## binary files
add_executable(data_publish data_publish.cpp)

## link binaries
target_link_libraries(data_publish paho-mqttpp3 paho-mqtt3a)

set(INSTALL_TARGETS data_publish)

## install binaries
install(TARGETS ${INSTALL_TARGETS} EXPORT PahoMqttCppSamples
	RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib
)

FOREACH( file_i ${PAHOMQTT_C_3ALIBS})
  ADD_CUSTOM_COMMAND(
    TARGET data_publish POST_BUILD                            # Adds a post-build event to paho-mqtt3a
    COMMENT "Copying file '${file_i}' after build...\n"
    COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different        # which executes "cmake -E copy_if_different..."
    "${CMAKE_BINARY_DIR}/src/$<CONFIGURATION>/${file_i}"      # <--this is in-file
    "${CMAKE_BINARY_DIR}/cpp_src/samples/$<CONFIGURATION>/"   # <--this is out-file path
)
ENDFOREACH( file_i )

FOREACH( file_i ${PAHOMQTT_CPP_3LIBS})
  ADD_CUSTOM_COMMAND(
    TARGET data_publish POST_BUILD                            # Adds a post-build event to paho-mqtt3a
    COMMENT "Copying file '${file_i}' after build...\n"
    COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different        # which executes "cmake -E copy_if_different..."
    "${CMAKE_BINARY_DIR}/cpp_src/$<CONFIGURATION>/${file_i}"  # <--this is in-file
    "${CMAKE_BINARY_DIR}/cpp_src/samples/$<CONFIGURATION>/"   # <--this is out-file path
)
ENDFOREACH( file_i )