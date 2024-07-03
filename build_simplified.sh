#!/bin/bash

# Generate project files using Premake
premake5 xcode4

# Construct the xcodebuild command
xcodebuild -workspace Vallaroy.xcworkspace -scheme Vallaroy -derivedDataPath build -configuration Debug -destination 'platform:iOS Simulator, id:AD7E4364-66B2-43D7-A402-F48E50391526, OS:17.5, name:iPhone 15 Pro Max' 

# xcodebuild -workspace Vallaroy.xcworkspace -scheme Vallaroy -derivedDataPath build -configuration Debug 'platform=iOS Simulator, name=iPhone 15, OS=latest' && xcrun simctl boot 'iPhone 15' && xcrun simctl install booted build/Build/Products/${CONFIGURATION}-iphonesimulator/Vallaroy.app && xcrun simctl launch booted com.finalfallgames.Vallaroy | xcpretty

# Add platform-specific destination
   # XCODEBUILD_CMD+=" -destination 'platform=iOS Simulator, name=iPhone 15, OS=latest'"
   # XCODEBUILD_CMD+=" -destination 'platform=${TARGET},arch=${ARCH}'"

