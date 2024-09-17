KORIN_DIR = path.getabsolute('..')

workspace 'korin' do
    startproject 'korin'
    configurations {'debug', 'release', 'dist'}
    location (KORIN_DIR ..'/build')
end

-- The generated library will use this name and append 'lib'
project 'korin' do
    kind 'SharedLib'
    staticruntime 'on'
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
        KORIN_DIR .. '/dependencies/submodules/spdlog/include'    -- spdlog
        -- KORIN_DIR ..'/dependencies/%{cfg.system}/glfw/include',  -- GLFW
    }
    libdirs 
    {
        KORIN_DIR .. '/dependencies/submodules/spdlog/build'   -- spdlog
        -- KORIN_DIR ..'/dependencies/%{cfg.system}/glfw', -- GLFW
    }
    links 
    {
        'spdlog'           -- spdlog
        -- 'glfw3',           -- GLFW
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
        'SPDLOG_COMPILED_LIB',         -- Required when using spdlog as a static library'
        'KORIN_BUILD_SHAREDLIB',       -- Allows the core KORIN_API to adjust to using a shared library 
        'KORIN_ASSERTIONS',            -- Enable asserts
    }

    filter 'configurations:debug' do
        symbols 'On'
        defines 
        {
            'KORIN_DEBUG',
        }
    end

    filter 'configurations:release' do
        optimize 'On'
        defines 
        {
            'KORIN_RELEASE',
            'KORIN_NDEBUG',
        }
    end

    filter 'configurations:dist' do
        optimize 'On'
        defines 
        {
            'KORIN_DIST',
            'KORIN_NDEBUG',
        }
    end

    filter {'system:macosx'} do
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

    filter {'system:macosx', 'configurations:release'} do
        buildoptions {'-flto=full'}
    end

    filter 'system:windows' do
        architecture 'x64'
        runtime 'Release'
        defines 'KORIN_PLATFORM_WINDOWS'
        flags 'FatalCompileWarnings'
        links
        {
            -- '../dependencies/windows/glfw/glfw3.lib'
        }
        buildoptions 
        {
            '/MT',                                 -- Multi-threaded runtime
            'WINDOWS_CLANG_CL_SUPPRESSED_WARNINGS' -- Suppress warnings for clang-cl
        }
        removebuildoptions 
        {
            '-fno-exceptions',
            '-fno-rtti'
        }
    end
end 