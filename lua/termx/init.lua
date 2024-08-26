local M = {}

M._state = {}

local function is_term_window_open()
	return M._state.term_win_id ~= nil
end

local function has_term_buf()
	return M._state.term_buf_id ~= nil
end

M.open = function()
	if is_term_window_open() then
		print("Terminal is already open")
		return
	end

	if has_term_buf() then
		local win_id = vim.api.nvim_open_win(M._state.term_buf_id, true, {
			split = "right",
			win = 0,
		})
		M._state.term_win_id = win_id
	else
		local buf_id = vim.api.nvim_create_buf(false, true)
		M._state.term_buf_id = buf_id
		local win_id = vim.api.nvim_open_win(buf_id, true, {
			split = "right",
			win = 0,
		})
		M._state.term_win_id = win_id

		local job_id = vim.fn.termopen("zsh")
		M._state.term_job_id = job_id
	end
end

M.hide = function()
	if is_term_window_open() then
		vim.api.nvim_win_hide(M._state.term_win_id)
		M._state.term_win_id = nil
	end
end

M.toggle = function()
	if is_term_window_open() then
		M.hide()
	else
		M.open()
	end
end
M.close = function()
	if is_term_window_open() then
		vim.api.nvim_win_close(M._state.term_win_id, true)
		M._state = {}
	end
end

M.run = function(cmd)
	if not is_term_window_open() then
		print("Terminal is not open")
		return
	end
	vim.api.nvim_chan_send(M._state.term_job_id, cmd .. "\n")
end

M.setup = function()
	vim.keymap.set("n", "<leader>to", M.open, { desc = "[T]erminal: [O]pen" })
	vim.keymap.set("n", "<leader>th", M.hide, { desc = "[T]erminal: [H]ide" })
	vim.keymap.set("n", "<leader>tt", M.toggle, { desc = "[T]erminal: [T]oggle" })
	vim.keymap.set("n", "<leader>tc", M.close, { desc = "[T]erminal: [C]lose" })
end

-- M.open()
-- M.run("ls")
-- M.run("git status")
-- M.run("ls")

return M
