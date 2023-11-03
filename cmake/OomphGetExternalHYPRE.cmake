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

set(HYPRE_TARBALL_URL
    https://github.com/hypre-space/hypre/archive/refs/tags/v2.29.0.tar.gz)
set(HYPRE_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/hypre")

# Hypre build options

# Define how to configure/build/install the project
oomph_get_external_project_helper(
  PROJECT_NAME hypre
  URL "${HYPRE_TARBALL_URL}"
  INSTALL_DIR "${HYPRE_INSTALL_DIR}"
  CONFIGURE_COMMAND
    ${CMAKE_COMMAND}
    --install-prefix=<INSTALL_DIR>
    -G=${CMAKE_GENERATOR}
    -S=src
    -DHYPRE_ENABLE_SHARED=OFF
    -DHYPRE_ENABLE_BIGINT=OFF
    -DHYPRE_ENABLE_MIXEDINT=OFF
    -DHYPRE_ENABLE_SINGLE=OFF
    -DHYPRE_ENABLE_LONG_DOUBLE=OFF
    -DHYPRE_ENABLE_COMPLEX=OFF
    -DHYPRE_WITH_MPI=${OOMPH_ENABLE_MPI}
    -DHYPRE_WITH_OPENMP=OFF
    -DHYPRE_ENABLE_HOPSCOTCH=OFF
    -DHYPRE_WITH_DSUPERLU=OFF
    -DHYPRE_PRINT_ERRORS=OFF
    -DHYPRE_TIMING=OFF
    -DHYPRE_BUILD_EXAMPLES=OFF
    -DHYPRE_BUILD_TESTS=OFF
    -DHYPRE_ENABLE_HYPRE_BLAS=OFF
    -DHYPRE_ENABLE_HYPRE_LAPACK=OFF
    -DTPL_ENABLE_BLAS=ON
    -DTPL_ENABLE_LAPACK=ON
    -DTPL_BLAS_LIBRARIES=${OpenBLAS_LIBRARIES}
    -DTPL_LAPACK_LIBRARIES=${OpenBLAS_LIBRARIES}
    -B=src/cmbuild
  BUILD_COMMAND cmake --build src/cmbuild -j ${NUM_THREADS_FOR_PARALLEL_MAKE}
  INSTALL_COMMAND cmake --install src/cmbuild
  TEST_COMMAND ""
  INSTALL_BYPRODUCTS "")

# ---------------------------------------------------------------------------------
