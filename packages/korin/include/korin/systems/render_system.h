// render_system.h
//
// Copyright (c) Zachary Duncan - Duncandoit
// 08/20/2024

#pragma once

#include "korin/system.h"
#include "korin/components/transform_component.h"

namespace korin
{
class RenderSystem : public System
{
public:
   RenderSystem() {}

   // Request the TransformComponent type
   virtual ComponentTypeID primaryComponentTypeID() const override
   {
      return Component::typeID<TransformComponent>();
   }

   virtual void notify(const ComponentPtr& component) override {}

   // Update method to process the input
   virtual void update(float timeStep, const ComponentPtr& component) override;
};
} // namespace korin