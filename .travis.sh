#!/bin/sh -x

# always build in-place so that Sphinx can find the modules
python setup.py build_ext --inplace
BUILD_RES=$?

if [ x"$KRB5_VER" = "xheimdal" ]; then
    # heimdal can't run the tests yet, so just exit
    exit $BUILD_RES
fi

if [ $BUILD_RES -ne 0 ]; then
    # if the build failed, don't run the tests
    exit $BUILD_RES
fi

flake8 setup.py
F8_SETUP=$?

flake8 gssapi
F8_PY=$?

flake8 gssapi --filename='*.pyx,*.pxd' --ignore=E225,E226,E227,E901,E402
F8_MAIN_CYTHON=$?

python setup.py nosetests --verbosity=3
TEST_RES=$?

if [ $F8_SETUP -eq 0 -a $F8_PY -eq 0 -a $F8_MAIN_CYTHON -eq 0 -a $TEST_RES -eq 0 ]; then
    exit 0
else
    exit 1
fi
