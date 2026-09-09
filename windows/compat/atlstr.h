#pragma once

#include <windows.h>

#include <stdexcept>
#include <string>

// Minimal compatibility implementation for the only ATL type used by
// flutter_secure_storage_windows. It intentionally does not emulate ATL.
class CA2W {
 public:
  explicit CA2W(const char* source) {
    if (source == nullptr) {
      value_.push_back(L'\0');
      m_psz = value_.data();
      return;
    }
    const int size = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, source,
                                         -1, nullptr, 0);
    if (size <= 0) {
      throw std::runtime_error("UTF-8 to UTF-16 conversion failed");
    }
    value_.resize(static_cast<size_t>(size));
    if (MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, source, -1,
                            value_.data(), size) <= 0) {
      throw std::runtime_error("UTF-8 to UTF-16 conversion failed");
    }
    m_psz = value_.data();
  }

  CA2W(const CA2W&) = delete;
  CA2W& operator=(const CA2W&) = delete;

  wchar_t* m_psz = nullptr;

 private:
  std::wstring value_;
};

class CW2A {
 public:
  explicit CW2A(const wchar_t* source) {
    if (source == nullptr) {
      value_.push_back('\0');
      m_psz = value_.data();
      return;
    }
    const int size = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, source,
                                         -1, nullptr, 0, nullptr, nullptr);
    if (size <= 0) {
      throw std::runtime_error("UTF-16 to UTF-8 conversion failed");
    }
    value_.resize(static_cast<size_t>(size));
    if (WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, source, -1,
                            value_.data(), size, nullptr, nullptr) <= 0) {
      throw std::runtime_error("UTF-16 to UTF-8 conversion failed");
    }
    m_psz = value_.data();
  }

  CW2A(const CW2A&) = delete;
  CW2A& operator=(const CW2A&) = delete;

  operator const char*() const { return m_psz; }

  char* m_psz = nullptr;

 private:
  std::string value_;
};
