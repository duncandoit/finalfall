// world.cpp
//
// Copyright Zachary Duncan 6/25/2024

#include "korin/world.h"

using namespace korin;

World::World() {}

void World::update(float deltaTime) 
{
   for (auto& entity : entities) 
   {
      entity->update(deltaTime);
   }
}

void World::render() const 
{
   for (const auto& entity : entities) 
   {
      entity->render();
   }
}

void World::addEntity(std::shared_ptr<WorldEntity> entity) 
{
   entities.push_back(entity);
}

void World::removeEntity(std::shared_ptr<WorldEntity> entity) 
{
   entities.erase(std::remove(entities.begin(), entities.end(), entity), entities.end());
}

const std::vector<std::shared_ptr<WorldEntity>>& World::getEntities() const 
{
   return entities;
}
