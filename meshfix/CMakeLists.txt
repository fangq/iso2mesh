cmake_minimum_required (VERSION 2.6)
project (MeshFix)
add_subdirectory(contrib/JMeshLib)
include_directories(
    include
    /usr/include/superlu
    /usr/include/SuperLU
    contrib/JMeshLib/include
    contrib/OpenNL3.2.1/src
    contrib/jrs_predicates
)
file(GLOB meshfix_h include/*.h)
set(meshfix_src
    contrib/jrs_predicates/jrs_predicates.c
    src/detectIntersections.cpp
    src/holeFilling.cpp
    src/sparseLSystem.cpp
    src/mwExtensions.cpp
    src/smoothing.cpp
    contrib/OpenNL3.2.1/src/nl_single_file.c
    src/epsilonSampling.cpp
    src/simplification.cpp
    src/uniform.cpp
    src/cleaning.cpp
)
add_custom_command(
    TARGET meshfix
    PRE_LINK
    COMMAND make
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/contrib/JMeshLib/
)
if(CMAKE_CXX_SIZEOF_DATA_PTR EQUAL 8)
    ADD_DEFINITIONS(-DIS64BITPLATFORM)  ## needed for 64 bit 
endif()
ADD_DEFINITIONS(-DNL_USE_SUPERLU)
add_executable(meshfix ${meshfix_src} ${meshfix_h} meshfix.cpp)
target_link_libraries(meshfix jmesh superlu blas)
