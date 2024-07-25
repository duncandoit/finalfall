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
struct TransformComponent : public Component 
{
public:
    TransformComponent(float x, float y, float rotation)
        : x(x), y(y), rotation(rotation), scaleX(1.0f), scaleY(1.0f) {}

    virtual ComponentTypeID typeID() override 
    {
        return Component::typeID<TransformComponent>();
    }

    virtual void create(std::string resource) override {}

public:
    float x, y;
    float rotation; // In degrees
    float scaleX, scaleY;
};
} // namespace korin