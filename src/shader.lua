local paths = require("lacer.paths")

local shader = {}

local shaderDir = paths.packageDir .. "/shaders"

---@param path string
---@return string
local function readFile(path)
	local file, err = io.open(path, "rb")
	if not file then
		error(err, 3)
	end

	local content = file:read("*a")
	file:close()

	return content
end

---@param source string
---@param directory string
---@param seen table<string, boolean>
---@return string
local function resolveIncludes(source, directory, seen)
	return (source:gsub('#include%s+"([^"]+)"', function(name)
		local path = directory .. "/" .. name

		if seen[path] then
			error("circular shader include: " .. path, 2)
		end

		seen[path] = true
		local resolved = resolveIncludes(readFile(path), path:match("^(.*)[/\\]") or ".", seen)
		seen[path] = nil

		return resolved
	end))
end

---@param name string
---@return string
function shader.source(name)
	local path = shaderDir .. "/" .. name .. ".comp.glsl"

	return resolveIncludes(readFile(path), shaderDir, { [path] = true })
end

---@param name string
---@return string
function shader.spirv(name)
	local path = shaderDir .. "/" .. name .. ".comp.spv"

	local file = io.open(path, "rb")
	if not file then
		error(path .. " is missing: delete the target directory and re-run to rebuild it", 3)
	end

	local content = file:read("*a")
	file:close()

	return content
end

---@param name string
---@param backend "vulkan" | "opengl"
---@return hood.ShaderModule
function shader.load(name, backend)
	if backend == "opengl" then
		return { type = "glsl", source = shader.source(name) }
	end

	return { type = "spirv", source = shader.spirv(name) }
end

return shader
