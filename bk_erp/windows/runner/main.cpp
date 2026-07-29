#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"
#include "resource.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  // Keep taskbar icon, remove title bar icon
  HWND hwnd = window.GetHandle();
  HICON hBigIcon = LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON));
  if (hBigIcon) {
    ::SendMessage(hwnd, WM_SETICON, ICON_BIG, reinterpret_cast<LPARAM>(hBigIcon));
  }
  
  // Create an invisible icon for the title bar
  BYTE andMask[32]; 
  memset(andMask, 0xFF, sizeof(andMask)); // All 1s = transparent
  BYTE xorMask[32]; 
  memset(xorMask, 0x00, sizeof(xorMask)); // All 0s
  HICON hEmptyIcon = CreateIcon(GetModuleHandle(nullptr), 16, 16, 1, 1, andMask, xorMask);
  if (hEmptyIcon) {
    ::SendMessage(hwnd, WM_SETICON, ICON_SMALL, reinterpret_cast<LPARAM>(hEmptyIcon));
  }

  // Start maximized so the app fills the screen on first launch.
  ::ShowWindow(window.GetHandle(), SW_MAXIMIZE);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
