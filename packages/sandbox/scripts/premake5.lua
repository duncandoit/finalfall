SANDBOX_DIR = path.getabsolute('..')
KORIN_DIR = path.getabsolute('../../korin')

workspace 'sandbox'
    configurations {'debug', 'release'}
    location (SANDBOX_DIR .. '/build')


project 'sandbox'
    kind 'ConsoleApp'
    language 'C++'
    cppdialect 'C++17'
    toolset 'clang'
    location '.'
    targetdir (SANDBOX_DIR .. '/build/%{cfg.system}/bin/%{cfg.buildcfg}')
    objdir (SANDBOX_DIR .. '/build/%{cfg.system}/obj/%{cfg.buildcfg}')
    files 
    {
        SANDBOX_DIR .. '/**.cpp'
    }
    removefiles
    {
        SANDBOX_DIR .. '/tests/**'
    }
    includedirs 
    {
        KORIN_DIR .. '/include',                                 -- libkorin
        -- KORIN_DIR .. '/dependencies/%{cfg.system}/glfw/include'  -- GLFW
        KORIN_DIR .. '/dependencies/submodules/spdlog/include'   -- spdlog
    }
    libdirs {
        KORIN_DIR .. '/build/%{cfg.system}/bin/%{cfg.buildcfg}',  -- libkorin
        -- KORIN_DIR .. '/dependencies/%{cfg.system}/glfw/'           -- GLFW
        KORIN_DIR .. '/dependencies/submodules/spdlog/build'            -- spdlog
    }
    links
    {
        'korin',            -- libkorin
        -- 'glfw3'             -- GLFW
        'spdlog'            -- spdlog
    }
    buildoptions 
    {
        "-Wall",                     -- Enable all warnings
        "-fno-rtti",                 -- Disable RTTI
        "-Werror=format",            -- Treat format errors as errors
        "-Wimplicit-int-conversion", -- Treat implicit int conversions as errors
        "-Werror=vla"                -- Treat variable length arrays as errors
        -- "-fno-exceptions",           -- Disable exceptions
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