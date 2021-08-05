# Modified from original source code CMakeLists.txt
# Based on version number 1.3.8
# Master branch : https://github.com/eclipse/paho.mqtt.c.git
#**************************************************************************************************

## compilation/linkage settings

CONFIGURE_FILE(VersionInfo.h.in
    ${CMAKE_BINARY_DIR}/VersionInfo.h
    @ONLY
    )

#Note: Only source files are copied from the original source code.
# samples are ignored for now.
	
SET(common_src
  MQTTTime.c
  MQTTProtocolClient.c
  Clients.c
  utf-8.c
  MQTTPacket.c
  MQTTPacketOut.c
  Messages.c
  Tree.c
  Socket.c
  Log.c
  MQTTPersistence.c
  Thread.c
  MQTTProtocolOut.c
  MQTTPersistenceDefault.c
  SocketBuffer.c
  LinkedList.c
  MQTTProperties.c
  MQTTReasonCodes.c
  Base64.c
  SHA1.c
  WebSocket.c
)

#PAHO_HIGH_PERFORMANCE is set by default. Hence commenting the below
#IF (NOT PAHO_HIGH_PERFORMANCE)
#  SET(common_src ${common_src}
#    StackTrace.c
#    Heap.c
#    )
#ENDIF()

IF (WIN32)
  SET(LIBS_SYSTEM ws2_32 crypt32 RpcRT4)
  SET(PAHOMQTT_C_LIB_DIR "win64_libs")
  # MQTT CPP requires only .lib file to built. 
  SET(PAHOMQTT_C_3CLIB  "paho-mqtt3c.lib" CACHE INTERNAL "")
  SET(PAHOMQTT_C_3ALIB  "paho-mqtt3a.lib" CACHE INTERNAL "")
  # this is required for copying the files
  SET(PAHOMQTT_C_3CLIBS "${PAHOMQTT_C_3CLIB}" "paho-mqtt3c.dll" CACHE INTERNAL "")
  SET(PAHOMQTT_C_3ALIBS "${PAHOMQTT_C_3ALIB}" "paho-mqtt3a.dll" CACHE INTERNAL "")
  
