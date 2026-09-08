local build = require("lde-build")

local shaderDir = "shaders"
local entryPoints = { "path" }

---@param name string
local function compile(name)
	local source = ("%s/%s.comp.glsl"):format(shaderDir, name)
	local output = ("%s/%s.comp.spv"):format(shaderDir, name)

	build:sh(('glslc -fshader-stage=comp -I "%s" "%s" -o "%s"')
		:format(build.outDir .. "/" .. shaderDir, build.outDir .. "/" .. source, build.outDir .. "/" .. output))
end

local hasGlslc = pcall(function()
	build:sh("glslc --version")
end)

if hasGlslc then
	for _, name in ipairs(entryPoints) do
		compile(name)
	end
else
	io.stderr:write("glslc not found: skipping SPIR-V compilation (the vulkan backend needs it, opengl does not)\n")
end
