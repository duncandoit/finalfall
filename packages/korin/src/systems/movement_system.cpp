// movement_system.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#include "korin/systems/movement_system.h"
#include "korin/components/transform_component.h"
#include "korin/components/input_stream_component.h"
#include "korin/log.h"
#include "korin/util/assert.h"

using namespace korin;

void MovementSystem::update(float timeStep, const ComponentPtr& component)
{
   KORIN_ASSERT(component->typeID() == Component::typeID<TransformComponent>());
   auto transform = std::static_pointer_cast<TransformComponent>(component);
   if (!transform) 
   { 
      KORIN_CORE_WARN("TransformComponent not found");
      return;
   }

   auto inputStream = transform->sibling<InputStreamComponent>().lock();
   if (!inputStream)
   {
      KORIN_CORE_WARN("InputStreamComponent not found");
      return;
   }

   if (didActionBegin(GameAction::MoveForward, inputStream) || didActionContinue(GameAction::MoveForward, inputStream))
   {
      transform->y += 5.5f * timeStep;
   }

   if (didActionBegin(GameAction::MoveBackward, inputStream) || didActionContinue(GameAction::MoveBackward, inputStream))
   {
      transform->y -= 5.5f * timeStep;
   }

   if (didActionBegin(GameAction::MoveRight, inputStream) || didActionContinue(GameAction::MoveRight, inputStream))
   {
      transform->x += 5.5f * timeStep;
   }

   if (didActionBegin(GameAction::MoveLeft, inputStream) || didActionContinue(GameAction::MoveLeft, inputStream))
   {
      transform->x -= 5.5f * timeStep;
   }
}

bool MovementSystem::didActionBegin(GameAction action, const std::shared_ptr<InputStreamComponent>& inputStream) const
{
   return inputStream->actionsBegun & static_cast<uint64_t>(action);
}

bool MovementSystem::didActionContinue(GameAction action, const std::shared_ptr<InputStreamComponent>& inputStream) const
{
   return (inputStream->currentActionStates & static_cast<uint64_t>(action)) 
      && (inputStream->previousActionStates & static_cast<uint64_t>(action));
}