AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/school/paper.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)

	self.SelectedID = nil
end

function ENT:Use(activator, caller)
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;
	local Owner = self:GetEOwner()

	if RES_IsVotePhase() and self.VoteStand and Owner == activator then
		net.Start("res_open_ballotmenu")
		net.Send(activator)
	end
end

function ENT:Touch(TouchEnt)
    if self.Entity.Touched and self.Entity.Touched > CurTime() then return ; end
	self.Entity.Touched = CurTime() + 1;

	local Class = TouchEnt:GetClass()
	if Class == "res_ballotinbox" then
		local Owner = self:GetEOwner()
		if !self.SelectedID then
			TBFY_Notify(Owner, 1, 4, RES_GetLang("NoVoteSelected"))
		else
			RES_DepositVote(self)
		end
	elseif !self.SelectedID and (Class == "res_votingbooth" or Class == "res_votingstand") then
		TouchEnt:AttachBallot(self)
	end
end

function ENT:Think()
end
