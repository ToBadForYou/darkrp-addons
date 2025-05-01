AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/school/paper.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)
  if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;

	if RES_IsVotePhase() then
		if !activator:RES_HasVoted() then
			if !IsValid(activator.Ballot) then
				activator.Ballot = ents.Create("res_ballot")
				activator.Ballot:SetPos(self:GetPos() + Vector(0,0,2))
				activator.Ballot:SetAngles(self:GetAngles())
				activator.Ballot:Spawn()
				activator.Ballot:GetPhysicsObject():Wake()
				activator.Ballot:SetEOwner(activator)
			else
				TBFY_Notify(activator, 1, 4, RES_GetLang("BallotExists"))
			end
		else
			TBFY_Notify(activator, 1, 4, RES_GetLang("AlreadyVoted"))
		end
	end
end

function ENT:Think()
end
