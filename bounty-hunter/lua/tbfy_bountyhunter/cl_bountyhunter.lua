
surface.CreateFont("WantedPosterTextName", {
	font = "Sitka Banner Bold",
	size = 17,
	weight = 500,
	antialias = true,
})

surface.CreateFont("WantedPosterTextBounty", {
	font = "Sitka Banner Bold",
	size = 20,
	weight = 500,
	antialias = true,
})

surface.CreateFont("PlaceBountyCheckMark", {
	font = "Sitka Banner Bold",
	size = 23,
	weight = 500,
	antialias = true,
})

surface.CreateFont("ClosePlaceBounty", {
	font = "arial",
	size = 23,
	weight = 1000,
	antialias = true,
})


net.Receive("NewBountySound", function()
    surface.PlaySound("bountyfixed.mp3")
end)

net.Receive("SendBounty", function(length, client)
	local Name = net.ReadString()
	local Kills = net.ReadFloat()
	local Model = net.ReadString()
	local Bounty = net.ReadFloat()

	if !BountyMenu then
		BountyMenu = vgui.Create("bounty_menu");
	end

	BountyMenu:Update(Name,Kills,Model,Bounty)
end)

net.Receive("UpdateBountyMenu", function(length, client)
	local Kills,Bounty = net.ReadFloat(), net.ReadFloat()

	BountyMenu:Update(nil,Kills,nil,Bounty)
end)

net.Receive("RemoveBountyMenu", function(length, client)
	if BountyMenu then
		BountyMenu:Remove()
		BountyMenu = nil
	end
end)

net.Receive("BountyFinished", function(length, client)
	local BountyHunterName = net.ReadString()
	local BountyName = net.ReadString()
	local Bounty = net.ReadFloat()

	local FinishedBounty = vgui.Create("bounty_finished")
	FinishedBounty:Update(BountyHunterName,BountyName,Bounty)

	timer.Create("RemoveBountyMenu", 5, 1, function()
		FinishedBounty:Remove()
	end)
end)

net.Receive("open_place_bounty_menu", function(length, client)
	vgui.Create("place_bounty_menu");
end)

local PANEL = {}

local Frame = Material("bountyframe.png")
function PANEL:Init()

	self:SetTitle("")
	self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:SetSkin(GAMEMODE.Config.DarkRPSkin)
    --self:MakePopup()

	self.Name = ""
	self.Kills = 0
	self.Bounty = 0

	self.ModelPanel = vgui.Create('DModelPanel', self);
end

