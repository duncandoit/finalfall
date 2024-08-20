// component.h
//
// Describes the Component struct which is used to represent a component of an entity.
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#pragma once

#include <memory>
#include <string>
#include <cstdint>
#include <unordered_map>

#include "korin/util/assert.h"

namespace korin
{
using ComponentTypeID = std::uint32_t;

/// Components represent modular state without any behavior that can be 
/// used to compose an Entity.
struct Component 
{
public:
   Component()
      : m_Siblings(std::unordered_map<ComponentTypeID, std::weak_ptr<Component>>()) 
      {}

   virtual ~Component() = default;

   // Create the component from a resource
   virtual void create(std::string resource) = 0;

   // Get the type ID of the component
   virtual ComponentTypeID typeID() = 0;

   // Get a sibling component by type
   template <typename T>
   std::weak_ptr<T> sibling() const
   {
      auto siblingIt = m_Siblings.find(typeID<T>());
      if (siblingIt == m_Siblings.end())
      {
         KORIN_DEBUG("ComponentTypeID:" 
            + std::to_string(typeID<T>()) 
            + " does not exist as a sibling to this Component.");

         return std::weak_ptr<T>();
      }

      // If the weak pointer to the sibling is empty, it's handled by the caller. 
      // Returning an empty weak_ptr<T> if not found.
      return std::static_pointer_cast<T>(siblingIt->second.lock());
   }

   // Add a sibling component
   bool addSibling(std::weak_ptr<Component> component)
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
         KORIN_DEBUG("ComponentTypeID:" + std::to_string(siblingPtr->typeID()) 
            + " already exists as a sibling to this Component.");
            
         return false;
      }

      m_Siblings[siblingPtr->typeID()] = component;
      return true;
   }

   // Sets the static type ID of each Component subclass
   template <typename T>
   static const ComponentTypeID typeID() noexcept 
   {
      static_assert(std::is_base_of<Component, T>::value, "T must derive from Component");
      static ComponentTypeID typeID = m_NextID++;
      return typeID;
   }

private:
   static ComponentTypeID m_NextID;
   std::unordered_map<ComponentTypeID, std::weak_ptr<Component>> m_Siblings;
};

using ComponentPtr = std::shared_ptr<Component>;
} // namespace korin