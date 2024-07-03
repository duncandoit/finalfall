// world.h
//
// Copyright Zachary Duncan 6/25/2024

#pragma once

#include "world-entity.h"
#include <vector>
#include <memory>

namespace korin
{

class World 
{
public:
   World();
   virtual ~World() = default;

   void update(float deltaTime);
   void render() const;

   void addEntity(std::shared_ptr<WorldEntity> entity);
   void removeEntity(std::shared_ptr<WorldEntity> entity);

   const std::vector<std::shared_ptr<WorldEntity>>& getEntities() const;

private:
   std::vector<std::shared_ptr<WorldEntity>> entities;
};

} // namespace korin