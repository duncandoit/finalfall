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
   Component() = default;
   virtual ~Component() = default;

   // Create the component from a resource
   virtual void create(std::string resource) = 0;

   // Get the type ID of the component
   virtual ComponentTypeID typeID() = 0;

   // Get a sibling component by ID
   std::weak_ptr<Component> sibling(ComponentTypeID id) const;

   // Add a sibling component
   bool addSibling(std::weak_ptr<Component> component);

   // Sets the static type ID of each Component subclass
   template <typename T>
   static const ComponentTypeID typeID() noexcept 
   {
      KORIN_STATIC_ASSERT(std::to_string(std::is_base_of<Component, T>::value) 
         + "T must be a subclass of Component");
      static ComponentTypeID typeID = m_NextID++;
      return typeID;
   }

private:
   static ComponentTypeID m_NextID;
   std::unordered_map<ComponentTypeID, std::weak_ptr<Component>> m_Siblings;
};

using ComponentPtr = std::shared_ptr<Component>;
} // namespace korin