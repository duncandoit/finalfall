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
#include "korin/util/game_action_util.h"

namespace korin
{
struct InputStreamComponent;
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

private:
   bool didActionBegin(GameAction action, const std::shared_ptr<InputStreamComponent>& inputStream) const;
   bool didActionContinue(GameAction action, const std::shared_ptr<InputStreamComponent>& inputStream) const;
};
} // namespace korin