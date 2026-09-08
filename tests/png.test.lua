local bit = require("bit")
local test = require("lde-test")

local png = require("lacer.png")

---@param data string
---@param offset integer
---@return number
local function u32be(data, offset)
	local a, b, c, d = data:byte(offset, offset + 3)

	return ((a * 256 + b) * 256 + c) * 256 + d
end

---@param data string
---@return number
local function crc32(data)
	local value = 0xFFFFFFFF

	for index = 1, #data do
		value = bit.bxor(value, data:byte(index))

		for _ = 1, 8 do
			value = bit.band(value, 1) == 1
				and bit.bxor(bit.rshift(value, 1), 0xEDB88320)
				or bit.rshift(value, 1)
		end
	end

	return bit.bxor(value, 0xFFFFFFFF) % 4294967296
end

---@param data string
---@return number
local function adler32(data)
	local a, b = 1, 0

	for index = 1, #data do
		a = (a + data:byte(index)) % 65521
		b = (b + a) % 65521
	end

	return b * 65536 + a
end

---@param data string
---@param tag string
---@return string
local function chunkData(data, tag)
	local offset = 9

	while offset <= #data do
		local length = u32be(data, offset)

		if data:sub(offset + 4, offset + 7) == tag then
			return data:sub(offset + 8, offset + 8 + length - 1)
		end

		offset = offset + 12 + length
	end

	error("missing chunk " .. tag)
end

local pixels = string.char(255, 0, 0, 255, 0, 255, 0, 255)
local encoded = png.encode(2, 1, pixels, 4)

test.it("png: writes the signature and IHDR", function()
	test.equal(encoded:sub(1, 8), "\137PNG\r\n\26\n")
	test.equal(u32be(encoded, 9), 13)
	test.equal(encoded:sub(13, 16), "IHDR")
	test.equal(u32be(encoded, 17), 2)
	test.equal(u32be(encoded, 21), 1)
	test.equal(encoded:byte(25), 8)
	test.equal(encoded:byte(26), 6)
end)

test.it("png: every chunk carries a valid crc32", function()
	local offset = 9
	local tags = {}

	while offset <= #encoded do
		local length = u32be(encoded, offset)
		local tag = encoded:sub(offset + 4, offset + 7)
		local data = encoded:sub(offset + 8, offset + 8 + length - 1)

		test.equal(u32be(encoded, offset + 8 + length), crc32(tag .. data), "crc of " .. tag)

		tags[#tags + 1] = tag
		offset = offset + 12 + length
	end

	test.deepEqual(tags, { "IHDR", "IDAT", "IEND" })
end)

test.it("png: IDAT is a stored zlib stream of filtered rows", function()
	local idat = chunkData(encoded, "IDAT")
	local filtered = "\0" .. pixels

	test.equal(idat:sub(1, 2), string.char(0x78, 0x01))
	test.equal(idat:byte(3), 0x00)
	test.equal(idat:byte(4) + idat:byte(5) * 256, #filtered)
	test.equal(idat:byte(6) + idat:byte(7) * 256, 65535 - #filtered)
	test.equal(idat:sub(8, 8 + #filtered - 1), filtered)
	test.equal(idat:sub(#idat - 8, #idat - 4), string.char(0x01, 0x00, 0x00, 0xFF, 0xFF))
	test.equal(u32be(idat, #idat - 3), adler32(filtered))
end)

test.it("png: rgb images use color type 2", function()
	local rgb = png.encode(1, 1, string.char(1, 2, 3), 3)

	test.equal(rgb:byte(26), 2)
	test.equal(u32be(rgb, 9), 13)
end)
