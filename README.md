# oomph_lib_superbuild

## Example

```bash
cmake -G Ninja -B build
cmake --build build
```

Note that we do not currently need an install step as third-party libraries are built and installed at build-time and we do not currently install the main `oomph-lib` project as part of this project.

## Build options

Option                 | Description                                    | Default
-----------------------|------------------------------------------------|--------
`OOMPH_ENABLE_MPI`     | *Enable MPI support?*                          | `OFF`
`OOMPH_BUILD_CGAL`     | *Build CGAL (with deps. GMP, MPFR and Boost)?* | `ON`
`OOMPH_BUILD_OPENBLAS` | *Build OpenBLAS?*                              | `ON`
`OOMPH_BUILD_MUMPS`    | *Build MUMPS?*                                 | `ON`
`OOMPH_BUILD_HYPRE`    | *Build Hypre?*                                 | `ON`
`OOMPH_BUILD_TRILINOS` | *Build Trilinos?*                              | `ON`

- **TODO:** Combine with main project to form superbuild.
- **TODO:** Decide whether to keep `OOMPH_USE_*_FROM` options or remove
