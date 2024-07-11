// entity_admin.h
//
// Describes the EntityAdmin class which is used to manage entities 
// and systems in the game world.
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#pragma once

#include <unordered_map>
#include <queue>
#include <vector>
#include <memory>

#include "korin/entity.h"
#include "korin/component.h"
#include "korin/system.h"

namespace korin
{
class EntityAdmin 
{
public:
   // Adds an entity to the admin
   bool addEntity(const EntityPtr entity);

   // Removes an entity from the admin
   void removeEntity(const EntityPtr entity);

   // Adds a component relative to an entity to the admin
   bool addComponent(EntityID entityID, ComponentPtr component);

   // Removes a component relative to an entity from the admin
   void removeComponent(EntityID entityID, ComponentTypeID componentTypeID);

   // Gets a component relative to an entity from the admin
   ComponentPtr getComponent(EntityID entityID, ComponentTypeID componentTypeID);

   // Adds a system to the admin
   bool addSystem(SystemPtr system);

   // Removes a system from the admin
   void removeSystem(SystemPtr system);

   // Updates all systems with the given time step
   void updateSystems(float ts);

private:
   void resetEntityIDQueue();
   EntityID getAvailableEntityID();

   std::unordered_map<EntityID, std::unordered_map<ComponentTypeID, ComponentPtr>> m_ComponentsByEntity;
   std::unordered_map<ComponentTypeID, std::vector<ComponentPtr>> m_ComponentsByType;
   std::unordered_map<EntityID, EntityPtr> m_Entities;
   std::vector<SystemPtr> m_Systems;

   std::queue<EntityID> m_AvailableEntityIDs;
   std::uint32_t m_LivingEntityCount = 0;

   static const std::uint32_t MAX_ENTITIES = 5000;
};
}