#!/bin/bash
set -e

# source dependencies/config_directories.sh
echo "Current directory: $(pwd)"
pushd scripts &>/dev/null
echo "Moved to directory: $(pwd)"

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
        echo "Building Korin library for platform=$PLATFORM option=$OPTION"
        
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
    }

    case $PLATFORM in
    # ios)
    #     echo "Building for iOS"
    #     export IOS_SYSROOT=$(xcrun --sdk iphoneos --show-sdk-path)
    #     build "--os=ios"
    #     if [ "$OPTION" = "clean" ]; then
    #         exit
    #     fi
    #     ;;

    # ios_sim)
    #     export IOS_SYSROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)
    #     build "--os=ios --variant=emulator"
    #     if [ "$OPTION" = "clean" ]; then
    #         exit
    #     fi
    #     ;;
    # # Android supports ABIs via a custom PLATFORM format:
    # #   e.g. 'android.x86', 'android.x64', etc.
    # android*)
    #     echo "Building for ${PLATFORM}"
    #     # Extract ABI from this opt by splitting on '.' character
    #     #   e.g. android.x86
    #     IFS="." read -ra strarr <<<"$PLATFORM"
    #     ARCH=${strarr[1]}
    #     build "--os=android --arch=${ARCH}"
    #     ;;
        
    *)
        echo "Building for ${PLATFORM}"
        build
        ;;
    esac
fi

echo "Finished build in directory: $(pwd)"
popd &>/dev/null
echo "Popped back to directory: $(pwd)"
