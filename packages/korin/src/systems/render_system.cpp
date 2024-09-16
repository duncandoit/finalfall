// render_system.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 08/20/2024

#include <iostream>

#include "korin/systems/render_system.h"
#include "korin/log.h"
#include "korin/util/assert.h"

using namespace korin;

void RenderSystem::update(float timeStep, const ComponentPtr& component)
{
   KORIN_ASSERT(component->typeID() == Component::typeID<TransformComponent>());
   auto transform = std::static_pointer_cast<TransformComponent>(component);

   KORIN_CORE_INFO("Entity Position X:{0}", transform->x);
   KORIN_CORE_INFO("Entity Position Y:{0}", transform->y);
}