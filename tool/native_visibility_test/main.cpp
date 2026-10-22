// Runs against temporary, non-activating windows, never the user's EchoDay.
#include <windows.h>
#include <dwmapi.h>

#include <iostream>
#include <string>

#include "../../windows/runner/window_visibility.h"

namespace {
LRESULT CALLBACK Procedure(HWND window, UINT message, WPARAM wparam,
                           LPARAM lparam) {
  if (message == WM_TIMER || message == WM_CLOSE) {
    DestroyWindow(window);
    return 0;
  }
  if (message == WM_DESTROY) {
    PostQuitMessage(0);
    return 0;
  }
  return DefWindowProc(window, message, wparam, lparam);
}

void Flush() {
  MSG message;
  while (PeekMessage(&message, nullptr, 0, 0, PM_REMOVE)) {
    TranslateMessage(&message);
    DispatchMessage(&message);
  }
  DwmFlush();
}

HWND CreateTestWindow(const std::wstring& name) {
  return CreateWindowEx(WS_EX_TOPMOST | WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW,
                        L"EchoDayVisibilityTest", name.c_str(), WS_POPUP,
                        100, 100, 320, 200, nullptr, nullptr,
                        GetModuleHandle(nullptr), nullptr);
}
}  // namespace

int wmain(int argc, wchar_t** argv) {
  WNDCLASS window_class{};
  window_class.lpfnWndProc = Procedure;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.lpszClassName = L"EchoDayVisibilityTest";
  RegisterClass(&window_class);

  if (argc == 3 && std::wstring(argv[1]) == L"--cover") {
    HWND cover = CreateTestWindow(argv[2]);
    ShowWindow(cover, SW_SHOWNOACTIVATE);
    SetTimer(cover, 1, 5000, nullptr);  // Never leave a test overlay behind.
    MSG message;
    while (GetMessage(&message, nullptr, 0, 0) > 0) {
      TranslateMessage(&message);
      DispatchMessage(&message);
    }
    return 0;
  }

  int failures = 0;
  auto expect = [&failures](const char* name, bool actual, bool expected) {
    std::cout << name << ": " << (actual == expected ? "PASS" : "FAIL") << '\n';
    if (actual != expected) ++failures;
  };
  HWND target = CreateTestWindow(L"EchoDay visibility target");
  ShowWindow(target, SW_SHOWNOACTIVATE);
  Flush();
  expect("visible without focus", HasVisibleWindowArea(target), true);

  wchar_t path[MAX_PATH];
  GetModuleFileName(nullptr, path, MAX_PATH);
  const auto name = L"EchoDay visibility cover " +
                    std::to_wstring(GetCurrentProcessId());
  std::wstring command = L"\"" + std::wstring(path) + L"\" --cover \"" + name + L"\"";
  STARTUPINFO startup{};
  startup.cb = sizeof(startup);
  PROCESS_INFORMATION process{};
  if (!CreateProcess(nullptr, command.data(), nullptr, nullptr, FALSE,
                     CREATE_NO_WINDOW, nullptr, nullptr, &startup, &process)) {
    DestroyWindow(target);
    return 2;
  }
  HWND cover = nullptr;
  for (int attempt = 0; attempt < 200 && cover == nullptr; ++attempt) {
    cover = FindWindow(L"EchoDayVisibilityTest", name.c_str());
    Sleep(10);
  }
  if (cover == nullptr) {
    ++failures;
  } else {
    SetWindowPos(cover, HWND_TOPMOST, 100, 100, 320, 200,
                 SWP_NOACTIVATE | SWP_SHOWWINDOW);
    Flush();
    expect("fully covered by another process", HasVisibleWindowArea(target), false);
    SetWindowPos(cover, HWND_TOPMOST, 100, 100, 160, 200, SWP_NOACTIVATE);
    Flush();
    expect("partially covered", HasVisibleWindowArea(target), true);
    SetWindowLongPtr(cover, GWL_EXSTYLE,
                     GetWindowLongPtr(cover, GWL_EXSTYLE) | WS_EX_LAYERED);
    SetLayeredWindowAttributes(cover, 0, 128, LWA_ALPHA);
    SetWindowPos(cover, HWND_TOPMOST, 100, 100, 320, 200, SWP_NOACTIVATE);
    Flush();
    expect("transparent overlay", HasVisibleWindowArea(target), true);
    ShowWindow(target, SW_SHOWMINNOACTIVE);
    Flush();
    expect("minimized", HasVisibleWindowArea(target), false);
    ShowWindow(target, SW_HIDE);
    Flush();
    expect("hidden", HasVisibleWindowArea(target), false);
    PostMessage(cover, WM_CLOSE, 0, 0);
  }
  DestroyWindow(target);
  WaitForSingleObject(process.hProcess, 6000);
  CloseHandle(process.hThread);
  CloseHandle(process.hProcess);
  return failures == 0 ? 0 : 1;
}
