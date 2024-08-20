// korin_loop.h
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/18/2024

#pragma once

#include <iostream>

namespace korin
{
class KorinLoop
{
public:
   KorinLoop()
      : FRAME_TIME(1.0f / 60.0f), lastTime(std::chrono::high_resolution_clock::now())
      , variableTickDeltaTime(0.0f), fixedTickLag(0.0f)
      {}

   ~KorinLoop() = default;

   void run();
   void tickFixed();
   void tickVariable();
   
private:
   // Time in seconds that each frame should take
   // TODO: This should be a setting that the user can choose
   const float FRAME_TIME;

   // The last time the game was updated in seconds
   std::chrono::steady_clock::time_point lastTime;

   // The time in seconds that the last frame took
   // Start with the ideal frame period in seconds
   // Used only in the variable time step tick
   float variableTickDeltaTime;

   // How far behind the game is from the real world
   // Used only in the fixed time step tick
   float fixedTickLag;
};
}