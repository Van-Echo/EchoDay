#ifndef RUNNER_WINDOW_VISIBILITY_H_
#define RUNNER_WINDOW_VISIBILITY_H_

#include <windows.h>

// True while any on-screen area of this window is not covered by an opaque
// window above it. Focus is deliberately not part of this decision.
bool HasVisibleWindowArea(HWND window);

#endif
