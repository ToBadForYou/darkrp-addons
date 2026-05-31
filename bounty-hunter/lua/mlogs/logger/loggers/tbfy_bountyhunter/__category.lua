--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"Bounty Hunter System", -- Name
	"bountyhunter", 
	Color(100,40,45), -- Color
	function() -- Check
		return true
	end,
	true
)

mLogs.addCategoryDefinitions("bountyhunter", {
	startbounty = function(data) return mLogs.doLogReplace({"^player1", "started a bounty hunt on", "^player2", "head!"},data) end,
	claimbounty = function(data) return mLogs.doLogReplace({"^player1", "claimed a bounty of $", "^bountyamount", "on", "^player2", "head!"},data) end,
})