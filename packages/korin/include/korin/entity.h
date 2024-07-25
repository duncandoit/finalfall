// entity.h
//
// Describes the Entity struct which is used to represent an entity in the game world 
// and the Component struct which is used to represent a component of an entity.
//
// Copyright Zachary Duncan - Duncandoit
// 7/9/2024

#pragma once

#include <memory>
#include <cstdint>
#include <string>

namespace korin
{
using EntityID = std::uint32_t;
/// Entity is an object with no behavior and whose state
/// is entirely composed of Components--other than its id.
struct Entity 
{
friend class EntityAdmin;

public:
   Entity(const std::string& resourceHandle)
      : id(Entity::getNextID()), resourceHandle(resourceHandle) 
      {}

   EntityID entityID() const { return id; }
   std::string getResourceHandle() const { return resourceHandle; }

private: 
   static const EntityID getNextID() noexcept { return m_NextID++; }

private:
   EntityID id;
   std::string resourceHandle;

   static EntityID m_NextID;
};

using EntityPtr = std::shared_ptr<Entity>;
} // namespace korin