local Util = require("powerline.utils.util")
local Git = {}

function Git.apply(Powerline)
	local gitDir = Util.containsPath(".git")
	if not gitDir then return nil end

	local branch = Git.getBranch(gitDir)
	if not branch then return nil end

	local value = Powerline.Symbols.branch .. " " .. branch

	if Git.getStatus() then
		bg = Powerline.Colors.green
	else
		bg = Powerline.Colors.yellow
		value = value .. "±"
	end

	return {
		fg = Powerline.Colors.black,
		bg = bg,
		value = value
	}
end

function Git.getBranch(gitDir)
	local headFile = gitDir and io.open(gitDir .. '/HEAD')
	if not headFile then return end

	local head = headFile:read()
	headFile:close()

	local branchName = head:match('ref: refs/heads/(.+)')
	return branchName or 'HEAD detached at' .. head:sub(1, 7)
end

function Git.getStatus()
	local file = io.popen("git status --no-lock-index --porcelain 2>nul")
	for line in file:lines() do
		file:close()
		return false
	end

	file:close()
	return true
end

return Git
