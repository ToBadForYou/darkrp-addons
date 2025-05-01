ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Category = "ToBadForYou"

ENT.Spawnable = false
ENT.PrintName		= "Podium"
ENT.Author			= "ToBadForYou"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.TBFYEnt = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "EOwner")
	self:NetworkVar("String", 0, "PName")
	self:NetworkVar("String", 1, "Slogan")
	self:NetworkVar("Float", 0, "DType")
	self:NetworkVar("Vector", 0, "DecalColor")
	self:NetworkVar("Vector", 1, "BackGColor")

	self:SetSlogan("Press E to edit")
	self:SetDType(11)
	self:SetBackGColor(Vector(0.2,0.2,0.5))
	self:SetDecalColor(Vector(0.5,0,0))
end
