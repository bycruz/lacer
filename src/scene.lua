local vec3 = require("lacer.vec3")

local camera = require("lacer.camera")
local light = require("lacer.light")
local material = require("lacer.material")
local paths = require("lacer.paths")

local cube = require("lacer.primitive.cube")
local sphere = require("lacer.primitive.sphere")

local Model = require("lacer.model")

---@class lacer.Scene
---@field camera lacer.Camera
---@field materials lacer.Material[]
---@field lights lacer.Light[]
---@field primitives lacer.Primitive[]

local scene = {}

local MATERIAL_WHITE = 0
local MATERIAL_RED = 1
local MATERIAL_GREEN = 2
local MATERIAL_METAL = 3
local MATERIAL_GOLD = 4
local MATERIAL_DRAGON = 5

local MATERIALS = {
	{
		ambient = vec3.new(0.7, 0.7, 0.7),
		diffuse = vec3.new(0.8, 0.8, 0.8),
		specular = vec3.new(0.1, 0.1, 0.1),
		roughness = 1.0,
	},
	{
		ambient = vec3.new(0.6, 0.1, 0.1),
		diffuse = vec3.new(0.8, 0.2, 0.2),
		specular = vec3.new(0.1, 0.1, 0.1),
		roughness = 1.0,
	},
	{
		ambient = vec3.new(0.1, 0.6, 0.1),
		diffuse = vec3.new(0.2, 0.8, 0.2),
		specular = vec3.new(0.1, 0.1, 0.1),
		roughness = 1.0,
	},
	{
		ambient = vec3.new(0.2, 0.2, 0.25),
		diffuse = vec3.new(0.4, 0.4, 0.5),
		specular = vec3.new(0.9, 0.9, 1.0),
		roughness = 0.05,
	},
	{
		ambient = vec3.new(0.24, 0.20, 0.07),
		diffuse = vec3.new(0.75, 0.61, 0.23),
		specular = vec3.new(1.0, 0.87, 0.35),
		roughness = 0.02,
	},
	{
		ambient = vec3.new(0.19, 0.17, 0.08),
		diffuse = vec3.new(0.7, 0.57, 0.23),
		specular = vec3.new(0.95, 0.64, 0.54),
		roughness = 0.1,
	},
}

---@return lacer.Material[]
local function buildMaterials()
	local materials = {}

	for index, value in ipairs(MATERIALS) do
		materials[index] = material.new(value)
	end

	return materials
end

---@param primitives lacer.Primitive[]
local function buildCornellBox(primitives)
	primitives[#primitives + 1] = cube.new({
		min = vec3.new(-200.0, -200.0, -0.1),
		max = vec3.new(200.0, 200.0, 0.0),
		materialId = MATERIAL_WHITE,
	})

	primitives[#primitives + 1] = cube.new({
		min = vec3.new(-1.0, -2.5, 0.0),
		max = vec3.new(5.0, 2.5, 0.1),
		materialId = MATERIAL_WHITE,
	})

	primitives[#primitives + 1] = cube.new({
		min = vec3.new(-1.0, -2.5, 4.9),
		max = vec3.new(5.0, 2.5, 5.0),
		materialId = MATERIAL_WHITE,
	})

	primitives[#primitives + 1] = cube.new({
		min = vec3.new(4.9, -2.5, 0.0),
		max = vec3.new(5.0, 2.5, 5.0),
		materialId = MATERIAL_WHITE,
	})

	primitives[#primitives + 1] = cube.new({
		min = vec3.new(-1.0, -2.5, 0.0),
		max = vec3.new(5.0, -2.4, 5.0),
		materialId = MATERIAL_RED,
	})

	primitives[#primitives + 1] = cube.new({
		min = vec3.new(-1.0, 2.4, 0.0),
		max = vec3.new(5.0, 2.5, 5.0),
		materialId = MATERIAL_GREEN,
	})

	primitives[#primitives + 1] = sphere.new({
		pos = vec3.new(1.5, -1.0, 1.0),
		radius = 0.8,
		materialId = MATERIAL_METAL,
	})
end

---@param primitives lacer.Primitive[]
local function buildDragon(primitives)
	local loaded, dragon = pcall(Model.loadObj, paths.asset("dragon.obj"), MATERIAL_DRAGON)
	if not loaded then
		io.stderr:write("failed to load dragon model: ", tostring(dragon), "\n")
		return
	end

	dragon
		:scale(20.0)
		:rotate(vec3.new(1.0, 0.0, 0.0), math.pi / 2.0)
		:translate(vec3.new(2.5, 1.0, -1.0))

	for _, value in ipairs(dragon:toPrimitives()) do
		primitives[#primitives + 1] = value
	end
end

---@return lacer.Scene
function scene.cornellBox()
	local primitives = {}

	buildCornellBox(primitives)
	buildDragon(primitives)

	return {
		camera = camera.new({
			pos = vec3.new(-8.0, 0.0, 2.5),
			forward = vec3.new(1.0, 0.0, 0.0),
			right = vec3.new(0.0, 1.0, 0.0),
			up = vec3.new(0.0, 0.0, 1.0),
			fov = 45.0,
		}),
		materials = buildMaterials(),
		lights = {
			light.new({
				pos = vec3.new(2.0, 0.0, 4.8),
				radius = 40.0,
				color = vec3.new(1.0, 1.0, 1.0),
			}),
		},
		primitives = primitives,
	}
end

return scene
