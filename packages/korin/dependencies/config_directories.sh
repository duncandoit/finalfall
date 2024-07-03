#!/bin/sh

# Platform specific build scripts are sourced directly the platform specific
# version of this script. 

set -e

unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) machine=linux ;;
Darwin*) machine=macosx ;;
*) machine="unhandled:${unameOut}" ;;
esac

source $(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/${machine}/config_directories.sh
