AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	self.Entity:SetCustomCollisionCheck(true)
	
	local Phys = self:GetPhysicsObject()
	if Phys then
		Phys:Wake()
	end
end

function ENT:Use( activator, caller )
    if self.Entity.Touched and self.Entity.Touched > CurTime() then return end
	self.Entity.Touched = CurTime() + 1
	
	activator:GiveCItem(self.CID, 1)
	self:Remove()
end

function ENT:Think()
end

function ENT:Touch()
end