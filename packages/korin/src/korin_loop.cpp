// korin_loop.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/18/2024

#include "korin/korin_loop.h"
#include "korin/entity_admin.h"

using namespace korin;

void KorinLoop::start()
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
      while (lag >= MS_PER_TICK)
      {
         EntityAdmin::instance().updateSystems(MS_PER_TICK);
         lag -= MS_PER_TICK;
      }

      // Render the game state only after the game state has caught up to the real world
      EntityAdmin::instance().updateRenderSystem();
   }
}