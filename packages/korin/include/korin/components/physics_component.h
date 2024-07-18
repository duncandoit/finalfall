// physics_component.h
//
// Describes the PhysicsComponent struct which is used to represent the velocity and acceleration of an entity.
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#pragma once

#include "korin/component.h"

namespace korin
{
struct PhysicsComponent : public Component 
{
public:
   PhysicsComponent(float dx, float dy, float accelerationX, float accelerationY)
      : dx(dx), dy(dy), accelerationX(0.0f), accelerationY(0.0f) {}

   PhysicsComponent() 
      : dx(0.0f), dy(0.0f), accelerationX(0.0f), accelerationY(0.0f) {}

   virtual ComponentTypeID typeID() override 
   {
      return Component::typeID<PhysicsComponent>();
   }

   virtual void create(std::string resource) override 
   {
      // Do nothing
   }

public:
   float dx, dy;
   float accelerationX, accelerationY; 
};
} // namespace korin