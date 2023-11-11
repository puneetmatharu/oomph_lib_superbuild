# cmake-format: off
# =============================================================================
# DESCRIPTION:
# ------------
#
# NOTE: The OpenBLAS installation automatically runs self-tests but it's hard
# to extract stats from them (partly because I don't know how a failed test
# would be reported; there's no executive summary.
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

set(MUMPS_TARBALL_URL
    https://github.com/scivision/mumps/archive/refs/tags/v5.6.2.2.tar.gz)
set(MUMPS_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/mumps")

# MUMPS build options
set(MUMPS_CMAKE_BUILD_ARGS
    -Dgemmt=ON
    -Dparallel=${OOMPH_ENABLE_MPI}
    -Dintsize64=OFF
    -Dscotch=OFF
    -Dparmetis=OFF
    -Dmetis=OFF
    -Dopenmp=OFF
    -Dmatlab=OFF
    -Doctave=OFF
    -Dfind=OFF
    -DBUILD_SHARED_LIBS=OFF
    -DBUILD_SINGLE=ON
    -DBUILD_DOUBLE=ON
    -DBUILD_COMPLEX=OFF
    -DBUILD_COMPLEX16=OFF)

# Define how to configure/build/install the project
oomph_get_external_project_helper(
  PROJECT_NAME mumps
  URL "${MUMPS_TARBALL_URL}"
  INSTALL_DIR "${MUMPS_INSTALL_DIR}"
  CONFIGURE_COMMAND ${CMAKE_COMMAND} --install-prefix=<INSTALL_DIR>
                    ${MUMPS_CMAKE_BUILD_ARGS} -G=${CMAKE_GENERATOR} -B=build
  BUILD_COMMAND ${CMAKE_COMMAND} --build build -j ${NUM_JOBS}
  INSTALL_COMMAND ${CMAKE_COMMAND} --install build
  TEST_COMMAND ${CMAKE_CTEST_COMMAND} --test-dir build -j ${NUM_JOBS}
  INSTALL_BYPRODUCTS "")

# ---------------------------------------------------------------------------------
