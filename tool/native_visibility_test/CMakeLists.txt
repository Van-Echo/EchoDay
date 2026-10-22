cmake_minimum_required(VERSION 3.14)
project(echoday_visibility_test LANGUAGES CXX)
add_executable(echoday_visibility_test
  main.cpp
  ../../windows/runner/window_visibility.cpp
)
target_compile_features(echoday_visibility_test PRIVATE cxx_std_17)
target_compile_definitions(echoday_visibility_test PRIVATE UNICODE _UNICODE NOMINMAX)
target_link_libraries(echoday_visibility_test PRIVATE user32 gdi32 dwmapi)
enable_testing()
add_test(NAME visible_unfocused_partial_full_minimized
  COMMAND echoday_visibility_test)
