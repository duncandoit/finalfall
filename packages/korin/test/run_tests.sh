#!/bin/bash
set -e

pushd build &>/dev/null

while getopts p: flag; do
    case "${flag}" in
    p)
        shift 2
        platform=${OPTARG}
        ;;
    \?) help ;;
    esac
done

help() {
    echo build.sh - build tests [debug]
    echo build.sh clean - clean the build
    echo build.sh release - build library [release]
    exit 1
}

# ensure the option is lowercase
OPTION="$(echo "$1" | tr '[A-Z]' '[a-z]')"

if [ "$OPTION" = 'help' ]; then
    help
else
    build() {
        # find ../suites -type f -name "*.cpp" | while read filename; do
            echo "Building Korin tests for platform=$platform option=$OPTION" #filename=$filename"
            echo premake5 gmake2 "$1" #"$filename"
            PREMAKE="premake5 gmake2 $1" #$filename"
            eval "$PREMAKE" #-j7"
        # done
        if [ "$OPTION" = "clean" ]; then
            make clean
            make clean config=release
        elif [ "$OPTION" = "release" ]; then
            make config=release -j7
        else
            make config=debug -j7
        fi
    }

    case $platform in
    *)
        build
        ;;
    esac
fi



popd &>/dev/null

# # Directory for compiled test executables
# mkdir -p bin

# # Find all .cpp files in the suites directory and compile them into separate executables
# find suites -type f -name "*.cpp" | while read filename; do
#     # Extract the base name without the extension for the executable name
#     base_name=$(basename "$filename" .cpp)
#     # Compile the .cpp file into an executable in the bin directory
#     g++ -o "bin/$base_name" "$filename" $(pkg-config --cflags --libs cppunit) -std=c++17

# done

# echo "Compilation of test suites complete. Executables are in the bin directory."