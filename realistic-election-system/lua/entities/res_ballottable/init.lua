AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/props/CS_militia/wood_table.mdl")	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	
	self.PPile = ents.Create("res_ballotpile")
	self.PPile:SetPos(self:GetPos() + self:GetUp() * 31 + self:GetForward() * -18)
	self.PPile:SetAngles(self:GetAngles())
	self.PPile:Spawn()
	self.PPile:Activate()
	
	self.PPile.Table = self
	self:DeleteOnRemove(self.PPile)
	self.PPile:DeleteOnRemove(self) 	
	constraint.Weld(self.PPile, self, 0, 0, 0, true)
    self.PPile:GetPhysicsObject():EnableMotion(false)	
	self.Entity.Paper = self.PPile
	self:GetPhysicsObject():EnableMotion(false)	
end

function ENT:Use( activator, caller )
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;
end

function ENT:Think()
end