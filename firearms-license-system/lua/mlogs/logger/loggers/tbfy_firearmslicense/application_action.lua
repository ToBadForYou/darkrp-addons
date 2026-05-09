--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "tbfy_firearmslicense"

mLogs.addLogger("Application Action","applicationaction",category)
mLogs.addHook("fa_applicaton_action", category, function(Player, MPlayer, LID, Approved)
	if(not IsValid(MPlayer) or not IsValid(Player))then return end
	local LogText = "approved"
	if !Approved then
		LogText = "disapproved"
	end

	local LicenseName = FALICENSE_DATABASE[LID].Name
	mLogs.log("application_action", category, {player1=mLogs.logger.getPlayerData(Player),player2=mLogs.logger.getPlayerData(MPlayer),text=LogText,lname=LicenseName,a=true})
end)
