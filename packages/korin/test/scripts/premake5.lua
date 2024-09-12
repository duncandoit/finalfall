workspace 'sandbox'
    configurations {'debug', 'release'}
    location '../../build'

project 'sandbox'
    kind 'ConsoleApp'
    language 'C++'
    cppdialect 'C++17'
    toolset 'clang'
    location '.'
    targetdir '../build/%{cfg.system}/bin/%{cfg.buildcfg}'
    objdir '../build/%{cfg.system}/obj/%{cfg.buildcfg}'
    
    files 
    {
        '../**.cpp'
    }

    removefiles
    {
        '../tests/**'
    }

    includedirs 
    {
        '../../include',                                 -- libkorin
        "../../dependencies/%{cfg.system}/glfw/include"  -- GLFW
    }

    libdirs {
        '../../build/%{cfg.system}/bin/%{cfg.buildcfg}/',  -- libkorin
        '../../dependencies/%{cfg.system}/glfw/'           -- GLFW
    }

    links 
    {
        'korin',            -- libkorin
        'glfw3'             -- GLFW
    }
    
    buildoptions 
    {
        "-Wall",                     -- Enable all warnings
        "-fno-exceptions",           -- Disable exceptions
        "-fno-rtti",                 -- Disable RTTI
        "-Werror=format",            -- Treat format errors as errors
        "-Wimplicit-int-conversion", -- Treat implicit int conversions as errors
        "-Werror=vla"                -- Treat variable length arrays as errors
    }
    
    filter {'system:macosx'}
        defines {'KORIN_PLATFORM_MACOSX'}
        links 
        { 
            'CoreFoundation.framework',
            'Cocoa.framework',
            'IOKit.framework',
            'CoreVideo.framework',
            'CoreGraphics.framework', 
            'OpenGL.framework',         -- OpenGL
        }
        buildoptions 
        {
            '-Wimplicit-float-conversion',
            '-arch x86_64',
            -- '-arch arm64'
        }

    filter {'system:macosx', 'configurations:release'}
        buildoptions {'-flto=full'}

    filter 'configurations:debug'
        defines {'DEBUG'}
        defines {'KORIN_ASSERTIONS'}
        symbols 'On'

    filter 'configurations:release'
        defines {'RELEASE'}
        defines {'NDEBUG'}
        optimize 'On'