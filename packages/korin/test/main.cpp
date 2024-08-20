// main.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/19/2024

#include <iostream>
#include <memory>

#include "korin/korin_loop.h"
#include "korin/entity_admin.h"
#include "korin/components/transform_component.h"
#include "korin/components/input_stream_component.h"

using namespace korin;

int main()
{
   EntityPtr playerEntity = EntityAdmin::instance().createEntity("player");
   KORIN_DEBUG("Player entity id:" + std::to_string(playerEntity->entityID()));

   auto locationComp = std::make_shared<TransformComponent>(0, 0, 0);
   EntityAdmin::instance().addComponent(playerEntity->entityID(), locationComp);
   KORIN_DEBUG("Location component typeid:" + std::to_string(locationComp->typeID()));

   auto inputComp = std::make_shared<InputStreamComponent>();
   EntityAdmin::instance().addComponent(playerEntity->entityID(), inputComp);
   KORIN_DEBUG("Input component typeid:" + std::to_string(inputComp->typeID()));

   KorinLoop loop;
   loop.run();

   return 0;
}