AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/sterling/tbfy_votingbooth.mdl")	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	self:SetBodygroup(2,1)
	self.Closed = true
end

function ENT:ToggleOpenClose()
	if self.Closed then
		self.Closed = false
		local OpenSeq, Time1 = self:LookupSequence("Open")		
		self:ResetSequence(OpenSeq)
		self:SetPlaybackRate(1.7)
	else
		self.Closed = true
		local CloseSeq, Time1 = self:LookupSequence("Close")
		self:ResetSequence(CloseSeq)	
		self:SetPlaybackRate(1.7)
	end
end

function ENT:Use( activator, caller )
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 1.5;
	
	self:ToggleOpenClose()
end

function ENT:Think()
	if self.NextBRemoveCheck and self.NextBRemoveCheck < CurTime() then
		self.NextBRemoveCheck = nil
		if IsValid(self.Ballot) then
			self.Ballot:Remove()
			self.Ballot = nil
		end
	end
end

function ENT:AttachBallot(Ballot)
	self.NextBRemoveCheck = CurTime() + 60

	self.Ballot = Ballot
	Ballot.VoteStand = self
	
	local pos = self:GetPos();
	local ang = self:GetAngles();	
	pos = pos + self:GetUp() *42.5 + self:GetForward()*-2
	ang:RotateAroundAxis(ang:Up(), 90);

	Ballot:SetPos(pos)
	Ballot:SetAngles(ang)
	
	Ballot:GetPhysicsObject():EnableMotion(false)
end