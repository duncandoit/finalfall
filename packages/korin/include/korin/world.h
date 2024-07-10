// world.h
//
// Copyright Zachary Duncan 6/25/2024

#ifndef KORIN_WORLD_H
#define KORIN_WORLD_H

#include <vector>
#include <memory>

namespace korin
{
class WorldEntity;
class Matrix2D;
class World 
{
public:
   World();
   virtual ~World() = default;

   void update(float deltaTime);
   void render() const;

   void addEntity(std::shared_ptr<WorldEntity> entity);
   void removeEntity(std::shared_ptr<WorldEntity> entity);
   void transformEntity(std::shared_ptr<WorldEntity> entity, const Matrix2D& matrix);

   const std::vector<std::shared_ptr<WorldEntity>>& getEntities() const;

private:
   std::vector<std::shared_ptr<WorldEntity>> entities;
};
} // namespace korin

#endif // KORIN_WORLD_H