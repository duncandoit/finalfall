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

std::weak_ptr<Component> Component::siblingOfTypeID(ComponentTypeID id) const
{
   auto siblingIt = m_Siblings.find(id);
   if (siblingIt == m_Siblings.end())
   {
      KORIN_DEBUG("ComponentTypeID:" + std::to_string(id) + " does not exist as a sibling to this Component.");
      return std::weak_ptr<Component>();
   }

   // If the weak pointer to the sibling is empty, it's handled by the caller. 
   // Returning an empty weak_ptr<Component> if not found.
   return siblingIt->second;
}

bool Component::addSibling(std::weak_ptr<Component> component)
{
   // Check if the weak pointer to the sibling component is still valid
   auto siblingPtr = component.lock();
   if (siblingPtr == nullptr)
   {
      KORIN_DEBUG("Cannot add a null Component sibling.");
      return false;
   }

   if (m_Siblings.find(siblingPtr->typeID()) != m_Siblings.end())
   {
      KORIN_DEBUG("ComponentTypeID:" + std::to_string(siblingPtr->typeID()) + " already exists as a sibling to this Component.");
      return false;
   }

   m_Siblings[siblingPtr->typeID()] = component;
   return true;
}