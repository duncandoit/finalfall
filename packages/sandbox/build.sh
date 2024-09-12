#!/bin/bash
set -e

# Move to korin
pushd ../korin &>/dev/null

if [ -f "build/$PLATFORM/bin/$OPTION/libkorin.a" ]; then
    echo "::SANDBOX:: build.sh > Korin library found."
else
    ./build.sh "$@"
fi

# Pop back to sandbox
popd &>/dev/null

while getopts p: flag; do
    case "${flag}" in
    p)
        shift 2
        PLATFORM=${OPTARG}
        ;;
    \?) help ;;
    esac
done

# ensure the option is lowercase
OPTION="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

if [ "$OPTION" = 'help' ]; then
    echo "Help"
elif [ "$OPTION" = "clean" ]; then
    echo "::SANDBOX:: build.sh > Cleaning Sandbox"
    rm scripts/Makefile
    rm -rf build/
else
    build() 
    {
        # Move to sandbox/scripts
        pushd scripts &>/dev/null

        echo "::SANDBOX:: build.sh > Building Korin sandbox for platform=$PLATFORM option=$OPTION" 
        PREMAKE="premake5 gmake2 $1 --file=premake5.lua"
        echo "::SANDBOX:: $PREMAKE"
        $PREMAKE

        if [ "$OPTION" = "release" ]; then
            make config=release -j7
        else
            make VERBOSE=1 config=debug -j7
        fi

        echo "::SANDBOX:: build.sh > Running sandbox binary"
        ../build/$PLATFORM/bin/$OPTION/sandbox

        # Pop back to sandbox
        popd &>/dev/null
    }

    case $PLATFORM in
    *)
        build
        ;;
    esac
fi