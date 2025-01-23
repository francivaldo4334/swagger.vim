local M = {}
function M.openSwaggerUi(swaggerurl)
	print("hello world. you url is " .. swaggerurl)
end

function M.setup(opts)
	vim.api.nvim_create_user_command("SwaggerUi", function(opts)
		local swaggerurl = opts.args
		M.openSwaggerUi(swaggerurl)
	end, {
		nargs = 1,
		desc = "Define a url do swagger que será utilizada.",
		complete = "swagger",
	})
end

return M
