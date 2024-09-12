# Build and Run the Sandbox Application
1. Navigate to `finalfall/packages/sandbox`.
2. Type `./build.sh -p platform config`. 
   - platform: macosx, windows
   - config: release, debug
3. Hit enter. That's it!

Note: When building for Windows you'll use the bat file instead of the shell script.

# Clean the Build
1. Navigate to `finalfall/packages/sandbox`.
2. Type `./build.sh clean`. 
3. Hit enter. That's it!

# More detail on the build process:
The Sandbox app relies on the Korin engine as well as other dependencies. The main build script takes care of setting all of that up automatically.
1. `<finalfall/packages/sandbox> ./build.sh -p macosx release`
2. This runs the `sandbox/build.sh` script 
3. This build script triggers `korin/build.sh` with the same arguments to run
4. That build script triggers `korin/scripts/premake5.lua` which builds the libkorin library
5. After the Korin library is built the `sandbox/build.sh` script continues and invokes the `sandbox/scripts/premake5_test.lua` script which makes the sandbox binary
6. The binary will be located in `sandbox/build/platform/bin/config/` and will be run automatically at the end of the build process.

# Just Building Korin 
Go [here for instructions](../korin/README.md) on building Korin independently of the Sandbox app.