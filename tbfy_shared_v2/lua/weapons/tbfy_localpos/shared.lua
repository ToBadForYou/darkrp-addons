if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Local Placement SWEP"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Author = "ToBadForYou"
SWEP.Instructions = "Left Click: Select Main/Child Entity\nRight Click: Reset Data\nReload: Print Data"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.HoldType = "normal";
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "normal"
SWEP.Category = "ToBadForYou"
SWEP.UID = 76561197989708503

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

function SWEP:Initialize() 
	self:SetHoldType("normal")
	
	self.MainEnt = nil
	self.ChildEnts = {}
end

function SWEP:PrimaryAttack()
	if self.NextLPress and self.NextLPress > CurTime() then return end
	self.NextLPress = CurTime() + 1	
	
	if CLIENT then
		local PTrace = self.Owner:GetEyeTrace()
		local Ent = PTrace.Entity
		if IsValid(Ent) then
			if !self.MainEnt then 
				self.MainEnt = Ent
			else
				self.ChildEnts[Ent:EntIndex()] = Ent
			end
		end
	end	
end

function SWEP:SecondaryAttack()
	if self.NextRPress and self.NextRPress > CurTime() then return end
	self.NextRPress = CurTime() + 1		
	
	if CLIENT then
		if self.MainEnt then
			self.MainEnt = nil
			self.ChildEnts = {}
		end
	end
end

function SWEP:Reload()
	if self.NextRPress and self.NextRPress > CurTime() then return end
	self.NextRPress = CurTime() + 1	
	if CLIENT then
		local MEnt = self.MainEnt
		if IsValid(MEnt) then
			for k,v in pairs(self.ChildEnts) do
				if IsValid(v) then
					local Pos, Ang = MEnt:WorldToLocal(v:GetPos()), MEnt:WorldToLocalAngles(v:GetAngles())
					print("{Pos = Vector(" .. Pos.x .. ", " .. Pos.y .. ", " .. Pos.z .. "), Ang = Angle(" .. Ang.p .. ", " .. Ang.y .. ", " .. Ang.r .. ")},")
				end
			end
		end
	end
end

if CLIENT then
 	function SWEP:DrawHUD()
		if !self.MainEnt then
			draw.SimpleTextOutlined("(LEFT CLICK) Select Main Ent","Trebuchet24",ScrW()/2,5,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
		else
			draw.SimpleTextOutlined("(LEFT CLICK) Select Child Ents","Trebuchet24",ScrW()/2,5,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
			draw.SimpleTextOutlined("(RIGHT CLICK) Reset","Trebuchet24",ScrW()/2,25,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
			draw.SimpleTextOutlined("(RELOAD) Print Data","Trebuchet24",ScrW()/2,45,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
		end
	end
end