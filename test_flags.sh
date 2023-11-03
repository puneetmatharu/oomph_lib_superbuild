CONFIGURE_COMMAND="CC=gcc CXX=g++ cmake -G Ninja -DCMAKE_BUILD_TYPE=Release "
CONFIGURE_COMMAND+="-DOOMPH_USE_GMP_FROM=/Users/PuneetMatharu/Dropbox/programming/oomph-lib/oomph-lib-repos/preinstall_third_party_libraries_for_oomph-lib/puneet/install/gmp "
CONFIGURE_COMMAND+="-DOOMPH_USE_MPFR_FROM=/Users/PuneetMatharu/Dropbox/programming/oomph-lib/oomph-lib-repos/preinstall_third_party_libraries_for_oomph-lib/puneet/install/mpfr "
CONFIGURE_COMMAND+="-DOOMPH_USE_BOOST_FROM=/Users/PuneetMatharu/Dropbox/programming/oomph-lib/oomph-lib-repos/preinstall_third_party_libraries_for_oomph-lib/puneet/install/boost "
CONFIGURE_COMMAND+="-DOOMPH_USE_CGAL_FROM=/Users/PuneetMatharu/Dropbox/programming/oomph-lib/oomph-lib-repos/preinstall_third_party_libraries_for_oomph-lib/puneet/install/cgal "
# CONFIGURE_COMMAND+="-DOOMPH_USE_OPENBLAS_FROM=/Users/PuneetMatharu/Dropbox/programming/oomph-lib/oomph-lib-repos/preinstall_third_party_libraries_for_oomph-lib/puneet/install/openblas  "
# CONFIGURE_COMMAND+="-DOOMPH_USE_HYPRE_FROM=/Users/PuneetMatharu/Dropbox/programming/oomph-lib/oomph-lib-repos/preinstall_third_party_libraries_for_oomph-lib/puneet/install/hypre "
# CONFIGURE_COMMAND+="-DOOMPH_USE_MUMPS_FROM=/Users/PuneetMatharu/Dropbox/programming/oomph-lib/oomph-lib-repos/preinstall_third_party_libraries_for_oomph-lib/puneet/install/mumps "
# CONFIGURE_COMMAND+="-DOOMPH_USE_TRILINOS_FROM=/Users/PuneetMatharu/Dropbox/programming/oomph-lib/oomph-lib-repos/preinstall_third_party_libraries_for_oomph-lib/puneet/install/trilinos "
CONFIGURE_COMMAND+="-B build "

echo ""
echo "Running configure command:"
echo ""
echo "    ${CONFIGURE_COMMAND}"
echo ""
eval ${CONFIGURE_COMMAND}

BUILD_COMMAND="cmake --build build"

echo ""
echo "Running build command:"
echo ""
echo "    ${BUILD_COMMAND}"
echo ""
eval ${BUILD_COMMAND}

INSTALL_COMMAND="cmake --install build"

echo ""
echo "Running install command:"
echo ""
echo "    ${INSTALL_COMMAND}"
echo ""
eval ${INSTALL_COMMAND}
