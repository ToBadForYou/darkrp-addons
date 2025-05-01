AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/sterling/tbfy_table.mdl")	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;
	
	local Ballot = self.Ballot
	if IsValid(Ballot) then
		local Owner = Ballot:GetEOwner()
		if RES_IsVotePhase() and Ballot.VoteStand and Owner == activator then
			net.Start("res_open_ballotmenu")
			net.Send(activator)
		end
	end
end

function ENT:Think()
end

function ENT:AttachBallot(Ballot)
	self.Ballot = Ballot
	Ballot.VoteStand = self
	
	local pos = self:GetPos();
	local ang = self:GetAngles();	
	pos = pos + self:GetUp() *40.5 + self:GetForward()*1
	ang:RotateAroundAxis(ang:Up(), 90);

	Ballot:SetPos(pos)
	Ballot:SetAngles(ang)
	
	Ballot:GetPhysicsObject():EnableMotion(false)
end