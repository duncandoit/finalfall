// assert.h
//
// Defines macors for assertions and debugging.
//
// Zachary Duncan - Duncandoit
// 7/7/2024

#if ASSERTIONS_ENABLED

// Defines inline assembly that causes a runtime break into the debugger
#define debugBreak asm { int 3 }

// Checks expression and fails if it is false at runtime
#define KORIN_ASSERT(expr) \
   if (expr) {} \
   else \
   { \
      reportAssertionFailure(#expr, __FILE__, __LINE__); \
      debugBreak; \
   }

// Checks expression at compile time
#ifdef __cplusplus
   // We must be using C++11 or later
   #if __cplusplus >= 201103L
      #define KORIN_STATIC_ASSERT(expr) \
         static_assert(expr, "Static assertion failed: " #expr)

   // We must be using C++98 or C++03
   #else 
      #define _ASSERT_GLUE(a, b) a ## b
      #define ASSERT_GLUE(a, b) _ASSERT_GLUE(a, b)

      // Declare a template but only define the true case (via specialization)
      template<bool> class KorinStaticAssert;
      template<> class KorinStaticAssert<true> {};

      #define KORIN_STATIC_ASSERT(expr) \
         enum \
         { \
            ASSERT_GLUE(g_assert_fail_, __LINE__) = sizeof(KorinStaticAssert<!!(expr)>) \
         }

   #endif
#endif

#define KORIN_DEBUG(expr) \
   if (expr) {} \
   else \
   { \
      reportAssertionFailure(#expr, __FILE__, __LINE__); \
   }

// ASSERTIONS_ENABLED != 1
#else 
   // Evaluates to nothing making the assertion check a no-op
   #define KORIN_ASSERT(expr)
   #define KORIN_STATIC_ASSERT(expr)
   #define KORIN_DEBUG(expr)

#endif // ASSERTIONS_ENABLED


