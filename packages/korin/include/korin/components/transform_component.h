// transform_component.h
//
// Describes the TransformComponent struct which is used to represent 
// the position and rotation of an entity.
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#pragma once

#include "korin/entity.h"

namespace korin
{
struct TransformComponent : public Component {
    float x, y;
    float rotation;

    TransformComponent(float x, float y, float rotation)
        : x(x), y(y), rotation(rotation) {}
};
} // namespace korin