function PANEL:Update(Name, Kills, Model, Bounty)
    if Name then
		self.Name = Name
	end
	if Kills then
		self.Kills = Kills
	end
	if Model then
		self.Model = Model
	end
	if Bounty then
		self.Bounty = Bounty
	end

	self.ModelPanel:SetModel(self.Model);
	function self.ModelPanel:LayoutEntity(Entity)  end
	local eyepos = self.ModelPanel.Entity:GetBonePosition(self.ModelPanel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
	self.ModelPanel:SetLookAt(eyepos+Vector(0,0,2))
	self.ModelPanel:SetCamPos(eyepos-Vector(20, 0, 0))
	self.ModelPanel.Entity:SetEyeTarget(eyepos-Vector(-12, 0, 0))
    self.ModelPanel.Entity:SetAngles(Angle(0,180,0))
end

function PANEL:PerformLayout()
	self:SetPos(5, 5)
    self:SetSize(150, 250)

	self.ModelPanel:SetPos(10, 60);
	self.ModelPanel:SetSize(130,140);
end

function PANEL:Paint(W,H)
	surface.SetMaterial(Frame)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, W, H)

	draw.SimpleText(self.Name, "WantedPosterTextName",W/2,H/3.5,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	draw.SimpleText("$" .. self.Bounty, "WantedPosterTextBounty",W/2,H-18,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end
vgui.Register("bounty_menu", PANEL, "DFrame");

local PANEL = {};

function PANEL:Init()

	self:ShowCloseButton(false);
    self:SetDraggable(false);
    self:SetSkin(GAMEMODE.Config.DarkRPSkin)
	self:SetTitle("")
    --self:MakePopup()

	self.DLabel1 = vgui.Create("DLabel", self)
	self.DLabel1:SetPos(0, 0)
	self.DLabel1:SetSize(20, 20);
	self.DLabel1:SetTextColor(Color(255, 255, 255, 255))
	self.DLabel1:SetFont("trebuchet24")
end

function PANEL:Update(BountyHunterName, BountyName, Bounty)
    self.BountyHunterName = BountyHunterName
	self.BountyName = BountyName
	self.Bounty = Bounty

	self.DLabel1:SetText(self.BountyHunterName .. " claimed a bounty of $" .. self.Bounty .. " on " .. self.BountyName .. "'s head!");
    self.DLabel1:SizeToContents()
end

function PANEL:PerformLayout ( )
	surface.SetFont("trebuchet24")
	local w = self.DLabel1:GetText()
	Width, Height = surface.GetTextSize(w)

	self:SetPos(ScrW() * .5 - Width * .5, 0)
    self:SetSize(Width, Height)
end
vgui.Register("bounty_finished", PANEL, "DFrame");

local PANEL = {}

local Width, Height = 180, 275
function PANEL:Init()
	self:SetTitle("")
	self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:SetSkin(GAMEMODE.Config.DarkRPSkin)
    self:MakePopup()

	self.Name = ""

	self.ModelPanel = vgui.Create("DModelPanel", self)

	self.PList = vgui.Create("DComboBox", self)
	self.PList:SetValue("")
	self.PList.DisplayText = "Select Player"
	for k,v in pairs(player.GetAll()) do
		if LocalPlayer() != v and v:CanReceiveBounty() and !v:IsBountyHunter() then
			self.PList:AddChoice(v:Nick(), {Ent = v})
		end
	end
	self.PList.OnSelect = function(panel, index, value)
		local id, Tbl = self.PList:GetSelected()
		local Player = Tbl.Ent
		self.Ent = Player

		self:Update(Player:Nick(), Player:GetModel())
		self.PList.DisplayText = value
		self.PList:SetValue("")
	end
	self.PList.Paint = function(panel, W,H)
		draw.SimpleText(self.PList.DisplayText, "WantedPosterTextName",W/2,H/2,color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	self.BountyField = vgui.Create("DTextEntry", self)
	self.BountyField:SetPlaceholderText("Enter Amount")
	self.BountyField:SetPlaceholderColor(color_black)
	self.BountyField:SetText("")
	self.BountyField:SetFont("WantedPosterTextBounty")
	self.BountyField:SetTextColor(color_black)
	self.BountyField:SetNumeric(true)
	self.BountyField:SetDrawBackground(false)
	self.BountyField:SetDrawBorder(false)
	self.BountyField:SetUpdateOnType(true)
	self.BountyField.OnGetFocus = function()
		self.BountyField:SetPlaceholderText("")
	end
	self.BountyField.OnValueChange = function(panel, value)
		if string.len(value) >= 10 then
			value = string.sub(value,1,10)
			self.BountyField:SetText(value)
		end

		surface.SetFont("WantedPosterTextBounty")
		local W,H = surface.GetTextSize(value)
		self:UpdateBountyAmount(W, value)
	end
	self.BountyField:SetPos(Width/2-60, Height-28)
	self.BountyField:SetSize(120,20)

	self.PlaceButton = vgui.Create("tbfy_button", self)
	self.PlaceButton.Paint = function(selfp, w, h)
		draw.SimpleText("✓", "PlaceBountyCheckMark", 0, 0, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	self.PlaceButton.DoClick = function()
		local Amount, Player = tonumber(self.BountyField:GetValue()), self.Ent
		local MinBounty, MaxBounty = TBFY_BHConfig.ManualMinimumBounty, TBFY_BHConfig.ManualMaximumBounty
		if Amount and Player then
			if MinBounty > Amount then
				LocalPlayer():ChatPrint("You must set bounty to at least: $" .. MinBounty)
			elseif MaxBounty < Amount then
				LocalPlayer():ChatPrint("The maximum bounty you can set is: $" .. MaxBounty)
			else
				net.Start("place_bounty_player")
					net.WriteEntity(Player)
					net.WriteFloat(Amount)
				net.SendToServer()

				self:Remove()
			end
		end
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton.Paint = function(selfp, w, h)
		draw.SimpleText("X", "ClosePlaceBounty", 0, 0, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:Update(Name, Model)
	self.Name = Name
	self.Model = Model

	self.ModelPanel:SetModel(self.Model);
	function self.ModelPanel:LayoutEntity(Entity)  end
	local eyepos = self.ModelPanel.Entity:GetBonePosition(self.ModelPanel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
	self.ModelPanel:SetLookAt(eyepos+Vector(0,0,2))
	self.ModelPanel:SetCamPos(eyepos-Vector(20, 0, 0))
	self.ModelPanel.Entity:SetEyeTarget(eyepos-Vector(-12, 0, 0))
    self.ModelPanel.Entity:SetAngles(Angle(0,180,0))
end

function PANEL:PerformLayout()
	local ScW, ScH = ScrW(), ScrH()
	self:SetPos(ScW/2-Width/2, ScH/2-Height/2)
    self:SetSize(Width, Height)

	self.ModelPanel:SetPos(10, 60)
	self.ModelPanel:SetSize(160,160)

	self.PList:SetSize(130,20)
	self.PList:SetPos(Width/2-65, 70)

	self.PlaceButton:SetPos(Width-35, Height-49)
	self.PlaceButton:SetSize(20,20)

	self.CloseButton:SetPos(15, Height-48)
	self.CloseButton:SetSize(20,20)
end

function PANEL:OnKeyCodePressed(keyCode)
    if keyCode == KEY_Q then
        self:Remove()
    end
end

function PANEL:UpdateBountyAmount(W)
	local BasePos = Width/2
	self.BountyField:SetPos(BasePos-W/2-2.5, Height-28)
end

function PANEL:Paint(W,H)
	surface.SetMaterial(Frame)
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(0, 0, W, H)
end
vgui.Register("place_bounty_menu", PANEL, "DFrame")

hook.Add("tbfy_InitSetup", "BH_InitSetup", function()
	local CatName = "Bounty Hunter"
	TBFY_SH:SetupCategory(CatName)

	TBFY_SH:SetupEntity(CatName, "Bounty Board", "bountyboard", "models/tbfu_noticeboard/noticeboard.mdl")
	TBFY_SH:SetupCustomFunctionThink(CatName, "bountyboard", function(SWEP)
		local Player = SWEP.Owner
		local PTrace = Player:GetEyeTrace()
		local GEnt = SWEP.GhostEnt
		local Offset = Vector(0,0,76)

		if IsValid(GEnt) then
			GEnt:SetPos(PTrace.HitPos+Offset)
			local Ang = Player:GetAngles()
			GEnt:SetAngles(Angle(0,Ang.y-180,0))
		end
	end)

	TBFY_SH:SetupCMDButton(CatName, "Save Bounty boards", "save_bountyboard")
end)
