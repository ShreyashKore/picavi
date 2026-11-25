#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <shlobj.h>
#include <windows.h>

#include <array>
#include <string>

#include "flutter_window.h"
#include "utils.h"

namespace {

constexpr wchar_t kProgId[] = L"Picavi.ImageFile";
constexpr wchar_t kFriendlyName[] = L"Picavi Image Viewer";
constexpr std::array<const wchar_t*, 8> kSupportedExtensions = {
    L".bmp", L".gif", L".ico", L".jpeg", L".jpg", L".png", L".svg",
    L".webp"};

std::wstring GetExecutablePath() {
  wchar_t buffer[MAX_PATH];
  const auto length = GetModuleFileNameW(nullptr, buffer, MAX_PATH);
  return std::wstring(buffer, length);
}

bool WriteRegistryString(HKEY root, const std::wstring& sub_key,
                         const std::wstring& value_name,
                         const std::wstring& value) {
  HKEY key = nullptr;
  if (RegCreateKeyExW(root, sub_key.c_str(), 0, nullptr, 0, KEY_SET_VALUE,
                      nullptr, &key, nullptr) != ERROR_SUCCESS) {
    return false;
  }

  const auto* raw_name = value_name.empty() ? nullptr : value_name.c_str();
  const auto result = RegSetValueExW(
      key, raw_name, 0, REG_SZ,
      reinterpret_cast<const BYTE*>(value.c_str()),
      static_cast<DWORD>((value.size() + 1) * sizeof(wchar_t)));
  RegCloseKey(key);
  return result == ERROR_SUCCESS;
}

void RegisterOpenWithSupport() {
  const std::wstring executable_path = GetExecutablePath();
  if (executable_path.empty()) {
    return;
  }

  const auto separator_index = executable_path.find_last_of(L"\\/");
  const std::wstring executable_name =
      separator_index == std::wstring::npos
          ? executable_path
          : executable_path.substr(separator_index + 1);
  const std::wstring command = L'"' + executable_path + L'"' + L" \"%1\"";
  const std::wstring classes_root = L"Software\\Classes\\";
  const std::wstring prog_id_root = classes_root + kProgId;
  const std::wstring app_root = classes_root + L"Applications\\" + executable_name;

  WriteRegistryString(HKEY_CURRENT_USER, prog_id_root, L"", kFriendlyName);
  WriteRegistryString(HKEY_CURRENT_USER, prog_id_root + L"\\DefaultIcon", L"",
                      executable_path + L",0");
  WriteRegistryString(HKEY_CURRENT_USER, prog_id_root + L"\\shell\\open\\command",
                      L"", command);

  WriteRegistryString(HKEY_CURRENT_USER, app_root, L"FriendlyAppName",
                      kFriendlyName);
  WriteRegistryString(HKEY_CURRENT_USER, app_root + L"\\shell\\open\\command",
                      L"", command);

  for (const auto* extension : kSupportedExtensions) {
    WriteRegistryString(HKEY_CURRENT_USER, app_root + L"\\SupportedTypes",
                        extension, L"");
  }

  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nullptr, nullptr);
}

}  // namespace

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

  RegisterOpenWithSupport();

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Picavi", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
