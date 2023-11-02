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
# cmake-format: on
include_guard()

set(GMP_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/gmp-6.3.0.tar.xz)
set(MPFR_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/mpfr-4.2.1.tar.xz)
set(BOOST_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/boost_1_83_0.tar.gz)
set(CGAL_TARBALL_URL ${OOMPH_THIRD_PARTY_TAR_FILE_URL}/CGAL-5.6.tar.xz)

set(GMP_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/gmp")
set(MPFR_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/mpfr")
set(BOOST_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/boost")
set(CGAL_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/cgal")

# ----------------------------------------
# GMP
# ----------------------------------------
# cmake-format: off
set(GMP_C_LIBNAME ${CMAKE_STATIC_LIBRARY_PREFIX}gmp${CMAKE_STATIC_LIBRARY_SUFFIX})
set(GMP_C_LIBRARIES ${GMP_INSTALL_DIR}/lib/${GMP_C_LIBNAME} CACHE PATH "Path to GMP C libraries")
set(GMP_C_INCLUDES ${GMP_INSTALL_DIR}/include CACHE PATH "Path to GMP C include directory")
# cmake-format: on

# Define how to configure/build/install the project
oomph_get_external_project_helper(
  PROJECT_NAME gmp
  URL "${GMP_TARBALL_URL}"
  INSTALL_DIR "${GMP_INSTALL_DIR}"
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> CXX=${CMAKE_CXX_COMPILER}
                    CC=${CMAKE_C_COMPILER}
  BUILD_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
                  install
  TEST_COMMAND ${MAKE_EXECUTABLE} check
  INSTALL_BYPRODUCTS ${GMP_C_LIBRARIES} ${GMP_C_INCLUDES}/gmp.h)

# ----------------------------------------
# MPFR
# ----------------------------------------
# cmake-format: off
set(MPFR_LIBNAME ${CMAKE_STATIC_LIBRARY_PREFIX}mpfr${CMAKE_STATIC_LIBRARY_SUFFIX})
set(MPFR_LIBRARIES ${MPFR_INSTALL_DIR}/lib/${MPFR_LIBNAME} CACHE PATH "Path to GMP libraries")
set(MPFR_INCLUDES ${MPFR_INSTALL_DIR}/include CACHE PATH "Path to GMP include directory")
# cmake-format: on

# Define how to configure/build/install the project
oomph_get_external_project_helper(
  PROJECT_NAME mpfr
  URL "${MPFR_TARBALL_URL}"
  INSTALL_DIR "${MPFR_INSTALL_DIR}"
  CONFIGURE_COMMAND
    ./configure --prefix=<INSTALL_DIR> --with-gmp=${GMP_INSTALL_DIR}
    CXX=${CMAKE_CXX_COMPILER} CC=${CMAKE_C_COMPILER}
  BUILD_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
                  install
  TEST_COMMAND ${MAKE_EXECUTABLE} check
  INSTALL_BYPRODUCTS ${MPFR_LIBRARIES} "${MPFR_INCLUDES}/mpfr.h")

# ----------------------------------------
# BOOST
# ----------------------------------------
set(BOOST_ENABLE_CMAKE ON)

# Define how to configure/build/install the project
oomph_get_external_project_helper(
  PROJECT_NAME boost
  URL "${BOOST_TARBALL_URL}"
  INSTALL_DIR "${BOOST_INSTALL_DIR}"
  CONFIGURE_COMMAND
    ./bootstrap.sh --prefix=<INSTALL_DIR>
    --with-libraries=thread,system,program_options CXX=${CMAKE_CXX_COMPILER}
    CC=${CMAKE_C_COMPILER}
  BUILD_COMMAND ./b2 install --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
  INSTALL_COMMAND "")

# ----------------------------------------
# CGAL
# ----------------------------------------
# Define how to configure/build/install the project
oomph_get_external_project_helper(
  PROJECT_NAME cgal
  URL "${CGAL_TARBALL_URL}"
  INSTALL_DIR ${CGAL_INSTALL_DIR}
  PATCH_COMMAND ${CMAKE_CURRENT_LIST_DIR}/patches/patch_cgal.sh <SOURCE_DIR>
  CONFIGURE_COMMAND
    ${CMAKE_COMMAND}
    --install-prefix=<INSTALL_DIR>
    -DCMAKE_BUILD_TYPE=Release
    -DGMP_INCLUDE_DIR=${GMP_INSTALL_DIR}/include
    -DGMP_LIBRARIES=${GMP_INSTALL_DIR}/lib/libgmp.a
    -DMPFR_INCLUDE_DIR=${MPFR_INSTALL_DIR}/include
    -DMPFR_LIBRARIES=${MPFR_INSTALL_DIR}/lib/libmpfr.a
    -DBOOST_ROOT=${BOOST_INSTALL_DIR}
    -B=<BINARY_DIR>
  BUILD_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
  INSTALL_COMMAND ${MAKE_EXECUTABLE} --jobs=${NUM_THREADS_FOR_PARALLEL_MAKE}
                  install)

# -----------------------------------------------------------------------------

# MPFR relies on GMP, and CGAL relies on GMP, MPFR and Boost
add_dependencies(mpfr gmp)
add_dependencies(cgal gmp mpfr boost)

# -----------------------------------------------------------------------------
