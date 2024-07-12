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
   if (sibling == m_Siblings.end())
   {
      return nullptr;
   }
   
   return sibling->second;
}

bool Component::addSibling(ComponentPtr component)
{
   if (m_Siblings.size() == 0)
   {
      m_Siblings.emplace(component->typeID(), component);
      return false;
   }

   if (m_Siblings.find(component->typeID()) == m_Siblings.end())
   {
      m_Siblings[component->typeID()] = component;
      return true;
   }

   return false;
}

ComponentTypeID Component::nextID()
{
   return m_NextID++;
}