local ffi = require("ffi")
local hood = require("hood")

local camera = require("lacer.camera")
local light = require("lacer.light")
local material = require("lacer.material")
local primitive = require("lacer.primitive")
local shader = require("lacer.shader")

---@class lacer.Renderer
---@field scene lacer.Scene
---@field config lacer.Config
---@field device hood.Device
---@field layout hood.BindGroupLayout
---@field pipeline hood.ComputePipeline
---@field bindGroup hood.BindGroup
---@field outputBuffer hood.Buffer
---@field primitiveBuffer hood.Buffer
---@field cameraBuffer hood.Buffer
---@field materialBuffer hood.Buffer
---@field lightBuffer hood.Buffer
---@field buffers hood.Buffer[]
local Renderer = {}
Renderer.__index = Renderer

local WORKGROUP_SIZE = 8
local BYTES_PER_PIXEL = 4

local BINDINGS = {
	{ type = "storage-buffer", binding = 0 },
	{ type = "storage-buffer", binding = 1 },
	{ type = "uniform-buffer", binding = 2 },
	{ type = "storage-buffer", binding = 3 },
	{ type = "storage-buffer", binding = 4 },
}

---@param device hood.Device
---@param size number
---@param usages hood.BufferUsage[]
---@param data ffi.cdata*?
---@param dataSize number?
---@return hood.Buffer
local function createBuffer(device, size, usages, data, dataSize)
	local buffer = device:createBuffer({ size = size, usages = usages })

	if data then
		device.queue:writeBuffer(buffer, dataSize or size, data)
	end

	return buffer
end

---@param scene lacer.Scene
---@param config lacer.Config
---@return lacer.Renderer
function Renderer.new(scene, config)
	local instance = hood.Instance.new({ backend = config.backend, flags = { "headless" } })
	local adapter = instance:requestAdapter({ powerPreference = "high-performance" })
	local device = adapter:requestDevice()

	local self = setmetatable({
		scene = scene,
		config = config,
		device = device,
		buffers = {},
	}, Renderer)

	self:createBuffers()
	self:createPipeline()

	return self
end

function Renderer:createBuffers()
	local device = self.device
	local scene = self.scene

	local primitiveData, primitiveSize = primitive.pack(scene.primitives)
	local materialData, materialSize = material.pack(scene.materials)
	local lightData, lightSize = light.pack(scene.lights)
	local cameraData, cameraSize = camera.pack(scene.camera, self.config.width, self.config.height)

	self.outputBuffer = createBuffer(device, self.config.width * self.config.height * BYTES_PER_PIXEL, { "STORAGE", "MAP_READ" })
	self.primitiveBuffer = createBuffer(device, primitiveSize, { "STORAGE", "COPY_DST" }, primitiveData, primitiveSize)
	self.cameraBuffer = createBuffer(device, cameraSize, { "UNIFORM", "COPY_DST" }, cameraData, cameraSize)
	self.materialBuffer = createBuffer(device, materialSize, { "STORAGE", "COPY_DST" }, materialData, materialSize)
	self.lightBuffer = createBuffer(device, lightSize, { "STORAGE", "COPY_DST" }, lightData, lightSize)

	self.buffers = {
		self.outputBuffer,
		self.primitiveBuffer,
		self.cameraBuffer,
		self.materialBuffer,
		self.lightBuffer,
	}
end

function Renderer:createPipeline()
	local device = self.device

	local entries = {}

	for _, binding in ipairs(BINDINGS) do
		entries[#entries + 1] = {
			type = binding.type,
			binding = binding.binding,
			visibility = { "COMPUTE" },
		}
	end

	self.layout = device:createBindGroupLayout(entries)
	self.pipeline = device:createComputePipeline({
		module = shader.load("path", self.config.backend),
		layout = self.layout,
	})

	local resources = {
		self.outputBuffer,
		self.primitiveBuffer,
		self.cameraBuffer,
		self.materialBuffer,
		self.lightBuffer,
	}

	local bindEntries = {}

	for index, binding in ipairs(BINDINGS) do
		bindEntries[#bindEntries + 1] = {
			type = binding.type,
			binding = binding.binding,
			visibility = { "COMPUTE" },
			buffer = resources[index],
		}
	end

	self.bindGroup = device:createBindGroup({ layout = self.layout, entries = bindEntries })
end

---@return string Raw RGBA8 pixels
function Renderer:render()
	local encoder = self.device:createCommandEncoder()

	encoder:setComputePipeline(self.pipeline)
	encoder:setBindGroup(0, self.bindGroup)
	encoder:beginComputePass({})
	encoder:dispatchWorkgroups(
		math.ceil(self.config.width / WORKGROUP_SIZE),
		math.ceil(self.config.height / WORKGROUP_SIZE),
		1
	)
	encoder:endComputePass()

	self.device.queue:submit(encoder:finish())
	self.device.queue:waitIdle()

	self.outputBuffer:mapAsync()
	local pointer = ffi.cast("uint8_t*", self.outputBuffer:getMappedRange())
	local pixels = ffi.string(pointer, self.config.width * self.config.height * BYTES_PER_PIXEL)
	self.outputBuffer:unmap()

	return pixels
end

function Renderer:destroy()
	for _, buffer in ipairs(self.buffers) do
		buffer:destroy()
	end

	if self.pipeline.destroy then
		self.pipeline:destroy()
	end
end

return Renderer
