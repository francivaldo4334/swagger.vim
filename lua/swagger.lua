local M = {}

function M.openSwaggerUi(swaggerurl)
	if swaggerurl == "" then
		print("Error: URL cannot be empty.")
	else
		print("Opening Swagger UI with URL: " .. swaggerurl)
	end
end

function M.setup()
	vim.api.nvim_create_user_command("SwaggerUi", function(event)
		local swaggerurl = event.args
		M.openSwaggerUi(swaggerurl)
	end, {
		nargs = 1,
		desc = "Define a url do swagger que será utilizada.",
	})
end

return M
