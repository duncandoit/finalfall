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

std::weak_ptr<Component> Component::sibling(ComponentTypeID id) const
{
   // TODO: Lock the mutex for thread safety

   // Check if there are any siblings
   if (m_Siblings.empty())
   {
      KORIN_DEBUG("Non-existant Component sibling accessed.");
      return std::weak_ptr<Component>();
   }

   // Find the sibling component with the specified ID
   auto siblingIt = m_Siblings.find(id);
   if (siblingIt == m_Siblings.end())
   {
      KORIN_DEBUG("Non-existant Component sibling accessed.");
      return std::weak_ptr<Component>();
   }

   // Check if the weak pointer to the sibling component is still valid
   if (auto siblingPtr = siblingIt->second.lock())
   {
      return siblingIt->second;
   }
   else
   {
      // If the weak pointer is expired, remove the entry from the map
      KORIN_DEBUG("Component sibling accessed after deletion.");
      return std::weak_ptr<Component>();
   }
}

bool Component::addSibling(std::weak_ptr<Component> component)
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