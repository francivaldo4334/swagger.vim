local M = {}
local sqlite = require("sqlite.db") --- for constructing sql databases
local tbl = require("sqlite.tbl") --- for constructing sql tables
local uri = "~/.local/share/nvim/lazy/swagger.vim/swagger.db"

---@class BMEntryTable: sqlite_tbl

---@class BMDatabase: sqlite_db
---@field swaggerurls BMEntryTable

---@type BMEntryTable
local swaggerurls = tbl("swaggerurls", {
	id = true,
	value = { "text", required = true },
	alias = { "text", required = true, unique = true },
})
---@type BMDatabase
local db = sqlite({
	uri = uri,
	swaggerurls = swaggerurls,
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
	swaggerurls:insert({
		alias = alias,
		value = url,
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
