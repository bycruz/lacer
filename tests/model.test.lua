local test = require("lde-test")
local vec3 = require("lacer.vec3")

local Model = require("lacer.model")

local OBJ = [[
# a quad and a triangle
v 0 0 0
v 1 0 0
v 1 1 0
v 0 1 0
v 2 0 0
vt 0 0
vn 0 0 1
f 1/1/1 2/1/1 3/1/1 4/1/1
f 1//1 3//1 5//1
]]

test.it("model: parses vertices", function()
	local model = Model.parseObj(OBJ, 3)

	test.equal(#model.positions, 5)
	test.deepEqual(model.positions[3], { x = 1, y = 1, z = 0 })
end)

test.it("model: triangulates polygons as a fan", function()
	local model = Model.parseObj(OBJ, 3)

	test.equal(#model.faces, 3)
	test.deepEqual(model.faces[1], { 1, 2, 3 })
	test.deepEqual(model.faces[2], { 1, 3, 4 })
	test.deepEqual(model.faces[3], { 1, 3, 5 })
end)

test.it("model: resolves negative face indices", function()
	local model = Model.parseObj("v 0 0 0\nv 1 0 0\nv 0 1 0\nf -3 -2 -1\n", 0)

	test.deepEqual(model.faces[1], { 1, 2, 3 })
end)

test.it("model: toPrimitives keeps the material id", function()
	local primitives = Model.parseObj(OBJ, 7):toPrimitives()

	test.equal(#primitives, 3)
	test.equal(primitives[1].materialId, 7)
	test.equal(primitives[1].data0, 0)
	test.equal(primitives[1].data1, 0)
end)

test.it("model: transforms move every vertex", function()
	local model = Model.parseObj("v 1 0 0\nv 0 1 0\nv 0 0 1\nf 1 2 3\n", 0)
	model:scale(2):translate(vec3.new(1, 1, 1))

	test.deepEqual(model.positions[1], { x = 3, y = 1, z = 1 })
	test.deepEqual(model.positions[2], { x = 1, y = 3, z = 1 })
	test.deepEqual(model.positions[3], { x = 1, y = 1, z = 3 })
end)
