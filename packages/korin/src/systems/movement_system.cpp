// movement_system.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#include "korin/systems/movement_system.h"
#include "korin/components/transform_component.h"

using namespace korin;

void MovementSystem::update(float ts)
{
   for (auto& entity : entities)
   {
      auto transform = entity->get_component<TransformComponent>();
      auto velocity = entity->get_component<VelocityComponent>();

      if (transform && velocity)
      {
         transform->x += velocity->dx * ts;
         transform->y += velocity->dy * ts;
      }
   }
}