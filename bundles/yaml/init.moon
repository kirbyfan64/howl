-- Copyright 2013 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE)

mode_reg =
  name: 'yaml'
  extensions: { 'yml', 'yaml' }
  create: -> bundle_load('yaml_mode')!

howl.mode.register mode_reg

unload = -> howl.mode.unregister 'yaml'

return {
  info:
    author: 'Copyright 2013 Nils Nordman <nino at nordman.org>',
    description: 'YAML mode',
    license: 'MIT',
  :unload
}
