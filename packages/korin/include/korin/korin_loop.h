// korin_loop.h
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/18/2024

#pragma once

namespace korin
{
class KorinLoop
{
public:
   KorinLoop()
      : FRAME_TIME(1.0f / 60.0f)
      {}

   ~KorinLoop() = default;

   void startFixed();
   void startVariable();
   
private:
   // Time in seconds that each frame should take
   // TODO: This should be a setting that the user can choose
   const float FRAME_TIME;
};
}