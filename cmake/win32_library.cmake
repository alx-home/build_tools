function(win32_library)
   set(options)
   set(oneValueArgs TARGET_NAME COMPILE_OPTIONS)
   set(multiValueArgs FILES)
   cmake_parse_arguments(PARSE_ARGV 0 arg
      "${options}" "${oneValueArgs}" "${multiValueArgs}"
   )

   list(LENGTH arg_FILES size_FILES)

   if(size_FILES GREATER 0)
      set(SCOPE PUBLIC)
      add_library(${arg_TARGET_NAME} ${arg_FILES})
   else()
      set(SCOPE INTERFACE)
      add_library(${arg_TARGET_NAME} INTERFACE)
   endif()

   target_include_directories(${arg_TARGET_NAME} ${SCOPE} ${CMAKE_CURRENT_SOURCE_DIR})

   set_target_properties(${arg_TARGET_NAME}
      PROPERTIES
         LINKER_LANGUAGE CXX
         CXX_STANDARD 23
         CMAKE_CXX_STANDARD_REQUIRED ON
         CMAKE_CXX_EXTENSIONS ON
   )

   target_compile_definitions(${arg_TARGET_NAME} PRIVATE NOMINMAX)

   if(ENABLE_ASAN)
      if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
         if(MSVC)
            # ASAN with clang-cl requires the release CRT (/MD), not the debug CRT (/MDd).
            set_property(TARGET ${arg_TARGET_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
         endif()

         target_compile_definitions(${arg_TARGET_NAME} ${SCOPE}
            _ITERATOR_DEBUG_LEVEL=0
            _HAS_ITERATOR_DEBUGGING=0
            _DISABLE_STRING_ANNOTATION
            _DISABLE_VECTOR_ANNOTATION
         )

         if(ASAN_RT_DIR)
            target_link_options(${arg_TARGET_NAME} PRIVATE "/LIBPATH:${ASAN_RT_DIR}")
         endif()

         target_link_libraries(${arg_TARGET_NAME} PRIVATE
            clang_rt.asan_dynamic-x86_64
            clang_rt.asan_dynamic_runtime_thunk-x86_64
         )

         if(ASAN_RT_DIR)
            add_custom_command(TARGET ${arg_TARGET_NAME} POST_BUILD
               COMMAND ${CMAKE_COMMAND} -E copy_if_different
               "${ASAN_RT_DIR}/clang_rt.asan_dynamic-x86_64.dll"
               "$<TARGET_FILE_DIR:${arg_TARGET_NAME}>/clang_rt.asan_dynamic-x86_64.dll"
            )
         endif()
      else()
         target_link_options(${arg_TARGET_NAME} PRIVATE /fsanitize=address)
      endif()
   endif()

   set(COMPILE_OPTIONS
      ${arg_COMPILE_OPTIONS}
      -std=c++2c
      "$<$<CONFIG:DEBUG>:-DDEBUG>"
      -Wall -Wextra -Wpedantic -Wcast-align -Waddress-of-packed-member -Werror
      -ftemplate-backtrace-limit=0
      "$<$<CONFIG:Release>:-O3>"
      "$<$<CONFIG:Debug>:-O0>"
   )

   if(ENABLE_ASAN)
      list(APPEND COMPILE_OPTIONS "-fsanitize=address")
   endif()

   if(MSVC)
      list(TRANSFORM COMPILE_OPTIONS PREPEND "-clang:")

      if(DEFINED SANITIZE AND SANITIZE STREQUAL "address")
         target_compile_options(${arg_TARGET_NAME} ${SCOPE} /W4 /Zi /Od /MD ${COMPILE_OPTIONS})
      else()
         target_compile_options(${arg_TARGET_NAME} ${SCOPE} /W4 ${COMPILE_OPTIONS})
      endif()
   else()
      target_compile_options(${arg_TARGET_NAME} ${SCOPE}
         -export-dynamic
         -ggdb3 -pg -g
         ${COMPILE_OPTIONS}
         -D_GNU_SOURCE
         -Wno-psabi
      )
   endif()
endfunction(win32_library)