// movement_system.h
//
// Brief description
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#pragma once

#include <unordered_map>
#include "korin/entity.h"
#include "korin/system.h"

namespace korin
{
struct TransformComponent;
struct VelocityComponent;
class MovementSystem : public System {
public:
      void update(float ts) override;
      // void notify(ComponentPtr component) override;
};
}