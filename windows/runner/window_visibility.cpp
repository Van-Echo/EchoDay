#include "window_visibility.h"

#include <dwmapi.h>

namespace {

bool IsCloaked(HWND window) {
  DWORD cloaked = 0;
  return SUCCEEDED(DwmGetWindowAttribute(window, DWMWA_CLOAKED, &cloaked,
                                       sizeof(cloaked))) && cloaked != 0;
}

RECT VisibleBounds(HWND window) {
  RECT bounds{};
  if (FAILED(DwmGetWindowAttribute(window, DWMWA_EXTENDED_FRAME_BOUNDS,
                                   &bounds, sizeof(bounds)))) {
    GetWindowRect(window, &bounds);
  }
  return bounds;
}

BOOL CALLBACK AddMonitor(HMONITOR, HDC, LPRECT bounds, LPARAM context) {
  HRGN monitors = reinterpret_cast<HRGN>(context);
  HRGN monitor = CreateRectRgnIndirect(bounds);
  CombineRgn(monitors, monitors, monitor, RGN_OR);
  DeleteObject(monitor);
  return TRUE;
}

bool IsOpaque(HWND window) {
  const LONG_PTR style = GetWindowLongPtr(window, GWL_EXSTYLE);
  if ((style & WS_EX_LAYERED) == 0) return true;
  BYTE alpha = 0;
  DWORD flags = 0;
  COLORREF color = 0;
  // Per-pixel alpha and colour-key windows may have transparent holes. Do not
  // incorrectly stop the ticker underneath overlays we cannot prove opaque.
  return GetLayeredWindowAttributes(window, &color, &alpha, &flags) &&
         (flags & LWA_ALPHA) && alpha == 255 && !(flags & LWA_COLORKEY);
}

}  // namespace

bool HasVisibleWindowArea(HWND window) {
  if (!IsWindowVisible(window) || IsIconic(window) || IsCloaked(window)) {
    return false;
  }
  const RECT bounds = VisibleBounds(window);
  HRGN remaining = CreateRectRgnIndirect(&bounds);
  HRGN monitors = CreateRectRgn(0, 0, 0, 0);
  EnumDisplayMonitors(nullptr, nullptr, AddMonitor,
                      reinterpret_cast<LPARAM>(monitors));
  CombineRgn(remaining, remaining, monitors, RGN_AND);
  DeleteObject(monitors);

  DWORD own_process = 0;
  GetWindowThreadProcessId(window, &own_process);
  for (HWND above = GetWindow(window, GW_HWNDPREV); above != nullptr;
       above = GetWindow(above, GW_HWNDPREV)) {
    if (!IsWindowVisible(above) || IsIconic(above) || IsCloaked(above) ||
        !IsOpaque(above)) continue;
    DWORD process = 0;
    GetWindowThreadProcessId(above, &process);
    if (process == own_process) continue;
    const RECT cover_bounds = VisibleBounds(above);
    RECT intersection{};
    if (!IntersectRect(&intersection, &bounds, &cover_bounds)) continue;
    HRGN cover = CreateRectRgn(0, 0, 0, 0);
    if (GetWindowRgn(above, cover) == ERROR) {
      SetRectRgn(cover, cover_bounds.left, cover_bounds.top,
                 cover_bounds.right, cover_bounds.bottom);
    } else {
      RECT origin{};
      GetWindowRect(above, &origin);
      OffsetRgn(cover, origin.left, origin.top);
    }
    const int result = CombineRgn(remaining, remaining, cover, RGN_DIFF);
    DeleteObject(cover);
    if (result == NULLREGION) break;
  }
  RECT remaining_bounds{};
  const bool visible = GetRgnBox(remaining, &remaining_bounds) != NULLREGION;
  DeleteObject(remaining);
  return visible;
}
