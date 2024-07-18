// movement_system.h
//
// Brief description
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#pragma once

#include <unordered_map>
#include <iostream>

#include "korin/system.h"
#include "korin/component.h"
#include "korin/components/transform_component.h"

namespace korin
{
class MovementSystem : public System
{
public:
   // Request the TransformComponent type
   virtual ComponentTypeID primaryComponentTypeID() const override
   {
      return Component::typeID<TransformComponent>(); 
   }

   virtual void notify(const ComponentPtr& component) override
   {
      // Do nothing
   }

   // Update method to move the TransformComponents
   virtual void update(float ts, const ComponentPtr& component) override
   {
      KORIN_ASSERT(component.typeID() == Component::typeID<TransformComponent>());
      
      auto transform = std::static_pointer_cast<TransformComponent>(component);
      if (transform)
      {
         transform->x += 1.0f * ts;
         transform->y += 1.0f * ts;
         std::cout << "Entity Position: (" << transform->x << ", " << transform->y << ")" << std::endl;
      }
   }
};
} // namespace korin
