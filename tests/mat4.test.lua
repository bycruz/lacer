local test = require("lde-test")
local mat4 = require("lacer.mat4")
local vec3 = require("lacer.vec3")

test.it("mat4: identity leaves points untouched", function()
	test.deepEqual(mat4.transformPoint(mat4.identity(), vec3.new(1, 2, 3)), { x = 1, y = 2, z = 3 })
end)

test.it("mat4: fromScale scales points", function()
	test.deepEqual(mat4.transformPoint(mat4.fromScale(3), vec3.new(1, -2, 4)), { x = 3, y = -6, z = 12 })
end)

test.it("mat4: fromTranslation offsets points", function()
	test.deepEqual(mat4.transformPoint(mat4.fromTranslation(vec3.new(1, 2, 3)), vec3.new(4, 5, 6)), { x = 5, y = 7, z = 9 })
end)

test.it("mat4: fromAxisAngle rotates around the axis", function()
	local quarterTurn = mat4.fromAxisAngle(vec3.new(1, 0, 0), math.pi / 2)
	local rotated = mat4.transformPoint(quarterTurn, vec3.new(0, 1, 0))

	test.equal(math.floor(rotated.x * 1e6 + 0.5), 0)
	test.equal(math.floor(rotated.y * 1e6 + 0.5), 0)
	test.equal(math.floor(rotated.z * 1e6 + 0.5), 1e6)
end)

test.it("mat4: fromAxisAngle leaves the axis fixed", function()
	local rotated = mat4.transformPoint(mat4.fromAxisAngle(vec3.new(0, 1, 0), 1.234), vec3.new(0, 5, 0))

	test.equal(math.floor(rotated.x * 1e6 + 0.5), 0)
	test.equal(math.floor(rotated.y * 1e6 + 0.5), 5e6)
	test.equal(math.floor(rotated.z * 1e6 + 0.5), 0)
end)

test.it("mat4: mul applies the right operand first", function()
	local transform = mat4.mul(mat4.fromTranslation(vec3.new(10, 0, 0)), mat4.fromScale(2))
	local point = mat4.transformPoint(transform, vec3.new(1, 0, 0))

	test.equal(math.floor(point.x + 0.5), 12)
end)
