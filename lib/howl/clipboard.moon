-- Copyright 2014 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE.md)

Atom = require 'ljglibs.gdk.atom'
GtkClipboard = require 'ljglibs.gtk.clipboard'

{:config} = howl

config.define {
  name: 'clipboard_max_items',
  description: 'The maximum number of anynomous clips to keep in the clipboard',
  type_of: 'number',
  default: 50,
  scope: 'global'
}

clips = {}
registers = {}
system_clipboard = GtkClipboard.get(Atom.SELECTION_CLIPBOARD)

local Clipboard
Clipboard = {
  push: (item, opts = {}) ->
    item = { text: item } if type(item) == 'string'
    error('Missing required field "text"', 2) unless item.text
    if opts.to
      registers[opts.to] = item
    else
      table.insert clips, 1, item
      clips[config.clipboard_max_items + 1] = nil
      system_clipboard.text = item.text

  clear: ->
    clips = {}
    registers = {}

  synchronize: ->
    system_text = system_clipboard.text
    return unless system_text
    cur = clips[1]
    if not cur or cur.text != system_text
      Clipboard.push system_text

  current: get: ->
    clips[1]

  clips: get: -> clips
  registers: get: -> registers
}

howl.aux.PropertyTable Clipboard
