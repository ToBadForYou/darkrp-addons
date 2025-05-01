ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Category = "ToBadForYou"

ENT.Spawnable = true
ENT.PrintName		= "Printer"
ENT.Author			= "ToBadForYou"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "EOwner")
	self:NetworkVar("Vector", 0, "PColor")
	
	self:SetPColor(Vector(1,1,1))
end