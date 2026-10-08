local signs = { Error = "", Warn = "", Hint = "💡", Info = "" }
local severity = vim.diagnostic.severity

-- カーソル行の診断を表示する。
-- 行末に収まるときは行末に、収まらないとき（ウィンドウが狭い・複数行のメッセージ）は
-- 行の下に折り返して出す。標準の virtual_text / virtual_lines は幅に合わせて折り返さないので自前で描く
local ns = vim.api.nvim_create_namespace("cursor_line_diagnostics")
local shown = {} -- bufnr -> { [diagnostic namespace] = diagnostics }
local hl = {
	[severity.ERROR] = "DiagnosticVirtualTextError",
	[severity.WARN] = "DiagnosticVirtualTextWarn",
	[severity.INFO] = "DiagnosticVirtualTextInfo",
	[severity.HINT] = "DiagnosticVirtualTextHint",
}
local width_of = vim.fn.strdisplaywidth

-- カーソル行以外の診断は、行末に薄い色でメッセージの1行目だけを出す
local quiet_ns = vim.api.nvim_create_namespace("quiet_line_diagnostics")
local quiet_hl = {
	[severity.ERROR] = "DiagnosticQuietError",
	[severity.WARN] = "DiagnosticQuietWarn",
	[severity.INFO] = "DiagnosticQuietInfo",
	[severity.HINT] = "DiagnosticQuietHint",
}

-- 色 fg を背景 bg に alpha の割合で寄せる
local function blend(fg, bg, alpha)
	local function ch(c, shift)
		return bit.band(bit.rshift(c, shift), 0xff)
	end
	local out = 0
	for _, shift in ipairs({ 16, 8, 0 }) do
		local v = math.floor(ch(fg, shift) * (1 - alpha) + ch(bg, shift) * alpha + 0.5)
		out = out + bit.lshift(v, shift)
	end
	return out
end

local function set_highlights()
	local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
	for _, name in ipairs({ "Error", "Warn", "Info", "Hint" }) do
		local fg = vim.api.nvim_get_hl(0, { name = "Diagnostic" .. name, link = false }).fg
		vim.api.nvim_set_hl(0, "DiagnosticQuiet" .. name, {
			fg = fg and bg and blend(fg, bg, 0.45) or fg,
			italic = true,
		})
		-- エラー箇所を波線にして見つけやすくする
		local underline = vim.api.nvim_get_hl(0, { name = "DiagnosticUnderline" .. name, link = false })
		underline.underline = nil
		underline.undercurl = true
		vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. name, underline)
	end
end

local function draw_quiet(bufnr, skip_lnum)
	vim.api.nvim_buf_clear_namespace(bufnr, quiet_ns, 0, -1)
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local top = {} -- lnum -> { 最も重い診断, その行の診断数 }
	for _, list in pairs(shown[bufnr] or {}) do
		for _, d in ipairs(list) do
			if d.lnum ~= skip_lnum and d.lnum < line_count then
				local t = top[d.lnum]
				if not t then
					top[d.lnum] = { d, 1 }
				else
					t[2] = t[2] + 1
					if d.severity < t[1].severity then
						t[1] = d
					end
				end
			end
		end
	end
	for lnum, t in pairs(top) do
		local d, count = t[1], t[2]
		local text = "● " .. (vim.split(d.message, "\n", { trimempty = true })[1] or "")
		if count > 1 then
			text = text .. (" (+%d)"):format(count - 1)
		end
		vim.api.nvim_buf_set_extmark(bufnr, quiet_ns, lnum, 0, {
			virt_text = { { "  " }, { text, quiet_hl[d.severity] } },
			virt_text_pos = "eol",
			hl_mode = "combine",
		})
	end
end

