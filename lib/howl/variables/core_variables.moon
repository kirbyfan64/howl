-- Copyright 2012-2013 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE.md)

import config from howl

config.define {
  name: 'complete'
  description: 'Controls the operation of auto-completion'
  default: 'auto'
  options: {
    { 'manual', 'Only complete when explicitly asked' }
    { 'auto', 'Complete whenever it is deemed appropriate' }
    { 'always', 'Alway start completion automatically' }
  }
}

config.define {
  name: 'word_pattern'
  description: 'A pattern determining what constitutes a "word" in a buffer'
  default: r'\\b[\\pL_][\\pL\\d_]*\\b'
}

config.define
  name: 'auto_format'
  description: 'Whether to automatically format code when possible'
  default: true
  type_of: 'boolean'
