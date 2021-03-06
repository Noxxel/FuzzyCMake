################################################################################
### fuzzy Global Options
################################################################################
# Global options show up during configuration

option(FUZZY_BUILD_TESTING "Build Testing" ON)
option(FUZZY_BUILD_EXAMPLES "Build Examples" ON)
option(FUZZY_BUILD_PARAVIEW "Build Paraview Plugins" ON)
option(FUZZY_ENABLE_OPENMP "Enable OpenMP" ON)
option(FUZZY_ENABLE_VTK "Enable VTK" ON)
option(FUZZY_BUILD_PARAVIEW_PLUGINS "Build ParaView Plugins" ON)



### C++ Standard Version
# Can also be used for other languages such as CUDA
set(CMAKE_CXX_STANDARD 17)
# If this is not specified CMake silently falls back to earlier C++ standards
# if the specified on is not present.
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_EXTENSIONS OFF)

#Build doxygen generator file
option(FUZZY_BUILD_DOCS "Build documentation" OFF)

################################################################################
### fuzzy Directory Variables
################################################################################
set(FUZZY_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
set(FUZZY_INCLUDE_DIR "${FUZZY_ROOT}/include/fuzzy")
set(FUZZY_SOURCE_DIR "${FUZZY_ROOT}/src")
set(FUZZY_THIRD_PARTY "${FUZZY_ROOT}/third_party")
set(FUZZY_VTK_SOURCE_DIR "${FUZZY_ROOT}/src/vtk")
set(FUZZY_VTK_INCLUDE_DIR "${FUZZY_ROOT}/include/fuzzy/vtk")

################################################################################
### Packages
################################################################################
# This is how you find system installed packages, such as Boost

### Boost
find_package(Boost REQUIRED)

### OpenMP
if (FUZZY_ENABLE_OPENMP)
  find_package(OpenMP REQUIRED)
endif ()

################################################################################
### Subdirectories
################################################################################

### Tests
if (FUZZY_BUILD_TESTING)
  enable_testing()
  add_subdirectory("${FUZZY_ROOT}/tests")
endif ()

### Examples
if (FUZZY_BUILD_EXAMPLES)
  add_subdirectory("${FUZZY_ROOT}/examples")
endif ()

### Paraview Plugins
if (FUZZY_BUILD_PARAVIEW)
  add_subdirectory("${FUZZY_ROOT}/paraview")
endif ()

### Third Party
add_subdirectory(${FUZZY_THIRD_PARTY})

### libFUZZY Source Files
## Add new source files here
set(FILES_FUZZY_CORE
    foo.cpp
    )

set(SOURCES_FUZZY_CORE)
foreach (FILENAME ${FILES_FUZZY_CORE})
  set(SOURCES_FUZZY_CORE ${SOURCES_FUZZY_CORE} "${FUZZY_SOURCE_DIR}/${FILENAME}")
endforeach ()

################################################################################
### Libraries
################################################################################
# The "common" target is used as a selection of libraries you want to link against
# Later you can simply link against "common" instead of linking against all libs separately


add_library(fuzzy_common INTERFACE)
target_include_directories(fuzzy_common INTERFACE "${FUZZY_ROOT}/include/")
target_link_libraries(fuzzy_common INTERFACE Eigen3 Boost::boost)

if (FUZZY_ENABLE_VTK)
  target_compile_definitions(fuzzy_common INTERFACE -DFUZZY_ENABLE_VTK)
endif ()

if (FUZZY_ENABLE_OPENMP)
  target_link_libraries(fuzzy_common INTERFACE OpenMP::OpenMP_CXX)
  target_compile_definitions(fuzzy_common INTERFACE -DFUZZY_ENABLE_OPENMP)
endif ()

# If you want another name to refer to this lib, use CMake's "alias"
add_library(fuzzy::common ALIAS fuzzy_common)

################################################################################
### fuzzy Core
################################################################################

add_library(fuzzy_core SHARED ${SOURCES_FUZZY_CORE})
target_include_directories(fuzzy_core PRIVATE ${FUZZY_INCLUDE_DIR})
target_link_libraries(fuzzy_core INTERFACE fuzzy_common)

add_library(fuzzy::core ALIAS fuzzy_core)

################################################################################
### VTK
################################################################################

if (FUZZY_ENABLE_VTK)
  add_subdirectory("${FUZZY_ROOT}/src/vtk")
endif ()

################################################################################
### Doxygen
################################################################################
# Some selected doxygen options

if (FUZZY_BUILD_DOCS)
  find_package(Doxygen REQUIRED)

  set(DOXYGEN_GENERATE_HTML YES)
  set(DOXYGEN_GENERATE_MAN NO)
  set(DOXYGEN_GENERATE_LATEX NO)
  set(DOXYGEN_RECURSIVE YES)
  set(DOXYGEN_EXTRACT_ALL YES)
  set(DOXYGEN_EXTRACT_PRIVATE YES)
  set(DOXYGEN_EXTRACT_STATIC YES)
  set(DOXYGEN_REFERENCED_BY_RELATION YES)
  set(DOXYGEN_REFERENCES_RELATION YES)
  set(DOXYGEN_INLINE_SOURCES YES)
  set(DOXYGEN_EXTRACT_ANON_NSPACES YES)
  set(DOXYGEN_SHOW_GROUPED_MEMB_INC YES)
  set(DOXYGEN_BUILTIN_STL_SUPPORT YES)
  set(DOXYGEN_BRIEF_MEMBER_DESC YES)
  set(DOXYGEN_REPEAT_BRIEF YES)
  set(DOXYGEN_DISTRIBUTE_GROUP_DOC YES)

  set(DOXYGEN_ENABLE_PREPROCESSING YES)
  set(DOXYGEN_MACRO_EXPANSION YES)
  set(DOXYGEN_SEARCH_INCLUDES YES)

  doxygen_add_docs(fuzzy-docs
      ${FUZZY_INCLUDE_DIR}
      WORKING_DIRECTORY ${FUZZY_INCLUDE_DIR})
endif ()

################################################################################
### Summary
################################################################################
# A summary function so the user (aka you when writing this) knows which parameters are set

function(fuzzy_print_summary)
  message(STATUS "FUZZY build ------------------------------------------------------------------")
  message(STATUS "FUZZY_WITH_MARCH_NATIVE: ${FUZZY_WITH_MARCH_NATIVE}")
  message(STATUS "FUZZY_BUILD_TESTING: ${FUZZY_BUILD_TESTING}")
  message(STATUS "FUZZY_BUILD_EXAMPLES: ${FUZZY_BUILD_EXAMPLES}")
  message(STATUS "FUZZY_BUILD_PARAVIEW: ${FUZZY_BUILD_PARAVIEW}")
  message(STATUS "FUZZY_ENABLE_OPENMP: ${FUZZY_ENABLE_OPENMP}")
  message(STATUS "BOOST_INCLUDE_DIR: ${Boost_INCLUDE_DIR}")
  message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
  message(STATUS "FUZZY_BUILD_DOCS: ${FUZZY_BUILD_DOCS}")
  if (FUZZY_BUILD_DOCS)
    message(STATUS "  DOXYGEN_EXECUTABLE: ${DOXYGEN_EXECUTABLE}")
  endif ()

  message(STATUS "FUZZY_BUILD_PARAVIEW_PLUGINS: ${FUZZY_BUILD_PARAVIEW_PLUGINS}")
  if (FUZZY_BUILD_PARAVIEW_PLUGINS)
    message(STATUS "  ParaView_DIR: ${ParaView_DIR}")
  endif ()
  message(STATUS "FUZZY_ENABLE_VTK: ${FUZZY_ENABLE_VTK}")
  if (FUZZY_ENABLE_VTK)
      message(STATUS "  ParaView_DIR: ${ParaView_DIR}")
  endif ()

  message(STATUS "FUZZY install ----------------------------------------------------------------")
  message(STATUS "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
  message(STATUS "-----------------------------------------------------------------------------")
endfunction()
