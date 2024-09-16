// test_matrix2d.cpp
//
// This file contains unit tests for the Matrix2D class.
//
// Zachary Duncan - Duncandoit
// 7/7/2024

#include <iostream>

#include "korin/math/matrix2d.h"
#include "korin/util/assert.h"

void test_matrix2d() {
   // Test matrix multiplication
   korin::Matrix2D matrix1(1, 0, 0, 0, 1, 0);
   korin::Matrix2D matrix2(1, 0, 0, 0, 1, 0);
   korin::Matrix2D result = matrix1 * matrix2;
   
   KORIN_STATIC_ASSERT(result.a() == 1.0f);
   KORIN_STATIC_ASSERT(result.b() == 0.0f);
   KORIN_STATIC_ASSERT(result.tx() == 0.0f);
   KORIN_STATIC_ASSERT(result.d() == 0.0f);
   KORIN_STATIC_ASSERT(result.e() == 1.0f);
   KORIN_STATIC_ASSERT(result.ty() == 0.0f);

   korin::Matrix2D matrix3(13.4f, 4.0f, 44.8f, 0.f, 17.f, 800.26f);
   korin::Matrix2D matrix4(2.9f, 6.12f, 5.75f, 23.1f, 1.f, 76.92f);
   result = matrix3 * matrix4;

   KORIN_STATIC_ASSERT(result.a() == 13.4f * 2.9f + 4.0f * 23.1f);
   KORIN_STATIC_ASSERT(result.b() == 13.4f * 6.12f + 4.0f * 1.0f);
   KORIN_STATIC_ASSERT(result.tx() == 13.4f * 5.75f + 44.8f * 23.1f + 800.26f);
   KORIN_STATIC_ASSERT(result.d() == 0.0f);
   KORIN_STATIC_ASSERT(result.e() == 17.0f);
   KORIN_STATIC_ASSERT(result.ty() == 800.26f + 17.0f * 76.92f);

   // Test invertOrIdentity()
   korin::Matrix2D identity;
   result = identity.invertOrIdentity();
   KORIN_STATIC_ASSERT(result.a() == 1.0f);
   KORIN_STATIC_ASSERT(result.b() == 0.0f);
   KORIN_STATIC_ASSERT(result.tx() == 0.0f);
   KORIN_STATIC_ASSERT(result.d() == 0.0f);
   KORIN_STATIC_ASSERT(result.e() == 1.0f);
   KORIN_STATIC_ASSERT(result.ty() == 0.0f);

   korin::Matrix2D nonInvertible(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
   result = nonInvertible.invertOrIdentity();
   KORIN_STATIC_ASSERT(result.a() == 1.0f);
   KORIN_STATIC_ASSERT(result.b() == 0.0f);
   KORIN_STATIC_ASSERT(result.tx() == 0.0f);
   KORIN_STATIC_ASSERT(result.d() == 0.0f);
   KORIN_STATIC_ASSERT(result.e() == 1.0f);
   KORIN_STATIC_ASSERT(result.ty() == 0.0f);

   // Test fromTranslation()
   korin::Matrix2D translation = korin::Matrix2D::fromTranslation(5.0f, 10.0f);
   KORIN_STATIC_ASSERT(translation.a() == 1.0f);
   KORIN_STATIC_ASSERT(translation.b() == 0.0f);
   KORIN_STATIC_ASSERT(translation.tx() == 5.0f);
   KORIN_STATIC_ASSERT(translation.d() == 0.0f);
   KORIN_STATIC_ASSERT(translation.e() == 1.0f);
   KORIN_STATIC_ASSERT(translation.ty() == 10.0f);

   // Test operator[]
   korin::Matrix2D matrix5(1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f);
   KORIN_STATIC_ASSERT(matrix5[0] == 1.0f);
   KORIN_STATIC_ASSERT(matrix5[1] == 2.0f);
   KORIN_STATIC_ASSERT(matrix5[2] == 3.0f);
   KORIN_STATIC_ASSERT(matrix5[3] == 4.0f);
   KORIN_STATIC_ASSERT(matrix5[4] == 5.0f);
   KORIN_STATIC_ASSERT(matrix5[5] == 6.0f);
}

int main() {
   test_matrix2d();

   KORIN_INFO("Matrix2D tests passed!");

   return 0;
}