ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Category = "ToBadForYou"

ENT.Spawnable = false
ENT.PrintName		= "Ballot"
ENT.Author			= "ToBadForYou"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "EOwner")
end