local ffi = require("ffi")

---@class lacer.Camera
---@field pos lacer.Vec3
---@field forward lacer.Vec3
---@field right lacer.Vec3
---@field up lacer.Vec3
---@field fov number Degrees
local camera = {}

local CAMERA_SIZE = 80

---@param descriptor lacer.Camera
---@return lacer.Camera
function camera.new(descriptor)
	return {
		pos = descriptor.pos,
		forward = descriptor.forward,
		right = descriptor.right,
		up = descriptor.up,
		fov = descriptor.fov,
	}
end

---@param value lacer.Camera
---@param width integer
---@param height integer
---@return ffi.cdata* buffer
---@return number size
function camera.pack(value, width, height)
	local buffer = ffi.new("uint8_t[?]", CAMERA_SIZE)
	local f32 = ffi.cast("float*", buffer)
	local u32 = ffi.cast("uint32_t*", buffer)

	f32[0], f32[1], f32[2] = value.pos.x, value.pos.y, value.pos.z
	f32[4], f32[5], f32[6] = value.forward.x, value.forward.y, value.forward.z
	f32[8], f32[9], f32[10] = value.right.x, value.right.y, value.right.z
	f32[12], f32[13], f32[14] = value.up.x, value.up.y, value.up.z
	f32[15] = value.fov

	u32[16], u32[17] = width, height

	return buffer, CAMERA_SIZE
end

return camera
