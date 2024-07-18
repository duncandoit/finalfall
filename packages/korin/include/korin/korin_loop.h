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
   KorinLoop() = default;
   ~KorinLoop() = default;

   void start();

private:
   // TODO: This should be a setting that the user can choose or 
   //       determined by the refresh rate of the monitor
   const double MS_PER_TICK = 16.6666666667; 
};
}