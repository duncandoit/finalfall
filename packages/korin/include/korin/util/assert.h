#pragma once

#ifdef KORIN_ASSERTIONS

#include <iostream>
#include "korin/log.h"

// Define a platform-independent debug break
#if defined(_MSC_VER)
    #define KORIN_DEBUG_BREAK() __debugbreak()
#elif defined(__GNUC__) || defined(__clang__)
    #include <signal.h>
    #define KORIN_DEBUG_BREAK() raise(SIGTRAP)
#else
    #define KORIN_DEBUG_BREAK() asm("int $3")
#endif 

// Checks expression and fails if it is false at runtime
#define KORIN_ASSERT(expr) \
   if (expr) {} \
   else \
   { \
      KORIN_FATAL("ASSERT FAILURE: {0} {1} {2}", #expr, __FILE__, __LINE__); \
      KORIN_DEBUG_BREAK(); \
   }

// Checks expression at compile time
#ifdef __cplusplus
   // We must be using C++11 or later
   #if __cplusplus >= 201103L
      #define KORIN_STATIC_ASSERT(expr) \
         static_assert(expr, "Static assertion failed: " #expr)

   // We must be using C++98 or C++03
   #else 
      #define KORIN_ASSERT_GLUE(a, b) a ## b
      #define KORIN_STATIC_ASSERT_GLUE(a, b) KORIN_ASSERT_GLUE(a, b)

      // Declare a template but only define the true case (via specialization)
      template<bool> class KorinStaticAssert;
      template<> class KorinStaticAssert<true> {};

      #define KORIN_STATIC_ASSERT(expr) \
         enum \
         { \
            KORIN_STATIC_ASSERT_GLUE(korin_assert_fail_, __LINE__) = sizeof(KorinStaticAssert<!!(expr)>) \
         }

   #endif
#endif 

// KORIN_ASSERTIONS is not defined so the assertions will be no-ops and evaluate to nothing.
#else 
   // KORIN_ASSERTIONS is not defined.
   #define KORIN_ASSERT(expr)

   // KORIN_ASSERTIONS is not defined.
   #define KORIN_STATIC_ASSERT(expr)

#endif // KORIN_ASSERTIONS