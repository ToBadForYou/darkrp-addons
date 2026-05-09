--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "tbfy_firearmslicense"

mLogs.addLogger("Toggle License","togglelicense",category)
mLogs.addHook("fa_togglelicense", category, function(Player, MPlayer, LID, Bool, Type)
	if(not IsValid(MPlayer) or not IsValid(Player))then return end
	local LogText = "granted"
	if !Bool then
		LogText = "revoked"
	end

	local LicenseName = FALICENSE_DATABASE[LID].Name
	mLogs.log("togglelicense", category, {player1=mLogs.logger.getPlayerData(Player),player2=mLogs.logger.getPlayerData(MPlayer),text=LogText,lname=LicenseName,type=Type,a=true})
end)
