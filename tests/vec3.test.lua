local test = require("lde-test")
local vec3 = require("lacer.vec3")

test.it("vec3: new stores components", function()
	local value = vec3.new(1, 2, 3)
	test.equal(value.x, 1)
	test.equal(value.y, 2)
	test.equal(value.z, 3)
end)

test.it("vec3: add and sub are component-wise", function()
	test.deepEqual(vec3.add(vec3.new(1, 2, 3), vec3.new(4, 5, 6)), { x = 5, y = 7, z = 9 })
	test.deepEqual(vec3.sub(vec3.new(4, 5, 6), vec3.new(1, 2, 3)), { x = 3, y = 3, z = 3 })
end)

test.it("vec3: scale multiplies every component", function()
	test.deepEqual(vec3.scale(vec3.new(1, -2, 3), 2), { x = 2, y = -4, z = 6 })
end)

test.it("vec3: dot product", function()
	test.equal(vec3.dot(vec3.new(1, 2, 3), vec3.new(4, -5, 6)), 12)
end)

test.it("vec3: cross product follows the right-hand rule", function()
	test.deepEqual(vec3.cross(vec3.new(1, 0, 0), vec3.new(0, 1, 0)), { x = 0, y = 0, z = 1 })
	test.deepEqual(vec3.cross(vec3.new(0, 1, 0), vec3.new(1, 0, 0)), { x = 0, y = 0, z = -1 })
end)

test.it("vec3: length and normalize", function()
	test.equal(vec3.length(vec3.new(3, 4, 0)), 5)
	test.deepEqual(vec3.normalize(vec3.new(0, 3, 4)), { x = 0, y = 0.6, z = 0.8 })
end)
