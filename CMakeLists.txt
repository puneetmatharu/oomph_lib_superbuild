# cmake-format: off
# ==============================================================================
#                                          888             888 d8b 888
#                                          888             888 Y8P 888
#                                          888             888     888
#  .d88b.   .d88b.  88888b.d88b.  88888b.  88888b.         888 888 88888b.
# d88""88b d88""88b 888 "888 "88b 888 "88b 888 "88b        888 888 888 "88b
# 888  888 888  888 888  888  888 888  888 888  888 888888 888 888 888  888
# Y88..88P Y88..88P 888  888  888 888 d88P 888  888        888 888 888 d88P
#  "Y88P"   "Y88P"  888  888  888 88888P"  888  888        888 888 88888P"
#                                 888
#                                 888
#                                 888
# ------------------------------------------------------------------------------
# oomph-lib is an object-oriented, open-source finite-element library for the
# simulation of multi-physics problems. It is developed and maintained by
# Matthias Heil and Andrew Hazel of the School of Mathematics at The University
# of Manchester, along with many other contributors.
#
# This library is distributed with a GNU LGPL License; see LICENSE.txt.
# ==============================================================================
# cmake-format: on
cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(
  third_party_libraries_for_oomph-lib
  DESCRIPTION "Helps build third-party libraries that can be used by oomph-lib."
  VERSION 0.0.1
  HOMEPAGE_URL "https://oomph-lib.github.io/oomph-lib/doc/html/"
  LANGUAGES C CXX Fortran)

# ---------------------------[ INITIAL PROJECT SETUP ]--------------------------

# Specify the location of non-standard CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/")

# Specify the C++ standard. NOTE: This version MUST align with the version used
# in the build of the main oomph-lib library
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# Build in Release (fully optimised) mode by default
if(NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL "")
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
endif()

# Select level of verbosity (e.g. STATUS, VERBOSE, etc.)
set(CMAKE_MESSAGE_LOG_LEVEL VERBOSE)

# ----------------------[ FIND REQUIRED/DESIRED PACKAGES ]----------------------

# Use CMake built-in modules to search for certain packages
find_package(Git)
find_package(Python3 REQUIRED)

# ------------------------------[ BUILD OPTIONS ]-------------------------------

# Third-party libraries
option(OOMPH_ENABLE_MPI "Build third-party libraries with MPI support?" OFF)
option(OOMPH_BUILD_CGAL "Build the CGAL library?" ON)
option(OOMPH_BUILD_HYPRE "Build Hypre?" OFF)
option(OOMPH_BUILD_MUMPS "Build MUMPS?" OFF)
option(OOMPH_BUILD_TRILINOS "Build Trilinos?" OFF)

# cmake-format: off
# Specify tar file url: This is where we host the tar files
set(OOMPH_THIRD_PARTY_TAR_FILE_URL "https://www.matthias-heil.co.uk/oomph-lib_third_party_tar_files")

# Local directory in which we store the downloaded tar files
set(OOMPH_THIRD_PARTY_TAR_DIR tar_files)

# Local directory in which we store the sources and build the libraries
set(OOMPH_THIRD_PARTY_SRC_DIR src)

# Local directory in which we (permanently!) install the libraries
set(OOMPH_THIRD_PARTY_INSTALL_DIR ${CMAKE_CURRENT_LIST_DIR}/install)
# cmake-format: on

# --------------------------------[ GENERAL ]----------------------------------

# The 'make' executable
find_program(MAKE_EXECUTABLE NAMES make REQUIRED)

# Helpful CMake modules
include(ExternalProject)
include(ProcessorCount)

# To handle timestamps when downloading archives via ExternalProject
cmake_policy(SET CMP0135 NEW)

# Determine the number of jobs to use for building/install Autoconf-based
# projects
ProcessorCount(NUM_PROCESSOR)
set(NUM_THREADS_FOR_PARALLEL_MAKE 1)
if(NUM_PROCESSOR EQUAL 0)
  message(
    WARNING
      "Encountered error trying to determine the number of available CPU cores. Will build Makefile-based projects with just 1 job."
  )
else()
  set(NUM_THREADS_FOR_PARALLEL_MAKE ${NUM_PROCESSOR})
  message(
    STATUS "Number of jobs for parallel make: ${NUM_THREADS_FOR_PARALLEL_MAKE}")
endif()

# ----------------------------------[ MPI ]------------------------------------

# Set up MPI functionality (see cmake/OomphMPI.cmake)
if(OOMPH_ENABLE_MPI)
  include(OomphMPI)

  # Sanity check
  if(NOT OOMPH_MPI_NUM_PROC MATCHES "^[0-9]+$")
    message(
      FATAL_ERROR
        "The flag 'OOMPH_MPI_NUM_PROC' must be an integer, not ${OOMPH_MPI_NUM_PROC}!"
    )
  endif()
endif()

# ----------------------------------[ CGAL ]-----------------------------------

# FIXME: Issue with standard SDK on macOS if(APPLE) export SDKROOT=$(xcrun --sdk
# macosx --show-sdk-path) export LIBRARY_PATH="$LIBRARY_PATH:$SDKROOT/usr/lib"
# endif()

