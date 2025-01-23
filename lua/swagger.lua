local M = {}

local sqlite = require("sqlite")
---@class Swagger: sqlite_db
---@field swaggerurls sqlite_tbl
local db = sqlite({
	uri = "~/.local/share/nvim/lazy/swagger.vim/swagger.db",
	swaggerurls = {
		id = true,
		value = { "text" },
		alias = { "text", unique = true },
	},
})

function M.openSwaggerUi(swaggerurl)
	if swaggerurl == "" then
		print("Error: URL cannot be empty.")
	else
		print("Opening Swagger UI with URL: " .. swaggerurl)
	end
end

---@param url string
---@param alias string
function M.addSwaggerUrl(url, alias)
	db:create("swaggerurls", {
		value = url,
		alias = alias,
	})
end

function M.setup()
	vim.api.nvim_create_user_command("SwaggerUi", function(event)
		local swaggerurl = event.args
		M.openSwaggerUi(swaggerurl)
	end, {
		nargs = 1,
		desc = "Define a url do swagger que será utilizada.",
	})
	vim.api.nvim_create_user_command("SwaggerAddUrl", function(event)
		local args = {}
		local i = 0
		for arg in string.gmatch(event.args, "[^%s]+") do
			args[i] = arg
			i = i + 1
		end
		local url = args[0]
		local alias = args[1]
		if not url then
			print("Error: argumento 'url' é obrigatorio")
		end
		if not alias then
			print("Error: argumento 'alias' é obrigatorio")
		end
		if url and alias then
			M.addSwaggerUrl(url, alias)
		end
	end, {
		nargs = "*",
		desc = "<url> <url-alias>",
	})
end

return M
