function(ts_app)
   set(options)
   set(oneValueArgs TARGET_NAME APP_DIR BUILD_TARGET OUTPUT_DIR)
   set(multiValueArgs DEPENDS)
   cmake_parse_arguments(PARSE_ARGV 0 arg
      "${options}" "${oneValueArgs}" "${multiValueArgs}"
   )

   if (DEFINED arg_APP_DIR)
      if (NOT DEFINED arg_OUTPUT_DIR)
         file(RELATIVE_PATH arg_OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR} ${arg_APP_DIR})
         set(arg_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/${arg_OUTPUT_DIR}/dist)
      endif()
   else()
      set(arg_APP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
      if (NOT DEFINED arg_OUTPUT_DIR)
         set(arg_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/dist")
      endif()
   endif()
   
   file(GLOB_RECURSE ASSETS
      ${arg_APP_DIR}/*
      ${CMAKE_CURRENT_SOURCE_DIR}/.env.*
      ${CMAKE_CURRENT_SOURCE_DIR}/build.ts
      ${CMAKE_CURRENT_SOURCE_DIR}/index.html
      ${CMAKE_CURRENT_SOURCE_DIR}/package.json
      ${CMAKE_CURRENT_SOURCE_DIR}/tailwind.config.ts
      ${CMAKE_CURRENT_SOURCE_DIR}/tsconfig.json
   )
   
   if (DEFINED arg_DEPENDS)
      file(GLOB_RECURSE ASSETS_
         ${arg_DEPENDS}/*
      )

      list(APPEND ASSETS ${ASSETS_})
   endif()

   if (NOT DEFINED arg_BUILD_TARGET)
      set(arg_BUILD_TARGET "build")
   endif()


   get_target_property(DEPS alx-home_ts_utils DEPS)
   add_custom_command(
      OUTPUT ${arg_OUTPUT_DIR}/index.html
      DEPENDS 
         alx-home_ts_utils
         ${DEPS}
         ${ASSETS}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMAND npm run "${arg_BUILD_TARGET}"
   )

   list(APPEND DEPS ${arg_OUTPUT_DIR}/index.html)
   add_custom_target(${arg_TARGET_NAME}
      DEPENDS 
         alx-home_ts_utils
         ${DEPS}
   )

   set_target_properties(${arg_TARGET_NAME} PROPERTIES
      FOLDER ${arg_OUTPUT_DIR}/
      DEPS "${DEPS}"
   )
endfunction(ts_app)