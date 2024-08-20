// game_input_system.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 07/31/2024

#include <iostream>

#ifdef KORIN_PLATFORM_MACOSX
#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>
#endif

#include "korin/systems/game_input_system.h"
#include "korin/util/game_action_util.h"

using namespace korin;

GameInputSystem::GameInputSystem()
{
   requestListenEventAccess();
   assignDefaultGameActions();
}

void GameInputSystem::update(float timeStep, const ComponentPtr& component)
{
   auto inputStream = std::static_pointer_cast<InputStreamComponent>(component);
   if (!inputStream)
   {
      KORIN_DEBUG("InputStreamComponent found");
      return;
   }

   uint64_t keyCodes = pollKeyCodes();
   uint64_t gameActions = GameActionUtil::instance().getActionsForInput(keyCodes);
   inputStream->previousActionStates = inputStream->currentActionStates;
   inputStream->currentActionStates = gameActions;

   updateButtonUpDownEvents(inputStream);

   // Update button squence events, held events, etc.
}

void GameInputSystem::updateButtonUpDownEvents(const std::shared_ptr<InputStreamComponent>& inputStream)
{
   // XOR the current and last button states to find the changes
   const uint64_t changes = inputStream->currentActionStates ^ inputStream->previousActionStates;

   // AND the changes with the current button states to find the downs
   inputStream->actionsBegun = changes & inputStream->currentActionStates;

   // AND-NOT the changes with the current button states to find the ups
   inputStream->actionsEnded = changes & (~inputStream->currentActionStates);
}

void GameInputSystem::requestListenEventAccess() const
{
   #ifdef KORIN_PLATFORM_MACOSX
      CGRequestListenEventAccess();
   #endif
}

void GameInputSystem::assignDefaultGameActions() const
{
   #ifdef KORIN_PLATFORM_MACOSX
      GameActionUtil::instance().mapInputToAction(kVK_ANSI_W, GameAction::MoveForward);
      GameActionUtil::instance().mapInputToAction(kVK_ANSI_A, GameAction::MoveLeft);
      GameActionUtil::instance().mapInputToAction(kVK_ANSI_S, GameAction::MoveBackward);
      GameActionUtil::instance().mapInputToAction(kVK_ANSI_D, GameAction::MoveRight);
   #endif
}

uint64_t GameInputSystem::pollKeyCodes() const
{
   #ifdef KORIN_PLATFORM_MACOSX
      uint64_t keyCodes = 0;
      for (const auto& [code, action] : GameActionUtil::instance().getActionsByInput())
      {
         // Check if the key is currently pressed
         if (CGEventSourceKeyState(kCGEventSourceStateHIDSystemState, code))
         {
            keyCodes |= (1ULL << code);
         }
      }

      std::cout << "InputSys > Poll > Return > keyCodes:" << keyCodes << std::endl;
      return keyCodes;

   #else
      return 0;
   #endif
}