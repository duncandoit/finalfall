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

#include <stdio.h> // This will be replaced with a logging system
#include "korin/application.h" 

extern korin::Application* korin::createApplication();

int main(int argc, char** argv)
{
   printf("::KORIN:: Application started\n");
   auto app = korin::createApplication();
   app->run();
   delete app;
   return 0;
}