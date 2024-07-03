#!/bin/bash

CLEAR='\033[0m'
RED='\033[0;31m'

function usage() {
if [ -n "$1" ]; then
   echo -e "${RED}👉 $1${CLEAR}\n";
fi
   echo "Usage: $0 [-t target] [-c configuration] [-a process] [-d device]"
   echo "  -t, --target             Target (iOS / macOS)"
   echo "  -c, --configuration      Configuration (Debug / Release)"
   echo "  -p, --process            Action (build / run / clean)"
   echo "  -a, --arch               Architecture (e.g., arm64, x86_64)"
   echo ""
   echo "Example: $0 --target iOS --configuration Release --process build --device 'iPhone 12'"
   exit 1
}

# parse params
while [[ "$#" > 0 ]]; do case $1 in
   -t|--target) TARGET="$2"; shift;shift;;
   -c|--configuration) CONFIGURATION="$2";shift;shift;;
   -p|--process) PROCESS="$2";shift;shift;;
   -a|--arch) ARCH="$2";shift;shift;;
   *) usage "Unknown parameter passed: $1"; shift; shift;;
esac; done

# clean
if [ "${PROCESS}" == "clean" ]; then
   BUILDDIR="build/${TARGET}/${CONFIGURATION}"
   rm -rf ${BUILDDIR}
   echo -e "Cleaned ${BUILDDIR} directory."
   exit 0
fi

# verify params
if [ -z "$TARGET" ]; then usage "Target is not set"; fi;
if [ "${TARGET}" != "macOS" ] && [ "${TARGET}" != "iOS" ]; then usage "${TARGET} is not a valid target platform"; fi;
if [ -z "$CONFIGURATION" ]; then usage "Configuration is not set."; fi;
if [ "${CONFIGURATION}" != "Debug" ] && [ "${CONFIGURATION}" != "Release" ]; then usage "${CONFIGURATION} is not a valid configuration"; fi;
if [ -z "$PROCESS" ]; then usage "Process is not set."; fi;
if [ "${PROCESS}" != "build" ] && [ "${PROCESS}" != "run" ] && [ "${PROCESS}" != "clean" ]; then usage "${PROCESS} is not a valid process"; fi;

# Generate project files using Premake
premake5 xcode4

# if [ "${TARGET}" == "iOS" ]; then
#    xcrun simctl list devices
#    echo -e "\n"
# fi

# Construct the xcodebuild command
XCODEBUILD_CMD="xcodebuild -workspace Vallaroy.xcworkspace -scheme Vallaroy -derivedDataPath build -configuration ${CONFIGURATION}"

# Add platform-specific destination
if [ "${TARGET}" == "iOS" ]; then
   XCODEBUILD_CMD+=" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'"
else
   XCODEBUILD_CMD+=" -destination 'platform=${TARGET},arch=${ARCH}'"
fi

# Execute the xcodebuild command
if [ "${PROCESS}" == "build" ]; then
   echo -e "Executing: ${XCODEBUILD_CMD}"
   $XCODEBUILD_CMD | xcpretty
elif [ "${PROCESS}" == "run" ]; then
   echo -e "Executing: ${XCODEBUILD_CMD} && xcrun simctl boot 'iPhone 15' && xcrun simctl install booted build/Build/Products/${CONFIGURATION}-iphonesimulator/Vallaroy.app && xcrun simctl launch booted com.finalfallgames.Vallaroy"
   
   $XCODEBUILD_CMD && xcrun simctl boot 'iPhone 15' && xcrun simctl install booted build/Build/Products/${CONFIGURATION}-iphonesimulator/Vallaroy.app && xcrun simctl launch booted com.finalfallgames.Vallaroy | xcpretty
fi

echo -e "Configuration -> ${CONFIGURATION}, Target -> ${TARGET}, Device -> ${DEVICE}"