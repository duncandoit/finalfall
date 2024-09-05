#!/bin/bash
set -e

# Move back to the root directory
pushd .. &>/dev/null
# echo "::KORIN:: test/build.sh > Moved to: $(pwd)"

# Build the Korin static library
echo "::KORIN:: test/build.sh > Build Korin library if necessary"
./build.sh "$@"

popd &>/dev/null
# echo "::KORIN:: test/build.sh > Popped back to: $(pwd)"

pushd scripts &>/dev/null
echo "Moved to: $(pwd)"

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
else
    build() 
    {
        echo "::KORIN:: test/build.sh > Building Korin test for platform=$PLATFORM option=$OPTION" 

        echo "::KORIN:: test/build.sh > Invoking korintest premake file at: $(pwd)"
        PREMAKE="premake5 gmake2 $1 --file=premake5_test.lua"
        echo "$PREMAKE"
        $PREMAKE

        if [ "$OPTION" = "clean" ]; then
            make clean
            make clean config=release
        elif [ "$OPTION" = "release" ]; then
            make config=release -j7
        else
            make VERBOSE=1 config=debug -j7
        fi

        echo "::KORIN:: test/build.sh > Running korintest binary"
        ../build/$PLATFORM/bin/$OPTION/korintest
    }

    case $PLATFORM in
    *)
        echo "Building for ${PLATFORM}"
        build
        ;;
    esac
fi

popd &>/dev/null
# echo "::KORIN:: test/build.sh > Popped back to: $(pwd)"