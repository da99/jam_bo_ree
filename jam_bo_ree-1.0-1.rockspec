
package = "jam_bo_ree"
version = "1.0-1"
source = {
  url = "https://github.com/da99/jam_bo_ree.git",
  tag = "1.0",
  dir = "."
}
description = {
  summary = "My personal event emitter.",
  detailed = [[
    Don't use this. You won't like it.
  ]],
  homepage = "http://github.com/da99/jam_bo_ree",
  license = "MIT/X11",
  maintainer = "da99@da99"
}
dependencies = {
  "lua >= 5.1",
  "penlight >= 0.1",
  "underscore >= 0.1"
}
build = {
  type = "builtin",
  modules = {
    jam_bo_ree = "jam_bo_ree.lua"
  }
}
