cmake_minimum_required (VERSION 2.6)
project (JMeshLib)
include_directories(include)

set(jmesh_h 
include/binTree.h
include/clusterGraph.h
include/dijkstraGraph.h
include/edge.h
include/graph.h
include/heap.h
include/jmesh.h
include/jqsort.h
include/j_mesh.h
include/list.h
include/matrix.h
include/point.h
include/tin.h
include/triangle.h
include/vertex.h
)
set(jmesh_src
src/PRIMITIVES/binTree.cpp
src/PRIMITIVES/clusterGraph.cpp
src/PRIMITIVES/dijkstraGraph.cpp
src/PRIMITIVES/graph.cpp
src/PRIMITIVES/heap.cpp
src/PRIMITIVES/jqsort.cpp
src/PRIMITIVES/list.cpp
src/PRIMITIVES/matrix.cpp
src/MESH_STRUCTURE/checkAndRepair.cpp
src/MESH_STRUCTURE/edge.cpp
src/MESH_STRUCTURE/point.cpp
src/MESH_STRUCTURE/tin.cpp
src/MESH_STRUCTURE/triangle.cpp
src/MESH_STRUCTURE/vertex.cpp
src/MESH_STRUCTURE/io.cpp
src/JMESH/jmesh.cpp
)
add_library(jmesh STATIC ${jmesh_src} ${jmesh_h})
add_executable(test_jmeshlib ${jmesh_src} ${jmesh_h} test/test.cpp)

## Compiler flags
if(CMAKE_COMPILER_IS_GNUCXX)
    ## Use '-pg' to prfile/debug; '-O1' for development; '-O2' for release version
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
    ## On some versions of gcc the optimizer uses strict aliasing rules.
    ## If this is not your case try to comment out the following line.
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing")
    if(CMAKE_CXX_SIZEOF_DATA_PTR EQUAL 8)
        ADD_DEFINITIONS(-DIS64BITPLATFORM)  ## needed for 64 bit
    endif()
endif()

