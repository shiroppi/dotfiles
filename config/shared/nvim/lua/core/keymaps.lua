-- プラグインのキーマップは lua/plugins/lazy.lua の各 spec の `keys` に置いている
local map = vim.keymap.set

-- コメント（Neovim 組み込みの gc / gcc を呼ぶ）
map("n", "<C-c>", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<C-c>", "gc", { remap = true, desc = "Toggle comment" })

-- システムクリップボード（旧 vim-system-copy の cp / cP / cv / cV）
map({ "n", "x" }, "cp", '"+y', { desc = "Copy to clipboard" })
map("n", "cP", '"+yy', { desc = "Copy line to clipboard" })
map({ "n", "x" }, "cv", '"+p', { desc = "Paste from clipboard" })
map("n", "cV", "<Cmd>put +<CR>", { desc = "Paste clipboard below" })
