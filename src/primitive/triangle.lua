local primitive = require("lacer.primitive")

---@class lacer.Triangle
---@field v0 lacer.Vec3
---@field v1 lacer.Vec3
---@field v2 lacer.Vec3

---@class lacer.TriangleDescriptor
---@field v0 lacer.Vec3
---@field v1 lacer.Vec3
---@field v2 lacer.Vec3
---@field materialId integer

local triangle = {}

---@param descriptor lacer.TriangleDescriptor
---@return lacer.Primitive
function triangle.new(descriptor)
	return {
		tag = primitive.TAG.TRIANGLE,
		materialId = descriptor.materialId,
		data0 = descriptor.v0.x,
		data1 = descriptor.v0.y,
		data2 = { descriptor.v0.z, descriptor.v1.x, descriptor.v1.y, descriptor.v1.z },
		data3 = { descriptor.v2.x, descriptor.v2.y, descriptor.v2.z, 0 },
	}
end

return triangle
