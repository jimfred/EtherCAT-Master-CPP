cmake_minimum_required(VERSION 3.10)
project(EtherCATMaster)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find TwinCAT installation path
if(NOT DEFINED TWINCAT_DIR)
    set(TWINCAT_DIR "C:/TwinCAT/3.1")
endif()

# Add TwinCAT ADS include directory
include_directories("${TWINCAT_DIR}/SDK/Include")

# Add TwinCAT ADS library directory
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    # 64-bit
    link_directories("${TWINCAT_DIR}/SDK/Lib")
else()
    # 32-bit
    link_directories("${TWINCAT_DIR}/SDK/Lib")
endif()

# Create executable
add_executable(${PROJECT_NAME} main.cpp)

# Link TwinCAT ADS library
target_link_libraries(${PROJECT_NAME} TcAdsDll)

# Set output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Copy required DLLs to output directory (if needed)
if(WIN32)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Build completed successfully!"
        COMMENT "Post-build message"
    )
endif()

