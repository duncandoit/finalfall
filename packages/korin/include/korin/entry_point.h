// entry_point.h
//
// The entry point for the Korin application. 
// This is where the application is created and run.
//
// Note: It is inteded to be included in a specific 
// order after other Korin headers. Best practice is to
// just include the korin.h header for the client app.
//
// Copyright (c) Zachary Duncan - Duncandoit
// 09/10/2024

#pragma once

#include "korin/korin.h"

extern korin::Application* korin::createApplication();

int main(int argc, char** argv)
{
   korin::Log::init();
   KORIN_CORE_INFO("Initialized Log!");

   int test = 1;
   KORIN_WARN("Testing Korin logging: {0}", test);

   auto app = korin::createApplication();
   app->run();
   delete app;
}