-- text を表示幅 width で折り返す。英単語は空白で切り、空白のない長い文（日本語など）は文字単位で切る
local function wrap(text, width)
	local lines = {}
	for _, src in ipairs(vim.split(text, "\n", { trimempty = true })) do
		local line = ""
		for _, char in ipairs(vim.fn.split(src, "\\zs")) do
			if width_of(line .. char) > width then
				local head, tail = line:match("^(.*%S)%s+(%S*)$")
				if head and width_of(tail .. char) <= width then
					table.insert(lines, head)
					line = tail
				else
					table.insert(lines, line)
					line = ""
				end
			end
			if not (line == "" and char:match("%s")) then
				line = line .. char
			end
		end
		table.insert(lines, line)
	end
	return lines
end

local function render()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	draw_quiet(bufnr, lnum)
	local diags = {}
	for _, list in pairs(shown[bufnr] or {}) do
		for _, d in ipairs(list) do
			if d.lnum == lnum then
				table.insert(diags, d)
			end
		end
	end
	if #diags == 0 then
		return
	end
	table.sort(diags, function(a, b)
		return a.severity < b.severity
	end)

	local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
	local text_width = info.width - info.textoff

	-- 行末に出す場合の幅を測る（行の末尾との間に空白1つ）
	local chunks, eol_width, multiline = {}, 1, false
	for _, d in ipairs(diags) do
		local text = "■ " .. d.message .. " "
		multiline = multiline or d.message:find("\n") ~= nil
		eol_width = eol_width + width_of(text)
		table.insert(chunks, { text, hl[d.severity] })
	end
	local line_width = width_of(vim.api.nvim_get_current_line())

	if not multiline and line_width + eol_width <= text_width then
		vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
			virt_text = chunks,
			virt_text_pos = "eol",
			hl_mode = "combine",
		})
		return
	end

	-- 行の下に、行のインデントにそろえて折り返す（狭すぎるときはインデントしない）
	local indent = vim.fn.indent(lnum + 1)
	if text_width - indent < 30 then
		indent = 0
	end
	local virt_lines = {}
	for _, d in ipairs(diags) do
		for i, l in ipairs(wrap(d.message, math.max(text_width - indent - 2, 10))) do
			local prefix = i == 1 and "■ " or "  "
			table.insert(virt_lines, { { string.rep(" ", indent) }, { prefix .. l, hl[d.severity] } })
		end
	end
	vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, { virt_lines = virt_lines })
end

vim.diagnostic.handlers.cursor_line = {
	show = function(namespace, bufnr, diagnostics)
		shown[bufnr] = shown[bufnr] or {}
		shown[bufnr][namespace] = diagnostics
		if bufnr == vim.api.nvim_get_current_buf() then
			render()
		else
			draw_quiet(bufnr)
		end
	end,
	hide = function(namespace, bufnr)
		if shown[bufnr] then
			shown[bufnr][namespace] = nil
		end
		if bufnr == vim.api.nvim_get_current_buf() then
			render()
		elseif vim.api.nvim_buf_is_valid(bufnr) then
			draw_quiet(bufnr)
		end
	end,
}

local group = vim.api.nvim_create_augroup("CursorLineDiagnostics", { clear = true })
vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter", "WinEnter", "WinResized", "VimResized" }, {
	group = group,
	callback = render,
})
-- 離れたウィンドウ・バッファにはカーソル行の診断を残さず、静かな表示だけにする
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = group,
	callback = function(ev)
		vim.api.nvim_buf_clear_namespace(ev.buf, ns, 0, -1)
		draw_quiet(ev.buf)
	end,
})
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = set_highlights,
})
set_highlights()
vim.api.nvim_create_autocmd("BufWipeout", {
	group = group,
	callback = function(ev)
		shown[ev.buf] = nil
	end,
})

vim.diagnostic.config({
	virtual_text = false,
	cursor_line = true, -- 上の vim.diagnostic.handlers.cursor_line を使う
	severity_sort = true,
	signs = {
		text = {
			[severity.ERROR] = signs.Error,
			[severity.WARN] = signs.Warn,
			[severity.HINT] = signs.Hint,
			[severity.INFO] = signs.Info,
		},
	},
})
