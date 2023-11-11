# Building `oomph-lib`s third-party libraries

## Example

To build all libraries without MPI support, simply run

```bash
cmake -G Ninja -B build
cmake --build build
```

Note that we do not need an install step; this is because we only build/install the third-party libraries in this project, which are installed at build-time.

## Build options

Option                                      | Description                                                | Default
--------------------------------------------|------------------------------------------------------------|-----------------------------
`OOMPH_ENABLE_MPI`                          | *Enable MPI support?*                                      | `OFF`
`OOMPH_BUILD_CGAL`                          | *Build CGAL (with deps. GMP, MPFR and Boost)?*             | `ON`
`OOMPH_BUILD_OPENBLAS`                      | *Build OpenBLAS?*                                          | `ON`
`OOMPH_BUILD_MUMPS`                         | *Build MUMPS?*                                             | `ON`
`OOMPH_BUILD_HYPRE`                         | *Build Hypre?*                                             | `ON`
`OOMPH_BUILD_TRILINOS`                      | *Build Trilinos?*                                          | `ON`
`OOMPH_DISABLE_THIRD_PARTY_LIBRARY_TESTING` | *Disable testing when building the third-party libraries?* | `OFF`
`OOMPH_THIRD_PARTY_INSTALL_DIR`             | *Base installation directory for third-party libraries.*   | `<project_root>/install/`

### Extended example

**Example 1:** To build all of the third-party libraries without any testing (at your own peril!), run

```bash
>>> cmake -G Ninja -DOOMPH_DISABLE_THIRD_PARTY_LIBRARY_TESTS=ON -B build
>>> cmake --build build
```

**Example 2:** To enable MPI support but only build CGAL and OpenBLAS without any testing whatsoever, run

```bash
>>> cmake -G Ninja -DOOMPH_ENABLE_MPI=ON -DOOMPH_BUILD_CGAL=ON -DOOMPH_BUILD_OPENBLAS=ON -DOOMPH_BUILD_MUMPS=OFF -DOOMPH_BUILD_HYPRE=OFF -DOOMPH_BUILD_TRILINOS=OFF -DOOMPH_DISABLE_THIRD_PARTY_LIBRARY_TESTS=ON -B build
>>> cmake --build build
```

Since, by default, we want to build all of the third-party libraries, you can actually reduce the above commands to

```bash
>>> cmake -G Ninja -DOOMPH_ENABLE_MPI=ON -DOOMPH_BUILD_MUMPS=OFF -DOOMPH_BUILD_HYPRE=OFF -DOOMPH_BUILD_TRILINOS=OFF -DOOMPH_DISABLE_THIRD_PARTY_LIBRARY_TESTS=ON -B build
>>> cmake --build build
```
