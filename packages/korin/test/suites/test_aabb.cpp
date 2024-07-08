// test_aabb.cpp
//
// This file contains unit tests for the AABB class.
//
// Zachary Duncan - Duncandoit
// 7/7/2024

#include <iostream>

#include "korin/math/aabb.h"
#include "korin/math/vector2d.h"
#include "korin/util/assert.h"

void test_aabb() {
   // Test getCorners()
   korin::AABB aabb(0.0f, 0.0f, 2.0f, 2.0f);
   std::vector<std::pair<float, float>> corners = aabb.getCorners();
   KORIN_STATIC_ASSERT(corners.size() == 4);
   KORIN_STATIC_ASSERT(corners[0] == std::make_pair(0.0f, 0.0f));
   KORIN_STATIC_ASSERT(corners[1] == std::make_pair(2.0f, 0.0f));
   KORIN_STATIC_ASSERT(corners[2] == std::make_pair(2.0f, 2.0f));
   KORIN_STATIC_ASSERT(corners[3] == std::make_pair(0.0f, 2.0f));

   // Test center()
   korin::Vector2D center = aabb.center();
   KORIN_STATIC_ASSERT(center.getX() == 1.0f);
   KORIN_STATIC_ASSERT(center.getY() == 1.0f);

   // Test width()
   float width = aabb.width();
   KORIN_STATIC_ASSERT(width == 2.0f);

   // Test height()
   float height = aabb.height();
   KORIN_STATIC_ASSERT(height == 2.0f);

   // Test size()
   float size = aabb.size();
   KORIN_STATIC_ASSERT(size == 4.0f);

   // Test contains()
   korin::Vector2D pointInside(1.0f, 1.0f);
   KORIN_STATIC_ASSERT(aabb.contains(pointInside));

   korin::Vector2D pointOutside(3.0f, 3.0f);
   KORIN_STATIC_ASSERT(!aabb.contains(pointOutside));

   // Test intersects()
   korin::AABB intersectingAABB(1.5f, 1.5f, 3.0f, 3.0f);
   KORIN_STATIC_ASSERT(aabb.intersects(intersectingAABB));

   korin::AABB nonIntersectingAABB(3.0f, 3.0f, 4.0f, 4.0f);
   KORIN_STATIC_ASSERT(!aabb.intersects(nonIntersectingAABB));

   // Test operator==
   korin::AABB equalAABB(0.0f, 0.0f, 2.0f, 2.0f);
   KORIN_STATIC_ASSERT(aabb == equalAABB);

   korin::AABB notEqualAABB(1.0f, 1.0f, 3.0f, 3.0f);
   KORIN_STATIC_ASSERT(!(aabb == notEqualAABB));

   // Test operator!=
   KORIN_STATIC_ASSERT(aabb != notEqualAABB);
   KORIN_STATIC_ASSERT(!(aabb != equalAABB));

   // Test expandToInclude()
   korin::Vector2D pointToInclude(3.0f, 3.0f);
   aabb.expandToInclude(pointToInclude);
   KORIN_STATIC_ASSERT(aabb.maxX == 3.0f);
   KORIN_STATIC_ASSERT(aabb.maxY == 3.0f);
}

int main() {
   test_aabb();

   std::cout << "AABB tests passed!" << std::endl;

   return 0;
}