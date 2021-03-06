-- Copyright 2012-2013 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE.md)

import PropertyObject from howl.aux.moon
import style, highlight from howl.ui
import Matcher from howl.util

style.define_default 'list_header', color: '#5E5E5E', underline: true
style.define_default 'list_caption', {}
style.define_default 'list_highlight', color: '#ffffff', underline: true

highlight.define_default 'list_selection', {
  style: highlight.ROUNDBOX,
  color: '#888888'
  alpha: 50
  outline_alpha: 100
}

calculate_column_widths = (items, headers) ->
    widths = {}

    for item in *items
      item = { item } if type(item) != 'table'
      for i, col in ipairs item
        widths[i] = math.max(widths[i] or 0, #tostring(col))

    if headers and #headers > 0
      for i, col in ipairs headers
        widths[i] = math.max(widths[i] or 0, #tostring(col))

    widths

column_padding = (field, column, widths) ->
  return '' if column == #widths
  string.rep ' ', (widths[column] - tostring(field).ulen) + 1

highlighter = (search, text) ->
  Matcher.explain search, text

class List extends PropertyObject
  column_styles: { 'string', 'comment', 'keyword', 'number' }

  new: (buffer, pos) =>
    @buffer = buffer
    @start_pos = pos
    @max_height = nil
    @offset = 1
    @selection_enabled = false
    @trailing_newline = true
    @column_styles = moon.copy @column_styles
    @highlighter = highlighter
    super!

  @property items:
    get: => @_items
    set: (items) =>
      @_items = items or {}
      @_widths = nil
      @offset = 1
      @_sel_row = nil

  @property headers:
    get: => @_headers
    set: (headers) =>
      @_headers = headers or {}
      @_widths = nil

  @property selection:
    get: => @_sel_row and @items[@_sel_row] or nil
    set: (sel_item) =>
      for i, item in ipairs @items
        if sel_item == item
          @select i
          return

      error 'Could not set selection: ' .. tostring(sel_item) .. ' was not found', 2

  @property limit:
    get: =>
      return nil if not @max_height
      height = @max_height
      height -= 1 if @headers and #@headers > 0
      height

  clear: =>
    if @end_pos and @end_pos > 1
      @buffer\delete @start_pos, @end_pos - 1
      @end_pos = nil

  @property showing:
    get: => @end_pos != nil

  scroll_to: (row) =>
    error 'List is not shown', 2 if not @showing

    total = #@items
    max_item_lines = (@last_shown - @offset) + 1
    @offset = row
    if @offset < 1
      @offset = 1
    elseif @offset > total or (total - @offset) + 1 < max_item_lines
      @offset = (total - max_item_lines) + 1

    @show!
    @select row if @selection_enabled

  prev_page: =>
    return if not @max_height
    row = @offset - (@last_shown - @offset) - 1
    if row < 1
      row = @offset == 1 and #@items or 1
    @scroll_to row

  next_page: =>
    return if not @max_height
    row = @last_shown + 1
    row = 1 if row > #@items
    @scroll_to row

  select_prev: =>
    row = @_sel_row - 1
    row = #@items if row < 1

    if row < @offset or row > @last_shown
      offset = row - @limit + 1
      @scroll_to math.max offset, 1

    @select row

  select_next: =>
    row = @_sel_row + 1
    row = 1 if row > #@items

    if row < @offset or row > @last_shown
      @scroll_to row

    @select row

  select: (row) =>
    error 'Selection is not enabled', 2 if not @selection_enabled
    if row < 1 or row > #@items
      error 'Row "' .. row .. '" out of range', 2

    @_sel_row = row

    if @showing
      highlight.remove_all 'list_selection', @buffer

      if row >= @offset and row <= @last_shown
        lines = @buffer.lines
        start_line = lines\at_pos(@item_start_pos).nr
        sel_line = start_line + (row - @offset)
        pos = lines[sel_line].start_pos
        length = #lines[sel_line]
        highlight.apply 'list_selection', @buffer, pos, length
      else
        @scroll_to row

  show: =>
    error "List: show() called without .items set", 2 unless @items

    @clear!

    total = #@items
    max_height = @max_height or math.huge
    nr_lines = 0
    pos = @start_pos
    buffer = @buffer

    if not @_widths
      @_widths = calculate_column_widths @items, @headers
      @_multi_column = #@_widths > 1

    if @caption and nr_lines < max_height
      cap = @caption .. '\n'
      pos = buffer\insert cap, pos, 'list_caption'
      nr_lines += cap\count '\n'

    if @headers and #@headers > 0 and nr_lines < max_height
      for column, header in ipairs @headers
        padding = column_padding header, column, @_widths
        pos = buffer\insert header, pos, 'list_header'
        pos = buffer\insert padding, pos

      pos = buffer\insert '\n', pos
      nr_lines += 1

    lines_left = max_height - nr_lines

    if total > lines_left
      @last_shown = math.min @offset + (lines_left - 2), total
    else
      @last_shown = total

    @nr_shown = @last_shown - @offset + 1
    @item_start_pos = pos
    total_length = 0
    total_length += width for width in *@_widths
    total_length += #@_widths if @_multi_column

    for row = @offset, @last_shown
      item = @items[row]
      start_pos = pos
      text = ''
      if @_multi_column
        for column, field in ipairs item
          padding = column_padding field, column, @_widths
          pos = buffer\insert field, pos, @_column_style(item, row, column)
          pos = buffer\insert padding, pos
          text ..= tostring(field) .. padding
      else
        text = tostring item
        pos = buffer\insert text, pos, @_column_style(item, row, 1)

      if @highlight_matches_for and not @highlight_matches_for.is_blank
        positions = self.highlighter @highlight_matches_for, text
        if positions
          for hl_pos in *positions
            p = start_pos + hl_pos - 1
            @buffer\style p, p, 'list_highlight'

      if @selection_enabled
        extra_spaces = total_length - (pos - start_pos)
        if extra_spaces > 0
          padding = string.rep ' ', extra_spaces
          pos = buffer\insert padding, pos

      if row != @last_shown
        pos = buffer\insert '\n', pos

      nr_lines += 1

    -- truncated list
    if total > lines_left and nr_lines < max_height
      info = string.format '\n[..] (showing %d - %d out of %d)',
        @offset, @last_shown, total
      pos = @buffer\insert info, pos, 'comment'
      nr_lines += 1

    pos = @buffer\insert '\n', pos if @trailing_newline

    if @min_height and nr_lines < @min_height
      filler_text = @filler_text or ''
      filler = filler_text\rep(@min_height - nr_lines, '\n') .. '\n'
      pos = @buffer\insert filler, pos, 'comment'

    @_sel_row = @offset if not @_sel_row and @selection_enabled
    @end_pos = pos
    @height = nr_lines

    @select @_sel_row if @_sel_row and #@items > 0

    pos

  @meta {
    __len: => #@items
  }

  _column_style: (item, row, column) =>
    if callable @column_styles then return self.column_styles(item, row, column)
    @column_styles[column]


return List
