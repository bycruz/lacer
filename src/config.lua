local config = {}

---@alias lacer.Backend "vulkan" | "opengl"

---@class lacer.Config
---@field width integer
---@field height integer
---@field output string
---@field backend lacer.Backend

local DEFAULTS = {
	width = 1920,
	height = 1080,
	output = "output.png",
	backend = "vulkan",
}

local BACKENDS = {
	vulkan = true,
	opengl = true,
}

local PARSERS = {
	width = tonumber,
	height = tonumber,
	output = tostring,
	backend = tostring,
}

---@param args string[]?
---@return lacer.Config
function config.parse(args)
	local options = {}

	for key, value in pairs(DEFAULTS) do
		options[key] = value
	end

	local environment = os.getenv("LACER_BACKEND")
	if environment then
		options.backend = environment
	end

	local index = 1

	while args and index <= #args do
		local name, inline = args[index]:match("^%-%-([%w-]+)=?(.*)$")
		local parser = name and PARSERS[name]

		if not parser then
			error("unknown option: " .. args[index], 2)
		end

		local value = inline
		if value == "" then
			index = index + 1
			value = args[index]
		end

		if not value then
			error("missing value for option: " .. name, 2)
		end

		local parsed = parser(value)
		if not parsed then
			error("invalid value for option: " .. name .. "=" .. value, 2)
		end

		options[name] = parsed
		index = index + 1
	end

	options.width = math.floor(options.width)
	options.height = math.floor(options.height)

	if options.width < 1 or options.height < 1 then
		error("render size must be positive", 2)
	end

	if not BACKENDS[options.backend] then
		error("unknown backend: " .. options.backend, 2)
	end

	return options
end

return config
