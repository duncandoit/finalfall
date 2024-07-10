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

void EntityAdmin::addEntity(const EntityPtr entity)
{
   if (m_LivingEntityCount >= MAX_ENTITIES) { return; }

   entity->id = getAvailableEntityID();
   m_Entities.emplace(entity->id, entity);
   m_LivingEntityCount++;
}

void EntityAdmin::removeEntity(const EntityPtr entity)
{
   m_Entities.erase(entity->id);
   m_LivingEntityCount--;

   auto entityComponentsIt = m_ComponentsByEntity.find(entity->id);
   if (entityComponentsIt == m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entity->id) + ") does not exist for removal of components.");
      return;
   }

   // Remove all components associated with entity. This maybe should be done async.
   m_ComponentsByEntity.erase(entityComponentsIt); 
}

void EntityAdmin::addComponent(EntityID entityID, ComponentPtr component)
{
   if (component == nullptr) 
   { 
      KORIN_DEBUG("Cannot add a null Component.");
      return; 
   }
   
   auto entityComponentsIt = m_ComponentsByEntity.find(entityID);
   if (entityComponentsIt != m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for adding components.");
      return;
   }

   auto componentIt = entityComponentsIt->second.find(component->id);
   if (entityComponentsIt->second.find(component->id) != entityComponentsIt->second.end())
   {
      KORIN_DEBUG("ComponentTypeID(" + std::to_string(component->id) + ") type already exists for entity.");
      return;
   }

   m_ComponentsByEntity.at(entityID).emplace(component->id, component);
   m_ComponentsByType.at(component->id).push_back(component); 
}

void EntityAdmin::removeComponent(EntityID entityID, ComponentTypeID componentTypeID)
{
   auto entityComponentsIt = m_ComponentsByEntity.find(entityID); 
   if (entityComponentsIt == m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for removing component.");
      return;
   }

   auto componentIt = entityComponentsIt->second.find(componentTypeID);
   if (componentIt == entityComponentsIt->second.end())
   {
      KORIN_DEBUG("ComponentTypeID(" + std::to_string(componentTypeID) + ") does not exist on entity for removal.");
      return;
   }
   
   m_ComponentsByEntity.at(entityID).erase(componentTypeID);
}

ComponentPtr EntityAdmin::getComponent(EntityID entityID, ComponentTypeID componentTypeID)
{
   auto entityComponentsIt = m_ComponentsByEntity.find(entityID);
   if (entityComponentsIt == m_ComponentsByEntity.end())
   {
      KORIN_DEBUG("EntityID(" + std::to_string(entityID) + ") does not exist for getting component.");
      return nullptr;
   }

   auto componentIt = entityComponentsIt->second.find(componentTypeID);
   if (componentIt == entityComponentsIt->second.end())
   {
      KORIN_DEBUG("ComponentTypeID(" + std::to_string(componentTypeID) + ") does not exist on entity for retrieval.");
      return nullptr;
   }

   return componentIt->second;
}

void EntityAdmin::addSystem(SystemPtr system)
{
   if (system == nullptr) 
   { 
      KORIN_DEBUG("Cannot add a null System.");
      return; 
   }

   if (std::find(m_Systems.begin(), m_Systems.end(), system) != m_Systems.end()) 
   { 
      KORIN_DEBUG("System already exists in admin.");
      return;
   }
   
   m_Systems.push_back(system);
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
      auto requestedComponentIDs = system->requestedComponents();
      for (auto& componentID : requestedComponentIDs)
      {
         auto componentsIt = m_ComponentsByType.find(componentID);
         if (componentsIt == m_ComponentsByType.end())
         {
            KORIN_DEBUG("ComponentTypeID(" + std::to_string(componentID) + ") does not exist for system update.");
            continue;
         }

         system->update(ts, componentsIt->second);
      }


      system->update(ts, );
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
      return -1;
   }

   EntityID id = m_AvailableEntityIDs.front();
   m_AvailableEntityIDs.pop();
   return id;
}