---
title: howl.timer
---

# howl.timer

## Overview

The timer module provides support for "timers", that is having functions invoked
at a later time. All callbacks are always invoked on the main GUI thread.

_See also_:

- The [spec](../spec/timer_spec.html) for timer

## Functions

### asap (callback, ...)

Invokes `callback` as soon as possible, passing along any optional extra
parameters passed to `asap`. It might be unclear what the value of having a
callback invoked as soon as possible is, compared to just invoking directly. The
rationale for this is that there are cases where you want to schedule
destructive buffer modifications, but are not allowed to do so at the current
point in time (e.g. when in a signal handler for the `text-deleted` signal).

### after (seconds, callback, ...)

Invokes `callback` after approximately `seconds` seconds, passing along any
optional extra parameters passed to `after`. `seconds` can contain fractions,
allowing you schedule callbacks at sub-second rates.

As an example, the below snippet would cause the text "I was invoked with Log
me!" to be logged after approximately 500 milliseconds:

```moonscript
callback = (text) ->
  log.info "I was invoked with #{text}"

timer.after 0.5, callback, 'Log me!'
```
