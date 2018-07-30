local Lambda = {}

function Lambda.apply(Powerline)
	local value = "λ"
	local lastExit = clink.get_env("=ExitCode")
	if lastExit ~= nil then
		lastExit = tonumber(lastExit)
		if lastExit ~= 0 then
			value = value .. "✘"
		end
	end

	return {
		fg = Powerline.Colors.black,
		bg = Powerline.Colors.yellow,
		value = value
	}
end

return Lambda
