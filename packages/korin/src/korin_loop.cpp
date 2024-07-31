// korin_loop.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/18/2024

#include <iostream>
#include <thread>

#include "korin/korin_loop.h"
#include "korin/entity_admin.h"

using namespace korin;

void KorinLoop::startFixed()
{
   // The last time the game was updated in seconds
   auto lastTime = std::chrono::high_resolution_clock::now();

   // How far behind the game is from the real world
   float lag = 0.0;

   while (true)
   {
      // Get the current time in seconds
      const auto currentTime = std::chrono::high_resolution_clock::now();
      const std::chrono::duration<float> deltaTime = currentTime - lastTime;
      
      lastTime = currentTime;
      lag += deltaTime.count();

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
   // The last time the game was updated in seconds
   auto lastTime = std::chrono::high_resolution_clock::now();
   
   // Start with the ideal frame period in seconds
   float deltaTime = KorinLoop::FRAME_TIME;

   while (true)
   {
      // Process input
      EntityAdmin::instance().updateInputSystem();

      EntityAdmin::instance().updateSystems(deltaTime);

      // Render the game state only after the game state has caught up to the real world
      EntityAdmin::instance().updateRenderSystem();

      // Get the current time in seconds
      const auto currentTime = std::chrono::high_resolution_clock::now();
      deltaTime = std::chrono::duration<float>(currentTime - lastTime).count();

      if (deltaTime > 1.0f)
      {
         deltaTime = KorinLoop::FRAME_TIME;
      }

      lastTime = currentTime;
   }
}