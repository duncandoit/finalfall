// vector2d.cpp
//
// Copyright Zachary Duncan 7/5/2024

#include "korin/math/vector2d.h"
#include <math.h>

using namespace korin;

Vector2D Vector2D::normalized() const
{
   float len = length();
   if (len != 0)
   {
      return Vector2D(x / len, y / len);
   }
   else
   {
      return Vector2D();
   }
}

float Vector2D::length() const
{
   return sqrt(x * x + y * y);
}

float Vector2D::nomalizedLength() const
{
   return length() / sqrt(2);
}

float Vector2D::dot(const Vector2D& a, const Vector2D& b)
{
   // This operation results in a scalar (a single floating-point number in this context) 
   // that represents the magnitude of one vector in the direction of the other.
   return a.x * b.x + a.y * b.y;
}

float Vector2D::cross(const Vector2D& a, const Vector2D& b)
{
   // This operation results in a scalar that represents the magnitude of one 
   // vector perpendicular to the other.
   return a.x * b.y - a.y * b.x;
}

float Vector2D::distance(const Vector2D& a, const Vector2D& b)
{
   float dx = b.x - a.x;
   float dy = b.y - a.y;
   return sqrt(dx * dx + dy * dy);
}

float Vector2D::distanceSquared(const Vector2D& a, const Vector2D& b)
{
   float dx = b.x - a.x;
   float dy = b.y - a.y;
   return dx * dx + dy * dy;
}

Vector2D Vector2D::lerp(const Vector2D& a, const Vector2D& b, float t)
{
   return Vector2D(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
}

Vector2D Vector2D::operator+(const Vector2D& other) const
{
   return Vector2D(x + other.x, y + other.y);
}

Vector2D Vector2D::operator-(const Vector2D& other) const
{
   return Vector2D(x - other.x, y - other.y);
}

Vector2D Vector2D::operator*(float scalar) const
{
   return Vector2D(x * scalar, y * scalar);
}

Vector2D Vector2D::operator/(float scalar) const
{
   return Vector2D(x / scalar, y / scalar);
}

bool Vector2D::operator==(const Vector2D& other) const
{
   return x == other.x && y == other.y;
}

bool Vector2D::operator!=(const Vector2D& other) const
{
   return !(*this == other);
}