// sandbox_application.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/19/2024

#include "korin/korin.h"

class SandboxApp : public korin::Application
{
public: 
    SandboxApp()
    {

    }

    ~SandboxApp()
    {

    }
};

korin::Application* korin::createApplication()
{
    return new SandboxApp();
}
