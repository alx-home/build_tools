cmake_minimum_required(VERSION 3.20)

# Sanitizers
option(ENABLE_ASAN "Enable AddressSanitizer in clang-cl builds" OFF)

if(ENABLE_ASAN AND MSVC AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
   # ASAN on Windows requires the release CRT and non-debug iterators.
   set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL" CACHE STRING "" FORCE)
   add_compile_definitions(
         _ITERATOR_DEBUG_LEVEL=0
         _HAS_ITERATOR_DEBUGGING=0
         _DISABLE_STRING_ANNOTATION
         _DISABLE_VECTOR_ANNOTATION
   )

   # Resolve the clang resource dir so we can link ASAN runtime libs with lld-link.
   execute_process(
         COMMAND "${CMAKE_CXX_COMPILER}" -print-resource-dir
         OUTPUT_VARIABLE CLANG_RESOURCE_DIR
         OUTPUT_STRIP_TRAILING_WHITESPACE
   )

   if(CLANG_RESOURCE_DIR)
      set(ASAN_RT_DIR "${CLANG_RESOURCE_DIR}/lib/windows" CACHE PATH "Clang ASAN runtime directory" FORCE)
   endif()
endif()

include(cmake/win32_executable.cmake)
include(cmake/win32_library.cmake)
include(cmake/ts_app.cmake)