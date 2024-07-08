// matrix2d.cpp
//
// Copyright Zachary Duncan 7/5/2024

#include "korin/math/matrix2d.h"

using namespace korin;

Matrix2D Matrix2D::fromTranslation(float tx, float ty) 
{
   Matrix2D result;
   result.m_Matrix[2] = tx; // translate_x
   result.m_Matrix[5] = ty; // translate_y
   return result;
}

Matrix2D Matrix2D::invertOrIdentity() const 
{
   float det = m_Matrix[0] * m_Matrix[4] - m_Matrix[1] * m_Matrix[3];

   // If the determinant is 0, the matrix is not invertible.
   if (det == 0) 
   {
      // A non-zero determinant means there exists another matrix that can reverse
      // the transformation applied by the original matrix. This is particularly 
      // important for operations like undoing transformations.
      return Matrix2D(); // Return identity
   }

   return {
         m_Matrix[4] / det, // scale_x
      -m_Matrix[1] / det, // skew_y
      -m_Matrix[3] / det, // skew_x
         m_Matrix[0] / det, // scale_y
      (m_Matrix[3] * m_Matrix[5] - m_Matrix[4] * m_Matrix[2]) / det, // translate_x
      (m_Matrix[1] * m_Matrix[2] - m_Matrix[0] * m_Matrix[5]) / det // translate_y
   };
}

Matrix2D Matrix2D::operator*(const Matrix2D& other) const 
{
   return {
      m_Matrix[0] * other.m_Matrix[0] + m_Matrix[1] * other.m_Matrix[3], // scale_x
      m_Matrix[0] * other.m_Matrix[1] + m_Matrix[1] * other.m_Matrix[4], // skew_y
      m_Matrix[0] * other.m_Matrix[2] + m_Matrix[1] * other.m_Matrix[5] + m_Matrix[2], // translate_x
      m_Matrix[3] * other.m_Matrix[0] + m_Matrix[4] * other.m_Matrix[3], // skew_x
      m_Matrix[3] * other.m_Matrix[1] + m_Matrix[4] * other.m_Matrix[4], // scale_y
      m_Matrix[3] * other.m_Matrix[2] + m_Matrix[4] * other.m_Matrix[5] + m_Matrix[5] // translate_y
   };
}