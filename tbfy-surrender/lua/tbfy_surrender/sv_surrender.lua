util.AddNetworkString("tbfy_surrender")
util.AddNetworkString("tbfy_bonemanipulate")

local PLAYER = FindMetaTable("Player")

function PLAYER:TBFY_ToggleSurrender()
	if self.TBFY_Surrendered then
		self:SetupSurrenderBones("HandsUp", true)
		self.TBFY_Surrendered = false
		self:StripWeapon("tbfy_surrendered")
	else
		self:Give("tbfy_surrendered")
		//FA Support
		local swep = self:GetActiveWeapon()
		if IsValid(swep) and swep.dt then
			swep.dt.Status = 6
		end
		self:SelectWeapon("tbfy_surrendered")
		self:SetupSurrenderBones("HandsUp")
		self.TBFY_Surrendered = true
	end
end

local boneManipulation = {
	["HandsUp"] = {
		["ValveBiped.Bip01_R_UpperArm"] = Angle(73,35,128),
		["ValveBiped.Bip01_L_Hand"] = Angle(-12,12,90),
		["ValveBiped.Bip01_L_Forearm"] = Angle(-28,-29,44),
		["ValveBiped.Bip01_R_Forearm"] = Angle(-22,1,15),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(-77,-46,4),
		["ValveBiped.Bip01_R_Hand"] = Angle(33,39,-21),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,30,0),
		["ValveBiped.Bip01_L_Finger1"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger11"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger2"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger3"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger31"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,30,0),
		["ValveBiped.Bip01_R_Finger2"] = Angle(20,25,0),
		["ValveBiped.Bip01_R_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger3"] = Angle(20,35,0),
		["ValveBiped.Bip01_R_Finger31"] = Angle(0,45,0)
	}
}

function PLAYER:SetupSurrenderBones(boneType, reset)
    if TBFYSurrenderConfig.BoneManipulateClientside then
		net.Start("tbfy_bonemanipulate")
			net.WriteEntity(self)
			net.WriteString(type)
			net.WriteBool(reset)
		net.Broadcast()
	else
		for k, v in pairs(boneManipulation[boneType]) do
			local bone = self:LookupBone(k)
			if bone then
				if reset then
					self:ManipulateBoneAngles(bone, Angle(0,0,0))
				else
					self:ManipulateBoneAngles(bone, v)
				end
			end
		end
	end
	if TBFYSurrenderConfig.DisablePlayerShadow then
		self:DrawShadow(false)
	end
end

local currentlySurrendering = {}
hook.Add("Think", "tbfy_surrender_think", function()
	for k,v in pairs(currentlySurrendering) do
		local ply, time = v.ply, v.surrenderTime
		if time <= CurTime() then
			currentlySurrendering[ply:SteamID()] = nil
			net.Start("tbfy_surrender")
				net.WriteUInt(0, 26)
			net.Send(ply)
			ply:TBFY_ToggleSurrender()
		end
	end
end)

hook.Add("PlayerDisconnected", "tbfy_surrender_playerdisconnected", function(ply)
	local SID = ply:SteamID()
	if currentlySurrendering[SID] then
		currentlySurrendering[SID] = nil
	end
end)

hook.Add("PlayerButtonDown","tbfy_surrender_playerbuttondown",function(ply, key)
	if TBFYSurrenderConfig.SurrenderEnabled and key == TBFYSurrenderConfig.SurrenderKey and ply:TBFY_CanSurrender() then
		local surrenderTime = CurTime() + 2
		currentlySurrendering[ply:SteamID()] = {ply = ply, surrenderTime = surrenderTime}
		net.Start("tbfy_surrender")
			net.WriteUInt(surrenderTime, 26)
		net.Send(ply)
	end
end)

hook.Add("PlayerButtonUp","tbfy_surrender_playerbuttonup",function(ply, key)
	if key == TBFYSurrenderConfig.SurrenderKey and currentlySurrendering[ply:SteamID()] then
		currentlySurrendering[ply:SteamID()] = nil
		net.Start("tbfy_surrender")
			net.WriteUInt(0, 26)
		net.Send(ply)
	end
end)

hook.Add("demoteTeam", "tbfy_surrender_demoteteam", function(ply)
	ply.being_demoted = true
end)

hook.Add("playerCanChangeTeam", "tbfy_surrender_playercanchangeteam", function(ply, team)
  if ply.TBFY_Surrendered and !ply.being_demoted then
		return false, ""
	end
	ply.being_demoted = false
end)

hook.Add("OnPlayerChangedTeam", "tbfy_surrender_onplayerchangeteam", function(ply, team)
  if ply.TBFY_Surrendered then
	ply:TBFY_ToggleSurrender()
	end
end)

hook.Add("PlayerSwitchWeapon", "tbfy_surrender_playerswitchweapon", function(ply, old, new)
	if ply.TBFY_Surrendered then return true end
end)

hook.Add("PlayerCanPickupWeapon", "tbfy_surrender_playercanpickupweapon", function(ply, weapon)
	if ply.TBFY_Surrendered and weapon:GetClass() != "tbfy_surrendered" then return false end
end)

hook.Add("canDropWeapon", "tbfy_surrender_candropweapon", function(ply)
	if ply.TBFY_Surrendered then return false end
end)

hook.Add("CanPlayerEnterVehicle", "tbfy_surrender_canplayerentervehicle", function(ply, veh)
	if ply.TBFY_Surrendered then return false end
end)

hook.Add("PlayerDeath", "tbfy_surrender_playerdeath", function(ply)
    if ply.TBFY_Surrendered then
        ply:TBFY_ToggleSurrender()
    end
end)

hook.Add("PlayerUse", "tbfy_surrender_playeruse", function(ply, ent)
	if ply.TBFY_Surrendered then return false end
end)

hook.Add("onDarkRPWeaponDropped", "tbfy_surrender_ondarkrpweapondropped", function(ply, ent, weapon)
	if weapon:GetClass() == "tbfy_surrendered" then
		ent:Remove()
	end
end)