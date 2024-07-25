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
   initSystems();
}

EntityAdmin::~EntityAdmin()
{
   m_Entities.clear();
   m_Systems.clear();
   m_ComponentsByType.clear();
   m_ComponentsByEntity.clear();
   m_AvailableEntityIDs = std::queue<EntityID>();
   m_LivingEntityCount = 0;
}

EntityPtr EntityAdmin::createEntity(const std::string& resourceHandle)
{
   KORIN_DEBUG("Creating Entity with resource handle: " + resourceHandle);

   EntityPtr entity = std::make_shared<Entity>(resourceHandle);
   if (!entity) 
   { 
      KORIN_DEBUG("Cannot add a null Entity.");
      return EntityPtr(); 
   }

   if (m_LivingEntityCount >= MAX_ENTITIES) 
   { 
      KORIN_DEBUG("Cannot add EntityID(" + std::to_string(entity->entityID()) + "). Maximum entities reached.");
      return EntityPtr();
   }

   KORIN_DEBUG("Adding EntityID(" + std::to_string(entity->entityID()) + ") to admin.");

   m_Entities[entity->entityID()] = entity;
   m_ComponentsByEntity[entity->entityID()] = std::vector<ComponentPtr>();
   m_LivingEntityCount++;

   return entity;
}

void EntityAdmin::removeEntity(EntityPtr entity)
{
   const auto entityComponentTypesIt = m_ComponentsByEntity.find(entity->entityID());
   if (entityComponentTypesIt == m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("Entity(" + std::to_string(entity->entityID()) + ") does not exist for removal.");
      return;
   }

   // Remove all components associated with entity. This maybe should be done async.
   m_ComponentsByEntity.erase(entityComponentTypesIt); 
 
   m_Entities.erase(entity->entityID());
   m_LivingEntityCount--;
}

bool EntityAdmin::addComponent(EntityID entityID, ComponentPtr component)
{
   KORIN_DEBUG("Adding Component to EntityID(" + std::to_string(entityID) + ").");

   if (!component) 
   { 
      KORIN_DEBUG("Cannot add a null Component.");
      return false; 
   }

   auto entityComponentsIt = m_ComponentsByEntity.find(entityID);
   if (entityComponentsIt == m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for adding component.");
      return false;
   }

   auto& entityComponentTypes = entityComponentsIt->second;

   // Check if the component type already exists
   for (const auto& existingComponent : entityComponentTypes)
   {
      if (existingComponent->typeID() == component->typeID())
      {
         KORIN_DEBUG("ComponentType(" + std::to_string(component->typeID()) + ") type already exists for entity.");
         return false;
      }
   }

   // Add siblings
   for (auto& sibling : entityComponentTypes)
   {
      component->addSibling(sibling);
      sibling->addSibling(component);
   }

   entityComponentTypes.emplace_back(component);
   m_ComponentsByType[component->typeID()].emplace_back(component);
   return true;
}

void EntityAdmin::removeComponent(EntityID entityID, ComponentTypeID componentTypeID)
{
   const auto& entityComponentTypes = m_ComponentsByEntity[entityID];
   if (entityComponentTypes.empty())
   {
      KORIN_DEBUG("Entity(" + std::to_string(entityID) + ") does not exist for removing component.");
   }

   const auto& existingComponent = entityComponentTypes[componentTypeID];
   if (existingComponent)
   {
      KORIN_DEBUG("ComponentType(" + std::to_string(componentTypeID) + ") type does not exist for removal.");
   }
   
   for (auto& sibling : m_ComponentsByEntity[entityID])
   {
      if (sibling->typeID() != componentTypeID)
      {
         break;
      }

      m_ComponentsByEntity[entityID].erase(
         std::remove(m_ComponentsByEntity[entityID].begin(), m_ComponentsByEntity[entityID].end(), sibling), 
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
   if (!component)
   {
      KORIN_DEBUG("ComponentType(" + std::to_string(componentTypeID) + ") does not exist on entity for retrieval.");
      return nullptr;
   }

   return component;
}

bool EntityAdmin::addSystem(const SystemPtr& system)
{
   if (!system) 
   { 
      KORIN_DEBUG("Cannot add a null System.");
      KORIN_ASSERT(system);
      return false; 
   }

   if (std::find(m_Systems.begin(), m_Systems.end(), system) != m_Systems.end()) 
   { 
      KORIN_DEBUG("System already exists in admin.");
      return false;
   }

   KORIN_DEBUG("Adding System to admin.");
   
   m_Systems.push_back(system);
   return true;
}

void EntityAdmin::removeSystem(SystemPtr system)
{
   if (!system) 
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

   m_Systems.erase(
      std::remove(m_Systems.begin(), m_Systems.end(), system), m_Systems.end()
   );
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
         KORIN_DEBUG("ComponentType(" + std::to_string(componentTypeID) + ") does not exist for System update.");
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

void EntityAdmin::initSystems()
{
   auto movement = std::make_shared<MovementSystem>();
   addSystem(movement);

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