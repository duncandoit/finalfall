// korin_loop.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/18/2024

#include "korin/korin_loop.h"
#include "korin/entity_admin.h"

using namespace korin;

void KorinLoop::startFixed()
{
   // The last time the game was updated in milliseconds
   float lastTime = std::chrono::high_resolution_clock::now().time_since_epoch().count(); 

   // How far behind the game is from the real world
   float lag = 0.0;

   while (true)
   {
      // Get the current time in milliseconds
      float currentTime = std::chrono::high_resolution_clock::now().time_since_epoch().count();
      float deltaTime = currentTime - lastTime;
      lastTime = currentTime;
      lag += deltaTime;

      // Process input
      EntityAdmin::instance().updateInputSystem();

      // Update game state only if the game is behind the real world
      while (lag >= KorinLoop::FRAME_TIME)
      {
         EntityAdmin::instance().updateSystems(KorinLoop::FRAME_TIME);
         lag -= KorinLoop::FRAME_TIME;
      }

      // Render the game state only after the game state has caught up to the real world
      EntityAdmin::instance().updateRenderSystem();
   }
}

void KorinLoop::startVariable()
{
   // Start with the ideal frame period or 
   float deltaTime = KorinLoop::FRAME_TIME;

   // The last time the game was updated in milliseconds
   // float duration = std::chrono::high_resolution_clock::now().time_since_epoch(); 
   auto entryFrameTime = std::chrono::high_resolution_clock::now();

   while (true)
   {
      // Process input
      EntityAdmin::instance().updateInputSystem();

      EntityAdmin::instance().updateSystems(deltaTime);

      // Render the game state only after the game state has caught up to the real world
      EntityAdmin::instance().updateRenderSystem();

      // Get the current time in milliseconds
      const auto exitFrameTime = std::chrono::high_resolution_clock::now();
      deltaTime = std::chrono::duration<float>(exitFrameTime - entryFrameTime).count() 
         * std::chrono::high_resolution_clock::period::num 
         / std::chrono::high_resolution_clock::period::den;

      if (deltaTime > 1.0f)
      {
         deltaTime = KorinLoop::FRAME_TIME;
      }

      entryFrameTime = exitFrameTime;
   }
}