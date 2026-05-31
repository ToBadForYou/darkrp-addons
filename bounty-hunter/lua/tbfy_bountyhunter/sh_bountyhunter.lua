
local PLAYER = FindMetaTable("Player")

util.PrecacheSound("newbounty.ogg")
util.PrecacheSound("newbounty.mp3")

function PLAYER:IsBountyHunter()
    return TBFY_BHConfig.BountyJobs[self:Team()]
end

function PLAYER:JobCanBountyHunt()
	if !TBFY_BHConfig.JobBlackList[self:Team()] then
		return true
	else
		return TBFY_BHConfig.JobBlackList[self:Team()].CanBountyHunt
	end
end

function PLAYER:CanPlaceBounty()
	if !TBFY_BHConfig.JobBlackList[self:Team()] then
		return true
	else
		return TBFY_BHConfig.JobBlackList[self:Team()].CanPlaceBounty
	end
end

function PLAYER:CanReceiveBounty()
	if self:IsBot() then return false end
	if !TBFY_BHConfig.JobBlackList[self:Team()] then
		return true
	else
		return TBFY_BHConfig.JobBlackList[self:Team()].CanReceiveBounty
	end
end

function PLAYER:CanBountyHunt()
    if !self:JobCanBountyHunt() then
	    return false
	end

	if TBFY_BHConfig.JobBH and self:IsBountyHunter() then
	    return true
	elseif !TBFY_BHConfig.JobBH then
	    return true
	else 
	    return false	
	end	
end

function BH_GetBountyHunterAmount()
    local Amount = 0
	
	for k,v in pairs(TBFY_BHConfig.BountyJobs) do
	    Amount = Amount+#team.GetPlayers(k)
	end

	return Amount
end


hook.Add("PhysgunPickup", "DisablePhysgunPosterEnt", function(Player, Ent)
    if Ent:GetClass() == "bountyposter" then
	    return false
	end	
end)