local ffi = require("ffi")

---@class lacer.Light
---@field pos lacer.Vec3
---@field radius number
---@field color lacer.Vec3

local light = {}

local LIGHT_SIZE = 32

---@param descriptor lacer.Light
---@return lacer.Light
function light.new(descriptor)
	return {
		pos = descriptor.pos,
		radius = descriptor.radius,
		color = descriptor.color,
	}
end

---@param lights lacer.Light[]
---@return ffi.cdata* buffer
---@return number size
function light.pack(lights)
	local size = LIGHT_SIZE * #lights
	local buffer = ffi.new("uint8_t[?]", math.max(size, 1))
	local f32 = ffi.cast("float*", buffer)

	for index, value in ipairs(lights) do
		local base = (index - 1) * 8

		f32[base + 0], f32[base + 1], f32[base + 2] = value.pos.x, value.pos.y, value.pos.z
		f32[base + 3] = value.radius
		f32[base + 4], f32[base + 5], f32[base + 6] = value.color.x, value.color.y, value.color.z
	end

	return buffer, size
end

return light
