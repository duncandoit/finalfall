workspace 'korin'
    startproject 'korin'
    configurations {'debug', 'release'}
    location '../build'

-- dofile(path.join(path.getabsolute('../dependencies/'), 'premake5_dependency.lua'))

-- The generated library will use this name and append 'lib'
project 'korin'
do
    kind 'StaticLib'
    language 'C++'
    cppdialect 'C++17'
    toolset 'clang'
    location '.'
    targetdir '../build/%{cfg.system}/bin/%{cfg.buildcfg}'
    objdir '../build/%{cfg.system}/obj/%{cfg.buildcfg}'

    files 
    {
        '../include/**.h',
        '../src/**.cpp'
    }

    includedirs 
    {
        '../include',
        '../dependencies/%{cfg.system}/glfw/include',
    }

    libdirs 
    {
        '../dependencies/%{cfg.system}/glfw' -- GLFW
    }

    links 
    {
        'glfw3'              -- GLFW
    }

    buildoptions 
    {
        '-Wall',                     -- Enable all warnings
        '-fno-exceptions',           -- Disable exceptions
        '-fno-rtti',                 -- Disable RTTI
        '-Werror=format',            -- Treat format errors as errors
        '-Wimplicit-int-conversion', -- Implicit int conversion
        '-Werror=vla'                -- Treat variable length arrays as errors
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
        defines {'KORIN_PLATFORM_MACOSX'}
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

    -- filter {'system:ios'}
    -- do
    --     links { "CoreGraphics.framework", "Cocoa.framework" }
    --     buildoptions {'-flto=full'}
    -- end

    -- filter {'system:ios', 'options:variant=system'}
    -- do
    --     buildoptions 
    --     {
    --         '-mios-version-min=10.0 -fembed-bitcode -arch armv7 -arch arm64 -arch arm64e -isysroot ' ..
    --             (os.getenv('IOS_SYSROOT') or '')
    --     }
    -- end

    -- filter {'system:ios', 'options:variant=emulator'}
    -- do
    --     buildoptions 
    --     {
    --         -- '-mios-version-min=10.0 -arch arm64 -arch x86_64 -arch i386 -isysroot ' .. (os.getenv('IOS_SYSROOT') or '')
    --         '-mios-version-min=10.0 -arch x86_64 -isysroot ' .. (os.getenv('IOS_SYSROOT') or '')
    --     }
    --     targetdir '%{cfg.system}_sim/bin/%{cfg.buildcfg}'
    --     objdir '%{cfg.system}_sim/obj/%{cfg.buildcfg}'
    -- end

    -- filter {'system:android', 'configurations:release'}
    -- do
    --     buildoptions {'-flto=full'}
    -- end

    -- filter {'system:android', 'options:arch=${cfg.architecture}'}
    -- do
    --     targetdir '%{cfg.system}/${cfg.architecture}/bin/%{cfg.buildcfg}'
    --     objdir '%{cfg.system}/${cfg.architecture}/obj/%{cfg.buildcfg}'
    -- end

    filter 'configurations:debug'
    do
        defines {'DEBUG'}
        symbols 'On'
    end

    filter 'configurations:release'
    do
        defines {'RELEASE'}
        defines {'NDEBUG'}
        optimize 'On'
    end
end

-- newoption 
-- {
--     trigger = 'variant',
--     value = 'type',
--     description = 'Choose the variant for iOS builds.',
--     allowed = 
--     {
--         {'system', 'Builds the static library for the provided system'},
--         {'emulator', 'Builds for an emulator/simulator for the provided system'}
--     },
--     default = 'system'
-- }

-- newoption 
-- {
--     trigger = 'arch',
--     value = 'ABI',
--     description = 'Choose the architecture for Android builds.',
--     allowed = 
--     {
--         {'x86'},
--         {'x64'},
--         {'arm'},
--         {'arm64'}
--     }
-- }

-- os.chdir("../scripts")