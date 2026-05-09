AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/clock01.mdl")
	self.Entity:SetSubMaterial(0, "models/fa_target")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_FLY )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	
	self.Entity.VeliVector = Vector(0,0,0)
	self.Entity.Enabled = false
	self.Entity.SwitchTime = 2
	self.Entity.SwitchDir = 0
	self.Entity.TStage = nil
	self.Entity.LID = nil
	self.Entity.Switched = false

	local Phys = self:GetPhysicsObject()
	if Phys then
		Phys:Wake()
	end
end

function ENT:Use( activator, caller )
end

function ENT:Think()
	if self.Enabled then
		if self.SwitchDir < CurTime() then
			self.SwitchDir = CurTime() + self.SwitchTime
			self:FA_ToggleMove()
		end
	end
end

function ENT:Touch()
end

local BellNames = {"c","d","e","f"}
function ENT:OnTakeDamage(DmgInfo)
	local Player = DmgInfo:GetAttacker()
	if Player:IsPlayer() and Player.FA_DoingPractical == self.LID then
		local RandomBell = table.Random(BellNames)
		self:EmitSound("ambient/misc/brass_bell_" .. RandomBell .. ".wav")
		local effect = EffectData();
		effect:SetOrigin(self:GetPos());
		util.Effect("balloon_pop", effect);	
		self:Remove()
		
		Player:FA_PracticalUpdate()
	end
end

function ENT:FA_Setup(X,Y,Z, Time, Stage, LID)
	self.VeliVector = Vector(X,Y,Z)
	self.SwitchTime = Time
	self.TStage = Stage
	self.LID = LID
end

function ENT:FA_Enable()
	self.SwitchDir = CurTime() + self.SwitchTime
	self.Enabled = true
	self:FA_ToggleMove()
end

function ENT:FA_Disable()
	self.Enabled = false
end

function ENT:FA_ToggleMove()
	self:SetVelocity(self:GetVelocity()*-1)
	
	timer.Simple(.1, function()
		if IsValid(self) then
			if self.Switched then
				self.Switched = false
				self:SetVelocity(self.VeliVector*-1)
			else
				self.Switched = true
				self:SetVelocity(self.VeliVector)
			end
		end
	end)
end