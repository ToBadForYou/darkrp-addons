AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction(Player, tr, Class)
	if !tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal* 20
	local SpawnAng = Player:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create(Class)
	ent:SetPos(SpawnPos)
	ent:SetAngles(SpawnAng)
	ent:Spawn()

	ent.RESPEnt = true
	ent:SetEOwner(Player)
	ent:GetPhysicsObject():EnableMotion(false)
	return ent
end

function ENT:Initialize()
	self:SetModel("models/alec/atom_smasher/alec_trump_podium_01b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:GetPhysicsObject():EnableMotion(false)
	self.RESPEnt = true
end

function ENT:Use( activator, caller )
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;

	if self:GetEOwner() == activator or (!IsValid(self:GetEOwner()) and activator:RESAdminAccess()) then
		activator.LastPodium = self
		net.Start("res_edit_podium")
			net.WriteEntity(self)
		net.Send(activator)
	end
end

function ENT:Think()
end
