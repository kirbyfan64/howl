-- Copyright 2014 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE)

{
  lexer: bundle_load('javascript_lexer')

  comment_syntax: '//'

  auto_pairs: {
    '(': ')'
    '[': ']'
    '{': '}'
    '"': '"'
    '"': '"'
  }
}
