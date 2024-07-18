build process:
follow these steps to build the `korin` module:

1. Clone the repository to your local machine.
2. Navigate to the project directory: `finalfall/packages/korin/`.
3. Run the build script in this way: `./build/sh -p platform config
   - platform: macosx, ios, ios_sim, etc
   - config: release, debug

This runs a Premake script, builds the `korin` project files as a static library in the `build` directory.