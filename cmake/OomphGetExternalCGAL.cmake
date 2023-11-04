# cmake-format: off
# =============================================================================
# DESCRIPTION:
# ------------
#
#
# USAGE:
# ------
#
# ...to be filled in...
#
# EXAMPLE:
# --------
#
# ...to be filled in...
#
# =============================================================================

include_guard()

# The tarballs for each library
set(GMP_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/gmp-6.3.0.tar.xz)
set(MPFR_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/mpfr-4.2.1.tar.xz)
set(BOOST_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/boost_1_83_0.tar.gz)
set(CGAL_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/CGAL-5.6.tar.xz)

# Set the default installation paths
set(GMP_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/gmp")
set(MPFR_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/mpfr")
set(BOOST_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/boost")
set(CGAL_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/cgal")

# If we've already been given GMP, MPFR and/or Boost, we'll use the files from
# there
if(OOMPH_USE_GMP_FROM)
  set(GMP_INSTALL_DIR "${OOMPH_USE_GMP_FROM}")
endif()
if(OOMPH_USE_MPFR_FROM)
  set(MPFR_INSTALL_DIR "${OOMPH_USE_MPFR_FROM}")
endif()
if(OOMPH_USE_BOOST_FROM)
  set(BOOST_INSTALL_DIR "${OOMPH_USE_BOOST_FROM}")
endif()

# ----------------------------------------
# GMP
# ----------------------------------------
# If we've already been given GMP
if(OOMPH_USE_GMP_FROM)
  set(GMP_INSTALL_DIR "${OOMPH_USE_GMP_FROM}")
else()
  set(GMP_C_LIBNAME ${CMAKE_STATIC_LIBRARY_PREFIX}gmp${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(GMP_C_LIBRARIES ${GMP_INSTALL_DIR}/lib/${GMP_C_LIBNAME} CACHE PATH "Path to GMP C libraries")
  set(GMP_C_INCLUDE_DIR ${GMP_INSTALL_DIR}/include CACHE PATH "Path to GMP C include directory")

  oomph_get_external_project_helper(
    PROJECT_NAME gmp
    URL "${GMP_TARBALL_URL}"
    INSTALL_DIR "${GMP_INSTALL_DIR}"
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER}
    BUILD_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE} install
    TEST_COMMAND ${MAKE_EXECUTABLE} check
    INSTALL_BYPRODUCTS ${GMP_C_LIBRARIES} ${GMP_C_INCLUDE_DIR}/gmp.h)
endif()

# ----------------------------------------
# MPFR
# ----------------------------------------
if(OOMPH_USE_MPFR_FROM)
  set(MPFR_INSTALL_DIR "${OOMPH_USE_MPFR_FROM}")
else()
  set(MPFR_LIBNAME ${CMAKE_STATIC_LIBRARY_PREFIX}mpfr${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(MPFR_LIBRARIES ${MPFR_INSTALL_DIR}/lib/${MPFR_LIBNAME} CACHE PATH "Path to GMP libraries")
  set(MPFR_INCLUDE_DIR ${MPFR_INSTALL_DIR}/include CACHE PATH "Path to GMP include directory")

  # Define how to configure/build/install the project
  oomph_get_external_project_helper(
    PROJECT_NAME mpfr
    URL "${MPFR_TARBALL_URL}"
    INSTALL_DIR "${MPFR_INSTALL_DIR}"
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-gmp=${GMP_INSTALL_DIR} CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER}
    BUILD_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE} install
    TEST_COMMAND ${MAKE_EXECUTABLE} check
    INSTALL_BYPRODUCTS ${MPFR_LIBRARIES} "${MPFR_INCLUDE_DIR}/mpfr.h")
endif()

# ----------------------------------------
# BOOST
# ----------------------------------------
if(OOMPH_USE_BOOST_FROM)
  set(BOOST_INSTALL_DIR "${OOMPH_USE_BOOST_FROM}")
else()
  oomph_get_external_project_helper(
    PROJECT_NAME boost
    URL "${BOOST_TARBALL_URL}"
    INSTALL_DIR "${BOOST_INSTALL_DIR}"
    CONFIGURE_COMMAND ./bootstrap.sh --prefix=<INSTALL_DIR> --with-libraries=thread,system,program_options CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER}
    BUILD_COMMAND ./b2 install --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
    INSTALL_COMMAND "")
endif()

# ----------------------------------------
# CGAL
# ----------------------------------------
oomph_get_external_project_helper(
  PROJECT_NAME cgal
  URL "${CGAL_TARBALL_URL}"
  INSTALL_DIR ${CGAL_INSTALL_DIR}
  PATCH_COMMAND ${CMAKE_CURRENT_LIST_DIR}/patches/patch_cgal.sh <SOURCE_DIR>
  CONFIGURE_COMMAND
    ${CMAKE_COMMAND}
    --install-prefix=<INSTALL_DIR>
    -DCMAKE_BUILD_TYPE=Release
    -DGMP_INCLUDE_DIR=${GMP_C_INCLUDE_DIR}
    -DGMP_LIBRARIES=${GMP_C_LIBRARIES}
    -DMPFR_INCLUDE_DIR=${MPFR_INCLUDE_DIR}
    -DMPFR_LIBRARIES=${MPFR_LIBRARIES}
    -DBOOST_ROOT=${BOOST_INSTALL_DIR}
    -B=build
  BUILD_COMMAND ${CMAKE_COMMAND} --build build --parallel ${NUM_THREADS_FOR_PARALLEL_MAKE}
  INSTALL_COMMAND ${CMAKE_COMMAND} --install build
  TEST_COMMAND ${CMAKE_CURRENT_LIST_DIR}/scripts/run_cgal_self_test.sh <SOURCE_DIR> <LOG_DIR>)

# -----------------------------------------------------------------------------

# MPFR relies on GMP, and CGAL relies on GMP, MPFR and Boost
add_dependencies(mpfr gmp)
add_dependencies(cgal gmp mpfr boost)

# -----------------------------------------------------------------------------
# cmake-format: on
