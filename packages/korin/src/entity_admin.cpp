// entity_admin.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#include <unordered_map>
#include <vector>
#include <memory>

#include "korin/entity_admin.h"
#include "korin/util/assert.h"

using namespace korin;

bool EntityAdmin::addEntity(const EntityPtr entity)
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

void EntityAdmin::removeEntity(const EntityPtr entity)
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
   
   const auto& entityComponentTypesIt = m_ComponentsByEntity.find(entityID);
   if (entityComponentTypesIt == m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for adding components.");
      return false;
   }
   
   const auto& componentTypeIt = entityComponentTypesIt->second.find(component->typeID());
   if (componentTypeIt != entityComponentTypesIt->second.end())
   {
      KORIN_DEBUG("ComponentTypeID(" + std::to_string(component->typeID()) + ") type already exists for entity.");
      return false;
   }

   for (const auto& sibling : entityComponentTypesIt->second)
   {
      if (sibling.second->typeID() == component->typeID())
      {
         KORIN_DEBUG("ComponentTypeID(" + std::to_string(component->typeID()) + ") type already exists for entity.");
         return false;
      }
   }
   
   for (auto& sibling : m_ComponentsByEntity.at(entityID))
   {
      component->addSibling(sibling.second);
      sibling.second->addSibling(component);
   }

   m_ComponentsByEntity.at(entityID).emplace(component->typeID(), component);
   m_ComponentsByType.at(component->typeID()).push_back(component); 
   return true;
}

void EntityAdmin::removeComponent(EntityID entityID, ComponentTypeID componentTypeID)
{
   const auto entityComponentTypesIt = m_ComponentsByEntity.find(entityID); 
   if (entityComponentTypesIt == m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for removing component.");
      return;
   }

   const auto componentTypeIt = entityComponentTypesIt->second.find(componentTypeID);
   if (componentTypeIt == entityComponentTypesIt->second.end())
   {
      KORIN_DEBUG("ComponentTypeID(" + std::to_string(componentTypeID) + ") does not exist on entity for removal.");
      return;
   }
   
   m_ComponentsByEntity.at(entityID).erase(componentTypeID);
}

ComponentPtr EntityAdmin::getComponent(EntityID entityID, ComponentTypeID componentTypeID)
{
   const auto entityComponentTypesIt = m_ComponentsByEntity.find(entityID);
   if (entityComponentTypesIt == m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for getting component.");
      return nullptr;
   }

   const auto componentTypeIt = entityComponentTypesIt->second.find(componentTypeID);
   if (componentTypeIt == entityComponentTypesIt->second.end())
   {
      KORIN_DEBUG("ComponentTypeID(" + std::to_string(componentTypeID) + ") does not exist on entity for retrieval.");
      return nullptr;
   }

   return componentTypeIt->second;
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

void EntityAdmin::updateSystems(float ts)
{
   for (auto& system : m_Systems)
   {
      auto requiredComponentTypeIDs = system->requiredComponentTypeIDs();
      for (auto& componentTypeID : requiredComponentTypeIDs)
      {
         auto componentsIt = m_ComponentsByType.find(componentTypeID);
         if (componentsIt == m_ComponentsByType.end())
         {
            KORIN_DEBUG("ComponentTypeID(" + std::to_string(componentTypeID) + ") does not exist for system update.");
            continue;
         }

         // Sending timestep and each component of the type to the system for update.
         for (auto& component : componentsIt->second)
         {
            system->update(ts, componentTypeID, component);
         }

         // Stop looking for components for the current system since it found one. If it needed any others
         // for that entity the system will find them by the first component's siblings.
         break;
      }
   }
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