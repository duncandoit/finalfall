// world-entity.h
//
// Copyright Zachary Duncan 6/25/2024

#pragma once

namespace korin
{

class WorldEntity 
{
public:
   WorldEntity(float x, float y, float width, float height, float scale);
   virtual ~WorldEntity() = default;

   virtual void update(float deltaTime) {};
   virtual void render() const {};

   float getX() const;
   float getY() const;
   float getWidth() const;
   float getHeight() const;
   float getScale() const;

   void setX(float x);
   void setY(float y);
   void setWidth(float width);
   void setHeight(float height);
   void setScale(float scale);

protected:
   float x, y;
   float width, height;
   float scale;
};

} // namespace korin