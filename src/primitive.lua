local ffi = require("ffi")

---@class lacer.Primitive
---@field tag integer
---@field materialId integer
---@field data0 number
---@field data1 number
---@field data2 number[]
---@field data3 number[]

local primitive = {}

---@enum lacer.PrimitiveTag
primitive.TAG = {
	TRIANGLE = 0,
	SPHERE = 1,
	CUBE = 2,
}

local PRIMITIVE_SIZE = 48
local PRIMITIVE_WORDS = 12

---@param primitives lacer.Primitive[]
---@return ffi.cdata* buffer
---@return number size
function primitive.pack(primitives)
	local size = PRIMITIVE_SIZE * #primitives
	local buffer = ffi.new("uint8_t[?]", math.max(size, 1))
	local u32 = ffi.cast("uint32_t*", buffer)
	local f32 = ffi.cast("float*", buffer)

	for index, value in ipairs(primitives) do
		local base = (index - 1) * PRIMITIVE_WORDS

		u32[base + 0] = value.tag
		u32[base + 1] = value.materialId
		f32[base + 2] = value.data0
		f32[base + 3] = value.data1

		for component = 1, 4 do
			f32[base + 3 + component] = value.data2[component]
			f32[base + 7 + component] = value.data3[component]
		end
	end

	return buffer, size
end

return primitive
