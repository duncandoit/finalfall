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
class System 
{
public:
   /// Sends the time step to update the system.
   virtual void update(float ts, ComponentTypeID componentTypeID, ComponentPtr components) = 0;
   virtual void notify(ComponentPtr component) = 0;

   virtual std::vector<ComponentTypeID> requiredComponentTypeIDs() const = 0;
};

using SystemPtr = std::shared_ptr<System>;
}