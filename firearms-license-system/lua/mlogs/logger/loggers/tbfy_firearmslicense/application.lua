--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "tbfy_firearmslicense"

mLogs.addLogger("Applications","applications",category)
mLogs.addHook("fa_applicaton", category, function(Player, LID, Carry, Sell)
	if not IsValid(Player) then return end
	local Text = ""
	if Carry then
		Text = "carry license"
	end
	if Sell then
		if Text == "" then
			Text = "sell license"
		else
			Text = Text .. " and sell license"
		end
	end

	local LicenseName = FALICENSE_DATABASE[LID].Name
	mLogs.log("application", category, {player1=mLogs.logger.getPlayerData(Player),lname=LicenseName,text=Text,a=true})
end)
