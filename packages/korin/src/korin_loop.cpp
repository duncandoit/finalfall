// korin_loop.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/18/2024

#include "korin/korin_loop.h"
#include "korin/entity_admin.h"

using namespace korin;

void KorinLoop::run()
{
   while(true)
   {
      tickFixed();
   }
}

void KorinLoop::tickFixed()
{
   // Get the current time in seconds
   const auto currentTime = std::chrono::high_resolution_clock::now();
   const std::chrono::duration<float> deltaTime = currentTime - lastTime;
   
   lastTime = currentTime;
   fixedTickLag += deltaTime.count();

   // Process input
   EntityAdmin::instance().updateInputSystem();

   // Update game state only if the game is behind the real world
   while (fixedTickLag >= KorinLoop::FRAME_TIME)
   {
      EntityAdmin::instance().updateSystems(KorinLoop::FRAME_TIME);
      fixedTickLag -= KorinLoop::FRAME_TIME;
   }

   // Render the game state only after the game state has caught up to the real world
   EntityAdmin::instance().updateRenderSystem();
}

void KorinLoop::tickVariable()
{
   EntityAdmin::instance().updateInputSystem();
   EntityAdmin::instance().updateSystems(variableTickDeltaTime);
   EntityAdmin::instance().updateRenderSystem();

   // Get the current time in seconds
   const auto currentTime = std::chrono::high_resolution_clock::now();
   variableTickDeltaTime = std::chrono::duration<float>(currentTime - lastTime).count();

   if (variableTickDeltaTime > 1.0f)
   {
      variableTickDeltaTime = KorinLoop::FRAME_TIME;
   }

   lastTime = currentTime;
}