if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Firearms License"
	SWEP.Slot = 2
	SWEP.SlotPos = 2
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "ToBadForYou"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.HoldType = "pistol";
SWEP.AnimPrefix	 = "pistol"
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

function SWEP:Initialize() self:SetHoldType("pistol") end
function SWEP:CanPrimaryAttack ( ) return false; end
function SWEP:CanSecondaryAttack ( ) return false; end

function SWEP:PreDrawViewModel(vm)
    return true
end

if CLIENT then
surface.CreateFont( "firearms_license_text", {
	font = "Verdana",
	size = 12,
	weight = 1000,
	antialias = true,
} )

local draw = draw
local surface = surface
local cam = cam

local DIMat = Material("fa_licenseframe.png")
local HasLMat = Material("fa_hasl.png")
local NoLMat = Material("fa_nol.png")

local FA_DB = FALICENSE_DATABASE

local MatTbl = {}
local function FetchLicenseIcon(ID)
	if !MatTbl[ID] then
		MatTbl[ID] = Material(FALICENSE_DATABASE[ID].Image)
	end
	return MatTbl[ID]
end

local FA_Config = TBFY_FAConfig
function SWEP:DrawHUD()
	local LW, LH = 515, 250
	local W,H = ScrW()-LW-5, ScrH()-LH-5

	local LP = LocalPlayer()
	LP.PIcon = LP.PIcon or vgui.Create( "ModelImage")
	LP.PIcon:SetSize(146,146)
	LP.PIcon:SetModel(LP:GetModel())

	surface.SetMaterial(DIMat)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(W, H, LW, LH)

	LP.PIcon:SetPos(W+25,H+70)
	LP.PIcon:SetPaintedManually(false)
	LP.PIcon:PaintManual()
	LP.PIcon:SetPaintedManually(true)

	local TextW,TextH = W+180, H + 75
	local SID = TBFY_SH:SID(LP)

	draw.SimpleText(LP:Nick(), "firearms_license_text", TextW, TextH, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	if FA_Config.DisplaySteamID then
		TextH = TextH + 15
		draw.SimpleText(SID, "firearms_license_text", TextW, TextH, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
	if FA_Config.DisplayJob then
		TextH = TextH + 15
		draw.SimpleText(LP:getDarkRPVar("job"), "firearms_license_text", TextW, TextH, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
	TextH = TextH + 15
	draw.SimpleText(FA_GetLang("Instructor") .. ":", "firearms_license_text", TextW, TextH, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	local LMat = NoLMat
	if LP:FA_IsInstructor() then
		LMat = HasLMat
	end
	surface.SetFont("firearms_license_text")
	local TW, TH = surface.GetTextSize(FA_GetLang("Instructor") .. ":")

	surface.SetMaterial(LMat)
	surface.DrawTexturedRect(TextW+TW+5, TextH-2.5, 10, 10)

	local DIS = 0
	local CS = 5
	local LicenseW, LicenseH = W+300, H+75

	draw.SimpleText(FA_GetLang("Theory"), "firearms_license_text", LicenseW+75, LicenseH-5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText(FA_GetLang("Practical"), "firearms_license_text", LicenseW+120, LicenseH-5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText(FA_GetLang("Carry"), "firearms_license_text", LicenseW+160, LicenseH-5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText(FA_GetLang("Sell"), "firearms_license_text", LicenseW+190, LicenseH-5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	for i,n in ipairs(FA_DB) do
		draw.SimpleText(n.Name, "firearms_license_text", LicenseW, LicenseH+DIS+11, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

		surface.SetMaterial(FetchLicenseIcon(i))
		surface.DrawTexturedRect(LicenseW+5, LicenseH+DIS, 50, 25)

		local TypeW = LicenseW + 70
		local LMat = NoLMat
		if TBFY_SH:PlayerHasTheory(SID, n.TheoryTest, i) then
		    LMat = HasLMat
		end
		surface.SetMaterial(LMat)
		surface.DrawTexturedRect(TypeW, LicenseH+CS+2, 12, 12)
		TypeW = TypeW + 45

		local LMat = NoLMat
		if LP:FAPassedPractical(i) then
		    LMat = HasLMat
		end
		surface.SetMaterial(LMat)
		surface.DrawTexturedRect(TypeW, LicenseH+CS+2, 12, 12)
		TypeW = TypeW + 40

		local LMat = NoLMat
		if LP:FACanCarry(i) then
		    LMat = HasLMat
		end
		surface.SetMaterial(LMat)
		surface.DrawTexturedRect(TypeW, LicenseH+CS+2, 12, 12)
		TypeW = TypeW + 30

		local LMat = NoLMat
		if LP:FACanSell(i) then
		    LMat = HasLMat
		end
		surface.SetMaterial(LMat)
		surface.DrawTexturedRect(TypeW, LicenseH+CS+2, 12, 12)

		DIS = DIS + 25
		CS = CS + 25
	end
end

function SWEP:DrawWorldModel()
	local LPlayer = LocalPlayer()
	local Owner = self.Owner
	if LPlayer == Owner then return end

	if !IsValid(self.WModel) then
		self.WModel = ClientsideModel("models/hunter/plates/plate1x1.mdl")
		self.WModel:SetSkin(1)
		self.WModel:SetNoDraw(true)
		self.WModel:DrawShadow(false)
		local mat = Matrix()
		mat:Scale(Vector(0.31,0.165,0.01))
		self.WModel:EnableMatrix("RenderMultiply", mat)
	elseif IsValid(Owner) then
		local offsetVec = Vector(3.88, -8.35, -1.7)
		local offsetAng = Angle(175, 90, 90)

		local boneid = Owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if !boneid then return end

		local matrix = Owner:GetBoneMatrix(boneid)
		if !matrix then return end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

		self.WModel:SetPos(newPos)
		self.WModel:SetAngles(newAng)

		self.WModel:SetupBones()
	end

	if IsValid(self.WModel) then
		self.WModel:DrawModel()
	end

	if LPlayer:GetPos():Distance(Owner:GetPos()) < 500 then
		local boneindex = Owner:LookupBone("ValveBiped.Bip01_R_Hand")
		local PonyOverride = false
		if !boneindex then
			boneindex = Owner:LookupBone("LrigNeck1")
			PonyOverride = true
		end

		if boneindex then
			local CurM = Owner:GetModel()
			if !self.PIcon then
				self.PIcon = vgui.Create("ModelImage")
				self.PIcon:SetSize(90,93)
				self.PIcon:SetPos(12,45)
				self.PIcon:SetModel(CurM)
				self.PIcon:SetPaintedManually(true)
				self.PIconLastM = CurM
			elseif CurM != self.PIconLastM then
				self.PIcon:SetModel(CurM)
				self.PIconLastM = CurM
			end

			local HPos, HAng = Owner:GetBonePosition(boneindex)

			if !PonyOverride then
				HAng:RotateAroundAxis(HAng:Forward(), -90)
				HAng:RotateAroundAxis(HAng:Right(), -90)
				HAng:RotateAroundAxis(HAng:Up(), 5)
				HPos = HPos + HAng:Up()*4 + HAng:Right()*-5 + HAng:Forward()*1
			else
				HAng:RotateAroundAxis(HAng:Forward(), -90)
				HAng:RotateAroundAxis(HAng:Right(), -30)
				HAng:RotateAroundAxis(HAng:Up(), -90)
				HPos = HPos + HAng:Up()*6 + HAng:Forward()*-7
			end

			cam.Start3D2D(HPos, HAng, 1)
				surface.SetMaterial(DIMat)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(0, 0, 15, 8)
			cam.End3D2D()

			cam.Start3D2D(HPos, HAng, .05)
				self.PIcon:PaintManual()

				local TextW = 105
				local TextH = 50

				draw.SimpleText(Owner:Nick(), "firearms_license_text", TextW, TextH, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				if FA_Config.DisplaySteamID then
					TextH = TextH + 10
					draw.SimpleText(TBFY_SH:SID(Owner), "firearms_license_text", TextW, TextH, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				end
				if FA_Config.DisplayJob then
					TextH = TextH + 10
					draw.SimpleText(Owner:getDarkRPVar("job"), "firearms_license_text", TextW, TextH, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				end
				TextH = TextH + 10
				draw.SimpleText(FA_GetLang("Instructor") .. ":", "firearms_license_text", TextW, TextH, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

				local LMat = NoLMat
				if Owner:FA_IsInstructor() then
					LMat = HasLMat
				end
				surface.SetFont("firearms_license_text")
				local TW, TH = surface.GetTextSize(FA_GetLang("Instructor") .. ":")

				surface.SetMaterial(LMat)
				surface.DrawTexturedRect(TextW+TW+5, TextH-2.5, 10, 10)

				draw.SimpleText(FA_GetLang("Carry"), "firearms_license_text", 250, 31, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText(FA_GetLang("Sell"), "firearms_license_text", 280, 31, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

				local LicenseW = 195
				local DIS = 40
				local CS = 40

				for i,n in ipairs(FA_DB) do
					draw.SimpleText(n.Name, "firearms_license_text", LicenseW, DIS+7.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

					surface.SetMaterial(FetchLicenseIcon(i))
					surface.DrawTexturedRect(LicenseW+5, DIS, 40, 20)

					local LMat = NoLMat
					if Owner:FACanCarry(i) then
						LMat = HasLMat
					end
					surface.SetMaterial(LMat)
					surface.DrawTexturedRect(LicenseW+50, CS+2.5, 12, 12)

					local LMat = NoLMat
					if Owner:FACanSell(i) then
						LMat = HasLMat
					end
					surface.SetMaterial(LMat)
					surface.DrawTexturedRect(LicenseW+80, CS+2.5, 12, 12)
					DIS = DIS + 20
					CS = CS + 20
				end
			cam.End3D2D()
		end
	end
end

end
