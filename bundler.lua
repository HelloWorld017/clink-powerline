#!/usr/bin/env lua

--[[
	The MIT License

	Copyright (C) 2017 Saravjeet 'Aman' Singh
	<saravjeetamansingh@gmail.com>

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

--[[
	pack.lua -- a module bundler for lua 5.1

	usage:
		pack.lua <toplevel-module>.lua

		this will create a file called <toplevel-module>.bundle.lua in the
		current directory

	features:
		* supports relative imports.
		* imported modules are only evaluated once.
		* works well with luarocks and other lua modules. (however, luarocks
		  modules are not bundled, sadly)

	requirements:
		pack.lua has been tested on lua 5.1 and only supports the new style
		module system.

		pack.lua requires that you pass in the '.lua' file extension to the
		require function. It will leave any require statements intact that
		don't have a '.lua' at the end.

		also, it only works on a POSIX system. (:


	information:
		pack.lua wraps and bundles a lua source tree into a single source file.

		The primary motivation for this script was to make it easier to write
		lua source to bundle as part of a C library.

		A neat trick that you can do is to use `luac` to compile the source and
		then use the tool `xxd` to generate a C header that can then directly
		be included into your C/C++ source. This is awesome because you cant
		actually see the lua source on inspecting the executable output.

	warning:
		pack.lua does not check for, or eliminate circular dependencies.

		if you have a circular dependency somewhere in your source tree,
		pack.lua will probably crash the call stack.
]]

-- map module path to modules array
local module_index = {}

-- contains source for modules
local modules = {}

local luapack_header = [[
__luapack_modules__ = {
%s
}
__luapack_cache__ = {}
__luapack_require__ = function(idx)
	local cache = __luapack_cache__[idx]
	if cache then
		return cache
	end

	local module = __luapack_modules__[idx]()
	__luapack_cache__[idx] = module
	return module
end
]]

-- python-like path helpers
local delimiter = '\\'
local platform = 'win32'

path = {
	isrelative = function(path)
		if platform ~= 'win32' then
			return path:sub(1, 1) ~= '/'
		end

		return path:find("^[A-Z]:") == nil
	end,
	isabsolute = function(pth)
		return not path.isrelative(pth)
	end,
	join = function(base, addon)

		-- addon path must be relative
		if path.isabsolute(addon) then
			return addon
		end

		-- prepare the base path, and make sure it points to a directory
		if path.isrelative(base) then
			base = path.abspath(base)
		end
		if path.isfile(base) then
			base = path.dirname(base)
		end

		-- join
		local newpath = base .. delimiter .. addon

		-- normalise
		newpath = path.abspath(newpath)

		-- realpath failed
		if path.isrelative(newpath) then
			return addon
		end

		return newpath
	end,
	isdir = function(path)
		return os.execute("test -d "..path) == 0
	end,
	isfile = function(path)
		return os.execute("test -f "..path) == 0
	end,
	abspath = function(path)
		local cmd = string.format('cygpath %s -w -a', path)

		if platform ~= 'win32' then
			cmd = string.format("realpath %s", path)
		end

		return strip(io.popen(cmd):read("*a"))
	end,
	basename = function(path)
		local cmd = string.format("basename %s", path)
		return strip(io.popen(cmd):read("*a"))
	end,
	dirname = function(path)
		local cmd = string.format("dirname %s", path)
		return strip(io.popen(cmd):read("*a"))
	end
}

function strip(str)
	return string.gsub(str, "%s", "")
end

function require_string(idx)
	return string.format("__luapack_require__(%d)\n", idx)
end

function import(module_path, context)

	local cache_idx = module_index[module_path]
	if cache_idx then
		return require_string(cache_idx)
	end

	local fd, err = io.open(module_path)
	if fd == nil then
		error(err)
	end
	local source = fd:read("*a")
	io.close(fd)
	print("Importing module : " .. module_path)
	source = transform(source, module_path, context)
	table.insert(modules, source)
	local idx = #modules
	module_index[module_path] = idx
	return require_string(idx)
end

function transform(source, source_path, context)
	local pattern = "require%s*%(?%s*[\"'](.-)[\"']%s*%)?"
	return string.gsub(source, pattern, function(name)
		name = name:gsub("%.", delimiter)
		name = name .. ".lua"
		local path_to_module = path.join(context, name)

		--[[ if not path.isfile(path_to_module) then
			print("Module not found : " .. path_to_module)
			return nil
		end --]]

		print("Module found : " .. path_to_module)

		return import(path_to_module, context)
	end)
end

function generate_module_header()

	if #modules < 1 then
		return ''
	end

	function left_pad(source, padding, ch)
		ch = ch or ' '
		local repl = function(str)
			return string.rep(ch, padding) .. str
		end
		return string.gsub(source, '(.-\n)', repl)
	end

	function pad(source)
		source = left_pad(source, 1, '\t')
		source = string.format('(function()\n%s\nend),\n', source)
		source = left_pad(source, 1, '\t')
		return source
	end
	local modstring = ''
	for i = 1, #modules do
		modstring = modstring .. pad(modules[i])
	end
	if #modules > 1 then
		-- strip the last newline, make it look pretty
		modstring = modstring:sub(1, -2)
	end
	local header = string.format(luapack_header, modstring)
	return header
end

function main(argv)
	if #argv == 0 then
		local usage = string.format('usage: %s <toplevel-module>.lua', argv[0])
		print(usage)
		return -1
	end

	local entry = argv[1]
	local fd, err = io.open(entry)
	if fd == nil then
		error(err)
	end
	local source = fd:read("*a")
	io.close(fd)
	local path_to_entry = path.abspath(entry)
	local context = path.abspath(path.dirname(path_to_entry))
	source = transform(source, path_to_entry, context)
	local header = generate_module_header()

	source = header..'\n'..source

	local outPath = path.join(path.dirname(entry), "dist")
	local outFileName = path.basename(entry):gsub("%.lua", ".bundle.lua")
	local out = path.join(outPath, outFileName)
	io.open(out, "w"):write(source)

	return 0
end

os.exit(main(arg))
