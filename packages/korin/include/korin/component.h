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

namespace korin
{
using ComponentTypeID = std::uint32_t;
using ComponentPtr = std::shared_ptr<Component>;
struct Component 
{
public:
   virtual void create(std::string resource) = 0;
   virtual ~Component() = default;

   ComponentPtr sibling(ComponentTypeID id) const;

   static ComponentTypeID nextID(); 

private:
   std::unordered_map<ComponentTypeID, ComponentPtr> m_Siblings;
   static ComponentTypeID m_NextID;
};
} // namespace korin