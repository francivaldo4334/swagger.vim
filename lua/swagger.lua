local M = {}
local sqlite = require("sqlite.db")
local tbl = require("sqlite.tbl")
local popup = require("plenary.popup")
local curl = require("plenary.curl")
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
---@type BMEntryTable
local selectedurls = tbl("selectedurls", {
	id = true,
	value = { "text" },
})
---@type BMDatabase
local db = sqlite({
	uri = uri,
	swaggerurls = swaggerurls,
	selectedurls = selectedurls,
})

function M.openSwaggerUi()
	if not selectedurls:exists() then
		print("Selecione uma url")
		return
	end
	local _, selectedurl = next(selectedurls:get())
	local _, url = next(swaggerurls:get({ alias = selectedurl.value }))
	local httpurl = url.value:gsub("/$", "") .. "/?format=openapi"
	local success, response = pcall(function()
		return curl.get(httpurl, {
			callback = function(response)
				print("Fim da Requisição")
				if response.status == 200 then
					print("Resposta recebida com sucesso!")
					print(response.body)
				else
					print("Erro na requisição, status:", response.status)
					print("Resposta do servidor:", response.body)
				end
			end,
			options = {
				timeout = 10, -- Ajuste o timeout conforme necessário
			},
		})
	end)

	if not success then
		print("Erro ao fazer a requisição:", response)
		if string.match(response, "timeout") then
			print("A requisição excedeu o tempo limite.")
		else
			print("Outro erro ocorreu:", response)
		end
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

function M.removeSwaggerUrl()
	local urls = swaggerurls:get()
	if #urls == 0 then
		print("Não há dados registrados.")
		return
	end
	local urlOptions = {}
	local i = 0
	for _, url in ipairs(urls) do
		table.insert(urlOptions, url.id .. " " .. url.alias)
		i = i + 1
	end
	popup.create(urlOptions, {
		title = "Urls",
		border = true,
		enter = true,
		cursorline = false,
		highlight = "PopupColor1",
		callback = function(win_id, cel)
			local id = string.gmatch(cel, "[^%s]+")()
			swaggerurls:remove({ id = id })
		end,
	})
end

function M.listSwaggerUrls()
	local urls = swaggerurls:get()
	if #urls == 0 then
		print("Não há dados registrados.")
		return
	end
	local urlOptions = {}
	local i = 0
	for _, url in ipairs(urls) do
		table.insert(urlOptions, url.alias)
		i = i + 1
	end
	popup.create(urlOptions, {
		title = "Urls",
		border = true,
		enter = true,
		cursorline = false,
		highlight = "PopupColor1",
		callback = function(win_id, cel)
			selectedurls:remove()
			selectedurls:insert({
				value = cel,
			})
		end,
	})
end

function M.setup()
	vim.api.nvim_create_user_command("SwaggerUi", function(event)
		M.openSwaggerUi()
	end, {
		nargs = 0,
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

vim.api.nvim_create_user_command("SwaggerSelectUrl", function()
	M.listSwaggerUrls()
end, {
	nargs = 0,
	desc = "Lista as urls cadastradas",
})
vim.api.nvim_create_user_command("SwaggerRemoveUrl", function()
	M.removeSwaggerUrl()
end, {
	nargs = 0,
	desc = "Remove uma url registrada",
})

return M
