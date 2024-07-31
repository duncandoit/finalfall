// movement_system.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#include "korin/systems/movement_system.h"
#include "korin/components/transform_component.h"

namespace korin
{
void MovementSystem::update(float timeStep, const ComponentPtr& component)
{
   KORIN_ASSERT(component->typeID() == Component::typeID<TransformComponent>());
   
   auto transform = std::static_pointer_cast<TransformComponent>(component);
   if (transform)
   {
      transform->x += 5.5f * timeStep;
      transform->y += 5.5f * timeStep;
      std::cout << "Entity Position:" << transform->x << ", " << transform->y << std::endl;
   }
}
} // namespace korin