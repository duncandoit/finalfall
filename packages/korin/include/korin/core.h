// core.h
//
// Copyright (c) Zachary Duncan - Duncandoit
// 09/10/2024

#pragma once

#ifdef KORIN_PLATFORM_WINDOWS
   #ifdef KORIN_BUILD_DLL
      #define KORIN_API __declspec(dllexport)
   #else
      #define KORIN_API __declspec(dllimport)
   #endif
#endif // KORIN_PLATFORM_WINDOWS

#ifdef KORIN_PLATFORM_MACOSX
   #ifdef KORIN_BUILD_DLL
      #define KORIN_API __attribute__((visibility("default")))
   #else
      #define KORIN_API
   #endif
#endif // KORIN_PLATFORM_MACOSX