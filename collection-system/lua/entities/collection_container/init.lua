AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	self.Entity.CollItems = {}
	
	local Phys = self:GetPhysicsObject()
	if Phys then
		Phys:EnableMotion(false)
	end
end

function ENT:Use( activator, caller )
    if self.Entity.Touched and self.Entity.Touched > CurTime() then return end
	self.Entity.Touched = CurTime() + 1
	
	activator.LastContainer = self
	net.Start("collect_open_container")
		net.WriteTable(self.Entity.CollItems)
	net.Send(activator)
end

function ENT:Think()
end

function ENT:Touch()
end