local Util = {ansi = "\x1b"}

function Util.pathname(path)
	local prefix = ""
	local i = path:find("[\\/][^\\/]*$")
	if i then
		prefix = path:sub(1, i-1)
	end
	return prefix
end

function Util.containsPath(target, isDir, path)
	if path == nil then path = '.' end
	if path == '.' then path = clink.get_cwd() end
	if isDir == nil then isDir = true end

	local fullPath = path .. '/' .. target
	local found

	if isDir then
		local foundList = clink.find_dirs(fullPath)
		found = #foundList > 0
	else
		found = Util.isFile(fullPath)
	end

	if found then
		return fullPath

	else
		local parentDir = Util.pathname(path)
		if parentDir == path then return nil end

		return Util.containsPath(target, isDir, parentDir)
	end
end

function Util.isFile(path)
	local f = io.open(path,"r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function Util.applyStyle(style)
	local styleCode = ""

	if style.bg ~= nil then
		styleCode = styleCode .. Util.ansi .. "[" .. (style.bg + 40) .. "m"
	end

	if style.fg ~= nil then
		styleCode = styleCode .. Util.ansi .. "[" .. (style.fg + 30) .. "m"
	end

	return styleCode
end

function Util.clearStyle()
	return Util.ansi .. "[0m"
end

function Util.splitPath(string)
	local fields = {}
	for token in string:gmatch("([^\\/]*)[\\/]*") do
		table.insert(fields, " " .. token .. " ")
	end

	fields[1] = fields[1]:sub(1, -1)
	fields[#fields] = ""
	return fields
end

return Util
