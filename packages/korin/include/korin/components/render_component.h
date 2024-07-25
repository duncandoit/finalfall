// render_component.h
//
// Copyright (c) Zachary Duncan - Duncandoit
// 11/07/2024

#pragma once

#include <string>
#include <memory>

#include "korin/component.h"

namespace korin
{
struct RenderComponent : public Component
{
public:
   RenderComponent(const std::string& textureHandle)
      : textureHandle(textureHandle) {}

   virtual ComponentTypeID typeID() override 
   {
      return Component::typeID<RenderComponent>();
   }

   virtual void create(std::string resource) override {}

public:
   int width, height; 
   std::string textureHandle;
};
}