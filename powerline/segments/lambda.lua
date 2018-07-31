local Util = require("powerline.utils.util")

local Lambda = {}

function Lambda.apply(Powerline, args)
	local value = args or "λ"
	local lastExit = clink.get_env("=ExitCode")
	if lastExit ~= nil then
		lastExit = tonumber(lastExit)
		if lastExit ~= 0 then
			value = value .. Util.applyStyle({fg = Powerline.Colors.red}) .. " ✘"
		end
	end

	return {
		fg = Powerline.Colors.yellow,
		bg = Powerline.Colors.black,
		value = value
	}
end

return Lambda
