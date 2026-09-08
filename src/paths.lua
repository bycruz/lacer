local source = debug.getinfo(1, "S").source:sub(2)

local paths = {}

---@type string
paths.packageDir = assert(source:match("^(.*)[/\\][^/\\]*$"), "cannot locate package directory")

---@param name string
---@return string
function paths.asset(name)
	return paths.packageDir .. "/assets/" .. name
end

return paths
