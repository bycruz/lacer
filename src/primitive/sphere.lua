local primitive = require("lacer.primitive")

---@class lacer.SphereDescriptor
---@field pos lacer.Vec3
---@field radius number
---@field materialId integer

local sphere = {}

---@param descriptor lacer.SphereDescriptor
---@return lacer.Primitive
function sphere.new(descriptor)
	return {
		tag = primitive.TAG.SPHERE,
		materialId = descriptor.materialId,
		data0 = 0,
		data1 = 0,
		data2 = { descriptor.pos.x, descriptor.pos.y, descriptor.pos.z, descriptor.radius },
		data3 = { 0, 0, 0, 0 },
	}
end

return sphere
