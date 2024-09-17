SANDBOX_DIR = path.getabsolute('..')
KORIN_DIR = path.getabsolute('../../korin')
TARGET_DIR = '/build/%{cfg.system}/bin/%{cfg.buildcfg}'

workspace 'sandbox' do
    configurations {'debug', 'release'}
    location (SANDBOX_DIR .. '/build')
end

project 'sandbox' do
    kind 'ConsoleApp'
    language 'C++'
    cppdialect 'C++17'
    toolset 'clang'
    location '.'
    targetdir (SANDBOX_DIR .. TARGET_DIR)
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
        KORIN_DIR .. '/dependencies/submodules/spdlog/include'   -- spdlog
        -- KORIN_DIR .. '/dependencies/%{cfg.system}/glfw/include'  -- GLFW
    }
    libdirs {
        KORIN_DIR .. TARGET_DIR,                               -- libkorin
    }
    links
    {
        'korin',
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
    defines
    {
        'KORIN_ASSERTIONS',          -- Enable assertions
    }

    filter 'configurations:debug' do
        symbols 'On'
        defines 
        {
            'KORIN_DEBUG'
        }
    end

    filter 'configurations:release' do
        optimize 'On'
        defines 
        {
            'KORIN_RELEASE',
            'KORIN_NDEBUG'
        }
    end

    filter 'configurations:dist' do
        optimize 'On'
        defines 
        {
            'KORIN_DIST',
            'KORIN_NDEBUG'
        }
    end
    
    filter {'system:macosx'} do
        defines {'KORIN_PLATFORM_MACOSX'}
        linkoptions
        {
            '-Wl,-rpath,' .. KORIN_DIR .. TARGET_DIR -- RPATH for dynamic linking
        }
        buildoptions 
        {
            '-Wimplicit-float-conversion',
            '-arch x86_64',
            -- '-arch arm64'
        }
    end

    filter {'system:macosx', 'configurations:release'} do
        buildoptions {'-flto=full'}
    end
end