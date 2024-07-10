// component.cpp
//
// Brief description
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-10

#include "korin/component.h"

namespace korin
{
   ComponentTypeID Component::m_NextID = 0;
} // namespace korin

using namespace korin;

ComponentPtr Component::sibling(ComponentTypeID id) const
{
   auto sibling = m_Siblings.find(id);

   if (sibling != m_Siblings.end())
   {
      return sibling->second;
   }
   
   return nullptr;
}

ComponentTypeID Component::nextID()
{
   return m_NextID++;
}