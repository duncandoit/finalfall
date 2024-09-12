#!/bin/bash
set -e

# Move to korin/scripts
pushd scripts &>/dev/null

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
elif [ "$OPTION" = "clean" ]; then
    echo "::KORIN:: build.sh > Cleaning Korin library"
    rm Makefile
    rm -rf ../build/
else
    build() 
    {
        echo "::KORIN:: build.sh > Building Korin library for platform=$PLATFORM option=$OPTION"
        
        PREMAKE="premake5 gmake2 $1"
        echo "::KORIN:: $PREMAKE"
        $PREMAKE

        if [ "$OPTION" = "release" ]; then
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

# Pop back to korin
popd &>/dev/null
