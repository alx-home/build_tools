function(ts_app)
   set(options)
   set(oneValueArgs TARGET_NAME APP_DIR OUTPUT_DIR OUTPUT)
   set(multiValueArgs DEPENDS BUILD_TARGET)
   cmake_parse_arguments(PARSE_ARGV 0 arg
      "${options}" "${oneValueArgs}" "${multiValueArgs}"
   )

   if (NOT DEFINED arg_DEPENDS) 
      message(FATAL_ERROR "DEPENDS is missing!")
   endif()

   if (DEFINED arg_APP_DIR)
      if (NOT DEFINED arg_OUTPUT_DIR)
         set(arg_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/${arg_APP_DIR}/dist)
      endif()
   else()
      set(arg_APP_DIR "src")
      if (NOT DEFINED arg_OUTPUT_DIR)
         set(arg_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/dist)
      endif()
   endif()

   if (NOT DEFINED arg_OUTPUT)
      set(arg_OUTPUT ${arg_OUTPUT_DIR}/index.html)
   endif()
   
   if (NOT DEFINED arg_BUILD_TARGET)
      set(arg_BUILD_TARGET "build$<$<CONFIG:DEBUG>:\:dev>")
   endif()

   find_program(NPM npm)

   message("TS App ${arg_TARGET_NAME} : ${arg_APP_DIR} -> ${arg_OUTPUT_DIR}")
   get_target_property(TS_UTILS_DEPS alx-home_ts_utils DEPS)
   list(APPEND arg_DEPENDS ${TS_UTILS_DEPS})
   add_custom_command(
      OUTPUT ${arg_OUTPUT}
      DEPENDS 
         alx-home_ts_utils
         ${arg_DEPENDS}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMAND NPM run ${arg_BUILD_TARGET}
      COMMENT "${arg_TARGET_NAME}: Running NPM run ${arg_BUILD_TARGET}"
   )

   add_custom_target(${arg_TARGET_NAME}
      DEPENDS 
         alx-home_ts_utils
         ${arg_OUTPUT}
   )

   set_target_properties(${arg_TARGET_NAME} PROPERTIES
      OUTPUT_DIRECTORY ${arg_OUTPUT_DIR}/
      DEPS "${arg_OUTPUT}"
   )
endfunction(ts_app)