// velocity_component.h
//
// Describes the VelocityComponent struct which is used to represent the velocity of an entity.
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#pragma once

#include "korin/component.h"

namespace korin
{
struct VelocityComponent : public Component {
   float dx, dy;

   VelocityComponent(float dx, float dy)
      : dx(dx), dy(dy) {}
};
} // namespace korin