ELSEIF (UNIX)
  SET(PAHOMQTT_C_LIB_DIR "posix64_lib")
  # MQTT CPP requires only .lib file to built.
  SET(PAHOMQTT_C_3CLIB  "libpaho-mqtt3c.so" CACHE INTERNAL "")
  SET(PAHOMQTT_C_3ALIB  "libpaho-mqtt3a.so" CACHE INTERNAL "")
  # this is required for copying the files (duplicate + to use similar format like WIN32)
  SET(PAHOMQTT_C_3CLIBS "libpaho-mqtt3c.so" CACHE INTERNAL "")
  SET(PAHOMQTT_C_3ALIBS "libpaho-mqtt3a.so" CACHE INTERNAL "")

  IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
    SET(LIBS_SYSTEM c dl pthread rt)
    # anl is only available with glibc so check if it is found before using
    # it or build will fail on uclibc or musl
    FIND_LIBRARY(LIB_ANL anl)
    IF(LIB_ANL)
      SET(LIBS_SYSTEM "${LIBS_SYSTEM} ${LIB_ANL}")
    ENDIF()
    
    ADD_DEFINITIONS(-D_GNU_SOURCE -fvisibility=hidden)
  ELSEIF (CMAKE_SYSTEM_NAME MATCHES "Android")
    SET(LIBS_SYSTEM c dl)
  ELSEIF (CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
    SET(LIBS_SYSTEM compat pthread)
  ELSE()
    SET(LIBS_SYSTEM c pthread)
  ENDIF()	
ENDIF()


# common compilation for libpaho-mqtt3c and libpaho-mqtt3a
ADD_LIBRARY(common_obj OBJECT ${common_src})
SET_TARGET_PROPERTIES(common_obj PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    COMPILE_DEFINITIONS "PAHO_MQTT_EXPORTS=1")

# not required
#ADD_EXECUTABLE(MQTTVersion MQTTVersion.c)
#SET_TARGET_PROPERTIES(MQTTVersion PROPERTIES
#    POSITION_INDEPENDENT_CODE ON
#    COMPILE_DEFINITIONS "PAHO_MQTT_IMPORTS=1")
	
ADD_LIBRARY(paho-mqtt3c SHARED $<TARGET_OBJECTS:common_obj> MQTTClient.c ${PROJECT_SOURCE_LIST})
ADD_LIBRARY(paho-mqtt3a SHARED $<TARGET_OBJECTS:common_obj> MQTTAsync.c MQTTAsyncUtils.c ${PROJECT_SOURCE_LIST})
    
TARGET_LINK_LIBRARIES(paho-mqtt3c ${LIBS_SYSTEM})
TARGET_LINK_LIBRARIES(paho-mqtt3a ${LIBS_SYSTEM})

# not required
#TARGET_LINK_LIBRARIES(MQTTVersion paho-mqtt3a paho-mqtt3c ${LIBS_SYSTEM})
    
SET_TARGET_PROPERTIES(
  paho-mqtt3c paho-mqtt3a PROPERTIES
  VERSION ${CLIENT_VERSION}
  SOVERSION ${PAHO_VERSION_MAJOR}
  COMPILE_DEFINITIONS "PAHO_MQTT_EXPORTS=1")

IF(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  SET(MQTTCLIENT_ENTRY_POINT _MQTTClient_init)
  SET(MQTTASYNC_ENTRY_POINT _MQTTAsync_init)
ELSEIF (NOT WIN32)
  SET(MQTTCLIENT_ENTRY_POINT MQTTClient_init)
  SET(MQTTASYNC_ENTRY_POINT MQTTAsync_init)
ENDIF()

IF (NOT WIN32)
  SET_TARGET_PROPERTIES(
    paho-mqtt3c PROPERTIES
    LINK_FLAGS "-Wl,-init,${MQTTCLIENT_ENTRY_POINT}")
  SET_TARGET_PROPERTIES(
    paho-mqtt3a PROPERTIES
    LINK_FLAGS "-Wl,-init,${MQTTASYNC_ENTRY_POINT}")
ENDIF()

FOREACH(TARGET paho-mqtt3c paho-mqtt3a)
  TARGET_INCLUDE_DIRECTORIES(${TARGET}
    PUBLIC
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    PRIVATE
    ${CMAKE_BINARY_DIR})
ENDFOREACH()
    
INSTALL(TARGETS paho-mqtt3c paho-mqtt3a
  EXPORT eclipse-paho-mqtt-cTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

# this is not required
#INSTALL(TARGETS MQTTVersion
#    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

INSTALL(FILES MQTTAsync.h MQTTClient.h MQTTClientPersistence.h MQTTProperties.h MQTTReasonCodes.h MQTTSubscribeOpts.h MQTTExportDeclarations.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

SET(PAHOMQTT_C_INC_FILES MQTTAsync.h MQTTClient.h MQTTClientPersistence.h MQTTProperties.h MQTTReasonCodes.h MQTTSubscribeOpts.h MQTTExportDeclarations.h)

# Include OpenSSL build commands here in future.

# Commented due to build error on Windows
# CMake Error: INSTALL(EXPORT) given unknown export "eclipse-paho-mqtt-cTargets"	
INSTALL(EXPORT eclipse-paho-mqtt-cTargets
  FILE eclipse-paho-mqtt-cConfig.cmake
  NAMESPACE eclipse-paho-mqtt-c::
  DESTINATION lib/cmake/eclipse-paho-mqtt-c)

INCLUDE(CMakePackageConfigHelpers)
WRITE_BASIC_PACKAGE_VERSION_FILE("eclipse-paho-mqtt-cConfigVersion.cmake"
  VERSION ${CLIENT_VERSION}
  COMPATIBILITY SameMajorVersion)
#add_custom_target(mytargetname ALL COMMAND ${CMAKE_COMMAND} -E make_directory ${directory})
INSTALL(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/eclipse-paho-mqtt-cConfigVersion.cmake"
  DESTINATION lib/cmake/eclipse-paho-mqtt-c)

#######################################################################################
# create directories to copy required include files and libraries during prebuild
#######################################################################################
SET(PAHOMQTT_C_DIR         ${CMAKE_SOURCE_DIR}/pahomqtt.c.dir CACHE INTERNAL "")
SET(PAHOMQTT_C_LIBS_DIR    ${PAHOMQTT_C_DIR}/${PAHOMQTT_C_LIB_DIR} CACHE INTERNAL "")
SET(PAHOMQTT_C_INCLUDE_DIR ${PAHOMQTT_C_DIR}/include CACHE INTERNAL "")

SET(OP_DIR_LIST "${PAHOMQTT_C_DIR}" "${PAHOMQTT_C_LIBS_DIR}" "${PAHOMQTT_C_INCLUDE_DIR}")

#######################################################################################
# Add pre build commands
#######################################################################################
FOREACH( dir_i ${OP_DIR_LIST})
  ADD_CUSTOM_COMMAND(
    TARGET paho-mqtt3a PRE_BUILD                              # Adds a pre-build event to paho-mqtt3a
    COMMENT "Creating directory '${dir_i}' before build...\n"
    COMMAND ${CMAKE_COMMAND} ARGS -E make_directory ${dir_i}) # which executes "cmake -E make_directory..."
ENDFOREACH( dir_i)

FOREACH( file_i ${PAHOMQTT_C_INC_FILES})
  ADD_CUSTOM_COMMAND(
    TARGET paho-mqtt3c PRE_BUILD                              # Adds a pre-build event to paho-mqtt3c
    COMMENT "Copying file '${file_i}' before build...\n"
    COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different        # which executes "cmake -E copy_if_different..."
    "${CMAKE_CURRENT_SOURCE_DIR}/${file_i}"                   # <--this is in-file
    "${PAHOMQTT_C_INCLUDE_DIR}"                               # <--this is out-file path
)
ENDFOREACH( file_i )

#######################################################################################
# Add post build commands
#######################################################################################

FOREACH( file_i ${PAHOMQTT_C_3ALIBS})
  ADD_CUSTOM_COMMAND(
    TARGET paho-mqtt3a POST_BUILD                             # Adds a post-build event to paho-mqtt3a
    COMMENT "Copying file '${file_i}' after build...\n"
    COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different        # which executes "cmake -E copy_if_different..."
    "${CMAKE_BINARY_DIR}/src/$<CONFIGURATION>/${file_i}"      # <--this is in-file
    "${PAHOMQTT_C_LIBS_DIR}"                                  # <--this is out-file path
)
ENDFOREACH( file_i )

FOREACH( file_i ${PAHOMQTT_C_3CLIBS})
  ADD_CUSTOM_COMMAND(
    TARGET paho-mqtt3c POST_BUILD                             # Adds a post-build event to paho-mqtt3c
    COMMENT "Copying file '${file_i}' after build...\n"
    COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different        # which executes "cmake -E copy_if_different..."
    "${CMAKE_BINARY_DIR}/src/$<CONFIGURATION>/${file_i}"      # <--this is in-file
    "${PAHOMQTT_C_LIBS_DIR}"                                  # <--this is out-file path
)
ENDFOREACH( file_i )

#**************************************************************************************************
# For now building without OpenSSL
# Note: On Linux system, it detects the SSL libraries/packages automatically
# Hence paho-mqtt3cs and paho-mqtt3as libraries will NOT be generated.	
# Base64 test and SHA1 test are NOT required for now.
