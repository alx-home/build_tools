function(ts_app)
   set(options)
   set(oneValueArgs TARGET_NAME)
   set(multiValueArgs)
   cmake_parse_arguments(PARSE_ARGV 0 arg
      "${options}" "${oneValueArgs}" "${multiValueArgs}"
   )

   file(GLOB_RECURSE ASSETS 
      ${CMAKE_CURRENT_SOURCE_DIR}/src/*
      ${CMAKE_CURRENT_SOURCE_DIR}/.env.*
      ${CMAKE_CURRENT_SOURCE_DIR}/build.ts
      ${CMAKE_CURRENT_SOURCE_DIR}/index.html
      ${CMAKE_CURRENT_SOURCE_DIR}/package.json
      ${CMAKE_CURRENT_SOURCE_DIR}/tailwind.config.ts
      ${CMAKE_CURRENT_SOURCE_DIR}/tsconfig.json
   )

   get_target_property(DEPS alx-home_ts_utils DEPS)
   add_custom_command(
      OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/dist/index.html
      DEPENDS 
         alx-home_ts_utils
         ${DEPS}
         ${ASSETS}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMAND npm run build
   )

   list(APPEND DEPS ${CMAKE_CURRENT_BINARY_DIR}/dist/index.html)
   add_custom_target(${arg_TARGET_NAME}
      DEPENDS 
         alx-home_ts_utils
         ${DEPS}
   )

   set_target_properties(${arg_TARGET_NAME} PROPERTIES
      FOLDER ${CMAKE_CURRENT_BINARY_DIR}/dist/
      DEPS "${DEPS}"
   )
endfunction(ts_app)