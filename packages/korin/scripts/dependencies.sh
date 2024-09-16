#!/bin/bash

set -e

# Define the submodules and their respective URLs using two parallel arrays
SUBMOD_KEYS=("spdlog")
SUBMOD_URLS=("https://github.com/gabime/spdlog.git")

# Directory where submodules are stored
SUBMOD_DIR="../dependencies/submodules"

# Create the submodules directory if it doesn't exist
mkdir -p "$SUBMOD_DIR"

# Check and download each submodule if not present
for i in "${!SUBMOD_KEYS[@]}"; do
    KEY="${SUBMOD_KEYS[$i]}"
    URL="${SUBMOD_URLS[$i]}"
    PATH="$SUBMOD_DIR/$KEY"
    
    if [ -d "$PATH/.git" ]; then
         echo "Submodule $KEY already exists and is a Git repository."

    elif [ -d "$PATH" ]; then
         echo "Submodule $KEY found but is not a valid Git repository. Please remove or check manually."
         exit 1

    else
         echo "Submodule $KEY not found. Cloning..."

         git submodule add "$URL" "$PATH" 

         git submodule update --init --recursive "$PATH" 

    fi
done

echo "All submodules are up to date."