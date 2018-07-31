local Util = require("powerline.utils.util")

local Text = {}

function Text.apply(Powerline, args)
	return {
		fg = Powerline.Colors.white,
		bg = Powerline.Colors.black,
		value = args
	}
end

return Text
