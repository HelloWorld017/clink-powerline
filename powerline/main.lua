local CwdSegment = require("powerline.segments.cwd")
local GitSegment = require("powerline.segments.git")
local LambdaSegment = require("powerline.segments.lambda")
local HgSegment = require("powerline.segments.mercurial")
local NodeSegment = require("powerline.segments.node")
local TimeSegment = require("powerline.segments.time")

local Util = require("powerline.utils.util")

local Powerline = {}

Powerline.Colors = {
	black = 0, red = 1, green = 2, yellow = 3,
	blue = 4, magenta = 5, cyan = 6, white = 7,
	lightBlack = 60, lightRed = 61, lightGreen = 62,
	lightYellow = 63, lightBlue = 64, lightMagenta = 65,
	lightCyan = 66, lightWhite = 67,

	default = 9
}

Powerline.Symbols = {
	segment = "",
	segmentSoft = "",
	branch = ""
}

Powerline.Segments = {
	cwd = CwdSegment,
	git = GitSegment,
	lambda = LambdaSegment,
	hg = HgSegment,
	node = NodeSegment,
	time = TimeSegment
}

function Powerline.init(powerline)
	powerline[#powerline + 1] = ''
	local function apply()
		local prompt = ""
		local previousSegment = nil

		for i, segmentKey in pairs(powerline) do
			local segmentGenerator = Powerline.Segments[segmentKey]
			if segmentGenerator == nil then
				prompt = prompt .. Powerline.updateSegment(previousSegment, nil) .. " " .. Util.clearStyle()
				prompt = prompt .. segmentKey
				previousSegment = nil
			else
				local segment = segmentGenerator.apply(Powerline)

				if segment ~= nil then
					prompt = prompt .. Powerline.updateSegment(previousSegment, segment) .. " " .. segment.value .. " "
					previousSegment = segment
				end
			end
		end

		clink.prompt.value = prompt
	end

	clink.prompt.register_filter(apply, 55)
end

function Powerline.updateSegment(previousSegment, segment)
	styleCode = ""

	if previousSegment ~= nil then
		local style = {fg = previousSegment.bg, bg = Powerline.Colors.default}
		local divider = Powerline.Symbols.segment

		if segment ~= nil then
			style.bg = segment.bg

			if previousSegment.bg == segment.bg then
				style.fg = segment.fg
				divider = Powerline.Symbols.segmentSoft
			end
		end

		styleCode = styleCode .. Util.applyStyle(style) .. divider
	end

	if segment ~= nil then
		styleCode = styleCode .. Util.applyStyle(segment)
	end

	return styleCode
end

return Powerline
