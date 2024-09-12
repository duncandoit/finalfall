// application.h
//
// Copyright (c) Zachary Duncan - Duncandoit
// 09/10/2024

#pragma once

#include "korin/core.h"

namespace korin
{
class KORIN_API Application
{
public:
   Application();
   virtual ~Application();

   void run();
};

// To be defined in the client Korin application
Application* createApplication();
} // namespace korin