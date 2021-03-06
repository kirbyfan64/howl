-- Copyright 2014 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE)

ffi = require 'ffi'
jit = require 'jit'
core = require 'ljglibs.core'
gobject = require 'ljglibs.gobject'
require 'ljglibs.gtk.window'

C = ffi.C
ref_ptr = gobject.ref_ptr

jit.off true, true

core.define 'GtkOffscreenWindow < GtkWindow', {
  new: -> ref_ptr C.gtk_offscreen_window_new!
}, (spec) -> spec.new!
