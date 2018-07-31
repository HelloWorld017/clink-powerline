local CwdSegment = require("powerline.segments.cwd")
local GitSegment = require("powerline.segments.git")
local LambdaSegment = require("powerline.segments.lambda")
local NodeSegment = require("powerline.segments.node")
local TextSegment = require("powerline.segments.text")
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
	node = NodeSegment,
	time = TimeSegment,
	textseg = TextSegment
}

function Powerline.init(powerlineArgs)
	powerlineArgs[#powerlineArgs + 1] = ''
	local powerline = {}

	for i, segmentExpression in pairs(powerlineArgs) do
		powerline[#powerline + 1] = Powerline.parseSegment(segmentExpression)
	end

	local function apply()
		local prompt = ""
		local previousSegment = nil

		for i, segmentParsed in pairs(powerline) do
			local segmentKey = segmentParsed.name
			local segmentGenerator = Powerline.Segments[segmentKey]

			if segmentGenerator == nil then
				prompt = prompt .. Powerline.updateSegment(previousSegment, nil) .. " " .. Util.clearStyle()
				prompt = prompt .. segmentParsed.args
				previousSegment = nil
			else
				local segment = segmentGenerator.apply(Powerline, segmentParsed.args)

				if segmentParsed.color then
					if segmentParsed.color.fg ~= nil then
						local foreground = Powerline.Colors[segmentParsed.color.fg]

						if foreground ~= nil then
							segment.fg = foreground
						end
					end

					if segmentParsed.color.bg ~= nil then
						local background = Powerline.Colors[segmentParsed.color.bg]

						if background ~= nil then
							segment.bg = background
						end
					end
				end

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

function Powerline.parseSegment(segmentSyntax)
	local segmentName = segmentSyntax:match("^([a-z]+)")
	if segmentName == nil then
		return {
			name = "text",
			args = segmentSyntax
		}
	end
	segmentSyntax = segmentSyntax:sub(#segmentName + 1)

	local segmentArgs = segmentSyntax:match("^%/([^:]+)")
	if segmentArgs ~= nil then
		segmentSyntax = segmentSyntax:sub(#segmentArgs + 2)
	end

	local segmentColor = nil
	local segmentColorMatch = segmentSyntax:match("^:([a-zA-Z]+)")
	if segmentColorMatch ~= nil then
		segmentColor = {}
		segmentSyntax = segmentSyntax:sub(#segmentColorMatch + 2)
		segmentColor.fg = segmentColorMatch

		local segmentBgMatch = segmentSyntax:match("^+([a-zA-Z]+)")
		if segmentBgMatch ~= nil then
			segmentColor.bg = segmentBgMatch
		end
	end

	return {
		name = segmentName,
		color = segmentColor,
		args = segmentArgs
	}
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
		else
			-- Add soft divider on Black -> Black
			if previousSegment.bg == Powerline.Colors.black then
				style.fg = previousSegment.fg
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
