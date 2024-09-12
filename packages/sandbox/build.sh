#!/bin/bash
set -e

# Move to Korin's root directory
        pushd ../korin &>/dev/null
        # echo "::SANDBOX:: build.sh > Moved to: $(pwd)"

        echo "::SANDBOX:: build.sh > Build Korin library if necessary"
        if [ -f "$OUTPUT_DIR/libkorin.a" ]; then
            echo "::SANDBOX:: build.sh > Korin library already built."
        else
            echo "::SANDBOX:: build.sh > Building Korin library."
            ./build.sh "$@"
        fi

        popd &>/dev/null
        # echo "::SANDBOX:: build.sh > Popped back to: $(pwd)"

        pushd scripts &>/dev/null
        # echo "Moved to: $(pwd)"

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
OPTION="$(echo "$1" | tr '[A-Z]' '[a-z]')"

if [ "$OPTION" = 'help' ]; then
    echo "Help"
elif [ "$OPTION" = "clean" ]; then
    make clean
    make clean config=release
else
    build() 
    {
        OUTPUT_DIR="build/$PLATFORM/bin/$OPTION"

        

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
        ../$OUTPUT_DIR/sandbox
    }

    case $PLATFORM in
    *)
        echo "Building for ${PLATFORM}"
        build
        ;;
    esac
fi

popd &>/dev/null
# echo "::SANDBOX:: build.sh > Popped back to: $(pwd)"