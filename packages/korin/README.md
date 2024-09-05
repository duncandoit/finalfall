Build the Library:
follow these steps to build the `korin` module:

1. Clone the repository to your local machine.
2. Navigate to the project directory: `finalfall/packages/korin/`.
3. Run the build script in this way: `./build.sh -p platform config
   - platform: macosx, ios, ios_sim, etc
   - config: release, debug

This runs a Premake script, builds the `korin` project files as a static library in the `build` directory.


Run the Tests:
follow these steps to build the core Korin module and run its tests:
(NOTE: Build currently only tested on macOS)

1. Clone the repository to your local machine.
2. Navigate to the project directory: `finalfall/packages/korin/test`.
3. Run the build script in this way: `./run_tests.sh -p platform config
   - platform: macosx, ios, ios_sim, etc
   - config: release, debug

This will build everything and begin running the test executable.

More detail on the build process for testing:
1. `<finalfall/packages/korin/test> ./build.sh -p macosx release`
2. This runs the `korin/test/build.sh` script 
3. This build script triggers `korin/build.sh` with the same arguments to run
4. That build script triggers `korin/scripts/premake5.lua` which builds the libkorin.a static library
5. After the Korin library is built the `korin/test/build.sh` script continues and invokes the `korin/test/scripts/premake5_test.lua` script which makes the korintest binary
6. Then the binary is run if it was created