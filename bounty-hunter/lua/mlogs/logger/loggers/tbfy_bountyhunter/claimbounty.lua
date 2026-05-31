--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "bountyhunter"

mLogs.addLogger("Claim Bounty","claimbounty",category)
mLogs.addHook("bh_claimbounty", category, function(BH, Player, BountyA)
	if(not IsValid(BH) or not IsValid(Player))then return end
	mLogs.log("claimbounty", category, {player1=mLogs.logger.getPlayerData(BH),player2=mLogs.logger.getPlayerData(Player),bountyamount=BountyA,a=true})
end)