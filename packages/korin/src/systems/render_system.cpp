// render_system.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 08/20/2024

#include <iostream>

#include "korin/systems/render_system.h"
#include "korin/util/assert.h"

using namespace korin;

void RenderSystem::update(float timeStep, const ComponentPtr& component)
{
   KORIN_ASSERT(component->typeID() == Component::typeID<TransformComponent>());
   auto transform = std::static_pointer_cast<TransformComponent>(component);

   std::cout << "Entity Position X:" << transform->x << std::endl;
   std::cout << "Entity Position Y:" << transform->y << std::endl;
}