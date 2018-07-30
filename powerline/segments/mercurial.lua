local Util = require("powerline.utils.util")
local Mercurial = {}

function Mercurial.apply(Powerline)
	return {
		fg = Powerline.Colors.white,
		bg = Powerline.Colors.red,
		value = "λ"
	}
end

return Mercurial
