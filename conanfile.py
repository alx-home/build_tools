import os

from conan import ConanFile
from conan.tools.files import copy


class AlxBuildToolsConan(ConanFile):
    name = "alx-build-tools"
    version = "1.1.0"
    package_type = "build-scripts"
    license = "MIT"
    author = "alx-home"
    url = "https://github.com/alx-home/build_tools"
    description = "Build tools for ALX projects."
    topics = ("build", "tools", "cpp", "alx", "alx-home")

    no_copy_source = True
    exports_sources = "cmake/*", "README.md", "LICENSE"

    def package(self):
        copy(
            self,
            "*.cmake",
            src=os.path.join(self.source_folder, "cmake"),
            dst=os.path.join(self.package_folder, "cmake"),
        )
        copy(
            self,
            "README.md",
            src=self.source_folder,
            dst=os.path.join(self.package_folder, "share", self.name),
        )
        copy(
            self,
            "LICENSE",
            src=self.source_folder,
            dst=os.path.join(self.package_folder, "share", self.name),
        )

    def package_info(self):
        self.cpp_info.includedirs = []
        self.cpp_info.libdirs = []
        self.cpp_info.bindirs = []
        self.cpp_info.set_property("cmake_file_name", "alx-build-tools")
        self.cpp_info.set_property(
            "cmake_build_modules",
            [
                os.path.join("cmake", "win32_library.cmake"),
                os.path.join("cmake", "win32_executable.cmake"),
                os.path.join("cmake", "ts_app.cmake"),
            ],
        )
        self.cpp_info.builddirs = ["cmake"]