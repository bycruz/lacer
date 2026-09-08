local primitive = require("lacer.primitive")

---@class lacer.CubeDescriptor
---@field min lacer.Vec3
---@field max lacer.Vec3
---@field materialId integer

local cube = {}

---@param descriptor lacer.CubeDescriptor
---@return lacer.Primitive
function cube.new(descriptor)
	return {
		tag = primitive.TAG.CUBE,
		materialId = descriptor.materialId,
		data0 = descriptor.min.x,
		data1 = descriptor.min.y,
		data2 = { descriptor.min.z, descriptor.max.x, descriptor.max.y, descriptor.max.z },
		data3 = { 0, 0, 0, 0 },
	}
end

return cube
