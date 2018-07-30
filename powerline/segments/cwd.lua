local Util = require("powerline.utils.util")
local Cwd = {}

function Cwd.apply(Powerline)
	return {
		fg = Powerline.Colors.black,
		bg = Powerline.Colors.blue,
		value = table.concat(Util.splitPath(clink.get_cwd()), Powerline.Symbols.segmentSoft)
	}
end

return Cwd
