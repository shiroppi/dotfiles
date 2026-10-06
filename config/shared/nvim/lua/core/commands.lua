local function show_slime_greeting()
	local slime_art = {
		"        ∩─────────∩",
		"       (  ◕     ◕  )",
		"      /   ＞   ＜   \\",
		"     (  ~~~~~~~~~~~~~~~~ )",
		"    (                    )",
		"     (  ~~~~~~~~~~~~~~~~ )",
		"      \\               /",
		"       \\─────────────/",
		"         ~~     ~~",
		"",
		"    Hello, I'm HidemaruOwO!!",
		"       Have a nice day!",
	}

	-- 新しいバッファを作成
	local buf = vim.api.nvim_create_buf(false, true)

	-- アスキーアートをバッファに設定
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, slime_art)

	-- ウィンドウの設定
	local width = 35
	local height = #slime_art
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
		title = " PuyoPuyo Slime ",
		title_pos = "center",
	})

	-- バッファの設定
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"

	-- ESCキーまたはqキーで閉じる
	vim.keymap.set("n", "<Esc>", "<Cmd>close<CR>", { buffer = buf })
	vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = buf })

	-- 3秒後に自動で閉じる
	vim.defer_fn(function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, false)
		end
	end, 3000)
end

-- コマンドを作成
vim.api.nvim_create_user_command("SlimeGreeting", show_slime_greeting, {})
