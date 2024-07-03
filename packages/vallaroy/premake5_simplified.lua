workspace "Vallaroy"
configurations { "Debug", "Release" }
platforms { "iOS" }
startproject "Vallaroy"

-- Global settings
cppdialect "C++17"
systemversion "latest"

filter "configurations:Debug"
    symbols "On"
filter "configurations:Release"
    optimize "On"

filter "platforms:iOS"
    system "ios"
    architecture "arm64"
    xcodebuildsettings {
        ["SDKROOT"] = "iphoneos",
        ["TARGETED_DEVICE_FAMILY"] = "1,2", -- 1 for iPhone, 2 for iPad
        ["CODE_SIGN_IDENTITY"] = "iPhone Developer",
        ["CODE_SIGN_STYLE"] = "Automatic",
        ["INFOPLIST_FILE"] = "src/platform/iOS/Info.plist",
        ["SWIFT_VERSION"] = "5.0",
        ["ENABLE_BITCODE"] = "NO", -- Disable Bitcode if not needed
        ["LD_RUNPATH_SEARCH_PATHS"] = "@executable_path/Frameworks"
    }
    buildoptions { "-fobjc-arc" }

project "Vallaroy"
location "src/platform/%{cfg.platform}"
kind "WindowedApp"
language "C++"
targetdir "bin/%{cfg.buildcfg}/%{cfg.platform}"

files { "src/core/**.h", "src/core/**.cpp", "include/core/**.h" }

filter "platforms:iOS"
    files {
        "src/platform/iOS/**.h", 
        "src/platform/iOS/**.hpp", 
        "src/platform/iOS/**.cpp", 
        "src/platform/iOS/**.swift"
    }
    defines { "PLATFORM_IOS" }
    links { 
        "CoreGraphics.framework", 
        "UIKit.framework",
        "Foundation.framework",
        "SwiftUI.framework",
    }

-- Reset filter for common settings
filter {}

includedirs { "include" }
-- Add any other include directories or libraries required for all platforms
