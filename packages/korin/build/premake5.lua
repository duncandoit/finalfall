workspace 'korin'
configurations {'debug', 'release'}

project 'korin'
do
    kind 'StaticLib'
    language 'C++'
    cppdialect 'C++17'
    toolset 'clang'
    targetdir '%{cfg.system}/bin/%{cfg.buildcfg}'
    objdir '%{cfg.system}/obj/%{cfg.buildcfg}'
    includedirs {
        '../include'
    }

    files {'../src/**.cpp'}

    buildoptions {
        '-Wall',
        '-fno-exceptions',
        '-fno-rtti',
        '-Werror=format',
        '-Wimplicit-int-conversion',
        '-Werror=vla'
    }

    filter {'system:macosx'}
    do
        buildoptions {
            -- this triggers too much on linux, so just enable here for now
            '-Wimplicit-float-conversion'
        }
    end
    filter {'system:macosx', 'configurations:release'}
    do
        buildoptions {'-flto=full'}
    end
    filter {'system:ios'}
    do
        buildoptions {'-flto=full'}
    end
    filter 'system:windows'
    do
        architecture 'x64'
        defines {'_USE_MATH_DEFINES'}
        flags {'FatalCompileWarnings'}
        buildoptions {WINDOWS_CLANG_CL_SUPPRESSED_WARNINGS}
        staticruntime 'on'
        runtime 'Release'
        removebuildoptions {
            '-fno-exceptions',
            '-fno-rtti'
        }
    end
    filter {'system:ios', 'options:variant=system'}
    do
        buildoptions {
            '-mios-version-min=10.0 -fembed-bitcode -arch armv7 -arch arm64 -arch arm64e -isysroot ' ..
                (os.getenv('IOS_SYSROOT') or '')
        }
    end
    filter {'system:ios', 'options:variant=emulator'}
    do
        buildoptions {
            '-mios-version-min=10.0 -arch arm64 -arch x86_64 -arch i386 -isysroot ' .. (os.getenv('IOS_SYSROOT') or '')
        }
        targetdir '%{cfg.system}_sim/bin/%{cfg.buildcfg}'
        objdir '%{cfg.system}_sim/obj/%{cfg.buildcfg}'
    end

    filter {'system:android', 'configurations:release'}
    do
        buildoptions {'-flto=full'}
    end

    filter {'system:android', 'options:arch=x86'}
    do
        targetdir '%{cfg.system}/x86/bin/%{cfg.buildcfg}'
        objdir '%{cfg.system}/x86/obj/%{cfg.buildcfg}'
    end

    filter {'system:android', 'options:arch=x64'}
    do
        targetdir '%{cfg.system}/x64/bin/%{cfg.buildcfg}'
        objdir '%{cfg.system}/x64/obj/%{cfg.buildcfg}'
    end
    filter {'system:android', 'options:arch=arm'}
    do
        targetdir '%{cfg.system}/arm/bin/%{cfg.buildcfg}'
        objdir '%{cfg.system}/arm/obj/%{cfg.buildcfg}'
    end
    filter {'system:android', 'options:arch=arm64'}
    do
        targetdir '%{cfg.system}/arm64/bin/%{cfg.buildcfg}'
        objdir '%{cfg.system}/arm64/obj/%{cfg.buildcfg}'
    end
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

newoption {
    trigger = 'variant',
    value = 'type',
    description = 'Choose a build variant.',
    allowed = {
        {'system', 'Builds the static library for the provided system'},
        {'emulator', 'Builds for an emulator/simulator for the provided system'}
    },
    default = 'system'
}

newoption {
    trigger = 'arch',
    value = 'ABI',
    description = 'The ABI with the right toolchain for this build, generally with Android',
    allowed = {
        {'x86'},
        {'x64'},
        {'arm'},
        {'arm64'}
    }
}