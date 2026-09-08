local ffi = require("ffi")

---@class lacer.Material
---@field ambient lacer.Vec3
---@field diffuse lacer.Vec3
---@field specular lacer.Vec3
---@field roughness number

local material = {}

local MATERIAL_SIZE = 48

---@param descriptor lacer.Material
---@return lacer.Material
function material.new(descriptor)
	return {
		ambient = descriptor.ambient,
		diffuse = descriptor.diffuse,
		specular = descriptor.specular,
		roughness = descriptor.roughness,
	}
end

---@param materials lacer.Material[]
---@return ffi.cdata* buffer
---@return number size
function material.pack(materials)
	local size = MATERIAL_SIZE * #materials
	local buffer = ffi.new("uint8_t[?]", math.max(size, 1))
	local f32 = ffi.cast("float*", buffer)

	for index, value in ipairs(materials) do
		local base = (index - 1) * 12

		f32[base + 0], f32[base + 1], f32[base + 2] = value.ambient.x, value.ambient.y, value.ambient.z
		f32[base + 4], f32[base + 5], f32[base + 6] = value.diffuse.x, value.diffuse.y, value.diffuse.z
		f32[base + 8], f32[base + 9], f32[base + 10] = value.specular.x, value.specular.y, value.specular.z
		f32[base + 11] = value.roughness
	end

	return buffer, size
end

return material
