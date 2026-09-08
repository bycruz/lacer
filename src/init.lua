local config = require("lacer.config")
local png = require("lacer.png")
local Renderer = require("lacer.renderer")
local scene = require("lacer.scene")

local options = config.parse(arg)
local cornellBox = scene.cornellBox()

print(("rendering %dx%d on %s"):format(options.width, options.height, options.backend))

local started = os.time()
local renderer = Renderer.new(cornellBox, options)
local pixels = renderer:render()
renderer:destroy()
local elapsed = os.time() - started

local file = assert(io.open(options.output, "wb"))
file:write(png.encode(options.width, options.height, pixels, 4))
file:close()

print(("saved %s in %ds"):format(options.output, elapsed))
