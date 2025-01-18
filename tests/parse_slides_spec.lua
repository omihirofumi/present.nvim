---@diagnostic disable: undefined-global
local parse = require("present")._parse_lines

local eq = assert.are.same
describe("present.parse_slides", function()
	it("should parse an empty file", function()
		eq({
			slides = {
				{
					title = "",
					body = {},
					blocks = {},
				},
			},
		}, parse({}))
	end)

	it("should parse a file with one slide", function()
		eq(
			{
				slides = {
					{
						title = "# This is the first slide",
						body = {
							"This is the body",
						},
						blocks = {},
					},
				},
			},
			parse({
				"# This is the first slide",
				"This is the body",
			})
		)
	end)

	it("should parse a file with one slide, and a block", function()
		local results = parse({
			"# This is the first slide",
			"This is the body",
			"```lua",
			"print('hi')",
			"```",
		})

		eq(1, #results.slides)

		local slide = results.slides[1]
		eq("# This is the first slide", slide.title)
		eq({
			"This is the body",
			"```lua",
			"print('hi')",
			"```",
		}, slide.body)

		local block = {
			language = "lua",
			body = vim.trim([[
      print('hi')
          ]]),
		}
		eq(block, slide.blocks[1])
		-- eq(
		-- 	{
		-- 		slides = {
		-- 			{
		-- 				title = "# This is the first slide",
		-- 				body = {
		-- 					"This is the body",
		-- 				},
		-- 				blocks = {
		-- 					{
		-- 						vim.trim([[
		--               ```lua
		--               print('hi')
		--               ```
		--               ]]),
		-- 					},
		-- 				},
		-- 			},
		-- 		},
		-- 	},
		-- 	parse({
		-- 		"# This is the first slide",
		-- 		"This is the body",
		-- 	})
		-- )
	end)
end)
