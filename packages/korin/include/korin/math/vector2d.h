// vector2d.h
//
// This file contains the Vector2D class which is used to represent a 2D 
// vector in Cartesian coordinate system.
//
// Copyright Zachary Duncan 7/5/2024

#ifndef KORIN_VECTOR2D_H
#define KORIN_VECTOR2D_H

namespace korin
{

/// @class Vector2D
/// @brief Represents a 2D vector in Cartesian coordinate system.
////
class Vector2D
{
public:
   float x, y;

   Vector2D() : x(0), y(0) {}
   Vector2D(float x, float y) : x(x), y(y) {}
   Vector2D(const Vector2D& copy) = default;

   
   /// @brief Calculates the normalized vector.
   /// @return The normalized vector.
   ///
   Vector2D normalized() const;

   
   /// @brief Calculates the length of the vector.
   /// @return The length of the vector.
   ///
   float length() const;

   
   /// @brief Calculates the normalized length of the vector.
   /// @return The normalized length of the vector.
   ////
   float nomalizedLength() const;

   
   /// @brief Calculates the dot product of two vectors.
   /// @param a The first vector.
   /// @param b The second vector.
   /// @return The dot product of the two vectors.
   ///
   static float dot(const Vector2D& a, const Vector2D& b);

   
   /// @brief Calculates the cross product of two vectors.
   /// @param a The first vector.
   /// @param b The second vector.
   /// @return The cross product of the two vectors.
   ///
   static float cross(const Vector2D& a, const Vector2D& b);

   
   /// @brief Calculates the distance between two vectors.
   /// @param a The first vector.
   /// @param b The second vector.
   /// @return The distance between the two vectors.
   ///
   static float distance(const Vector2D& a, const Vector2D& b);

   
   /// @brief Calculates the squared distance between two vectors.
   /// @param a The first vector.
   /// @param b The second vector.
   /// @return The squared distance between the two vectors.
   ///
   static float distanceSquared(const Vector2D& a, const Vector2D& b);

   /// @brief Performs linear interpolation between two vectors.
   /// @param a The starting vector.
   /// @param b The ending vector.
   /// @param t The interpolation parameter (between 0 and 1).
   /// @return The interpolated vector.
   ///
   static Vector2D lerp(const Vector2D& a, const Vector2D& b, float t);

   Vector2D operator+(const Vector2D& other) const;
   Vector2D operator-(const Vector2D& other) const;
   Vector2D operator*(float scalar) const;
   Vector2D operator/(float scalar) const;
   bool operator==(const Vector2D& other) const;
   bool operator!=(const Vector2D& other) const;
};
} // namespace korin

#endif // KORIN_VECTOR2D_H