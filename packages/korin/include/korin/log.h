// log.h
//
// Copyright (c) Zachary Duncan - Duncandoit
// 09/13/2024

#pragma once

#include <memory>

#include "korin/core.h"
#include "spdlog/spdlog.h"

namespace korin
{
class KORIN_API Log
{
public:
   static void init();

   inline static std::shared_ptr<spdlog::logger>& coreLogger() { return s_CoreLogger; }
   inline static std::shared_ptr<spdlog::logger>& clientLogger() { return s_ClientLogger; }

private:
   static std::shared_ptr<spdlog::logger> s_CoreLogger;
   static std::shared_ptr<spdlog::logger> s_ClientLogger;
};
} // namespace korin

// Core log macros
#define KORIN_CORE_ERROR(...) ::korin::Log::coreLogger()->error(__VA_ARGS__)
#define KORIN_CORE_WARN(...)  ::korin::Log::coreLogger()->warn(__VA_ARGS__)
#define KORIN_CORE_INFO(...)  ::korin::Log::coreLogger()->info(__VA_ARGS__)
#define KORIN_CORE_TRACE(...) ::korin::Log::coreLogger()->trace(__VA_ARGS__)
#define KORIN_CORE_FATAL(...) ::korin::Log::coreLogger()->critical(__VA_ARGS__)

// Client log macros
#define KORIN_ERROR(...) ::korin::Log::clientLogger()->error(__VA_ARGS__)
#define KORIN_WARN(...)  ::korin::Log::clientLogger()->warn(__VA_ARGS__)
#define KORIN_INFO(...)  ::korin::Log::clientLogger()->info(__VA_ARGS__)
#define KORIN_TRACE(...) ::korin::Log::clientLogger()->trace(__VA_ARGS__)
#define KORIN_FATAL(...) ::korin::Log::clientLogger()->critical(__VA_ARGS__)
