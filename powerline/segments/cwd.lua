local Util = require("powerline.utils.util")
local Cwd = {}

function Cwd.apply(Powerline)
	local pathList = Util.splitPath(clink.get_cwd())
	if pathList[#pathList] == '' then
		table.remove(pathList)
	end

	return {
		fg = Powerline.Colors.black,
		bg = Powerline.Colors.blue,
		value = table.concat(pathList, Powerline.Symbols.segmentSoft)
	}
end

return Cwd
