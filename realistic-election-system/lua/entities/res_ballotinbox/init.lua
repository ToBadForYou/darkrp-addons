AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/props_street/mail_dropbox.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	self.Entity:SetMaterial("tbfy/mail_dropbox")
end

function ENT:Use( activator, caller )
	if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;
end

function ENT:Think()
end
