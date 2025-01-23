local M = {}
function M.openSwaggerUi(swaggerurl)
	print("hello world. you url is " .. swaggerurl)
end

function M.setup(opts)
	local group = vim.api.nvim_create_augroup("swagger", { clear = true })
	vim.api.nvim_create_user_command("SwaggerUi", function(opts)
		local swaggerurl = opts.args
		M.openSwaggerUi(swaggerurl)
	end, {
		nargs = 1,
		desc = "Define a url do swagger que será utilizada.",
		complete = "swagger",
	})
	vim.api.nvim_create_autocmd("AddSwaggerUrl", {
		group = group,
		pattern = "swagger_pat",
		callback = function(event)
			---@type number
			local buf = event.buf == 0 and vim.api.nvim_get_current_buf() or event.buf
			print("hello world")
		end,
	})
end

return M
