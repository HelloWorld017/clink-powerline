local json = require('powerline.utils.json')
local Util = require("powerline.utils.util")

local Node = {}

local version = io.popen("node -v"):read("*a")
version = version:sub(2, -1):gsub("\n", ""):gsub("\r", "")

function Node.apply(Powerline)
	local value = " " .. version
	local nodeDir = Util.containsPath("package.json", false)
	if nodeDir ~= nil then
		local fd, err = io.open(nodeDir)

		if fd ~= nil then
			local packageFile = fd:read("*a")
			io.close(fd)
	
			value = value .. " " .. Powerline.Symbols.segmentSoft .. " "
			
			local err, parsedPackage = pcall(json.parse, packageFile)
			
			if not err then
				value = value .. "Invalid Package"
			elseif parsedPackage.name ~= nil and parsedPackage.name ~= json.null then
				value = value .. parsedPackage.name
			end
		end
	end

	return {
		fg = Powerline.Colors.white,
		bg = Powerline.Colors.green,
		value = value
	}
end

return Node
