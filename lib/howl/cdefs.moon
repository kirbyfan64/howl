ffi = require 'ffi'

ffi.cdef [[
  typedef char gchar;
  typedef long glong;
  typedef int gint;
  typedef gint gboolean;
  typedef signed long gssize;
  typedef void* gpointer;
  typedef int32_t GQuark;

  typedef struct {
    GQuark  domain;
    gint    code;
    gchar * message;
  } GError;

  void *malloc(size_t size);
  void free(void *ptr);

  glong g_utf8_pointer_to_offset(const gchar *str, const gchar *pos);
]]

return {
  const_char_p: ffi.typeof 'const char *'
  char_p: ffi.typeof 'char *'
  char_arr: ffi.typeof 'char[?]'
  gint: ffi.typeof 'gint'
  GError: ffi.typeof 'GError'
}