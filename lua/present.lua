local M = {}

M.setup = function()
	-- nothing
end

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)

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
		border = "rounded",
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
		print(line, "find:", line:find(seperator), "|")
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

	vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[1])
end

vim.print(parse_slides({
	"# Hello",
	"This is something else",
	"# World",
	"this is another thing",
}))

M.start_presentation({ bufnr = 57 })

return M
