function(win32_library)
   set(options)
   set(oneValueArgs TARGET_NAME COMPILE_OPTIONS)
   set(multiValueArgs FILES)
   cmake_parse_arguments(PARSE_ARGV 0 arg
      "${options}" "${oneValueArgs}" "${multiValueArgs}"
   )

   list(LENGTH arg_FILES size_FILES)

   if (size_FILES GREATER 0)
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

   set(COMPILE_OPTIONS
      ${arg_COMPILE_OPTIONS}
      -std=c++2c
      "$<$<CONFIG:DEBUG>:-DDEBUG>"
      -Wall -Wextra -Wpedantic -Wcast-align -Waddress-of-packed-member -Werror
      -ftemplate-backtrace-limit=0
      "$<$<CONFIG:Release>:-O3>"
      "$<$<CONFIG:Debug>:-O0>"
   )

   # set(SANITIZE "address")

   if(DEFINED SANITIZE)
      list(APPEND COMPILE_OPTIONS
         -fsanitize=${SANITIZE}
      )
   endif(DEFINED SANITIZE)

   # if(DEFINED ADDRESS_SANITIZER)
   #     list(APPEND COMPILE_OPTIONS 
   #         "-DADDRESS_SANITIZER"
   #         -fsanitize-recover=address
   #     )
   # endif(DEFINED ADDRESS_SANITIZER)

   if(MSVC)
      list(TRANSFORM COMPILE_OPTIONS PREPEND "-clang:")
      target_compile_options(${arg_TARGET_NAME} ${SCOPE} /W4 ${COMPILE_OPTIONS})
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