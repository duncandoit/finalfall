// matrix2d.h
//
// This file contains the Matrix2D class which is used to represent a 2D transformation a more 
// compact 2x3 matrix specifically for affine transformations where the homogeneous coordinate 
// is implicit.
//
// Copyright Zachary Duncan 7/5/2024

#ifndef KORIN_MATRIX2D_H
#define KORIN_MATRIX2D_H

#include <cstddef>

namespace korin 
{
class Matrix2D 
{
public:
   /// Initialize to identity matrix
   /// | a, b, tx | == | scale_x, skew_y,  translate_x |
   /// | d, e, ty | == | skew_x,  scale_y, translate_y |
   ///
   Matrix2D()  : m_Matrix{1, 0, 0, 0, 1, 0} {}
   Matrix2D(const Matrix2D& copy) = default;
   Matrix2D(float a, float b, float tx, float d, float e, float ty) : 
      m_Matrix{a, b, tx, d, e, ty} {}

   
   static Matrix2D fromTranslation(float tx, float ty);

   /// Inverts the matrix if possible, otherwise returns the identity matrix.
   ///
   Matrix2D invertOrIdentity() const;

   float& operator[](std::size_t i) { return m_Matrix[i]; }

   Matrix2D operator*(const Matrix2D& other) const;

   float a() const { return m_Matrix[0]; }
   float b() const { return m_Matrix[1]; }
   float tx() const { return m_Matrix[2]; }
   float d() const { return m_Matrix[3]; }
   float e() const { return m_Matrix[4]; }
   float ty() const { return m_Matrix[5]; }

   void a(float value) { m_Matrix[0] = value; }
   void b(float value) { m_Matrix[1] = value; }
   void tx(float value) { m_Matrix[2] = value; }
   void d(float value) { m_Matrix[3] = value; }
   void e(float value) { m_Matrix[4] = value; }
   void ty(float value) { m_Matrix[5] = value; }

private:
   float m_Matrix[6];
};
} // namespace korin

#endif // KORIN_MATRIX2D_H