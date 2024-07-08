// aabb.cpp
//
// Copyright Zachary Duncan 7/5/2024

#include <vector>
#include <utility>
#include <algorithm>

#include "korin/math/aabb.h"
#include "korin/math/vector2d.h"

using namespace korin;

std::vector<std::pair<float, float>> AABB::getCorners() const 
{
   return {
      {minX, minY},
      {maxX, minY},
      {maxX, maxY},
      {minX, maxY}
   };
}

Vector2D AABB::center() const 
{
   return {(minX + maxX) / 2, (minY + maxY) / 2};
}

float AABB::width() const 
{
   return maxX - minX;
}

float AABB::height() const 
{
   return maxY - minY;
}

float AABB::size() const 
{
   return width() * height();
}

bool AABB::contains(const Vector2D& point) const 
{
   return point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY;
}

bool AABB::intersects(const AABB& other) const 
{
   return minX <= other.maxX && maxX >= other.minX && minY <= other.maxY && maxY >= other.minY;
}

bool AABB::operator==(const AABB& other) const 
{
   return minX == other.minX && minY == other.minY && maxX == other.maxX && maxY == other.maxY;
}

bool AABB::operator!=(const AABB& other) const 
{
   return !(*this == other);
}

void AABB::expandToInclude(const Vector2D& point) 
{
   minX = std::min(minX, point.x);
   minY = std::min(minY, point.y);
   maxX = std::max(maxX, point.x);
   maxY = std::max(maxY, point.y);
}