AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/props/de_inferno/picture2.mdl")	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
end

function ENT:SetupPValues(Poster)
	local PEnt = Poster
	if IsValid(PEnt) then
		self:SetEOwner(PEnt:GetEOwner())
		self:SetPName(PEnt:GetPName())
		self:SetPText(PEnt:GetPText())
		self:SetDType(PEnt:GetDType())
		self:SetBackGColor(PEnt:GetBackGColor())
		self:SetDecalColor(PEnt:GetDecalColor())
	end
end

function ENT:SetupPValuesInput(Owner, N, T, DT, BGC, DC)
	self:SetEOwner(Owner)
	self:SetPName(N)
	self:SetPText(T)
	self:SetDType(DT)
	self:SetBackGColor(BGC)
	self:SetDecalColor(DC)
end

function ENT:Use(activator, caller)
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;
	
	if !self.PosterPlaced then
		activator:RES_GivePoster(self:GetPName(),self:GetPText(),self:GetDType(),self:GetBackGColor(),self:GetDecalColor())
		self:Remove()
	elseif self.PosterPlaced and self:GetEOwner() == activator then
		activator.RES_LastPosterE = self
		net.Start("res_poster_options")
		net.Send(activator)
	end
end

function ENT:Think()
end