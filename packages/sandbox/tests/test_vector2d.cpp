// test_vector2d.cpp
//
// This file contains unit tests for the Vector2D class.
//
// Zachary Duncan - Duncandoit
// 7/7/2024

#include <iostream>

#include "korin/math/vector2d.h"
#include "korin/util/assert.h"

void test_vector2d() {
   // Test x and y values
   korin::Vector2D v1(2.0f, 3.0f);
   KORIN_STATIC_ASSERT(v1.x == 2.0f);
   KORIN_STATIC_ASSERT(v1.y == 3.0f);

   // Test operator==
   korin::Vector2D v2(2.0f, 3.0f);
   KORIN_STATIC_ASSERT(v1 == v2);
   
   korin::Vector2D v3(6.0f, 7.0f);
   KORIN_STATIC_ASSERT(!(v1 == v3));

   // Test operator!=
   KORIN_STATIC_ASSERT(v1 != v3);
   KORIN_STATIC_ASSERT(!(v1 != v2));
}

int main() {
   test_vector2d();

   KORIN_INFO("Vector2D tests passed!");

   return 0;
}