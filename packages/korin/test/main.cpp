// main.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/19/2024

#include <iostream>
#include <memory>

#include "GLFW/glfw3.h"

#include "korin/korin_loop.h"
#include "korin/entity_admin.h"
#include "korin/components/transform_component.h"
#include "korin/components/input_stream_component.h"

using namespace korin;

// int main()
// {
//    EntityPtr playerEntity = EntityAdmin::instance().createEntity("player");
//    KORIN_DEBUG("Player entity id:" + std::to_string(playerEntity->entityID()));

//    auto locationComp = std::make_shared<TransformComponent>(0, 0, 0);
//    EntityAdmin::instance().addComponent(playerEntity->entityID(), locationComp);
//    KORIN_DEBUG("Location component typeid:" + std::to_string(locationComp->typeID()));

//    auto inputComp = std::make_shared<InputStreamComponent>();
//    EntityAdmin::instance().addComponent(playerEntity->entityID(), inputComp);
//    KORIN_DEBUG("Input component typeid:" + std::to_string(inputComp->typeID()));

//    KorinLoop loop;
//    loop.run();

//    return 0;
// }

int main(void)
{
    GLFWwindow* window;

    /* Initialize the library */
    if (!glfwInit())
        return -1;

    /* Create a windowed mode window and its OpenGL context */
    window = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
    if (!window)
    {
        glfwTerminate();
        return -1;
    }

    /* Make the window's context current */
    glfwMakeContextCurrent(window);

    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
        /* Render here */
        glClear(GL_COLOR_BUFFER_BIT);

        /* Swap front and back buffers */
        glfwSwapBuffers(window);

        /* Poll for and process events */
        glfwPollEvents();
    }

    glfwTerminate();
    return 0;
}