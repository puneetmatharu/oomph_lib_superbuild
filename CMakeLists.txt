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
  oomph_lib_third_party_libraries
  DESCRIPTION "Helps build third-party libraries that can be used by oomph-lib."
  VERSION 0.0.1
  HOMEPAGE_URL "https://oomph-lib.github.io/oomph-lib/doc/html/"
  LANGUAGES C CXX Fortran)

# ---------------------------[ INITIAL PROJECT SETUP ]--------------------------

# Handle warning about timestamps when downloading archives via ExternalProject
cmake_policy(SET CMP0135 NEW)

# Specify the location of non-standard CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/")

# Specify the C++ standard. NOTE: This version MUST align with the version used
# in the build of the main oomph-lib library
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# Build in Release (fully optimised) mode by default
if(NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL "")
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
endif()

# Select level of verbosity (e.g. STATUS, VERBOSE, etc.)
set(CMAKE_MESSAGE_LOG_LEVEL VERBOSE)

# ------------------------------[ BUILD OPTIONS ]-------------------------------
# cmake-format: off
include(OomphPathOption)

# Boolean options
option(OOMPH_ENABLE_MPI "Build third-party libraries with MPI support?" OFF)
option(OOMPH_BUILD_OPENBLAS "Build OpenBLAS?" ON)
option(OOMPH_BUILD_CGAL "Build CGAL?" ON)
option(OOMPH_BUILD_MUMPS "Build MUMPS?" ON)
option(OOMPH_BUILD_HYPRE "Build Hypre?" ON)
option(OOMPH_BUILD_TRILINOS "Build Trilinos?" ON)

# Path-like flags
oomph_path_option(
  FLAG OOMPH_THIRD_PARTY_INSTALL_DIR
  DEFAULT "${CMAKE_CURRENT_LIST_DIR}/install"
  DOCSTRING "Base installation directory for third-party libraries."
)

# cmake-format: on
# ----------------------[ FIND REQUIRED/DESIRED PACKAGES ]----------------------

# Use CMake built-in modules to search for certain packages
find_package(Git)
find_package(Python3 REQUIRED)

# Helpful CMake modules
include(ExternalProject)
include(ProcessorCount)

# The 'make' executable
find_program(MAKE_EXECUTABLE NAMES make REQUIRED)

# Get our helper function for getting external libraries
include(OomphGetExternalProjectHelper)

# --------------------------------[ GENERAL ]----------------------------------

# Decide on number of jobs to use for building projects
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

# Where to download files from and where to install to
set(OOMPH_THIRD_PARTY_TAR_FILE_URL
    "https://www.matthias-heil.co.uk/oomph-lib_third_party_tar_files")

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

# --------------------------------[ OPENBLAS ]---------------------------------

# FIXME: OpenBLAS doesn't build on macOS Sonoma beta 14.2. Expecting OpenBLAS
# 0.3.24 to be installed via Homebrew for now...
if(OOMPH_USE_OPENBLAS_FROM)
  find_package(OpenBLAS 0.3.24 REQUIRED PATHS ${OOMPH_USE_OPENBLAS_FROM})
elseif(APPLE)
  find_package(OpenBLAS REQUIRED PATHS /opt/homebrew/Cellar/openblas/0.3.24/)
elseif(OOMPH_BUILD_OPENBLAS)
  include(OomphGetExternalOpenBLAS)
endif()

# ----------------------------------[ CGAL ]-----------------------------------

# FIXME: Currently only works on macOS if "CC=gcc CXX=g++" is passed to CMake
if(OOMPH_USE_CGAL_FROM)
  if((NOT OOMPH_USE_GMP_FROM)
     OR (NOT OOMPH_USE_MPFR_FROM)
     OR (NOT OOMPH_USE_BOOST_FROM))
    message(
      FATAL_ERROR
        "If you define OOMPH_USE_CGAL_FROM, you must also define OOMPH_USE_GMP_FROM, OOMPH_USE_MPFR_FROM and OOMPH_USE_BOOST_FROM!"
    )
  endif()

  # NOTE: FindGMP and FindMPFR will read the values of OOMPH_USE_GMP_FROM and
  # OOMPH_USE_MPFR_FROM
  find_package(GMP REQUIRED)
  find_package(MPFR REQUIRED)
  find_package(
    Boost 1.83.0 REQUIRED
    PATHS ${OOMPH_USE_BOOST_FROM}
    NO_DEFAULT_PATH)
  find_package(
    CGAL 5.6 REQUIRED
    PATHS ${OOMPH_USE_CGAL_FROM}
    NO_DEFAULT_PATH)
elseif(OOMPH_BUILD_CGAL)
  include(OomphGetExternalCGAL)
endif()

# ----------------------------------[ MUMPS ]----------------------------------

if(OOMPH_USE_MUMPS_FROM)
  find_package(
    MUMPS 5.6.2.2 REQUIRED
    PATHS ${OOMPH_USE_MUMPS_FROM}
    NO_DEFAULT_PATH)
elseif(OOMPH_BUILD_MUMPS)
  include(OomphGetExternalMUMPS)
endif()

# ----------------------------------[ HYPRE ]----------------------------------

if(OOMPH_USE_HYPRE_FROM)
  find_package(
    HYPRE 2.29.0 REQUIRED
    PATHS ${OOMPH_USE_HYPRE_FROM}
    NO_DEFAULT_PATH)
elseif(OOMPH_BUILD_HYPRE)
  if(NOT OpenBLAS_LIBRARIES)
    message(FATAL_ERROR "Refusing to build HYPRE without OpenBLAS!")
  endif()
  include(OomphGetExternalHYPRE)
endif()

# ---------------------------------[ TRILINOS ]--------------------------------

if(OOMPH_USE_TRILINOS_FROM)
  find_package(
    Trilinos 14.4.0 REQUIRED
    PATHS ${OOMPH_USE_TRILINOS_FROM}
    NO_DEFAULT_PATH)
elseif(OOMPH_BUILD_TRILINOS)
  if(NOT OpenBLAS_LIBRARIES)
    message(FATAL_ERROR "Refusing to build Trilinos without OpenBLAS!")
  endif()
  include(OomphGetExternalTrilinos)
endif()

# -----------------------------------------------------------------------------
