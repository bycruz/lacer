local test = require("lde-test")

local scene = require("lacer.scene")

local cornellBox = scene.cornellBox()

test.it("scene: has the cornell box materials and light", function()
	test.equal(#cornellBox.materials, 6)
	test.equal(#cornellBox.lights, 1)
	test.equal(cornellBox.lights[1].radius, 40.0)
end)

test.it("scene: has the box primitives plus the dragon", function()
	test.greater(#cornellBox.primitives, 7, "box and sphere are present")

	local triangles = 0

	for _, value in ipairs(cornellBox.primitives) do
		if value.tag == 0 then
			triangles = triangles + 1
		end
	end

	test.greater(triangles, 1000, "dragon triangles are present")
end)

test.it("scene: camera looks down the positive x axis", function()
	test.deepEqual(cornellBox.camera.pos, { x = -8.0, y = 0.0, z = 2.5 })
	test.deepEqual(cornellBox.camera.forward, { x = 1.0, y = 0.0, z = 0.0 })
	test.equal(cornellBox.camera.fov, 45.0)
end)
