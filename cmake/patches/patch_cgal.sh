#!/bin/bash

CGAL_ROOT_DIR=$1

echo "Patching files in CGAL_ROOT_DIR: ${CGAL_ROOT_DIR}"
if [ ! -d "${CGAL_ROOT_DIR}" ]; then
    echo "Argh! This isn't a directory!"
    exit 1
fi

# Need to change all instances of 'BUILD_TESTING' --> 'CGAL_BUILD_TESTING'
if grep -qR '\bBUILD_TESTING\b' "${CGAL_ROOT_DIR}"; then
    # Update 'BUILD_TESTING' --> 'CGAL_BUILD_TESTING'
    if [ "$(uname)" == "Darwin" ]; then
        LC_ALL=C find "${CGAL_ROOT_DIR}" -type f -exec sed -i '' "s|BUILD_TESTING|CGAL_BUILD_TESTING|g" {} \;
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        LC_ALL=C find "${CGAL_ROOT_DIR}" -type f -exec sed -i "s|BUILD_TESTING|CGAL_BUILD_TESTING|g" {} \;
    fi

    # Make sure it worked
    if grep -qR '\bBUILD_TESTING\b' "${CGAL_ROOT_DIR}"; then
        echo ""
        echo "It looks like you failed to change all occurrences of BUILD_TESTING!"
        echo ""
        grep -R '\bBUILD_TESTING\b' "${CGAL_ROOT_DIR}"
    fi
fi
