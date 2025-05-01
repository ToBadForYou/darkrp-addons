AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( Player, tr, Class )
	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal
	local SpawnAng = Player:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( Class )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()	
	
	ent.RESPEnt = true
	ent:SetEOwner(Player)
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel("models/props/CS_militia/table_shed.mdl")	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	self.RESPEnt = true
end

function ENT:Use(activator, caller)
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;
	
	if self:GetEOwner() == activator then
		activator.LastPoster = self
		net.Start("res_edit_poster")
			net.WriteEntity(self)
		net.Send(activator)
	end
end

function ENT:Think()
end