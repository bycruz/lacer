local bit = require("bit")

local png = {}

local ADLER_MODULUS = 65521
local CRC_TABLE = {}

for index = 0, 255 do
	local value = index

	for _ = 1, 8 do
		if bit.band(value, 1) == 1 then
			value = bit.bxor(bit.rshift(value, 1), 0xEDB88320)
		else
			value = bit.rshift(value, 1)
		end
	end

	CRC_TABLE[index] = value
end

---@param value number
---@return string
local function packU32(value)
	value = value % 4294967296

	return string.char(
		math.floor(value / 16777216) % 256,
		math.floor(value / 65536) % 256,
		math.floor(value / 256) % 256,
		value % 256
	)
end

---@param data string
---@return number
local function crc32(data)
	local value = 0xFFFFFFFF

	for index = 1, #data do
		value = bit.bxor(bit.rshift(value, 8), CRC_TABLE[bit.band(bit.bxor(value, data:byte(index)), 0xFF)])
	end

	return bit.bxor(value, 0xFFFFFFFF) % 4294967296
end

---@param data string
---@return number
local function adler32(data)
	local a, b = 1, 0

	for index = 1, #data do
		a = (a + data:byte(index)) % ADLER_MODULUS
		b = (b + a) % ADLER_MODULUS
	end

	return b * 65536 + a
end

---@param tag string
---@param data string
---@return string
local function chunk(tag, data)
	return packU32(#data) .. tag .. data .. packU32(crc32(tag .. data))
end

---@param data string
---@return string
local function deflateStored(data)
	local parts = { string.char(0x78, 0x01) }
	local offset = 1

	while offset <= #data do
		local length = math.min(65535, #data - offset + 1)

		parts[#parts + 1] = string.char(
			0x00,
			length % 256,
			math.floor(length / 256),
			255 - length % 256,
			255 - math.floor(length / 256)
		)
		parts[#parts + 1] = data:sub(offset, offset + length - 1)

		offset = offset + length
	end

	parts[#parts + 1] = string.char(0x01, 0x00, 0x00, 0xFF, 0xFF)
	parts[#parts + 1] = packU32(adler32(data))

	return table.concat(parts)
end

---@param width integer
---@param height integer
---@param pixels string
---@param channels integer?
---@return string
function png.encode(width, height, pixels, channels)
	channels = channels or 4

	local rowLength = width * channels
	local rows = {}

	for row = 0, height - 1 do
		rows[row + 1] = "\0" .. pixels:sub(row * rowLength + 1, (row + 1) * rowLength)
	end

	local colorType = channels == 3 and 2 or 6
	local header = packU32(width) .. packU32(height) .. string.char(8, colorType, 0, 0, 0)

	return "\137PNG\r\n\26\n"
		.. chunk("IHDR", header)
		.. chunk("IDAT", deflateStored(table.concat(rows)))
		.. chunk("IEND", "")
end

return png
