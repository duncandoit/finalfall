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

   virtual void notify(const ComponentPtr& component) override {}

   // Update method to move the TransformComponents
   virtual void update(float timeStep, const ComponentPtr& component) override;
};
} // namespace korin
