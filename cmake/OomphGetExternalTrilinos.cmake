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

set(TRILINOS_TARBALL_URL
    https://github.com/trilinos/Trilinos/archive/refs/tags/trilinos-release-14-4-0.tar.gz
)
set(TRILINOS_INSTALL_DIR "${OOMPH_THIRD_PARTY_INSTALL_DIR}/trilinos")

set(MPI_BASE_DIR)
if(OOMPH_ENABLE_MPI AND MPI_FOUND)
  set(MPI_BASE_DIR "${MPI_CXX_INCLUDE_DIRS}")
endif()

set(TRILINOS_OPTION_ARGS
    -DTrilinos_ENABLE_TESTS=OFF
    -DTrilinos_ENABLE_EXAMPLES=OFF
    -DTrilinos_ENABLE_ALL_PACKAGES=OFF
    -DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF
    -DTrilinos_ENABLE_Amesos=ON
    -DTrilinos_ENABLE_Anasazi=ON
    -DTrilinos_ENABLE_AztecOO=ON
    -DTrilinos_ENABLE_Epetra=ON
    -DTrilinos_ENABLE_EpetraExt=ON
    -DTrilinos_ENABLE_Ifpack=ON
    -DTrilinos_ENABLE_ML=ON
    -DTrilinos_ENABLE_Teuchos=ON
    -DTrilinos_ENABLE_Triutils=ON
    -DTrilinos_INSTALL_LIBRARIES_AND_HEADERS=ON
    -DTrilinos_ENABLE_INSTALL_CMAKE_CONFIG_FILES=ON
    -DTPL_ENABLE_BLAS=ON
    -DTPL_ENABLE_LAPACK=ON
    -DTPL_BLAS_LIBRARIES=${OpenBLAS_LIBRARIES}
    -DTPL_LAPACK_LIBRARIES=${OpenBLAS_LIBRARIES}
    -DTPL_ENABLE_MPI=${OOMPH_ENABLE_MPI})

if(OOMPH_ENABLE_MPI)
  if(NOT MPI_BASE_DIR)
    message(FATAL_ERROR "Requested MPI but MPI_BASE_DIR is not set!")
  endif()
  list(APPEND TRILINOS_OPTION_ARGS -DMPI_BASE_DIR=${MPI_BASE_DIR})
endif()

oomph_get_external_project_helper(
  PROJECT_NAME trilinos
  URL "${TRILINOS_TARBALL_URL}"
  INSTALL_DIR "${TRILINOS_INSTALL_DIR}"
  CONFIGURE_COMMAND ${CMAKE_COMMAND} --install-prefix=<INSTALL_DIR>
                    -G=${CMAKE_GENERATOR} -B=build ${TRILINOS_OPTION_ARGS}
  BUILD_COMMAND cmake --build build
  INSTALL_COMMAND cmake --install build
  TEST_COMMAND ""
  INSTALL_BYPRODUCTS "")

# ---------------------------------------------------------------------------------
