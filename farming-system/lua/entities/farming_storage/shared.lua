ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Category = "ToBadForYou"

ENT.Spawnable = false
ENT.PrintName		= "Storage"
ENT.Author			= "ToBadForYou"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()
    self:NetworkVar("String",0,"contents")
    self:NetworkVar("Int",0,"count")
end