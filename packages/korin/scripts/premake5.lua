KORIN_DIR = path.getabsolute('..')

workspace 'korin'
    startproject 'korin'
    configurations {'debug', 'release'}
    location (KORIN_DIR ..'/build')

-- The generated library will use this name and append 'lib'
project 'korin'
do
    kind 'StaticLib'
    language 'C++'
    cppdialect 'C++17'
    toolset 'clang'
    location '.'
    targetdir (KORIN_DIR .. '/build/%{cfg.system}/bin/%{cfg.buildcfg}')
    objdir (KORIN_DIR .. '/build/%{cfg.system}/obj/%{cfg.buildcfg}')
    files 
    {
        KORIN_DIR .. '/include/**.h',
        KORIN_DIR .. '/src/**.cpp',
    }
    includedirs 
    {
        KORIN_DIR .. '/include',                                  -- Korin
        -- KORIN_DIR ..'/dependencies/%{cfg.system}/glfw/include',  -- GLFW
        KORIN_DIR .. '/dependencies/submodules/spdlog/include'    -- spdlog
    }
    libdirs 
    {
        -- KORIN_DIR ..'/dependencies/%{cfg.system}/glfw', -- GLFW
        KORIN_DIR .. '/dependencies/submodules/spdlog/build'   -- spdlog
    }
    links 
    {
        -- 'glfw3',           -- GLFW
        'spdlog'           -- spdlog
    }
    buildoptions 
    {
        '-Wall',                     -- Enable all warnings
        '-fno-rtti',                 -- Disable RTTI
        '-Werror=format',            -- Treat format errors as errors
        '-Wimplicit-int-conversion', -- Implicit int conversion
        '-Werror=vla',               -- Treat variable length arrays as errors
        -- '-fno-exceptions',           -- Disable exceptions 
    }
    defines 
    {
        'SPDLOG_COMPILED_LIB',        -- Required when using spdlog as a static library'
        'KORIN_BUILD_SHAREDLIB'       -- Allows the core KORIN_API to adjust to using a shared library 
    }

    filter {'system:macosx'}
    do
        links 
        { 
            'CoreFoundation.framework',
            'Cocoa.framework',
            'IOKit.framework',
            'CoreVideo.framework',
            'CoreGraphics.framework', 
            'OpenGL.framework',
        }
        defines 
        {
            'KORIN_PLATFORM_MACOSX'
        }
        buildoptions 
        {
            '-Wimplicit-float-conversion'
        }
    end

    filter {'system:macosx', 'configurations:release'}
    do
        buildoptions {'-flto=full'}
    end

    -- filter 'system:windows'
    -- do
    --     links
    --     {
    --         '../dependencies/windows/glfw/glfw3.lib'
    --     }
    --     architecture 'x64'
    --     defines {'_USE_MATH_DEFINES'}
    --     flags {'FatalCompileWarnings'}
    --     buildoptions {WINDOWS_CLANG_CL_SUPPRESSED_WARNINGS}
    --     staticruntime 'on'
    --     runtime 'Release'
    --     removebuildoptions 
    --     {
    --         '-fno-exceptions',
    --         '-fno-rtti'
    --     }
    -- end

    filter 'configurations:debug'
    do
        defines 
        {
            'DEBUG'
        }
        symbols 'On'
    end

    filter 'configurations:release'
    do
        defines 
        {
            'RELEASE',
            'NDEBUG'
        }
        optimize 'On'
    end
end
