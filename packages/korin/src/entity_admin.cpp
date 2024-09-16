// entity_admin.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#include "korin/entity_admin.h"
#include "korin/log.h"
#include "korin/util/assert.h"
#include "korin/systems/movement_system.h"
#include "korin/systems/game_input_system.h"
#include "korin/systems/render_system.h"

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
   KORIN_CORE_INFO("Creating Entity with resource handle: " + resourceHandle);

   EntityPtr entity = std::make_shared<Entity>(resourceHandle);
   if (!entity) 
   { 
      KORIN_CORE_WARN("Cannot add a null Entity.");
      return EntityPtr(); 
   }

   if (m_LivingEntityCount >= MAX_ENTITIES) 
   { 
      KORIN_CORE_WARN("Cannot add EntityID(" + std::to_string(entity->entityID()) + "). Maximum entities reached.");
      return EntityPtr();
   }

   KORIN_CORE_INFO("Adding EntityID(" + std::to_string(entity->entityID()) + ") to admin.");

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
      KORIN_CORE_WARN("Entity(" + std::to_string(entity->entityID()) + ") does not exist for removal.");
      return;
   }

   // Remove all components associated with entity. This maybe should be done async.
   m_ComponentsByEntity.erase(entityComponentTypesIt); 
 
   m_Entities.erase(entity->entityID());
   m_LivingEntityCount--;
}

bool EntityAdmin::addComponent(EntityID entityID, ComponentPtr component)
{
   KORIN_CORE_INFO("Adding Component to EntityID(" + std::to_string(entityID) + ").");

   if (!component) 
   { 
      KORIN_CORE_WARN("Cannot add a null Component.");
      return false; 
   }

   auto entityComponentsIt = m_ComponentsByEntity.find(entityID);
   if (entityComponentsIt == m_ComponentsByEntity.end())
   {
      KORIN_CORE_WARN("EntityID(" + std::to_string(entityID) + ") does not exist for adding component.");
      return false;
   }

   auto& entityComponentTypes = entityComponentsIt->second;

   // Check if the component type already exists
   for (const auto& existingComponent : entityComponentTypes)
   {
      if (existingComponent->typeID() == component->typeID())
      {
         KORIN_CORE_WARN("ComponentType(" + std::to_string(component->typeID()) + ") type already exists for entity.");
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
      KORIN_CORE_WARN("Entity(" + std::to_string(entityID) + ") does not exist for removing component.");
   }

   const auto& existingComponent = entityComponentTypes[componentTypeID];
   if (existingComponent)
   {
      KORIN_CORE_WARN("ComponentType(" + std::to_string(componentTypeID) + ") type does not exist for removal.");
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
      KORIN_CORE_WARN("EntityID(" + std::to_string(entityID) + ") does not exist for getting component.");
      return nullptr;
   }

   const auto& component = entityComponentTypes[componentTypeID];
   if (!component)
   {
      KORIN_CORE_WARN("ComponentType(" + std::to_string(componentTypeID) + ") does not exist on entity for retrieval.");
      return nullptr;
   }

   return component;
}

bool EntityAdmin::addSystem(const SystemPtr& system)
{
   if (!system) 
   { 
      KORIN_CORE_WARN("Cannot add a null System.");
      KORIN_ASSERT(system);
      return false; 
   }

   if (std::find(m_Systems.begin(), m_Systems.end(), system) != m_Systems.end()) 
   { 
      KORIN_CORE_WARN("System already exists in admin.");
      return false;
   }

   KORIN_CORE_INFO("Adding System to admin.");
   
   m_Systems.push_back(system);
   return true;
}

void EntityAdmin::removeSystem(SystemPtr system)
{
   if (!system) 
   { 
      KORIN_CORE_WARN("Cannot remove a null System.");
      return; 
   }

   auto systemIt = std::find(m_Systems.begin(), m_Systems.end(), system);
   if (systemIt == m_Systems.end()) 
   { 
      KORIN_CORE_WARN("System does not exist in admin.");
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
         KORIN_CORE_WARN("ComponentType(" + std::to_string(componentTypeID) + ") does not exist for System update.");
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
   auto gameInput = std::make_shared<GameInputSystem>();
   addSystem(gameInput);

   // Observer
   // Fixed update
   // World state
   // Game mode
   // AI point find
   // Path data invalidate
   // Weapon staging
   // View target
   // Possession
   // Command
   // Movement volume
   // AI Strategic
   // AI path find
   // AI behavior
   // AI Spawn
   // AI movement

   auto movementState = std::make_shared<MovementSystem>();
   addSystem(movementState);

   // Simple movement
   // Unsynchronized movement
   // Local player movement
   // Movement exertion
   // AI perception
   // Weapon aim
   // Weapon
   // Debug
   // Animation
   // Finish async work animation
   // Weapon post simulation
   // Combat
   // Stats
   // Hero
   // Seen by
   // Idle animation 
   // Mover effect
   // Spacial query
   // Camera
   // POV
   // Map
   // Sound
   // Local hit effects
   // Hero full body effects
   // Update scene view flags
   // Resolve contact
   // Interpolate movement state
   // Spacial query
   // World 
   // Game moderator
   // Game UX

   auto renderSystem = std::make_shared<RenderSystem>();
   addSystem(renderSystem);



 
// Simple
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