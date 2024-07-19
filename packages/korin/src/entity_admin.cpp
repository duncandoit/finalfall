// entity_admin.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#include "korin/entity_admin.h"
#include "korin/util/assert.h"

#include "korin/systems/movement_system.h"

using namespace korin;

EntityAdmin::EntityAdmin()
   : m_Entities(std::unordered_map<EntityID, EntityPtr>()), 
   m_Systems(std::vector<SystemPtr>()),
   m_ComponentsByType(std::unordered_map<ComponentTypeID, std::vector<ComponentPtr>>()),
   m_ComponentsByEntity(std::unordered_map<EntityID, std::vector<ComponentPtr>>()),
   m_AvailableEntityIDs(std::queue<EntityID>()), 
   m_LivingEntityCount(0)
{
   resetEntityIDQueue();
   initSystems();
}

bool EntityAdmin::addEntity(EntityPtr entity)
{
   if (entity == nullptr) 
   { 
      KORIN_DEBUG("Cannot add a null Entity.");
      return false; 
   }

   if (m_LivingEntityCount >= MAX_ENTITIES) 
   { 
      KORIN_DEBUG("Cannot add EntityID(" + std::to_string(entity->id) + "). Maximum entities reached.");
      return false;
   }

   entity->id = getAvailableEntityID();
   m_Entities.emplace(entity->id, entity);
   m_LivingEntityCount++;
   return true;
}

void EntityAdmin::removeEntity(EntityPtr entity)
{
   const auto entityComponentTypesIt = m_ComponentsByEntity.find(entity->id);
   if (entityComponentTypesIt == m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entity->id) + ") does not exist for removal.");
      return;
   }

   // Remove all components associated with entity. This maybe should be done async.
   m_ComponentsByEntity.erase(entityComponentTypesIt); 
 
   m_Entities.erase(entity->id);
   m_LivingEntityCount--;
}

bool EntityAdmin::addComponent(EntityID entityID, ComponentPtr component)
{
   if (component == nullptr) 
   { 
      KORIN_DEBUG("Cannot add a null Component.");
      return false; 
   }
   
   const auto& entityComponentTypes = m_ComponentsByEntity[entityID];
   if (entityComponentTypes.empty())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for adding component.");
      return false;
   }
   
   const auto& existingComponent = entityComponentTypes[component->typeID()];
   if (existingComponent == nullptr)
   {
      KORIN_DEBUG("ComponentTypeID(" + std::to_string(component->typeID()) + ") type already exists for entity.");
      return false;
   }
   
   for (auto& sibling : m_ComponentsByEntity[entityID])
   {
      component->addSibling(sibling);
      sibling->addSibling(component);
   }

   m_ComponentsByEntity[entityID].emplace_back(component);
   m_ComponentsByType[component->typeID()].emplace_back(component);
   return true;
}

void EntityAdmin::removeComponent(EntityID entityID, ComponentTypeID componentTypeID)
{
   const auto& entityComponentTypes = m_ComponentsByEntity[entityID];
   if (entityComponentTypes.empty())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for removing component.");
   }

   const auto& existingComponent = entityComponentTypes[componentTypeID];
   if (existingComponent != nullptr)
   {
      KORIN_DEBUG("ComponentTypeID(" + std::to_string(componentTypeID) + ") type does not exist for removal.");
   }
   
   for (auto& sibling : m_ComponentsByEntity[entityID])
   {
      if (sibling->typeID() != componentTypeID)
      {
         break;
      }

      m_ComponentsByEntity[entityID].erase(
         std::remove(
            m_ComponentsByEntity[entityID].begin(), 
            m_ComponentsByEntity[entityID].end(), 
            sibling
         ), 
         m_ComponentsByEntity[entityID].end()
      );
   }
}

ComponentPtr EntityAdmin::getComponent(EntityID entityID, ComponentTypeID componentTypeID)
{
   const auto& entityComponentTypes = m_ComponentsByEntity[entityID];
   if (entityComponentTypes.empty())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for getting component.");
      return nullptr;
   }

   const auto& component = entityComponentTypes[componentTypeID];
   if (component == nullptr)
   {
      KORIN_DEBUG("ComponentTypeID(" + std::to_string(componentTypeID) + ") does not exist on entity for retrieval.");
      return nullptr;
   }

   return component;
}

bool EntityAdmin::addSystem(SystemPtr system)
{
   if (system == nullptr) 
   { 
      KORIN_DEBUG("Cannot add a null System.");
      return false; 
   }

   if (std::find(m_Systems.begin(), m_Systems.end(), system) != m_Systems.end()) 
   { 
      KORIN_DEBUG("System already exists in admin.");
      return false;
   }
   
   m_Systems.push_back(system);
   return true;
}

void EntityAdmin::removeSystem(SystemPtr system)
{
   if (system == nullptr) 
   { 
      KORIN_DEBUG("Cannot remove a null System.");
      return; 
   }

   auto systemIt = std::find(m_Systems.begin(), m_Systems.end(), system);
   if (systemIt == m_Systems.end()) 
   { 
      KORIN_DEBUG("System does not exist in admin.");
      return;
   }

   m_Systems.erase(systemIt);
}

void EntityAdmin::updateInputSystem()
{
}

void EntityAdmin::updateSystems(float timeStep)
{
   for (auto& system : m_Systems)
   {
      const auto componentTypeID = system->primaryComponentTypeID();
      const auto& componentItr = m_ComponentsByType.find(componentTypeID);
      if (componentItr == m_ComponentsByType.end())
      {
         KORIN_DEBUG("ComponentTypeID(" + std::to_string(componentTypeID) + ") does not exist in admin.");
         continue;
      }

      // All components of the same type are updated by the system.
      for (auto& component : componentItr->second)
      {
         // Any other component that the system needs should be searched 
         // for in the siblings to this component.
         system->update(timeStep, component);
      }
   }
}

void EntityAdmin::updateRenderSystem()
{
}

void EntityAdmin::resetEntityIDQueue()
{
   m_AvailableEntityIDs = std::queue<EntityID>();
   for (EntityID i = 0; i < MAX_ENTITIES; i++)
   {
      m_AvailableEntityIDs.push(i);
   }
}

EntityID EntityAdmin::getAvailableEntityID()
{
   if (m_AvailableEntityIDs.empty())
   {
      KORIN_DEBUG("No available EntityIDs.");
      return -1;
   }

   EntityID id = m_AvailableEntityIDs.front();
   m_AvailableEntityIDs.pop();
   return id;
}

void EntityAdmin::initSystems()
{
   addSystem(std::shared_ptr<MovementSystem>());
      // TargetName
      // LifetimeEntity
      // PlayerSpawn
      // Gamelnput
      // Behavior
      // AimAtTarget
      // MouseCursorFollow
      // ParametricMovement
      // PlatformerPlayerController
      // WallCrawler
      // RaycastMovement
      // Physics
      // Grounded
      // Health
      // Socket
      // Attach
      // Camera
      // DebugEntity
      // ImageAnimation
      // Render
      // EntitySpawner
      // LifeSpan
      // SpawnOnDestroy
}