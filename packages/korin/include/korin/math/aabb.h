// aabb.h
//
// This file contains the AABB class, which represents an axis-aligned bounding box.
//
// Copyright Zachary Duncan 7/5/2024

#ifndef KORIN_AABB_H
#define KORIN_AABB_H

#include <vector>
#include <utility>

namespace korin 
{
class Vector2D;

class AABB 
{
public:
   float minX, minY;
   float maxX, maxY;

   AABB(float minX, float minY, float maxX, float maxY)
      : minX(minX), minY(minY), maxX(maxX), maxY(maxY) {}

   std::vector<std::pair<float, float>> getCorners() const;

   Vector2D center() const;

   float width() const;

   float height() const;

   float size() const;

   bool contains(const Vector2D& point) const;

   bool intersects(const AABB& other) const;

   bool operator==(const AABB& other) const;

   bool operator!=(const AABB& other) const;

   void expandToInclude(const Vector2D& point);
};
} // namespace korin

#endif // KORIN_AABB_H