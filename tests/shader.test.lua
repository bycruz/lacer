local test = require("lde-test")

local paths = require("lacer.paths")
local shader = require("lacer.shader")

test.it("shader: resolves every include into one source", function()
	local source = shader.source("path")

	test.falsy(source:find("#include"), "no include directives remain")
	test.truthy(source:find("void main", 1, true), "entry point is present")
	test.truthy(source:find("vec3 tracePath", 1, true), "path tracing code is present")
end)

test.it("shader: keeps the version directive first", function()
	test.equal(shader.source("path"):sub(1, 14), "#version 430 c")
end)

test.it("shader: loads glsl for the opengl backend", function()
	local module = shader.load("path", "opengl")

	test.equal(module.type, "glsl")
	test.truthy(module.source:find("void main", 1, true))
end)

local spirvFile = io.open(paths.packageDir .. "/shaders/path.comp.spv", "rb")
if spirvFile then
	spirvFile:close()

	test.it("shader: loads spirv for the vulkan backend", function()
		local module = shader.load("path", "vulkan")

		test.equal(module.type, "spirv")
		test.equal(module.source:sub(1, 4), string.char(0x03, 0x02, 0x23, 0x07))
	end)
else
	test.skip("shader: loads spirv for the vulkan backend")
end