# WORKS IF I USE GCC/G++

set(BUILD_GMP ON)
set(BUILD_MPFR ON)
set(BUILD_BOOST ON)
set(BUILD_CGAL ON)
set(BUILD_OPEN_BLAS OFF)

# ----------------------------------------
# GMP
# ----------------------------------------
if(BUILD_GMP)
  set(GMP_PACKAGE_NAME gmp)
  set(GMP_VERSION 6.3.0)
  set(GMP_TARBALL_URL "${OOMPH_THIRD_PARTY_TAR_FILE_URL}/gmp-6.3.0.tar.xz")
  set(GMP_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/${GMP_PACKAGE_NAME}")
  set(GMP_CONFIG_FLAGS --prefix=${GMP_INSTALL_DIR} CXX=${CMAKE_CXX_COMPILER}
      CC=${CMAKE_C_COMPILER})
  list(JOIN GMP_CONFIG_FLAGS " " GMP_CONFIG_FLAGS)

  # cmake-format: off
  set(GMP_C_LIBNAME ${CMAKE_STATIC_LIBRARY_PREFIX}gmp${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(GMP_CXX_LIBNAME ${CMAKE_STATIC_LIBRARY_PREFIX}gmpxx${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(GMP_C_LIBRARIES ${GMP_INSTALL_DIR}/lib/${GMP_C_LIBNAME} CACHE PATH "Path to GMP C libraries")
  set(GMP_CXX_LIBRARIES ${GMP_INSTALL_DIR}/lib/${GMP_CXX_LIBNAME} CACHE PATH "Path to GMP C++ libraries")
  set(GMP_C_INCLUDES ${GMP_INSTALL_DIR}/include CACHE PATH "Path to GMP C include directory")
  set(GMP_CXX_INCLUDES ${GMP_C_INCLUDES} CACHE PATH "Path to GMP C++ include directory")
  # cmake-format: on

  # Define how to configure/build/install the project
  ExternalProject_Add(
    ${GMP_PACKAGE_NAME}
    URL "${GMP_TARBALL_URL}"
    UPDATE_DISCONNECTED TRUE
    CONFIGURE_HANDLED_BY_BUILD TRUE
    DOWNLOAD_NO_PROGRESS TRUE
    CONFIGURE_COMMAND
      <SOURCE_DIR>/configure --enable-silent-rules --prefix=${GMP_INSTALL_DIR}
      CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER} || <SOURCE_DIR>/configure
      --prefix=${GMP_INSTALL_DIR} CXX=${CMAKE_CXX_COMPILER}
      CC=${CMAKE_C_COMPILER}
    BUILD_COMMAND ${MAKE_EXECUTABLE} -s -j ${NUM_THREADS_FOR_PARALLEL_MAKE} ||
                  ${MAKE_EXECUTABLE} -j ${NUM_THREADS_FOR_PARALLEL_MAKE}
    BUILD_ALWAYS FALSE
    INSTALL_COMMAND
      ${MAKE_EXECUTABLE} -s -j ${NUM_THREADS_FOR_PARALLEL_MAKE} install ||
      ${MAKE_EXECUTABLE} -j ${NUM_THREADS_FOR_PARALLEL_MAKE} install
    # TEST_COMMAND ${MAKE_EXECUTABLE} check
    BUILD_BYPRODUCTS ${GMP_C_LIBRARIES} ${GMP_CXX_LIBRARIES})
endif()

# ----------------------------------------
# MPFR
# ----------------------------------------
if(BUILD_MPFR)
  set(MPFR_PACKAGE_NAME mpfr)
  set(MPFR_VERSION 4.2.1)
  set(MPFR_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/mpfr-4.2.1.tar.xz)
  set(MPFR_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/${MPFR_PACKAGE_NAME}")

  # cmake-format: off
  set(MPFR_LIBNAME ${CMAKE_STATIC_LIBRARY_PREFIX}mpfr${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(MPFR_LIBRARIES ${MPFR_INSTALL_DIR}/lib/${MPFR_LIBNAME} CACHE PATH "Path to GMP libraries")
  set(MPFR_INCLUDES ${MPFR_INSTALL_DIR}/include CACHE PATH "Path to GMP include directory")
  # cmake-format: on

  # Define how to configure/build/install the project
  ExternalProject_Add(
    ${MPFR_PACKAGE_NAME}
    URL "${MPFR_TARBALL_URL}"
    UPDATE_DISCONNECTED TRUE
    CONFIGURE_HANDLED_BY_BUILD TRUE
    DOWNLOAD_NO_PROGRESS TRUE
    CONFIGURE_COMMAND
      <SOURCE_DIR>/configure --enable-silent-rules --prefix=${GMP_INSTALL_DIR}
      --with-gmp=${GMP_INSTALL_DIR} CXX=${CMAKE_CXX_COMPILER}
      CC=${CMAKE_C_COMPILER} || <SOURCE_DIR>/configure
      --prefix=${GMP_INSTALL_DIR} --with-gmp=${GMP_INSTALL_DIR}
      CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER}
    BUILD_COMMAND ${MAKE_EXECUTABLE} -s -j ${NUM_THREADS_FOR_PARALLEL_MAKE} ||
                  ${MAKE_EXECUTABLE} -j ${NUM_THREADS_FOR_PARALLEL_MAKE}
    BUILD_ALWAYS FALSE
    INSTALL_COMMAND
      ${MAKE_EXECUTABLE} -s -j ${NUM_THREADS_FOR_PARALLEL_MAKE} install ||
      ${MAKE_EXECUTABLE} -j ${NUM_THREADS_FOR_PARALLEL_MAKE} install
    # TEST_COMMAND ${MAKE_EXECUTABLE} check
    BUILD_BYPRODUCTS ${MPFR_LIBRARIES})

  # If we're building gmp ourselves, make sure to build it before mpfr
  if(TARGET ${GMP_PACKAGE_NAME})
    add_dependencies(${MPFR_PACKAGE_NAME} ${GMP_PACKAGE_NAME})
  endif()
endif()

# ----------------------------------------
# BOOST
# ----------------------------------------
if(BUILD_BOOST)
  set(BOOST_PACKAGE_NAME boost)
  set(BOOST_VERSION 1.83.0)
  set(BOOST_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/boost_1_83_0.tar.gz)
  set(BOOST_INSTALL_DIR
      "${OOMPH_THIRD_PARTY_INSTALL_DIR}/${BOOST_PACKAGE_NAME}")
  set(BOOST_INCLUDE_LIBRARIES "thread,system,program_options")
  set(BOOST_ENABLE_CMAKE ON)

  # Define how to configure/build/install the project
  ExternalProject_Add(
    ${BOOST_PACKAGE_NAME}
    URL "${BOOST_TARBALL_URL}"
    UPDATE_DISCONNECTED TRUE
    CONFIGURE_HANDLED_BY_BUILD TRUE
    DOWNLOAD_NO_PROGRESS false
    CONFIGURE_HANDLED_BY_BUILD TRUE
    CONFIGURE_COMMAND
      cd <SOURCE_DIR> && ./bootstrap.sh --prefix=<INSTALL_DIR>
      CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER}
      --with-libraries=${BOOST_INCLUDE_LIBRARIES}
    BUILD_COMMAND cd <SOURCE_DIR> && ./b2 install -j
                  ${NUM_THREADS_FOR_PARALLEL_MAKE}
    BUILD_ALWAYS FALSE
    INSTALL_COMMAND ""
    INSTALL_DIR ${BOOST_INSTALL_DIR}
    BUILD_BYPRODUCTS "")

  # SHOULD DEFINE THE SET COMMAND WHEN CALLING:
  #
  # find_package(Boost 1.83.0 COMPONENTS ${REQUIRED_COMPONENTS} REQUIRED)
  #
  # set(BOOST_REQUIRED_COMPONENTS Thread System Program_options)
endif()

# ----------------------------------------
# CGAL
# ----------------------------------------
if(BUILD_CGAL)
  set(CGAL_PACKAGE_NAME CGAL)
  set(CGAL_VERSION 5.6)
  set(CGAL_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/CGAL-5.6.tar.xz)
  set(CGAL_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/${CGAL_PACKAGE_NAME}")
  set(CGAL_ENABLE_CMAKE ON)

  # Define how to configure/build/install the project
  ExternalProject_Add(
    ${CGAL_PACKAGE_NAME}
    URL "${CGAL_TARBALL_URL}"
    UPDATE_DISCONNECTED true
    CONFIGURE_HANDLED_BY_BUILD true
    DOWNLOAD_NO_PROGRESS false
    CONFIGURE_COMMAND
      cd <SOURCE_DIR> && ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR}
      --install-prefix=<INSTALL_DIR> -DCMAKE_BUILD_TYPE=Release
      -DGMP_INCLUDE_DIR=${GMP_INSTALL_DIR}/include
      -DGMP_LIBRARIES=${GMP_INSTALL_DIR}/lib/libgmp.a
      -DMPFR_INCLUDE_DIR=${MPFR_INSTALL_DIR}/include
      -DMPFR_LIBRARIES=${MPFR_INSTALL_DIR}/lib/libmpfr.a
      -DBOOST_ROOT=${BOOST_INSTALL_DIR} -B <BINARY_DIR>
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    INSTALL_DIR ${CGAL_INSTALL_DIR}
    BUILD_BYPRODUCTS "")

  # Build MPFR before Boost
  if((TARGET ${GMP_PACKAGE_NAME})
     OR (TARGET ${MPFR_PACKAGE_NAME})
     OR (TARGET ${BOOST_PACKAGE_NAME}))
    add_dependencies(${CGAL_PACKAGE_NAME} ${GMP_PACKAGE_NAME}
                     ${MPFR_PACKAGE_NAME} ${BOOST_PACKAGE_NAME})
  endif()
endif()

# --------------------------------[ OPENBLAS ]---------------------------------

# ----------------------------------[ MUMPS ]----------------------------------

# ----------------------------------[ HYPRE ]----------------------------------

# ---------------------------------[ TRILINOS ]--------------------------------

# -----------------------------------------------------------------------------
