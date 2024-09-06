// game_input_system.h
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/31/2024

#pragma once

#include <memory>

#include "korin/system.h"
#include "korin/component.h"
#include "korin/components/input_stream_component.h"

namespace korin
{
class GameInputSystem : public System
{
public:
   GameInputSystem() : consumed(false) {};

   // Request the InputStreamComponent type
   virtual ComponentTypeID primaryComponentTypeID() const override
   {
      return Component::typeID<InputStreamComponent>();
   }

   virtual void notify(const ComponentPtr& component) override {}

   // Update method to process the input
   virtual void update(float timeStep, const ComponentPtr& component) override;

public:
   bool consumed;

private:
   // Assuming that ButtonStates and PreviousButtonStates 
   // are valid, generate ButtonDowns and ButtonUps
   void updateButtonUpDownEvents(const std::shared_ptr<InputStreamComponent>& inputStream);
   void requestListenEventAccess() const;
   void assignDefaultGameActions() const;
   uint64_t pollKeyCodes() const;
};
} // namespace korin