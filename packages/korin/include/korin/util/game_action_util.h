// game_action_util.h
//
// Copyright (c) Zachary Duncan - Duncandoit
// 08/03/2024

#pragma once

#include <unordered_map>
#include "korin/log.h"

namespace korin
{
enum class GameAction : uint64_t
{
   // Menu
   Menu = 1 << 0,
   Confirm = 1 << 1,
   Cancel = 1 << 2,

   // Movement
   MoveForward = 1 << 3,
   MoveBackward = 1 << 4,
   MoveRight = 1 << 5,
   MoveLeft = 1 << 6,
   RotateRight = 1 << 7,
   RotateLeft = 1 << 8,
   Crouch = 1 << 9,
   Sprint = 1 << 10,
   Jump = 1 << 11,

   // Camera
   LookUp = 1 << 12,
   LookDown = 1 << 13,
   LookLeft = 1 << 14,
   LookRight = 1 << 15,

   // Actions
   PrimaryAbility = 1 << 16,
   SecondaryAbility = 1 << 17,
   TertiaryAbility = 1 << 18,
   QuaternaryAbility = 1 << 19,

   Any = 0xFFFFFF,
   None = 0
};

class GameActionUtil
{
public:
   GameActionUtil(const GameActionUtil&) = delete;
   void operator=(const GameActionUtil&) = delete;

   static GameActionUtil& instance()
   {
      static GameActionUtil instance;
      return instance;
   }

   void mapInputToAction(uint64_t input, GameAction action)
   {
      m_ActionsByInput[input] = action;
      KORIN_INFO("Mapped Keycode:{0}", input, " with Action:{0}", static_cast<uint64_t>(action));
   }

   uint64_t getActionsForInput(uint64_t input)
   {
      uint64_t actions = 0;
      for (const auto& [key, value] : m_ActionsByInput)
      {
         if ((1ULL << key) & input)
         {
            actions |= static_cast<uint64_t>(value);
         }
      }

      return actions;
   }

   std::unordered_map<uint64_t, GameAction> getActionsByInput() const
   {
      return m_ActionsByInput;
   }

private:
   GameActionUtil() = default;

   std::unordered_map<uint64_t, GameAction> m_ActionsByInput;
};
} // namespace korin