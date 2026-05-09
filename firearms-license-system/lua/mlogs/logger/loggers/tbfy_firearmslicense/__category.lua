--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"Firearms License System", -- Name
	"tbfy_firearmslicense",
	Color(125,35,35), -- Color
	function() -- Check
		return true
	end,
	true
)

mLogs.addCategoryDefinitions("tbfy_firearmslicense", {
	toggleinstructor = function(data) return mLogs.doLogReplace({"^player1", "^text", "^player2", "instructor status."},data) end,
	togglelicense = function(data) return mLogs.doLogReplace({"^player1", "^text", "^player2", "^lname","^type"},data) end,
	toggletheory = function(data) return mLogs.doLogReplace({"^player1", "^text", "^player2", "^lname","theory test."},data) end,
	application = function(data) return mLogs.doLogReplace({"^player1", "submitted an application for", "^lname","^text"},data) end,
	application_action = function(data) return mLogs.doLogReplace({"^player1", "^text", "^player2", "^lname","application."},data) end,
})
