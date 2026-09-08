local test = require("lde-test")
local hood = require("hood")

local camera = require("lacer.camera")
local light = require("lacer.light")
local material = require("lacer.material")
local vec3 = require("lacer.vec3")

local cube = require("lacer.primitive.cube")

local Renderer = require("lacer.renderer")

local WIDTH = 8
local HEIGHT = 8

local available = pcall(function()
	local instance = hood.Instance.new({ backend = "vulkan", flags = { "headless" } })
	instance:requestAdapter({ powerPreference = "high-performance" }):requestDevice()
end)

---@param name string
---@param fn fun()
local function it(name, fn)
	if available then
		test.it(name, fn)
	else
		test.skip(name)
	end
end

---@return lacer.Scene
local function scene()
	return {
		camera = camera.new({
			pos = vec3.new(-2.0, 0.0, 0.0),
			forward = vec3.new(1.0, 0.0, 0.0),
			right = vec3.new(0.0, 1.0, 0.0),
			up = vec3.new(0.0, 0.0, 1.0),
			fov = 45.0,
		}),
		materials = {
			material.new({
				ambient = vec3.new(0.1, 0.1, 0.1),
				diffuse = vec3.new(0.9, 0.9, 0.9),
				specular = vec3.new(0.1, 0.1, 0.1),
				roughness = 1.0,
			}),
		},
		lights = {
			light.new({
				pos = vec3.new(0.0, 0.0, 2.0),
				radius = 10.0,
				color = vec3.new(1.0, 1.0, 1.0),
			}),
		},
		primitives = {
			cube.new({
				min = vec3.new(0.0, -1.0, -1.0),
				max = vec3.new(1.0, 1.0, 1.0),
				materialId = 0,
			}),
		},
	}
end

---@return lacer.Config
local function config()
	return { width = WIDTH, height = HEIGHT, output = "", backend = "vulkan" }
end

it("renderer: renders deterministic opaque pixels", function()
	local renderer = Renderer.new(scene(), config())
	local first = renderer:render()
	local second = renderer:render()
	renderer:destroy()

	test.equal(#first, WIDTH * HEIGHT * 4)
	test.equal(first, second)

	for index = 4, #first, 4 do
		test.equal(first:byte(index), 255, "pixel " .. index / 4 .. " is opaque")
	end
end)

it("renderer: lit surface reaches the centre pixel", function()
	local renderer = Renderer.new(scene(), config())
	local pixels = renderer:render()
	renderer:destroy()

	local offset = (math.floor(HEIGHT / 2) * WIDTH + math.floor(WIDTH / 2)) * 4

	test.greater(pixels:byte(offset + 1), 50, "centre pixel is lit")
end)
