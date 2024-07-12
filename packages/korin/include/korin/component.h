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
struct Component 
{
public:
   virtual ~Component() = default;

   std::shared_ptr<Component> sibling(ComponentTypeID id) const;
   bool addSibling(std::shared_ptr<Component> component);

   virtual ComponentTypeID typeID() = 0;
   template <typename T>
   static ComponentTypeID typeID() noexcept {
      KORIN_STATIC_ASSERT(std::to_string(std::is_base_of<Component, T>::value) 
         + "T must be a subclass of Component");
      static ComponentTypeID typeID = m_NextID++;
      return typeID;
   }
   
   virtual void create(std::string resource) = 0;

private:
   static ComponentTypeID m_NextID;

   std::unordered_map<ComponentTypeID, std::shared_ptr<Component>> m_Siblings;
};

using ComponentPtr = std::shared_ptr<Component>;
} // namespace korin