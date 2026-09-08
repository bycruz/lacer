local mat4 = require("lacer.mat4")
local vec3 = require("lacer.vec3")

local triangle = require("lacer.primitive.triangle")

---@class lacer.Model
---@field positions lacer.Vec3[]
---@field faces integer[][]
---@field materialId integer
local Model = {}
Model.__index = Model

---@param content string
---@param materialId integer
---@return lacer.Model
function Model.parseObj(content, materialId)
	local positions = {}
	local faces = {}

	for line in content:gmatch("[^\r\n]+") do
		local kind = line:sub(1, 2)

		if kind == "v " then
			local x, y, z = line:match("^v%s+(%S+)%s+(%S+)%s+(%S+)")
			positions[#positions + 1] = vec3.new(tonumber(x), tonumber(y), tonumber(z))
		elseif kind == "f " then
			local indices = {}

			for token in line:match("^f%s+(.+)"):gmatch("%S+") do
				local index = tonumber(token:match("^%-?%d+"))
				if index < 0 then
					index = #positions + index + 1
				end

				indices[#indices + 1] = index
			end

			for corner = 2, #indices - 1 do
				faces[#faces + 1] = { indices[1], indices[corner], indices[corner + 1] }
			end
		end
	end

	return setmetatable({ positions = positions, faces = faces, materialId = materialId }, Model)
end

---@param path string
---@param materialId integer
---@return lacer.Model
function Model.loadObj(path, materialId)
	local file = io.open(path, "rb")
	if not file then
		error("cannot read model " .. path, 2)
	end

	local content = file:read("*a")
	file:close()

	return Model.parseObj(content, materialId)
end

---@param m lacer.Mat4
---@return lacer.Model
function Model:transform(m)
	for index, position in ipairs(self.positions) do
		self.positions[index] = mat4.transformPoint(m, position)
	end

	return self
end

---@param factor number
---@return lacer.Model
function Model:scale(factor)
	return self:transform(mat4.fromScale(factor))
end

---@param translation lacer.Vec3
---@return lacer.Model
function Model:translate(translation)
	return self:transform(mat4.fromTranslation(translation))
end

---@param axis lacer.Vec3
---@param angle number
---@return lacer.Model
function Model:rotate(axis, angle)
	return self:transform(mat4.fromAxisAngle(axis, angle))
end

---@return lacer.Primitive[]
function Model:toPrimitives()
	local primitives = {}

	for _, face in ipairs(self.faces) do
		primitives[#primitives + 1] = triangle.new({
			v0 = self.positions[face[1]],
			v1 = self.positions[face[2]],
			v2 = self.positions[face[3]],
			materialId = self.materialId,
		})
	end

	return primitives
end

return Model
