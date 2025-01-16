local M = {}

M.setup = function()
	-- nothing
end

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or vim.o.columns
	local height = opts.height or vim.o.lines

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local buf = vim.api.nvim_create_buf(false, true)

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = { " ", " ", " ", " ", " ", " ", " ", " " },
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

---@class present.Slides
---@fields slides string[]: The slides of the file

--- Takes some lines and parses them
--- @param lines string[]; The lines in the buffer
--- @return present.Slides
local parse_slides = function(lines)
	local slides = { slides = {} }
	local current_slide = {}

	local seperator = "^#"
	for _, line in ipairs(lines) do
		-- print(line, "find:", line:find(seperator), "|")
		if line:find(seperator) then
			if #current_slide > 0 then
				table.insert(slides.slides, current_slide)
			end

			current_slide = {}
		end

		table.insert(current_slide, line)
	end
	table.insert(slides.slides, current_slide)
	return slides
end

M.start_presentation = function(opts)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0
	local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
	local parsed = parse_slides(lines)
	local float = create_floating_window()

	local current_slide = 1
	vim.keymap.set("n", "n", function()
		current_slide = math.min(current_slide + 1, #parsed.slides)
		vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
	end, {
		buffer = float.buf,
	})
	vim.keymap.set("n", "p", function()
		current_slide = math.max(1, current_slide - 1)
		vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
	end, {
		buffer = float.buf,
	})
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(float.win, true)
	end, {
		buffer = float.buf,
	})

	local restore = {
		cmdheight = {
			original = vim.o.cmdheight,
			present = 0,
		},
	}

	for option, config in pairs(restore) do
		vim.opt[option] = config.present
	end

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = float.buf,
		callback = function()
			for option, config in pairs(restore) do
				vim.opt[option] = config.original
			end
		end,
	})

	vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[1])
end

-- vim.print(parse_slides({
-- 	"# Hello",
-- 	"This is something else",
-- 	"# World",
-- 	"this is another thing",
-- }))

M.start_presentation({ bufnr = 272 })

return M
