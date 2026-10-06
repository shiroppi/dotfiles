-- SpaceをLeaderキーに設定
vim.g.mapleader = " "

-- load core
require("core.options")
require("core.colors") -- ColorScheme autocmd はカラースキーム適用前に登録する必要がある
require("core.keymaps")
require("core.commands")
require("core.filetypes")
require("core.lsp")

-- load plugins
require("plugins.lazy")
