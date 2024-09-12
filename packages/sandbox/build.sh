#!/bin/bash
set -e

RAW_INPUT="$@"

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

# Move to korin
pushd ../korin &>/dev/null

if [ -f "build/$PLATFORM/bin/$OPTION/libkorin.a" ]; then
    echo "::SANDBOX:: Korin library found."

else
    eval ./build.sh "$RAW_INPUT"

fi

# Pop back to sandbox
popd &>/dev/null

if [ "$OPTION" = 'help' ]; then
    echo "Help"

elif [ "$OPTION" = "clean" ]; then
    echo "::SANDBOX:: Cleaning Sandbox"
    rm scripts/Makefile &>/dev/null
    rm -rf build/ &>/dev/null

else
    build() 
    {
        # Move to sandbox/scripts
        pushd scripts &>/dev/null

        echo "::SANDBOX:: Building Korin sandbox for platform=$PLATFORM option=$OPTION" 
        PREMAKE="premake5 gmake2 $1 --file=premake5.lua"
        echo "::SANDBOX:: $PREMAKE"
        $PREMAKE

        if [ "$OPTION" = "release" ]; then
            make config=release -j7

        else
            make VERBOSE=1 config=debug -j7

        fi

        echo "::SANDBOX:: Running sandbox binary"
        eval ../build/$PLATFORM/bin/$OPTION/sandbox

        # Pop back to sandbox
        popd &>/dev/null
    }

    case $PLATFORM in
    *)
        build
        ;;
    esac
fi