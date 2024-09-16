// log.cpp
//
// Copyright (c) Zachary Duncan - Duncandoit
// 09/13/2024

#include "korin/log.h"

#include "spdlog/sinks/stdout_color_sinks.h"

using namespace korin;

std::shared_ptr<spdlog::logger> Log::s_CoreLogger;
std::shared_ptr<spdlog::logger> Log::s_ClientLogger;

void Log::init()
{
   // Log's output format
   spdlog::set_pattern("%^[%T] %n: %v%$"); 
   s_CoreLogger = spdlog::stdout_color_mt("KORIN");
   s_ClientLogger = spdlog::stdout_color_mt("APP");
   
   s_CoreLogger->set_level(spdlog::level::trace); 
   s_ClientLogger->set_level(spdlog::level::trace);
}