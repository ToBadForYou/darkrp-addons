if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Setup SWEP"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "ToBadForYou"
SWEP.Instructions = "Left Click: Spawn Entity\nR: Selection Menu"
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
	self.CurEnt = nil
	self:SetHoldType("normal")
	self.ETbl = nil
	self.CurStage = 1
	if CLIENT then
		LocalPlayer().TBFY_LastEntData = nil
	end
end

function SWEP:PrimaryAttack()
	if self.NextLPress and self.NextLPress > CurTime() then return end
	self.NextLPress = CurTime() + 1

	if CLIENT then
		if self.ETbl and self.ETbl.CFuncL then
			self.ETbl.CFuncL(self)
		else
			if IsValid(self.GhostEnt) then
				local Name = LocalPlayer().TBFY_EName or ""
				net.Start("tbfy_spawn_entity")
					net.WriteString(self.CurEnt)
					net.WriteVector(self.GhostEnt:GetPos())
					net.WriteAngle(self.GhostEnt:GetAngles())
					net.WriteString(Name)
				net.SendToServer()
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if self.NextRPress and self.NextRPress > CurTime() then return end
	self.NextRPress = CurTime() + 1

	if self.ETbl and self.ETbl.CFuncR then
		self.ETbl.CFuncR(self)
	else
		return false
	end
end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:DrawWorldModel()
end

function SWEP:Reload()
	if self.NextRPress and self.NextRPress > CurTime() then return end
	self.NextRPress = CurTime() + 1
	if CLIENT then
		vgui.Create("tbfy_selectionmenu")
	end
end

if CLIENT then
	function SWEP:UpdateSelectedEnt(Ent, ETbl)
		LocalPlayer().TBFY_LastEntData = nil

		self.CurEnt = Ent
		self.ETbl = ETbl
		self.CurStage = 1

		if !self.GhostEnt then
			self.GhostEnt = ents.CreateClientProp()
			self.GhostEnt:SetModel(ETbl.M)
			self.GhostEnt:Spawn()

			self.GhostEnt:SetMaterial("models/wireframe")
			if ETbl.NoGhost then
				self.GhostEnt:SetNoDraw(true)
			else
				self.GhostEnt:SetNoDraw(false)
			end

			LocalPlayer().GhostEnt = self.GhostEnt
		else
			if ETbl.NoGhost then
				self.GhostEnt:SetNoDraw(true)
			else
				self.GhostEnt:SetNoDraw(false)
				self.GhostEnt:SetModel(ETbl.M)
			end
		end
	end

	function SWEP:Think()
		if self.ETbl and self.ETbl.CFuncThink then
			self.ETbl.CFuncThink(self)
		else
			local Player = self.Owner
			local PTrace = Player:GetEyeTrace()
			local GEnt = self.GhostEnt
			local Offset = Vector(0,0,0)
			local AngAdj = Angle(0,0,0)

			if IsValid(GEnt) then
				local ETbl = self.ETbl
				if ETbl and ETbl.Offset then
					Offset = ETbl.Offset
				end

				if ETbl and ETbl.AngAdj then
					AngAdj = ETbl.AngAdj
				end
				GEnt:SetPos(PTrace.HitPos+Offset)
				local Ang = Player:GetAngles()
				GEnt:SetAngles(Angle(0,Ang.y-180,0)+AngAdj)
			end
		end
	end

	function SWEP:DrawHUD()
		if !self.ETbl then
			draw.SimpleTextOutlined("Press R(+reload) to open selection menu","Trebuchet24",ScrW()/2,5,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
		elseif self.ETbl then
			if self.ETbl.CFuncDraw then
				self.ETbl.CFuncDraw(self)
			end
		end
	end

	function SWEP:Holster()
		if CLIENT then
			if IsValid(self.GhostEnt) then
				self.GhostEnt:Remove()
				self.GhostEnt = nil
			end
			self.ETbl = nil
		end
		return true
	end

	function SWEP:OnRemove()
		if IsValid(self.GhostEnt) then
			self.GhostEnt:Remove()
			self.GhostEnt = nil
		end
	end
end
