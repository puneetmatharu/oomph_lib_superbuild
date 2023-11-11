# Building `oomph-lib`s third-party libraries

## Library versions

The table below contains the version of each library that you can install with this repository. If you wish to provide your own version of OpenBLAS, GMP, MPFR or Boost, make sure it is the right version.

Library    | Version
-----------|--------
`OpenBLAS` | 0.3.24
`GMP`      | 6.3.0
`MPFR`     | 4.2.1
`Boost`    | 1.83.0
`CGAL`     | 5.6
`MUMPS`    | 5.6.2
`HYPRE`    | 2.29.0
`Trilinos` | 14.4.0

## Example

To build all libraries without MPI support, simply run

```bash
>>> cmake -G Ninja -B build
>>> cmake --build build
```

Note that we do not need an install step; this is because we only build/install the third-party libraries in this project, which are installed at build-time.

## Build options

Option                                      | Description                                                | Default
--------------------------------------------|------------------------------------------------------------|--------------------------
`OOMPH_ENABLE_MPI`                          | *Enable MPI support?*                                      | `OFF`
`OOMPH_BUILD_CGAL`                          | *Build CGAL (with deps. GMP, MPFR and Boost)?*             | `ON`
`OOMPH_BUILD_OPENBLAS`                      | *Build OpenBLAS?*                                          | `ON`
`OOMPH_BUILD_MUMPS`                         | *Build MUMPS?*                                             | `ON`
`OOMPH_BUILD_HYPRE`                         | *Build Hypre?*                                             | `ON`
`OOMPH_BUILD_TRILINOS`                      | *Build Trilinos?*                                          | `ON`
`OOMPH_DISABLE_THIRD_PARTY_LIBRARY_TESTING` | *Disable testing when building the third-party libraries?* | `OFF`
`OOMPH_THIRD_PARTY_INSTALL_DIR`             | *Base installation directory for third-party libraries.*   | `<project_root>/install/`
`OOMPH_USE_OPENBLAS_FROM`                   | *The path to a preinstalled version of OpenBLAS.*          | `""`
`OOMPH_USE_GMP_FROM`                        | *The path to a preinstalled version of GMP.*               | `""`
`OOMPH_USE_MPFR_FROM`                       | *The path to a preinstalled version of MPFR.*              | `""`
`OOMPH_USE_BOOST_FROM`                      | *The path to a preinstalled version of Boost.*             | `""`

### Remark on `OOMPH_USE_<LIBRARY>_FROM` variables

**Note:** The arguments to the `OOMPH_USE_<LIBRARY>_FROM` flags must be a folder containing a `lib/` and `include/` folder (and possibly even a `bin/` folder) for that library. For example, consider `MPFR`. Below is the output of the `locate libmpfr` command

```bash
>>> locate libmpfr
/opt/homebrew/Cellar/mpfr/4.2.1/lib/libmpfr.6.dylib
/opt/homebrew/Cellar/mpfr/4.2.1/lib/libmpfr.a
/opt/homebrew/Cellar/mpfr/4.2.1/lib/libmpfr.dylib
...
```

You would therefore provide the path to CMake like so

```bash
>>> cmake -DOOMPH_USE_MPFR_FROM=/opt/homebrew/Cellar/mpfr/4.2.1/ ...
```

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

**Example 3:** To build everything with your own copy of OpenBLAS, GMP, MPFR and Boost, run

```bash
>>> cmake -G Ninja -DOOMPH_USE_OPENBLAS_FROM=<path-to-installed-openblas> -DOOMPH_USE_GMP_FROM=<path-to-installed-gmp> -DOOMPH_USE_MPFR_FROM=<path-to-installed-mpfr> -DOOMPH_USE_BOOST_FROM=<path-to-installed-boost> -B build
>>> cmake --build build
```

See [Remark on `OOMPH_USE_<LIBRARY>_FROM` variables](#remark-on-oomph_use_library_from-variables) for how to determine the correct value for `<path-to-installed-XXXX>`.

### macOS support

Currently the build of OpenBLAS does not work on macOS with the compilers detected by CMake, but it does work with `gcc`/`g++`. However, we recommend that you let CMake pick the compiler itself. For this reason, it is best to install OpenBLAS, GMP and MPFR with your desired package manager. If you install these libraries Homebrew, you can pass them to CMake like so

```bash
>>> cmake -G Ninja -DOOMPH_USE_OPENBLAS_FROM=$(brew --prefix openblas) -DOOMPH_USE_GMP_FROM=$(brew --prefix gmp) -DOOMPH_USE_MPFR_FROM=$(brew --prefix mpfr) -B build
>>> cmake --build build
```
