#!/bin/bash
set -e

# source dependencies/config_directories.sh

# echo "::KORIN:: build.sh > Current directory: $(pwd)"
pushd scripts &>/dev/null
# echo "::KORIN:: build.sh > Moved to directory: $(pwd)"

while getopts p: flag; do
    case "${flag}" in
    p)
        shift 2
        PLATFORM=${OPTARG}
        ;;
    \?) help ;;
    esac
done

help() {
    echo build.sh - build library [debug]
    echo build.sh clean - clean the build
    echo build.sh release - build library [release]
    echo build.sh -p ios release - build ios library [release]
    echo build.sh -p ios_sim release - build ios simulator library [release]
    exit 1
}

# ensure the option is lowercase
OPTION="$(echo "$1" | tr '[A-Z]' '[a-z]')"

if [ "$OPTION" = 'help' ]; then
    help
else
    build() 
    {
        echo "::KORIN:: build.sh > Building Korin library for platform=$PLATFORM option=$OPTION"
        
        PREMAKE="premake5 gmake2 $1"
        echo "::KORIN:: $PREMAKE"
        $PREMAKE

        if [ "$OPTION" = "clean" ]; then
            make clean
            make clean config=release
        elif [ "$OPTION" = "release" ]; then
            make config=release -j7
        else
            make VERBOSE=1 config=debug -j7
        fi
    }

    case $PLATFORM in        
    *)
        build
        ;;
    esac
fi

# echo "::KORIN:: build.sh > Finished build in directory: $(pwd)"
popd &>/dev/null
# echo "::KORIN:: build.sh > Popped back to directory: $(pwd)"
