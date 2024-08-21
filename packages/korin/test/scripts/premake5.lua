workspace 'korintest'
    configurations {'debug', 'release'}

project 'korintest'
    kind 'ConsoleApp'
    language 'C++'
    cppdialect 'C++17'
    toolset 'clang'
    location '../build' --Setting the location at the project level rather than workspace level means that a Makefile is created in the directory of the premake file. Setting the location at the workspace level is ideal but breaks the process. To be solved..
    targetdir '../build/%{cfg.system}/bin/%{cfg.buildcfg}'
    objdir '../build/%{cfg.system}/obj/%{cfg.buildcfg}'
    
    files 
    {
        '../main.cpp',
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
        links { "CoreGraphics.framework", "Cocoa.framework" }
        defines {'KORIN_PLATFORM_MACOSX'}
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