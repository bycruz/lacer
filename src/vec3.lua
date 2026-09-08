---@class lacer.Vec3
---@field x number
---@field y number
---@field z number

local vec3 = {}

---@param x number
---@param y number
---@param z number
---@return lacer.Vec3
function vec3.new(x, y, z)
	return { x = x, y = y, z = z }
end

---@param a lacer.Vec3
---@param b lacer.Vec3
---@return lacer.Vec3
function vec3.add(a, b)
	return { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z }
end

---@param a lacer.Vec3
---@param b lacer.Vec3
---@return lacer.Vec3
function vec3.sub(a, b)
	return { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }
end

---@param v lacer.Vec3
---@param scalar number
---@return lacer.Vec3
function vec3.scale(v, scalar)
	return { x = v.x * scalar, y = v.y * scalar, z = v.z * scalar }
end

---@param a lacer.Vec3
---@param b lacer.Vec3
---@return number
function vec3.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

---@param a lacer.Vec3
---@param b lacer.Vec3
---@return lacer.Vec3
function vec3.cross(a, b)
	return {
		x = a.y * b.z - a.z * b.y,
		y = a.z * b.x - a.x * b.z,
		z = a.x * b.y - a.y * b.x,
	}
end

---@param v lacer.Vec3
---@return number
function vec3.length(v)
	return math.sqrt(vec3.dot(v, v))
end

---@param v lacer.Vec3
---@return lacer.Vec3
function vec3.normalize(v)
	local magnitude = vec3.length(v)
	return { x = v.x / magnitude, y = v.y / magnitude, z = v.z / magnitude }
end

return vec3
