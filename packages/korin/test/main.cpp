// main.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/19/2024

#include <iostream>
#include <memory>

#include "korin/korin_loop.h"
#include "korin/entity_admin.h"
#include "korin/components/transform_component.h"
#include "korin/components/render_component.h"

using namespace korin;

int main()
{
   KorinLoop loop;

   EntityPtr worldEntity = EntityAdmin::instance().createEntity("world");
   // EntityAdmin::instance().addEntity(worldEntity);
   KORIN_DEBUG("World entity id:" + std::to_string(worldEntity->entityID()));

   EntityPtr playerEntity = EntityAdmin::instance().createEntity("player");
   // EntityAdmin::instance().addEntity(playerEntity);
   KORIN_DEBUG("Player entity id:" + std::to_string(playerEntity->entityID()));

   auto locationComp = std::make_shared<TransformComponent>(0, 0, 0);
   EntityAdmin::instance().addComponent(worldEntity->entityID(), locationComp);
   KORIN_DEBUG("Location component typeid:" + std::to_string(locationComp->typeID()))

   auto renderComp = std::make_shared<RenderComponent>("RenderAsset");
   EntityAdmin::instance().addComponent(playerEntity->entityID(), renderComp);
   KORIN_DEBUG("Render component typeid:" + std::to_string(renderComp->typeID()))

   loop.start();

   return 0;
}