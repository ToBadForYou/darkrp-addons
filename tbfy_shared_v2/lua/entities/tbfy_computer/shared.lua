ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Category = "ToBadForYou"

ENT.Spawnable = false
ENT.PrintName		= "TBFY Computer"
ENT.Author			= "ToBadForYou"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.TBFYEnt = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "EName")
	self:NetworkVar("String", 1, "IP")
	self:NetworkVar("String", 2, "AvatarID")
	self:NetworkVar("String", 3, "WallpaperID")
	self:NetworkVar("Float", 0, "ScreenStatus")
	self:NetworkVar("Float", 1, "PCType")
	self:NetworkVar("Bool", 0, "Firewall")
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Entity", 1, "EOwner")
end
