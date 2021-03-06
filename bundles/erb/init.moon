mode_reg =
  name: 'erb'
  extensions: { 'erb', 'rhtml' }
  create: -> bundle_load('erb_mode')

howl.mode.register mode_reg

unload = -> howl.mode.unregister 'erb'

return {
  info:
    author: 'Copyright 2014 Nils Nordman <nino at nordman.org>',
    description: 'erb support',
    license: 'MIT',
  :unload
}
