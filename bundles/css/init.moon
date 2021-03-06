-- Copyright 2013 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE.md)

mode_reg =
  name: 'css'
  aliases: 'scss'
  extensions: {'css', 'scss'}
  create: -> bundle_load('css_mode')!
  parent: 'curly_mode'

howl.mode.register mode_reg

unload = -> howl.mode.unregister 'css'

return {
  info:
    author: 'Copyright 2013 Nils Nordman <nino at nordman.org>',
    description: 'CSS mode',
    license: 'MIT',
  :unload
}
