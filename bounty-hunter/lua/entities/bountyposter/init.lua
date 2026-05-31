AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/Frame002a.mdl")
    self.Entity:SetModelScale(0.55,0)
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	self.Bounty = 0
end

function ENT:UpdateReward(Bounty)
    net.Start("UpdateBountyPoster")
	    net.WriteEntity(self)
		net.WriteFloat(Bounty)
	net.Broadcast()
	self.Bounty = Bounty
end

function ENT:Use(activator, caller )
    if self.Entity.Touched and self.Entity.Touched > CurTime() then return ; end
	self.Entity.Touched = CurTime() + 1;
		
	local Player = self.Player
	if !IsValid(Player) then self:Remove() return end
	if self.PlacedBy and self.PlacedBy == activator then
		DarkRP.notify(activator, 1, 4, "You can't start a bounty placed by yourself!")
		return
	end
	
	if activator.Bounty then
	    DarkRP.notify(activator, 1, 4, "You have already started a bounty, finish it, then come back!")
	    return
	end
	
	local PBounty = activator.PBountyCD[Player:UniqueID()]
	if PBounty and PBounty > CurTime() then 
	    local TimeLeft = math.Round(PBounty-CurTime())
		DarkRP.notify(activator, 1, 4, "You can start a bounty on this player again in: " .. TimeLeft .. " seconds.")
		return 
	end
	
	if activator:CanBountyHunt() and Player != activator then	
		activator.Bounty = Player
	    Player.HuntedBy = activator
		net.Start("SendBounty")
			net.WriteString(Player:Nick()) 
			net.WriteFloat(Player.Kills)
			net.WriteString(Player:GetModel())
			net.WriteFloat(self.Bounty)
		net.Send(activator)
		
		DarkRP.notify(activator, 1, 4, "Bounty on " .. Player:Nick() .. "s head started.")
		hook.Call("bh_startbounty", GAMEMODE, activator, Player)
		
		Player:CleanUpPosters()	 
	end
end

function ENT:Think()
end

function ENT:Touch(TouchEnt)
    if self.Entity.Touched and self.Entity.Touched > CurTime() then return ; end
	self.Entity.Touched = CurTime() + 1;
end