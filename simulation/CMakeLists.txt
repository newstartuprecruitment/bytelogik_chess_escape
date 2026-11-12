cmake_minimum_required(VERSION 4.3)

project(simulation)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

add_executable(simulation simulation.cc)

target_compile_options(simulation PUBLIC
    -Wall
    -Wextra
    -O3
    -march=native
    -mtune=native 
    -static
    -fno-strict-overflow
    -fuse-ld=lld
    -funroll-loops
    -fipa-pta 
    -fno-PIE    
    -fno-exceptions
    -fno-rtti
    -fno-math-errno
    -fno-stack-protector
    -U_FORTIFY_SOURCE
    -fomit-frame-pointer
    -fno-unwind-tables
    -fno-asynchronous-unwind-tables
    -fno-threadsafe-statics
    -flto=auto
    -fno-semantic-interposition
)

target_link_options(simulation PUBLIC -no-pie)
