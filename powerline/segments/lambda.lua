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
	
	if Lambda.checkRoot() then
		value = "⚡"
	end

	return {
		fg = Powerline.Colors.yellow,
		bg = Powerline.Colors.black,
		value = value
	}
end

function Lambda.checkRoot()
	local isRoot = io.popen("cmd /c net.exe session 1>nul 2>nul || echo false")
	for line in isRoot:lines() do
		isRoot:close()
		return false
	end
	return true
end
return Lambda
