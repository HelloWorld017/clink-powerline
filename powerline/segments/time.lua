local Time = {}

function Time.apply(Powerline)
	return {
		fg = Powerline.Colors.cyan,
		bg = Powerline.Colors.black,
		value = os.date("%X")
	}
end

return Time
