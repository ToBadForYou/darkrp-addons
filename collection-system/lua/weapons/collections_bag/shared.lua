if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Collection Bag"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "ToBadForYou"
SWEP.Instructions = "Left Click: Open Collection Bag\nRight Click: Open Collection Menu"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.HoldType = "normal";
SWEP.WorldModel = ""
SWEP.UID = 76561197989708503
SWEP.AnimPrefix	 = "normal"
SWEP.Category = "ToBadForYou"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.Kind = 9
SWEP.InLoadoutFor = {ROLE_INNOCENT, ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.AllowDelete = false
SWEP.AllowDrop = false

function SWEP:Initialize() self:SetHoldType("normal") end
function SWEP:CanPrimaryAttack ( ) return false; end
function SWEP:CanSecondaryAttack ( ) return false; end

function SWEP:Think()
end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:PrimaryAttack()
	if CLIENT then
		if !IsValid(COLLECTIONS_INV) then
			COLLECTIONS_INV = vgui.Create("collections_inventory")
		end
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then
		if !IsValid(COLLECTIONS_MENU) then
			COLLECTIONS_MENU = vgui.Create("collections_mainmenu")
		end
	end
end

function SWEP:DrawWorldModel()
end

function SWEP:Reload()
end

function SWEP:DampenDrop()
	self:Remove()
end