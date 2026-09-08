local test = require("lde-test")

local config = require("lacer.config")

test.it("config: defaults to a 1920x1080 vulkan render", function()
	local options = config.parse()

	test.equal(options.width, 1920)
	test.equal(options.height, 1080)
	test.equal(options.output, "output.png")
	test.equal(options.backend, "vulkan")
end)

test.it("config: parses long options with a space or an equals sign", function()
	local options = config.parse({ "--width", "320", "--height=180", "--output", "small.png" })

	test.equal(options.width, 320)
	test.equal(options.height, 180)
	test.equal(options.output, "small.png")
end)

test.it("config: accepts the opengl backend", function()
	test.equal(config.parse({ "--backend", "opengl" }).backend, "opengl")
end)

test.it("config: rejects unknown options and backends", function()
	test.errors(function()
		config.parse({ "--nope" })
	end)
	test.errors(function()
		config.parse({ "--backend", "metal" })
	end)
	test.errors(function()
		config.parse({ "--width", "zero" })
	end)
end)
