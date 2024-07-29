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

1. Clone the repository to your local machine.
2. Navigate to the project directory: `finalfall/packages/korin/test`.
3. Run the build script in this way: `./run_tests.sh -p platform config
   - platform: macosx, ios, ios_sim, etc
   - config: release, debug

This will build everything and begin running the test executable.