// system.h
//
// Defines the System class which is used to represent a system in the ECS.
//
// Copyright (c) Zachary Duncan - Duncandoit
// 2024-07-09

#pragma once

#include <vector>

#include "korin/component.h"

namespace korin
{
/// Systems represent modular behavior without any state.
class System 
{
public:
   /// Sends the time step to update the Component and potentially its siblings.
   virtual void update(float timeStep, const ComponentPtr& component) = 0;

   /// Notifies the System that a Component needs to be updated.
   virtual void notify(const ComponentPtr& component) = 0;

   /// Returns the ComponentTypeIDs of the required Components.
   virtual ComponentTypeID primaryComponentTypeID() const = 0;
};

using SystemPtr = std::shared_ptr<System>;
}