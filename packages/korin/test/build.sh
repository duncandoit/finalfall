#!/bin/bash
set -e

pushd build &>/dev/null

while getopts p: flag; do
    case "${flag}" in
    p)
        shift 2
        platform=${OPTARG}
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
        echo "Building Korin tests for platform=$platform option=$OPTION" 
        echo premake5 gmake2 "$1"
        PREMAKE="premake5 gmake2 $1" 
        eval "$PREMAKE"

        if [ "$OPTION" = "clean" ]; then
            make clean
            make clean config=release
        elif [ "$OPTION" = "release" ]; then
            make config=release -j7
        else
            make VERBOSE=1 config=debug -j7
        fi

        # if [ $run ]; then
            ../build/$platform/bin/$OPTION/korintest
        # fi
    }

    case $platform in
    *)
        build
        ;;
    esac
fi

popd &>/dev/null