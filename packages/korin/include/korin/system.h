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
using SystemPtr = std::shared_ptr<System>;
class System 
{
public:
   /// Sends the time step to update the system.
   virtual void update(float ts, std::vector<ComponentPtr> components) = 0;
   virtual void notify(ComponentPtr component) = 0;

   virtual std::vector<ComponentTypeID> requestedComponentIDs() const
   {
      return m_RequestedComponentIDs;
   }

private:
   std::vector<ComponentTypeID> m_RequestedComponentIDs;
};
}