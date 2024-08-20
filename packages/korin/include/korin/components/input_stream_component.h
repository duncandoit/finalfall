// input_stream_component.h
//
// Contains information about the current state of the input devices
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/31/2024

#pragma once

#include "korin/component.h"

namespace korin
{
// Contains information about the current state of the input devices
struct InputStreamComponent : public Component
{
public:
   InputStreamComponent()
      : currentActionStates(0), previousActionStates(0), actionsBegun(0), actionsEnded(0) {}

   virtual ComponentTypeID typeID() override
   {
      return Component::typeID<InputStreamComponent>();
   }

   virtual void create(std::string resource) override {}

public:
   // Current frame's GameAction button states 
   uint32_t currentActionStates;

   // Previous frame's GameAction button states
   uint32_t previousActionStates;

   // 1 = GameAction key pressed this frame
   uint32_t actionsBegun;

   // 1 = GameAction key released this frame
   uint32_t actionsEnded;
};
} // namespace korin