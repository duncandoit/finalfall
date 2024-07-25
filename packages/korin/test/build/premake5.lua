-- local suitename = _OPTIONS["suite-name"] or "aabb.cpp" -- default path

workspace 'korintest'
configurations {'debug', 'release'}

project 'korintest'
    kind 'ConsoleApp'
    language 'C++'
    cppdialect 'C++17'
    toolset 'clang'
    targetdir '%{cfg.system}/bin/%{cfg.buildcfg}'
    objdir '%{cfg.system}/obj/%{cfg.buildcfg}'
    
    files 
    {
        '../../test/main.cpp',
        '../../src/**.cpp',
        '../../src/**.h',
    }

    includedirs 
    {
        '../../include'
    }

    buildoptions 
    {
        '-Wall',
        '-fno-exceptions',
        '-fno-rtti',
        '-Werror=format',
        '-Wimplicit-int-conversion',
        '-Werror=vla'
    }

    filter {'system:macosx'}
        buildoptions 
        {
            '-Wimplicit-float-conversion',
            '-arch x86_64'
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