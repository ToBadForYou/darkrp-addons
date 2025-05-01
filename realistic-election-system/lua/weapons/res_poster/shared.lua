if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Poster"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "ToBadForYou"
SWEP.Instructions = "Left Click: Set Poster"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.HoldType = "normal";
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "normal"
SWEP.Category = "ToBadForYou"
SWEP.UID = 76561197989708503

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
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
end

local WHEnts = {
["trigger_soundscape"] = true,
["keyframe_rope"] = true,
}

function SWEP:PrimaryAttack()
	if self.NextLPress and self.NextLPress > CurTime() then return end
	self.NextLPress = CurTime() + 1

	if SERVER then
		local Player = self.Owner
		local Posters = Player.RES_Posters
			if Posters then
			local PAmount = table.Count(Posters)
			local CurPosters = Player:GetCPostersAmount()
			local MaxPosters = RES_GetConf("ELECTION_MaxPosters")

			if CurPosters >= MaxPosters then
				TBFY_Notify(Player, 1, 4, string.format(RES_GetLang("MaxPostersReached"), MaxPosters))
			else
				if PAmount > 0 then
					local Trace = Player:GetEyeTrace()
					local Pos, Ang = Trace.HitPos-Vector(0,0,2.5), Trace.HitNormal:Angle()

					local EntF = false
					for k,v in pairs(ents.FindInSphere(Pos, 15)) do
						if v:IsPlayer() or !WHEnts[v:GetClass()] then
							EntF = true
						end
					end

					if !EntF then
						Player:RES_PlacePoster(Pos, Ang)
					else
						TBFY_Notify(Player, 1, 4, RES_GetLang("PositionBlocked"))
					end
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if self.NextRPress and self.NextRPress > CurTime() then return end
	self.NextRPress = CurTime() + 1
end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:DrawWorldModel()
end

if CLIENT then
	function SWEP:DrawHUD()
		local Posters = LocalPlayer().RES_Posters
		if Posters then
			local PAmount = table.Count(Posters)
			draw.SimpleTextOutlined("You are carrying: " .. PAmount .. " posters","Trebuchet24",ScrW()/2,5,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
		end
	end

	local Frame = Material("tbfy/posters/post_env.png")
	local function RES_DrawCPoster(Info)
		local Name = Info.N
		local DType = Info.DT
		local BGColor = Info.BG
		local DecalColor = Info.DTC

		local DTbl = RES_Config.PosterDecals[DType]
		draw.RoundedBox(0, -250, -375, 500, 750, Color(BGColor.x*255, BGColor.y*255, BGColor.z*255, 255))
		if DTbl and DTbl.Mat then
			surface.SetMaterial(DTbl.Mat)
		else
			surface.SetMaterial(Frame)
		end
		surface.SetDrawColor(DecalColor.x*255, DecalColor.y*255, DecalColor.z*255, 255)
		surface.DrawTexturedRect(-250, -375, 500, 750)
		draw.SimpleText(Name, "res_poster_head", 0, 160-375, Color(255,255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	hook.Add("PostDrawTranslucentRenderables", "res_DrawPosterPlacement", function()
		local LPlayer = LocalPlayer()
		local CurWep = LPlayer:GetActiveWeapon()
		local Trace = LPlayer:GetEyeTrace()
		local HitPos = Trace.HitPos
		if IsValid(CurWep) and CurWep:GetClass() == "res_poster" and LPlayer.RES_Posters and LPlayer:HasWeapon("res_poster") and LPlayer:GetPos():Distance(HitPos) < 300 then
			local Pos, Ang = HitPos, Trace.HitNormal:Angle()
			Ang:RotateAroundAxis(Ang:Right( ), -90)
			Ang:RotateAroundAxis(Ang:Up( ), 90)

			local PInfo = LPlayer.RES_Posters[1]
			cam.Start3D2D(Pos, Ang, .06)
				RES_DrawCPoster(PInfo)
			cam.End3D2D()
		end
	end)
end
