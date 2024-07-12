// entity.h
//
// Describes the Entity struct which is used to represent an entity in the game world 
// and the Component struct which is used to represent a component of an entity.
//
// Copyright Zachary Duncan - Duncandoit
// 7/9/2024

#pragma once

#include <vector>
#include <memory>
#include <cstdint>
#include <string>

#include "component.h"

namespace korin
{
using EntityID = std::uint32_t;
struct Entity 
{
public:
   Entity(EntityID id, const std::string& resourceHandle)
      : id(id), resourceHandle(resourceHandle) {}

   EntityID id;
   std::string resourceHandle;
};

using EntityPtr = std::shared_ptr<Entity>;
} // namespace korin