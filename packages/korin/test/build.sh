#!/bin/bash
set -e

echo "Current directory: $(pwd)"
pushd scripts &>/dev/null
echo "Moved to directory: $(pwd)"

while getopts p: flag; do
    case "${flag}" in
    p)
        shift 2
        PLATFORM=${OPTARG}
        ;;
    # r)
    #     run=true
    #     ;;
    \?) help ;;
    esac
done

help() {
    echo build.sh  - build tests [debug]
    echo build.sh clean  - clean the build
    echo build.sh release  - build tests [release]
    echo build.sh debug -r  - build and run tests [debug]
    exit 1
}

# ensure the option is lowercase
OPTION="$(echo "$1" | tr '[A-Z]' '[a-z]')"

if [ "$OPTION" = 'help' ]; then
    help
else
    build() 
    {
        echo "Building Korin tests for platform=$PLATFORM option=$OPTION" 
        
        PREMAKE="premake5 gmake2 $1"
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

        # if [ $run ]; then
            ../build/$PLATFORM/bin/$OPTION/korintest
        # fi
    }

    case $PLATFORM in
    *)
        echo "Building for ${PLATFORM}"
        build
        ;;
    esac
fi

echo "Finished build in directory: $(pwd)"
popd &>/dev/null
echo "Popped back to directory: $(pwd)"