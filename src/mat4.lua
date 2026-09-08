---@alias lacer.Mat4 number[] Column-major 4x4 matrix

local mat4 = {}

---@return lacer.Mat4
function mat4.identity()
	return {
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}
end

---@param a lacer.Mat4
---@param b lacer.Mat4
---@return lacer.Mat4
function mat4.mul(a, b)
	local result = {}

	for column = 0, 3 do
		for row = 0, 3 do
			local sum = 0

			for k = 0, 3 do
				sum = sum + a[k * 4 + row + 1] * b[column * 4 + k + 1]
			end

			result[column * 4 + row + 1] = sum
		end
	end

	return result
end

---@param scale number
---@return lacer.Mat4
function mat4.fromScale(scale)
	return {
		scale, 0, 0, 0,
		0, scale, 0, 0,
		0, 0, scale, 0,
		0, 0, 0, 1,
	}
end

---@param translation lacer.Vec3
---@return lacer.Mat4
function mat4.fromTranslation(translation)
	return {
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		translation.x, translation.y, translation.z, 1,
	}
end

---@param axis lacer.Vec3
---@param angle number
---@return lacer.Mat4
function mat4.fromAxisAngle(axis, angle)
	local x, y, z = axis.x, axis.y, axis.z
	local magnitude = math.sqrt(x * x + y * y + z * z)
	x, y, z = x / magnitude, y / magnitude, z / magnitude

	local c = math.cos(angle)
	local s = math.sin(angle)
	local t = 1 - c

	return {
		t * x * x + c, t * x * y + s * z, t * x * z - s * y, 0,
		t * x * y - s * z, t * y * y + c, t * y * z + s * x, 0,
		t * x * z + s * y, t * y * z - s * x, t * z * z + c, 0,
		0, 0, 0, 1,
	}
end

---@param m lacer.Mat4
---@param v lacer.Vec3
---@return lacer.Vec3
function mat4.transformPoint(m, v)
	return {
		x = m[1] * v.x + m[5] * v.y + m[9] * v.z + m[13],
		y = m[2] * v.x + m[6] * v.y + m[10] * v.z + m[14],
		z = m[3] * v.x + m[7] * v.y + m[11] * v.z + m[15],
	}
end

return mat4
