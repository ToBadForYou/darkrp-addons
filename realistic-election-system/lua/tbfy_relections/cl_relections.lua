
local RES_Conf = RES_Config

local function RES_ToggleVM(Bool)
	LocalPlayer():DrawViewModel(Bool, 0)
	LocalPlayer():DrawViewModel(Bool, 1)
	LocalPlayer():DrawViewModel(Bool, 2)
end

net.Receive("res_startpoll", function()
	local PollID = net.ReadFloat()
	if PollID != 0 then
		local Question, OptionAmount = net.ReadString(), net.ReadFloat()

		local PossAnswers = {}
		for i = 1, OptionAmount do
			local ID, Answer = net.ReadFloat(), net.ReadString()
			PossAnswers[ID] = {Option = Answer, Votes = 0}
		end
		RES_Polls[PollID] = {Question = Question, Options = PossAnswers}
		RES_CurrentPoll = PollID
	else
		RES_Polls = {}
		RES_CurrentPoll = nil
	end
end)

net.Receive("res_update_poll", function()
	RES_CurrentPoll = nil
end)

net.Receive("res_poster_options", function()
	local PosterM = vgui.Create("DMenu")
	PosterM:AddOption(RES_GetLang("PickupPoster"), function() net.Start("res_pickup_poster") net.SendToServer() end)
	PosterM:AddOption(RES_GetLang("DeletePoster"), function() net.Start("res_delete_poster") net.SendToServer() end)
	PosterM:Open()
	PosterM:SetPos(ScrW()/2,ScrH()/2)
end)

net.Receive("res_update_candidate", function()
	local Reset = net.ReadBool()

	if Reset then
		RES_Candidates = {}
	else
		local SID, Player, Initials, r,g,b, Slogan, Agenda = net.ReadString(), net.ReadEntity(), net.ReadString(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadString(), net.ReadString()
		RES_Candidates[SID] = {Player = Player, Votes = Votes or 0, Initials = Initials, Colors = {r,g,b}, Slogan = Slogan, Agenda = Agenda}
	end
end)

net.Receive("res_remove_candidate", function()
	local SID = net.ReadString()
	RES_Candidates[SID] = nil
end)

net.Receive("res_update_votes", function()
	local IsPoll = net.ReadBool()
	if IsPoll then
		local PollID, VoteID, Votes = net.ReadFloat(), net.ReadFloat(), net.ReadFloat()
		RES_Polls[PollID].Options[VoteID].Votes = Votes
	else
		local SID, Votes = net.ReadString(), net.ReadFloat()
	 	RES_Candidates[SID].Votes = Votes
	end
end)

net.Receive("res_update_phase", function()
	local Phase, Timer = net.ReadFloat(), net.ReadFloat()

	RES_Phase = Phase
	RES_PhaseEnd = Timer or 0
end)

net.Receive("res_removeposter", function()
	LocalPlayer().RES_Posters[1] = nil
	LocalPlayer().RES_Posters = table.ClearKeys(LocalPlayer().RES_Posters)
end)

net.Receive("res_SendPosterInfo", function()
	local PName, PText, DType, BGC, DC = net.ReadString(), net.ReadString(), net.ReadFloat(), net.ReadVector(), net.ReadVector()

	LocalPlayer().RES_Posters = LocalPlayer().RES_Posters or {}
	LocalPlayer().RES_Posters = table.ClearKeys(LocalPlayer().RES_Posters)
	local Index = table.Count(LocalPlayer().RES_Posters)+1
	LocalPlayer().RES_Posters[Index] = {N = PName, T = PText, DT = DType, BG = BGC, DTC = DC}
end)

net.Receive("res_printer", function()
	local PrintMenu = vgui.Create("DMenu")
	PrintMenu:AddOption(RES_GetLang("PrintPoster"), function() net.Start("res_request_print") net.SendToServer() end)
	PrintMenu:Open()

	PrintMenu:SetPos(ScrW()/2,ScrH()/2)
end)

net.Receive("res_open_application", function()
	vgui.Create("res_application_form")
end)

net.Receive("res_open_ballotmenu", function()
	vgui.Create("res_ballotmenu")
end)

net.Receive("res_edit_poster", function()
	local Poster = net.ReadEntity()

	LocalPlayer().LastPoster = Poster

	local Name = Poster:GetPName()
	local PText = Poster:GetPText()
	local DType = Poster:GetDType()
	local BGColor = Poster:GetBackGColor()
	local DecalColor = Poster:GetDecalColor()

	LocalPlayer().CS_PosterSettings = {
		N = Name,
		Text = PText,
		D = DType,
		BGc = BGColor,
		Dc = DecalColor
	}
	vgui.Create("res_poster_editor")
	RES_ToggleVM(false)
end)

net.Receive("res_edit_podium", function()
	local Podium = net.ReadEntity()

	LocalPlayer().LastPodium = Podium

	local Name = Podium:GetPName()
	local Slogan = Podium:GetSlogan()
	local DType = Podium:GetDType()
	local BGColor = Podium:GetBackGColor()
	local DecalColor = Podium:GetDecalColor()

	LocalPlayer().CS_PodiumSettings = {
		N = Name,
		S = Slogan,
		D = DType,
		BGc = BGColor,
		Dc = DecalColor
	}
	vgui.Create("res_podium_editor")
	RES_ToggleVM(false)
end)

surface.CreateFont("res_timer_head", {
	font = "Verdana",
	size = 16,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("res_timer", {
	font = "Verdana",
	size = 26,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("res_text", {
	font = "Verdana",
	size = 14,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("res_app_headline", {
	font = "coolvetica",
	size = 25,
	weight = 500,
	antialias = true,
	underline = true,
})

surface.CreateFont("res_app_subhead", {
	font = "Calibri",
	size = 15,
	weight = 500,
	antialias = true,
	underline = true,
})

surface.CreateFont("res_candidate_info_subhead", {
	font = "Calibri",
	size = 15,
	weight = 500,
	antialias = true,
	underline = true,
})

surface.CreateFont("res_poll_title", {
	font = "Calibri",
	size = 15,
	weight = 0,
	antialias = true,
	underline = false,
})

surface.CreateFont("res_poll_subhead", {
	font = "Calibri",
	size = 15,
	weight = 500,
	antialias = true,
	underline = true,
})

surface.CreateFont("res_poll_text", {
	font = "Calibri",
	size = 12,
	weight = 0,
	antialias = true,
	underline = false,
})

surface.CreateFont("res_app_text", {
	font = "coolvetica",
	size = 22,
	weight = 750,
	antialias = true,
})

surface.CreateFont("res_app_sign", {
	font = "coolvetica",
	size = 19,
	weight = 500,
	antialias = true,
})

surface.CreateFont("res_comp_header", {
	size = 16,
	weight = 500,
	antialias = false,
	shadow = false,
	font = "arial"
})

surface.CreateFont("res_comp_diagram_candidate", {
	size = 15,
	weight = 1000,
	antialias = false,
	shadow = false,
	font = "arial"
})

surface.CreateFont("res_comp_diagram_sub", {
	size = 15,
	weight = 100,
	antialias = false,
	shadow = false,
	font = "arial"
})

surface.CreateFont("res_comp_diagram_initals", {
	size = 25,
	weight = 100,
	antialias = false,
	shadow = false,
	font = "arial"
})

surface.CreateFont("res_comp_diagram_poll", {
	size = 12,
	weight = 0,
	antialias = true,
	shadow = false,
	font = "arial"
})


surface.CreateFont("res_comp_cand_initial", {
	font = "Arial",
	size = 14,
	weight = 1000,
	antialias = true,
})

local Derma = TBFY_SH.Config.Derma
local MainPanelColor = Color(255,255,255,200)
local HeaderColor = Color(50,50,50,255)
local TabListColors = Color(215,215,220,255)
local ButtonColor = Color(50,50,50,255)
local ButtonColorHovering = Color(75,75,75,200)
local ButtonColorPressed = Color(150,150,150,200)
local ButtonOutline = Color(0,0,0,200)
local HeaderH = 25
local Padding = 5

local function TimeToString(Time)
	local s = Time % 60
	Time = math.floor(Time/60)
	local m = Time % 60
	Time = math.floor(Time/60)
	local h = Time % 60
	Time = math.floor(Time/60)

	return string.format("%02i:%02i:%02i", h, m, s)
end

local WSize, HSize, Top = 150,50, 25
hook.Add("HUDPaint", "RES_HUD", function()
	if RES_Phase != 0 then
		local W,H = ScrW(), ScrH()
		local WStart = W/2-WSize/2

		draw.RoundedBox(4, WStart, Top+Padding, WSize, HSize, MainPanelColor)
		draw.RoundedBox(4, WStart+Padding/2, Top+Padding+Padding/2, WSize-Padding, HSize-Padding, TabListColors)

		draw.RoundedBoxEx(4, WStart, Padding, WSize, Top, HeaderColor, true, true, false, false)

		local PName
		if RES_Phase == 1 then
			PName = RES_GetLang("CampaignPhase")
		elseif RES_Phase == 2 then
			PName = RES_GetLang("VotingPhase")
		end

		local Timer = math.Round(RES_PhaseEnd-CurTime())
		draw.SimpleText(PName, "res_timer_head", W/2, Top/2+Padding, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(TimeToString(Timer), "res_timer", W/2, Top+Padding+HSize/2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)

local PANEL = {}

function PANEL:Init()
	self.Player = LocalPlayer()
	self.Colors = {0,0,0}

	self.TopFrame = vgui.Create("tbfy_comp_dpanel", self)
	self.TopFrame:SetTitle(RES_GetLang("ApplicationHeadline"))

	self.CandColor = vgui.Create("DColorButton", self)
	self.CandColorPicker = vgui.Create("DColorPalette", self)
	self.CandColorPicker.OnValueChanged = function(selfp, value)
		self.CandColor:SetColor(value)
		self.Colors = {value.r, value.g, value.b}
	end

	self.InitialInput = vgui.Create("DTextEntry", self)
	self.InitialInput:SetText("")
	self.InitialInput:SetFont("res_app_text")
	self.InitialInput:SetDrawBackground(false)
	self.InitialInput:SetDrawBorder(false)
	self.InitialInput:SetUpdateOnType(true)
	self.InitialInput.OnValueChange = function(panel, value)
		if string.len(value) >= 5 then
			value = string.sub(value,1,4)
			self.InitialInput:SetText(value)
		end
	end

	self.Slogan = vgui.Create("DTextEntry", self)
	self.Slogan:SetText("")
	self.Slogan:SetFont("res_app_text")
	self.Slogan:SetDrawBackground(false)
	self.Slogan:SetDrawBorder(false)
	self.Slogan:SetUpdateOnType(true)
	self.Slogan.OnValueChange = function(panel, value)
		if string.len(value) >= 26 then
			value = string.sub(value,1,25)
			self.Slogan:SetText(value)
		end
	end

	self.Agenda = vgui.Create("DTextEntry", self)
	self.Agenda:SetText("")
	self.Agenda:SetFont("res_app_text")
	self.Agenda:SetDrawBackground(false)
	self.Agenda:SetDrawBorder(false)
	self.Agenda:SetMultiline(true)

	self.SignB = vgui.Create("tbfy_button", self)
	self.SignB:SetBText(RES_GetLang("SignApp"))
	self.SignB:SetBFont("res_app_sign")
	self.SignB.Paint = function(selfp, W, H) draw.SimpleText(selfp.ButtonText, selfp.Font, W/2, H/2, selfp.BColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  end
	self.SignB.DoClick = function()
		local Initials = self.InitialInput:GetValue()
		local r,g,b = self.Colors[1],self.Colors[2],self.Colors[3]
		local Slogan = self.Slogan:GetValue()
		local Agenda = self.Agenda:GetValue()
		net.Start("res_signup_election")
			net.WriteString(Initials)
			net.WriteFloat(r)
			net.WriteFloat(g)
			net.WriteFloat(b)
			net.WriteString(Slogan)
			net.WriteString(Agenda)
		net.SendToServer()

		local MainP = self.MainP
		timer.Simple(.2, function()
			MainP:UpdateMenu()
		end)
		self:Remove()
	end
end

local Frame = Material("res_app_form.png")
function PANEL:Paint(W,H)
	surface.SetMaterial(Frame)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, W, H)

	local Player = self.Player
	local HPad = 0

	surface.SetDrawColor(0, 0, 0, 255)
	surface.SetFont("res_app_subhead")
	surface.DrawOutlinedRect(15, 40+HPad, W-30, 30)
	draw.SimpleText(RES_GetLang("AppName"), "res_app_subhead", 20, 50+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	local TW = surface.GetTextSize(RES_GetLang("AppName"))
	draw.SimpleText(Player:Nick(), "res_app_text", 20 + TW, 55+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 25
	local BDay = RES_GetLang("BirthDate")
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(BDay, "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(BDay)
	draw.SimpleText("13/09/1965", "res_app_text", 20 + TW, 65+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	local Occupation = RES_GetLang("AppOccupation")
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(Occupation, "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(Occupation)
	draw.SimpleText(LocalPlayer():getDarkRPVar("job"), "res_app_text", 20 + TW, 65+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	local PNumber = RES_GetLang("PhoneNumber")
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(PNumber, "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(PNumber)
	draw.SimpleText("+" .. LocalPlayer():SteamID64(), "res_app_text", 20 + TW, 65+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(RES_GetLang("AppSlogan"), "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 75)
	draw.SimpleText(RES_GetLang("AppAgenda"), "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 80
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(RES_GetLang("AppColor"), "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	surface.DrawOutlinedRect(15, 50+HPad, 225, 30)
	draw.SimpleText(RES_GetLang("AppInitials"), "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	surface.DrawOutlinedRect(15, H-45, 225, 30)
	draw.SimpleText(RES_GetLang("YourSignature"), "res_app_subhead", 20, H-35, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local Width, Height = 350, 420
function PANEL:PerformLayout(W,H)
	self:SetSize(Width, Height)

	if !self.SetInitialPos then
		self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
		self.SetInitialPos = true
	end

	self.TopFrame:SetSize(W-4,Derma.HeaderH)
	self.TopFrame:SetPos(2,2)

	surface.SetFont("res_app_subhead")

	local HPad = 185
	TW = surface.GetTextSize(RES_GetLang("AppSlogan"))
	self.Slogan:SetSize(275, 20)
	self.Slogan:SetPos(15 + TW, HPad)

	HPad = HPad + 35
	TW = surface.GetTextSize(RES_GetLang("AppAgenda"))
	self.Agenda:SetSize(275, 70)
	self.Agenda:SetPos(15 + TW, HPad)

	HPad = HPad + 80
	local TW = surface.GetTextSize(RES_GetLang("AppColor"))
	self.CandColor:SetSize(20,20)
	self.CandColor:SetPos(25+TW,HPad)

	self.CandColorPicker:SetSize(250,30)
	self.CandColorPicker:SetPos(50+TW,HPad)

	HPad = HPad + 35
	TW = surface.GetTextSize(RES_GetLang("AppInitials"))
	self.InitialInput:SetSize(110,20)
	self.InitialInput:SetPos(10 + TW,HPad)

	self.SignB:SetPos(105, H-40)
	self.SignB:SetSize(110,20)
end
vgui.Register("res_computer_application", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Player = LocalPlayer()
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:SetTitle("")
	self:MakePopup()
	self.Colors = {0,0,0}

	self.CandColor = vgui.Create("DColorButton", self)
	self.CandColorPicker = vgui.Create("DColorPalette", self)
	self.CandColorPicker.OnValueChanged = function(selfp, value)
		self.CandColor:SetColor(value)
		self.Colors = {value.r, value.g, value.b}
	end

	self.InitialInput = vgui.Create("DTextEntry", self)
	self.InitialInput:SetText("")
	self.InitialInput:SetFont("res_app_text")
	self.InitialInput:SetDrawBackground(false)
	self.InitialInput:SetDrawBorder(false)
	self.InitialInput:SetUpdateOnType(true)
	self.InitialInput.OnValueChange = function(panel, value)
		if string.len(value) >= 5 then
			value = string.sub(value,1,4)
			self.InitialInput:SetText(value)
		end
	end

	self.Slogan = vgui.Create("DTextEntry", self)
	self.Slogan:SetText("")
	self.Slogan:SetFont("res_app_text")
	self.Slogan:SetDrawBackground(false)
	self.Slogan:SetDrawBorder(false)
	self.Slogan:SetUpdateOnType(true)
	self.Slogan.OnValueChange = function(panel, value)
		if string.len(value) >= 26 then
			value = string.sub(value,1,25)
			self.Slogan:SetText(value)
		end
	end

	self.Agenda = vgui.Create("DTextEntry", self)
	self.Agenda:SetText("")
	self.Agenda:SetFont("res_app_text")
	self.Agenda:SetDrawBackground(false)
	self.Agenda:SetDrawBorder(false)
	self.Agenda:SetMultiline(true)

	self.SignB = vgui.Create("tbfy_button", self)
	self.SignB:SetBText(RES_GetLang("SignApp"))
	self.SignB:SetBFont("res_app_sign")
	self.SignB.Paint = function(selfp, W, H) draw.SimpleText(selfp.ButtonText, selfp.Font, W/2, H/2, selfp.BColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  end
	self.SignB.DoClick = function()
		local Initials = self.InitialInput:GetValue()
		local r,g,b = self.Colors[1],self.Colors[2],self.Colors[3]
		local Slogan = self.Slogan:GetValue()
		local Agenda = self.Agenda:GetValue()
		net.Start("res_signup_election")
			net.WriteString(Initials)
			net.WriteFloat(r)
			net.WriteFloat(g)
			net.WriteFloat(b)
			net.WriteString(Slogan)
			net.WriteString(Agenda)
		net.SendToServer()
		self:Remove()
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.Paint = function(selfp, W, H) draw.SimpleText(selfp.ButtonText, selfp.Font, W/2, H/2, selfp.BColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  end
	self.CloseButton.DoClick = function() self:Remove() end
end

local Frame = Material("res_app_form.png")
function PANEL:Paint(W,H)
	surface.SetMaterial(Frame)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, W, H)

	draw.SimpleText(RES_GetLang("ApplicationHeadline"), "res_app_headline", W/2, 25, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	local Player = self.Player
	surface.SetDrawColor(0, 0, 0, 255)
	surface.SetFont("res_app_subhead")
	surface.DrawOutlinedRect(15, 50, W-30, 30)
	draw.SimpleText(RES_GetLang("AppName"), "res_app_subhead", 20, 60, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	local TW = surface.GetTextSize(RES_GetLang("AppName"))
	draw.SimpleText(Player:Nick(), "res_app_text", 20 + TW, 65, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local HPad = 35
	local BDay = RES_GetLang("BirthDate")
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(BDay, "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(BDay)
	draw.SimpleText("13/09/1965", "res_app_text", 20 + TW, 65+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	local Occupation = RES_GetLang("AppOccupation")
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(Occupation, "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(Occupation)
	draw.SimpleText(LocalPlayer():getDarkRPVar("job"), "res_app_text", 20 + TW, 65+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	local PNumber = RES_GetLang("PhoneNumber")
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(PNumber, "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(PNumber)
	draw.SimpleText("+" .. LocalPlayer():SteamID64(), "res_app_text", 20 + TW, 65+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(RES_GetLang("AppSlogan"), "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 75)
	draw.SimpleText(RES_GetLang("AppAgenda"), "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 80
	surface.DrawOutlinedRect(15, 50+HPad, W-30, 30)
	draw.SimpleText(RES_GetLang("AppColor"), "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	HPad = HPad + 35
	surface.DrawOutlinedRect(15, 50+HPad, 225, 30)
	draw.SimpleText(RES_GetLang("AppInitials"), "res_app_subhead", 20, 60+HPad, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	surface.DrawOutlinedRect(15, H-45, 225, 30)
	draw.SimpleText(RES_GetLang("YourSignature"), "res_app_subhead", 20, H-35, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local Width, Height = 350, 420
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	surface.SetFont("res_app_subhead")

	TW = surface.GetTextSize(RES_GetLang("AppSlogan"))
	self.Slogan:SetSize(275, 20)
	self.Slogan:SetPos(15 + TW, 195)

	TW = surface.GetTextSize(RES_GetLang("AppAgenda"))
	self.Agenda:SetSize(275, 70)
	self.Agenda:SetPos(15 + TW, 230)

	local TW = surface.GetTextSize(RES_GetLang("AppColor"))
	self.CandColor:SetSize(20,20)
	self.CandColor:SetPos(25+TW,310)

	self.CandColorPicker:SetSize(250,30)
	self.CandColorPicker:SetPos(50+TW,310)

	TW = surface.GetTextSize(RES_GetLang("AppInitials"))
	self.InitialInput:SetSize(100,20)
	self.InitialInput:SetPos(10 + TW,345)

	self.SignB:SetPos(105, H-40)
	self.SignB:SetSize(110,20)

	self.CloseButton:SetPos(Width-25,5)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("res_application_form", PANEL, "DFrame")

local PANEL = {}

local SelectOption = Material("tbfy/res_select.png")
local SelectSize = 15
function PANEL:Init()
	self.CandidateName = ""
	self.CandidateSID = ""
	self.Selected = false

	self.SelectButton = vgui.Create("tbfy_button", self)
	self.SelectButton.Paint = function(selfp, W, H)
		surface.SetDrawColor(60,60,60, 255)
		surface.DrawRect(0,0,W,H)

		surface.SetDrawColor(255,255,255, 255)
		surface.SetMaterial(SelectOption)
		surface.DrawTexturedRect(W/2-SelectSize/2,H/2-SelectSize/2,SelectSize,SelectSize)
		if self.Selected then
			surface.SetDrawColor(0,175,0, 255)
			surface.SetMaterial(SelectOption)
			surface.DrawTexturedRect(W/2-SelectSize/2+2,H/2-SelectSize/2+2,SelectSize-4,SelectSize-4)
		end
	end
	self.SelectButton.DoClick = function()
		local CandList = self:GetParent():GetParent()
		CandList:UpdateSelection(self.CandidateSID)
		self.Selected = true
	end
end

function PANEL:SetPlayerInfo(Player)
	self.CandidateName = Player:Nick()
	self.CandidateSID = TBFY_SH:SID(Player)
end

function PANEL:Paint(W,H)
	draw.SimpleText(self.CandidateName, "res_app_text", 5, H/2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(0, 0, W, H)
end

function PANEL:PerformLayout(W,H)
	self.SelectButton:SetPos(W-H, 0)
	self.SelectButton:SetSize(H,H)
end
vgui.Register("res_ballot_candidaterow", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Player = LocalPlayer()
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:SetTitle("")
	self:MakePopup()

	self.CandidateList = vgui.Create("DScrollPanel", self)
	self.CandidateList.Paint = function(selfp, W, H)
		W = W - 15
		draw.RoundedBox(0, 0, 0, W, H, Color(255,255,255,0))
	end
	self.CandidateList.Candidates = {}
	self.CandidateList.VBar.Paint = function() end
	self.CandidateList.VBar.btnUp.Paint = function() end
    self.CandidateList.VBar.btnDown.Paint = function() end
	self.CandidateList.VBar.btnGrip.Paint = function() end
	self.CandidateList.UpdateSelection = function(selfp, Candidate)
		self.Candidate = Candidate
		for k,v in pairs(self.CandidateList.Candidates) do
			v.Selected = false
		end
	end

	for k,v in pairs(RES_Candidates) do
		if IsValid(v.Player) then
			local CandRow = vgui.Create("res_ballot_candidaterow", self.CandidateList)
			CandRow:SetPlayerInfo(v.Player)
			self.CandidateList.Candidates[k] = CandRow
		end
	end

	self.SignB = vgui.Create("tbfy_button", self)
	self.SignB:SetBText(RES_GetLang("SignBallot"))
	self.SignB:SetBFont("res_app_sign")
	self.SignB.Paint = function(selfp, W, H)  end
	self.SignB.DoClick = function()
		if self.Candidate then
			net.Start("res_ballot_candidate")
				net.WriteString(self.Candidate)
			net.SendToServer()
			self:Remove()
		end
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.Paint = function(selfp, W, H) draw.SimpleText(selfp.ButtonText, selfp.Font, W/2, H/2, selfp.BColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  end
	self.CloseButton.DoClick = function() self:Remove() end
end

local Frame = Material("res_app_form.png")
function PANEL:Paint(W,H)
	surface.SetMaterial(Frame)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, W, H)

	draw.SimpleText(RES_GetLang("BallotHeadline"), "res_app_headline", W/2, 25, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(15, H-45, 140, 30)
	draw.SimpleText(RES_GetLang("YourSignature"), "res_app_subhead", 20, H-35, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local Width, Height = 300, 400
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.CandidateList:SetPos(10, 40)
	self.CandidateList:SetSize(W-5, H-130)

	local HStart = 0
	local width, height = W-20, 30
	for k,v in pairs(self.CandidateList.Candidates) do
		v:SetPos(0,HStart)
		v:SetSize(width, height)
		HStart = HStart + 31
	end

	self.SignB:SetPos(105, H-40)
	self.SignB:SetSize(80,20)

	self.CloseButton:SetPos(Width-25,5)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("res_ballotmenu", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	local Settings = LocalPlayer().CS_PodiumSettings
	LocalPlayer().EditingPodium = true

	self:ShowCloseButton(false)
	self:SetTitle("")
	self:SetDraggable(true)
	self:MakePopup()

	self.Candidate = vgui.Create("DTextEntry", self)
	self.Candidate:SetText(Settings.N)
	self.Candidate:SetUpdateOnType(true)
	self.Candidate.OnValueChange = function(selfp, text)
		LocalPlayer().CS_PodiumSettings.N = string.sub(text, 1, 16)
	end

	self.Slogan = vgui.Create("DTextEntry", self)
	self.Slogan:SetText(Settings.S)
	self.Slogan:SetUpdateOnType(true)
	self.Slogan.OnValueChange = function(selfp, text)
		LocalPlayer().CS_PodiumSettings.S = string.sub(text, 1, 25)
	end

	self.DType = vgui.Create("DComboBox", self)
	self.DType:SetValue("Decal Type")
	for k,v in pairs(RES_Conf.PodiumDecals) do
		self.DType:AddChoice(v.Name, k)
	end
	self.DType.OnSelect = function(panel, index, value)
		LocalPlayer().CS_PodiumSettings.D = self.DType:GetOptionData(index)
	end

	self.BGC = vgui.Create("DColorMixer", self)
	self.BGC:SetPalette(false)
	self.BGC:SetAlphaBar(false)
	self.BGC:SetColor(Color(Settings.BGc.x*255,Settings.BGc.y*255,Settings.BGc.z*255))
	self.BGC.ValueChanged = function(selfp, ctbl)
		LocalPlayer().CS_PodiumSettings.BGc = {x = ctbl.r/255, y = ctbl.g/255, z = ctbl.b/255}
	end

	self.DecalC = vgui.Create("DColorMixer", self)
	self.DecalC:SetPalette(false)
	self.DecalC:SetAlphaBar(false)
	self.DecalC:SetColor(Color(Settings.Dc.x*255,Settings.Dc.y*255,Settings.Dc.z*255))
	self.DecalC.ValueChanged = function(selfp, ctbl)
		LocalPlayer().CS_PodiumSettings.Dc = {x = ctbl.r/255, y = ctbl.g/255, z = ctbl.b/255}
	end

	self.SaveButton = vgui.Create("tbfy_button", self)
	self.SaveButton:SetBText(RES_GetLang("SaveSettings"))
	self.SaveButton:SetBFont("res_text")
	self.SaveButton.DoClick = function()
		local Settings = LocalPlayer().CS_PodiumSettings
		net.Start("res_save_settings_podium")
			net.WriteString(Settings.N)
			net.WriteString(Settings.S)
			net.WriteFloat(Settings.D)
			net.WriteFloat(Settings.BGc.x)
			net.WriteFloat(Settings.BGc.y)
			net.WriteFloat(Settings.BGc.z)
			net.WriteFloat(Settings.Dc.x)
			net.WriteFloat(Settings.Dc.y)
			net.WriteFloat(Settings.Dc.z)
		net.SendToServer()

		self:PRemove()
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:PRemove() end
end

function PANEL:PRemove()
	LocalPlayer().EditingPodium = false
	self:Remove()
	RES_ToggleVM(true)
end

local TextEnt, TextH, Mixer = 20, 15, 100
function PANEL:Paint(W,H)
	draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, MainPanelColor,false,false,true,true)

	draw.RoundedBoxEx(8, 0, 0, W, HeaderH, HeaderColor, true, true, false, false)
	draw.SimpleText(RES_GetLang("PodiumEditor"), "res_text", W/2, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	draw.RoundedBox(4, 5, HeaderH+5, W-10, H-HeaderH-10, TabListColors)

	local SH = HeaderH + 5
	draw.SimpleText(RES_GetLang("Candidate"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	SH = SH+TextEnt+TextH+Padding
	draw.SimpleText(RES_GetLang("Slogan"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	SH = SH+TextEnt+TextH+Padding
	draw.SimpleText(RES_GetLang("DecalType"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	SH = SH+TextEnt+TextH+Padding
	draw.SimpleText(RES_GetLang("Background"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	SH = SH+Mixer+TextH+Padding
	draw.SimpleText(RES_GetLang("Decals"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

local Width, Height = 200, 425
function PANEL:PerformLayout()
	self:SetPos(ScrW()-Width-5, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	local SW, SH = 10, HeaderH + TextH + 5

	self.Candidate:SetPos(SW, SH)
	self.Candidate:SetSize(Width-20, TextEnt)
	SH = SH + TextH + Padding + TextEnt

	self.Slogan:SetPos(SW, SH)
	self.Slogan:SetSize(Width-20, TextEnt)
	SH = SH + TextH + Padding + TextEnt

	self.DType:SetPos(SW,SH)
	self.DType:SetSize(Width-20, TextEnt)
	SH = SH + TextH + Padding + TextEnt

	self.BGC:SetPos(SW, SH)
	self.BGC:SetSize(Width-20, Mixer)
	SH = SH + TextH + Padding + Mixer

	self.DecalC:SetPos(SW, SH)
	self.DecalC:SetSize(Width-20, Mixer)

	self.SaveButton:SetPos(SW, Height-SW-25)
	self.SaveButton:SetSize(Width-20, 25)

	self.CloseButton:SetPos(Width-HeaderH,HeaderH/2-9)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("res_podium_editor", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	local Settings = LocalPlayer().CS_PosterSettings
	LocalPlayer().EditingPoster = true

	self:ShowCloseButton(false)
	self:SetTitle("")
	self:SetDraggable(true)
	self:MakePopup()

	self.Candidate = vgui.Create("DTextEntry", self)
	self.Candidate:SetText(Settings.N)
	self.Candidate:SetUpdateOnType(true)
	self.Candidate.OnValueChange = function(selfp, text)
		LocalPlayer().CS_PosterSettings.N = string.sub(text, 1, 16)
	end

	self.Text = vgui.Create("DTextEntry", self)
	self.Text:SetMultiline(true)
	self.Text:SetText(Settings.Text)
	self.Text:SetUpdateOnType(true)
	self.Text.OnValueChange = function(selfp, text)
		local MLines = string.Explode("\n", text)
		local NewString = ""
		local LineAmount = 0
		for k,v in pairs(MLines) do
			if LineAmount < 15 then
				NewString = NewString .. string.sub(v, 1, 35) .. "\n"
				LineAmount = LineAmount + 1
			end
		end
		LocalPlayer().CS_PosterSettings.Text = NewString
	end

	self.DType = vgui.Create("DComboBox", self)
	self.DType:SetValue("Decal Type")
	for k,v in pairs(RES_Conf.PosterDecals) do
		self.DType:AddChoice(v.Name, k)
	end
	self.DType.OnSelect = function(panel, index, value)
		LocalPlayer().CS_PosterSettings.D = self.DType:GetOptionData(index)
	end

	self.BGC = vgui.Create("DColorMixer", self)
	self.BGC:SetPalette(false)
	self.BGC:SetAlphaBar(false)
	self.BGC:SetColor(Color(Settings.BGc.x*255,Settings.BGc.y*255,Settings.BGc.z*255))
	self.BGC.ValueChanged = function(selfp, ctbl)
		LocalPlayer().CS_PosterSettings.BGc = {x = ctbl.r/255, y = ctbl.g/255, z = ctbl.b/255}
	end

	self.DecalC = vgui.Create("DColorMixer", self)
	self.DecalC:SetPalette(false)
	self.DecalC:SetAlphaBar(false)
	self.DecalC:SetColor(Color(Settings.Dc.x*255,Settings.Dc.y*255,Settings.Dc.z*255))
	self.DecalC.ValueChanged = function(selfp, ctbl)
		LocalPlayer().CS_PosterSettings.Dc = {x = ctbl.r/255, y = ctbl.g/255, z = ctbl.b/255}
	end

	self.SaveButton = vgui.Create("tbfy_button", self)
	self.SaveButton:SetBText(RES_GetLang("SaveSettings"))
	self.SaveButton:SetBFont("res_text")
	self.SaveButton.DoClick = function()
		local Settings = LocalPlayer().CS_PosterSettings
		net.Start("res_save_settings_poster")
			net.WriteString(Settings.N)
			net.WriteString(Settings.Text)
			net.WriteFloat(Settings.D)
			net.WriteFloat(Settings.BGc.x)
			net.WriteFloat(Settings.BGc.y)
			net.WriteFloat(Settings.BGc.z)
			net.WriteFloat(Settings.Dc.x)
			net.WriteFloat(Settings.Dc.y)
			net.WriteFloat(Settings.Dc.z)
		net.SendToServer()

		self:PRemove()
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:PRemove() end
end

function PANEL:PRemove()
	LocalPlayer().EditingPoster = false
	self:Remove()
	RES_ToggleVM(true)
end

local TextEnt, TextH, Mixer = 20, 15, 100
function PANEL:Paint(W,H)
	draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, MainPanelColor,false,false,true,true)

	draw.RoundedBoxEx(8, 0, 0, W, HeaderH, HeaderColor, true, true, false, false)
	draw.SimpleText(RES_GetLang("PosterEditor"), "res_text", W/2, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	draw.RoundedBox(4, 5, HeaderH+5, W-10, H-HeaderH-10, TabListColors)

	local SH = HeaderH + 5
	draw.SimpleText(RES_GetLang("Candidate"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	SH = SH+TextEnt+TextH+Padding
	draw.SimpleText(RES_GetLang("PText"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	SH = SH+TextEnt*4+TextH+Padding
	draw.SimpleText(RES_GetLang("DecalType"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	SH = SH+TextEnt+TextH+Padding
	draw.SimpleText(RES_GetLang("Background"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	SH = SH+Mixer+TextH+Padding
	draw.SimpleText(RES_GetLang("Decals"), "res_text", W/2, SH, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

local Width, Height = 200, 490
function PANEL:PerformLayout()
	self:SetPos(ScrW()-Width-5, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	local SW, SH = 10, HeaderH + TextH + 5

	self.Candidate:SetPos(SW, SH)
	self.Candidate:SetSize(Width-20, TextEnt)
	SH = SH + TextH + Padding + TextEnt

	self.Text:SetPos(SW, SH)
	self.Text:SetSize(Width-20, TextEnt*4)
	SH = SH + TextH + Padding + TextEnt*4

	self.DType:SetPos(SW,SH)
	self.DType:SetSize(Width-20, TextEnt)
	SH = SH + TextH + Padding + TextEnt

	self.BGC:SetPos(SW, SH)
	self.BGC:SetSize(Width-20, Mixer)
	SH = SH + TextH + Padding + Mixer

	self.DecalC:SetPos(SW, SH)
	self.DecalC:SetSize(Width-20, Mixer)

	self.SaveButton:SetPos(SW, Height-SW-25)
	self.SaveButton:SetSize(Width-20, 25)

	self.CloseButton:SetPos(Width-HeaderH,HeaderH/2-9)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("res_poster_editor", PANEL, "DFrame")

hook.Add("CalcView", "res_calcview", function(ply, pos, angles, fov)
	if LocalPlayer().EditingPodium then
		local Ent = LocalPlayer().LastPodium
		if IsValid(Ent) then
			pos, angles = Ent:GetPos()+Ent:GetRight()*-50+Ent:GetUp()*50+Ent:GetForward()*0, Ent:GetAngles()
			angles:RotateAroundAxis(angles:Forward(), 0)
			angles:RotateAroundAxis(angles:Up(), -90)

			local view = {}

			view.origin = pos
			view.angles = angles
			view.fov = fov
			view.drawviewer = false

			return view
		end
	elseif LocalPlayer().EditingPoster then
		local Ent = LocalPlayer().LastPoster
		if IsValid(Ent) then
			pos, angles = Ent:GetPos()+Ent:GetRight()*0+Ent:GetUp()*75+Ent:GetForward()*0, Ent:GetAngles()
			angles:RotateAroundAxis(angles:Right(), 90)
			angles:RotateAroundAxis(angles:Up(), -180)

			local view = {}

			view.origin = pos
			view.angles = angles
			view.fov = fov
			view.drawviewer = false

			return view
		end
	end
end)

local PANEL = {}

function PANEL:Init()
end

function PANEL:PerformLayout(W, H)
end

function PANEL:Paint(W, H)
	local MaxCandidates = RES_GetConf("ELECTION_MaxCandidates")
	local TotPlayers = table.Count(player.GetAll())
	local TotVotes = 0
	local PerVotes = (H*0.7)/TotPlayers

	local Hs = H*0.85
	local TotW = (W-20)/MaxCandidates
	local TotH = (H*0.85)/MaxCandidates

	draw.RoundedBox(8, 0, 0, W, H, TabListColors)
	if RES_IsVotePhase() then
		draw.SimpleText(RES_GetLang("CurrentVotes"), 'res_comp_header', W/2,10, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		surface.SetDrawColor(0,0,0,255)
		surface.DrawLine(0,Hs,W,Hs)

		local WStart = 25
		for k,v in pairs(RES_Candidates) do
			local Padding = TotW*0.3
			local BarSize = TotW*0.7
			surface.SetDrawColor(v.Colors[1],v.Colors[2],v.Colors[3],255)
			draw.SimpleText(v.Initials, 'res_comp_diagram_initals', WStart+BarSize/2,Hs+5, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			local TotH = math.Round(PerVotes*v.Votes)
			surface.DrawRect(WStart, Hs-TotH, BarSize, TotH)
			TotVotes = TotVotes + v.Votes
			WStart = WStart + TotW
		end

		local VotePercent = math.Round((TotVotes/TotPlayers)*100)
		VotePercent = VotePercent .. "%"
		draw.SimpleText(RES_GetLang("TotalVotes") .. TotVotes, 'res_comp_diagram_sub', 10,10, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(string.format(RES_GetLang("VoterTurnout"), VotePercent), 'res_comp_diagram_sub', 10,25, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	elseif RES_IsCampaignPhase() then
		if RES_CurrentPoll then
			local CurrPoll = RES_Polls[RES_CurrentPoll]

			draw.SimpleText(CurrPoll.Question, 'res_comp_header', W/2,10, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			surface.SetDrawColor(0,0,0,255)
			surface.DrawLine(0,Hs,W,Hs)

			local WStart = 25
			for k,v in pairs(CurrPoll.Options) do
				local Padding = TotW*0.3
				local BarSize = TotW*0.7
				surface.SetDrawColor(0,0,0,255)

				local splitResults = TBFY_cutLength(v.Option, TotW-10, "res_comp_diagram_poll")
				for i, text in pairs(splitResults) do
					draw.SimpleText(text, 'res_comp_diagram_poll', WStart+BarSize/2,Hs+((i-1)*10), Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				end

				local BarHs = math.Round(PerVotes*v.Votes)
				surface.DrawRect(WStart, Hs-BarHs, BarSize, BarHs)
				TotVotes = TotVotes + v.Votes
				WStart = WStart + TotW
			end

			local VotePercent = math.Round((TotVotes/TotPlayers)*100)
			VotePercent = VotePercent .. "%"
			draw.SimpleText(RES_GetLang("TotalVotes") .. TotVotes, 'res_comp_diagram_sub', 10,10, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(string.format(RES_GetLang("VoterTurnout"), VotePercent), 'res_comp_diagram_sub', 10,25, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		else
			draw.SimpleText(RES_GetLang("NoPoll"), 'res_comp_header', W/2,H/2, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	else
		draw.SimpleText(table.Count(RES_Candidates) .. "/" .. RES_GetConf("ELECTION_CandidatesRequired") .. " " .. RES_GetLang("CandidatesReq"), 'res_comp_header', W/2,H/2, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
vgui.Register("res_computer_diagram", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Option = ""
	self.Votes = 0
end

function PANEL:SetPoll(Option, CanVote, PollID, SoftID)
	self.Option = Option.Option
	self.Votes = Option.Votes

	if CanVote then
		self.VoteButton = vgui.Create("tbfy_button", self)
		self.VoteButton:SetBText(RES_GetLang("Vote"))
		self.VoteButton.DoClick = function(selfp)
			net.Start("tbfy_computer_run")
				net.WriteString(SoftID)
				net.WriteString("PollVote")
				net.WriteFloat(PollID)
			net.SendToServer()
		end
	end
end

function PANEL:Paint(W, H)
	draw.SimpleText(self.Option .. " (" .. self.Votes .. " Votes)","res_poll_title",0, 0, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function PANEL:PerformLayout(W,H)
	if IsValid(self.VoteButton) then
		local Vote = RES_GetLang("Vote")
		surface.SetFont("tbfy_buttontext")
		local TW, TH = surface.GetTextSize(Vote)

		self.VoteButton:SetSize(TW + 5, H)
		self.VoteButton:SetPos(W-TW-5)
	end
end
vgui.Register("res_comp_vote_poll", PANEL)

local PANEL = {}

function PANEL:Init()
	self.TopFrame = vgui.Create("tbfy_comp_dpanel", self)
	self.TopFrame:SetTitle(RES_GetLang("Polls"))

	self.CurrPoll = vgui.Create("DScrollPanel", self)
	self.CurrPoll.Paint = function(selfp, W, H)
		W = W - 15
	end

	self.CurrPoll.VBar.Paint = function() end
	self.CurrPoll.VBar.btnUp.Paint = function() end
	self.CurrPoll.VBar.btnDown.Paint = function() end
	self.CurrPoll.VBar.btnGrip.Paint = function() end

	self.PollOptions = {}
end

function PANEL:SetPoll(Poll, CanVote, SoftID)
	self.TopFrame:SetTitle(Poll.Question)

	for k,v in pairs(Poll.Options) do
		local PollOption = vgui.Create("res_comp_vote_poll", self.CurrPoll)
		PollOption:SetPoll(v, CanVote, k, SoftID)
		self.PollOptions[k] = PollOption
	end
end

function PANEL:Paint(W, H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 2, 2, W-4, H-4, Derma.CProgramBG)
end

local Width, Height = 300, 200
function PANEL:PerformLayout(W,H)
	self:SetSize(Width, Height)

	if !self.SetInitialPos then
		self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
		self.SetInitialPos = true
	end

	self.TopFrame:SetSize(W-4,Derma.HeaderH)
	self.TopFrame:SetPos(2,2)

	self.CurrPoll:SetSize(Width-10, Height/2 - Derma.HeaderH - 10)
	self.CurrPoll:SetPos(5, Derma.HeaderH + 5)

	local HStart = 0
	for k,v in pairs(self.PollOptions) do
		v:SetPos(0,HStart)
		v:SetSize(W-10, 15)
		HStart = HStart + 20
	end
end
vgui.Register("res_comp_poll_information", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Initials = ""

	self.TopFrame = vgui.Create("tbfy_comp_dpanel", self)
	self.TopFrame:SetFont("res_comp_cand_initial")

	self.Slogan = vgui.Create("DLabel", self)

	self.Agenda = vgui.Create("DTextEntry", self)
	self.Agenda:SetMultiline(true)
	self.Agenda:SetEditable(false)
	self.Agenda:SetDrawBackground(false)
	self.Agenda:SetDrawBorder(false)

	self.VoteButton = vgui.Create("tbfy_button", self)
	self.VoteButton.TW = 0
	self.VoteButton:SetBText(RES_GetLang("Vote"))
	self.VoteButton:SetVisible(false)
end

function PANEL:SetCandidate(Nick, SID, CandInfo, SoftID)
	self.Initials = CandInfo.Initials
	self.Slogan:SetText(CandInfo.Slogan)
	self.Agenda:SetText(CandInfo.Agenda)

	self.TopFrame:SetTitle(self.Initials, false)

	if RES_IsVotePhase() then
		local VoteText = RES_GetLang("Vote") .. " " .. Nick
		self.VoteButton:SetBText(VoteText)
		surface.SetFont("tbfy_buttontext")
		local TW, TH = surface.GetTextSize(VoteText)
		self.VoteButton.TW = TW

		self.VoteButton:SetVisible(true)
		self.VoteButton.DoClick = function(selfp)
			net.Start("tbfy_computer_run")
				net.WriteString(SoftID)
				net.WriteString("Vote")
				net.WriteString(SID)
			net.SendToServer()
			
			self:Remove()
		end
	end
end

local CandidateInfoW, CandidateInfoH = 210, 175
function PANEL:PerformLayout(W,H)
	self:SetSize(CandidateInfoW,CandidateInfoH)
	self:SetPos(ScrW()/2-CandidateInfoW/2, ScrH()/2-CandidateInfoH/2)

	self.TopFrame:SetSize(W-4,Derma.HeaderH)
	self.TopFrame:SetPos(2,2)

	local HStart = Derma.HeaderH

	self.Slogan:SetPos(6, HStart + 18)
	self.Slogan:SetSize(W - 10, 20)

	self.Agenda:SetPos(5, HStart + 55)
	self.Agenda:SetSize(W-10, 70)

	self.VoteButton:SetSize(self.VoteButton.TW+10, 20)
	self.VoteButton:SetPos(W/2 - self.VoteButton.TW/2-5, H-25)
end

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 2, 2, W-4, H-4, Derma.CProgramBG)

	local HPos = Derma.HeaderH + 5
	draw.SimpleText(RES_GetLang("AppSlogan"),"res_candidate_info_subhead",5, HPos,Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	HPos = HPos + 35
	draw.SimpleText(RES_GetLang("AppAgenda"),"res_candidate_info_subhead",5, HPos,Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end
vgui.Register("res_computer_candidate_info", PANEL)

local PANEL = {}

function PANEL:Init()
	self.TopFrame = vgui.Create("tbfy_comp_dpanel", self)
	self.TopFrame:SetTitle(RES_GetLang("Polls"))

	self.CurrentPoll = vgui.Create("DPanel", self)
	self.CurrentPoll.Paint = function(selfp, W, H)
		draw.SimpleText(RES_GetLang("CurrentPoll"),"res_candidate_info_subhead",0, 0,Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	self.PollList = vgui.Create("DScrollPanel", self)
	self.PollList.Paint = function(selfp, W, H)
		draw.SimpleText(RES_GetLang("Polls"),"res_candidate_info_subhead",0, 0,Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	self.PollList.VBar.Paint = function() end
	self.PollList.VBar.btnUp.Paint = function() end
	self.PollList.VBar.btnDown.Paint = function() end
	self.PollList.VBar.btnGrip.Paint = function() end

	self.Polls = {}

	for k,v in pairs(RES_Polls) do
		if k != RES_CurrentPoll then
			local Poll = vgui.Create("res_comp_view_poll", self.PollList)
			Poll:SetPoll(v, self)
			self.Polls[k] = Poll
		end
	end
end

function PANEL:SetSoftID(SoftID)
	if RES_CurrentPoll then
		local CurrPoll = RES_Polls[RES_CurrentPoll]
		self.CPoll = vgui.Create("res_comp_view_poll", self.CurrentPoll)
		self.CPoll:SetPoll(CurrPoll, self, true, SoftID)
	end
end

function PANEL:Paint(W, H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 2, 2, W-4, H-4, Derma.CProgramBG)
end

local Width, Height = 300, 200
function PANEL:PerformLayout(W,H)
	self:SetSize(Width, Height)

	if !self.SetInitialPos then
		self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
		self.SetInitialPos = true
	end

	self.TopFrame:SetSize(W-4,Derma.HeaderH)
	self.TopFrame:SetPos(2,2)

	local HPos = Derma.HeaderH + 5
	self.CurrentPoll:SetPos(5, HPos)
	self.CurrentPoll:SetSize(W - 10, 36)

	if IsValid(self.CPoll) then
		self.CPoll:SetPos(0, 16)
		self.CPoll:SetSize(W-10, 16)
	end

	HPos = HPos + 33

	self.PollList:SetSize(W + 15, H - Derma.HeaderH - 33)
	self.PollList:SetPos(5, HPos)

	local HStart = 16
	for k,v in pairs(self.Polls) do
		v:SetPos(0, HStart)
		v:SetSize(W-10, 16)
		HStart = HStart + 18
	end
end

function PANEL:OnRemove()
    if IsValid(self.PollInfo) then
			self.PollInfo:Remove()
		end
end
vgui.Register("res_comp_polls", PANEL)

local PANEL = {}

function PANEL:Init()
	self.PollQuestion = ""

	self.ViewButton = vgui.Create("tbfy_button", self)
	self.ViewButton:SetBText(RES_GetLang("View"))
end

function PANEL:SetPoll(Poll, Parent, CanVote, SoftID)
	self.PollQuestion = Poll.Question

	self.ViewButton.DoClick = function(selfp)
		if !IsValid(self.PollsInfo) then
			self.PollsInfo = vgui.Create("res_comp_poll_information", Parent:GetParent())
			self.PollsInfo:SetPoll(Poll, CanVote, SoftID)
			Parent.PollInfo = self.PollsInfo
		end
	end
end

function PANEL:Paint(W, H)
	draw.SimpleText(self.PollQuestion,"res_poll_title",0, 0, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function PANEL:PerformLayout(W,H)
	local Vote = RES_GetLang("View")
	surface.SetFont("tbfy_buttontext")
	local TW, TH = surface.GetTextSize(Vote)

	self.ViewButton:SetSize(TW + 5, H)
	self.ViewButton:SetPos(W-TW-5)
end
vgui.Register("res_comp_view_poll", PANEL)

local PANEL = {}

function PANEL:Init()
	self.ID = 0

	self.Input = vgui.Create("DTextEntry", self)
	self.Input:SetText("")
end

function PANEL:GetInputValue()
	return self.Input:GetValue()
end

function PANEL:Paint(W, H)
	draw.SimpleText(RES_GetLang("PollOption") .. " " .. self.ID .. ":","res_candidate_info_subhead",0, 0, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function PANEL:PerformLayout(W,H)
	self.Input:SetPos(0, 20)
	self.Input:SetSize(W, 20)
end
vgui.Register("res_comp_poll", PANEL)

local PANEL = {}

function PANEL:Init()
	self.TopFrame = vgui.Create("tbfy_comp_dpanel", self)
	self.TopFrame:SetTitle(RES_GetLang("StartPoll"))

	self.PollList = vgui.Create("DScrollPanel", self)
	self.PollList.Paint = function(selfp, W, H)
	end
	self.PollList.VBar.Paint = function() end
	self.PollList.VBar.btnUp.Paint = function() end
	self.PollList.VBar.btnDown.Paint = function() end
	self.PollList.VBar.btnGrip.Paint = function() end

	self.PollOptions = {}

	self.Question = vgui.Create("DTextEntry", self)
	self.Question:SetText("")

	self.Option1 = vgui.Create("res_comp_poll", self.PollList)
	self.Option1.ID = 1
	self.PollOptions[1] = self.Option1

	self.Option2 = vgui.Create("res_comp_poll", self.PollList)
	self.Option2.ID = 2
	self.PollOptions[2] = self.Option2

	surface.SetFont("tbfy_buttontext")
	local PollOption = RES_GetLang("AddPollOption")
	local TW, TH = surface.GetTextSize(PollOption)
	self.AddPollOption = vgui.Create("tbfy_button", self)
	self.AddPollOption:SetBText(PollOption)
	self.AddPollOption.TW = TW
	self.AddPollOption.DoClick = function(selfp)
		local Index = table.Count(self.PollOptions) + 1
		if Index > RES_GetConf("ELECTION_MaxPollOptions") then
			TBFY_SH:SendMessage(RES_GetLang("Polls"), RES_GetLang("MaxPollOptions"))
		else
			local Option = vgui.Create("res_comp_poll", self.PollList)
			Option.ID = Index
			self.PollOptions[Index] = Option
		end
	end

	local StartPoll = RES_GetLang("StartPoll")
	local TW, TH = surface.GetTextSize(StartPoll)
	self.FinishButton = vgui.Create("tbfy_button", self)
	self.FinishButton:SetBText(StartPoll)
	self.FinishButton.TW = TW
	self.FinishButton.DoClick = function(selfp)
		if RES_CurrentPoll then
			TBFY_SH:SendMessage(RES_GetLang("Polls"), RES_GetLang("ActivePoll"))
		elseif !RES_IsCampaignPhase() then
			TBFY_SH:SendMessage(RES_GetLang("Polls"), RES_GetLang("PollNotCampaign"))
		else
			net.Start("tbfy_computer_run")
				net.WriteString(self.SoftID)
				net.WriteString("StartPoll")
				net.WriteString(self.Question:GetValue())
				net.WriteFloat(table.Count(self.PollOptions))
				for k,v in pairs(self.PollOptions) do
					net.WriteString(v:GetInputValue())
				end
			net.SendToServer()

			self:Remove()
		end
	end
end

function PANEL:Paint(W, H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 2, 2, W-4, H-4, Derma.CProgramBG)

	draw.SimpleText(RES_GetLang("PollQuestion"),"res_candidate_info_subhead", 5, Derma.HeaderH + 5,Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

local Width, Height = 225, 280
function PANEL:PerformLayout(W,H)
	self:SetSize(Width, Height)

	if !self.SetInitialPos then
		self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
		self.SetInitialPos = true
	end

	self.TopFrame:SetSize(W-4,Derma.HeaderH)
	self.TopFrame:SetPos(2,2)

	self.Question:SetPos(5, 50)
	self.Question:SetSize(W - 10, 20)

	self.PollList:SetSize(W + 10, H - 105)
	self.PollList:SetPos(0, 75)

	local HStart = 0
	for k,v in pairs(self.PollOptions) do
		v:SetPos(5, HStart)
		v:SetSize(W - 10, 40)
		HStart = HStart + 45
	end

	local TW = self.AddPollOption.TW + 10
	self.AddPollOption:SetSize(TW,20)
	self.AddPollOption:SetPos(W/2-TW, H - 25)

	local TW2 = self.FinishButton.TW + 10
	self.FinishButton:SetSize(TW2,20)
	self.FinishButton:SetPos(W/2 + 5, H - 25)
end
vgui.Register("res_comp_poll_start", PANEL)

local PANEL = {}

function PANEL:Init()
	self.ViewButton = vgui.Create("tbfy_button", self)
	self.ViewButton:SetBText(RES_GetLang("View"))

	self.Name = ""
end

function PANEL:SetCandidate(Nick, SID, CandInfo, SoftID, MainP)
	self.Name = Nick

	self.ViewButton.DoClick = function(selfp)
		if !IsValid(MainP.CandidateInfo) then
			if IsValid(CandInfo.Player) then
				MainP.CandidateInfo = vgui.Create("res_computer_candidate_info", MainP:GetParent():GetParent())
				MainP.CandidateInfo.MainP = MainP
				MainP.CandidateInfo:SetCandidate(Nick, SID, CandInfo, SoftID)
			else
				self:Remove()
			end
		end
	end
end

function PANEL:PerformLayout(W, H)
	local Vote = RES_GetLang("View")
	surface.SetFont("tbfy_buttontext")
	local TW, TH = surface.GetTextSize(Vote)

	self.ViewButton:SetSize(TW + 5, H)
	self.ViewButton:SetPos(W-TW-5)
end

function PANEL:Paint(W, H)
	draw.SimpleText(self.Name, "res_comp_diagram_candidate", 0, H/2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end
vgui.Register("res_computer_candidate", PANEL)

local PANEL = {}

function PANEL:Init()
	if RES_NoElectionJob() then
		self.Sheet = vgui.Create("DPropertySheet", self)
		self.Sheet:SetPadding(1)

		self.ElectionSheet = vgui.Create("DPanel", self.Sheet)
		self.DiagramSheet = vgui.Create("DPanel", self.Sheet)

		self.Sheet:AddSheet("Election", self.ElectionSheet)
		self.Sheet:AddSheet("Diagram", self.DiagramSheet)

		self.CandidateList = vgui.Create("DScrollPanel", self.ElectionSheet)
		self.CandidateList.Paint = function(selfp, W, H)
			W = W - 15
			draw.RoundedBox(8, 0, 0, W, H, TabListColors)
			draw.SimpleText(RES_GetLang("CurrentCandidates"), 'res_comp_header', W/2,5, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
		self.CandidateList.VBar.Paint = function() end
		self.CandidateList.VBar.btnUp.Paint = function() end
		self.CandidateList.VBar.btnDown.Paint = function() end
		self.CandidateList.VBar.btnGrip.Paint = function() end

		self.Candidates = {}

		for k,v in pairs(RES_Candidates) do
			local Player = v.Player
			if IsValid(Player) then
				local SID = TBFY_SH:SID(Player)
				local Nick = Player:Nick()
				local CandInfo = RES_Candidates[SID]
				if CandInfo then
					local Candidate = vgui.Create("res_computer_candidate", self.CandidateList)
					Candidate:SetCandidate(Nick, SID, CandInfo, self:GetParent().SoftID, self)
					self.Candidates[k] = Candidate
				end
			end
		end

		self.CandidateActionList = vgui.Create("DScrollPanel", self.ElectionSheet)
		self.CandidateActionList.Paint = function(selfp, W, H)
			W = W - 15
			draw.RoundedBox(8, 0, 0, W, H, TabListColors)
			draw.SimpleText(RES_GetLang("CandidateActions"), 'res_comp_header', W/2,5, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
		self.CandidateActionList.VBar.Paint = function() end
		self.CandidateActionList.VBar.btnUp.Paint = function() end
		self.CandidateActionList.VBar.btnDown.Paint = function() end
		self.CandidateActionList.VBar.btnGrip.Paint = function() end

		self.CandidateActions = {}

		self.SignUp = vgui.Create("tbfy_button", self.CandidateActionList)
		self.SignUp:SetBText(RES_GetLang("PoliticalApp"))
		self.SignUp.DoClick = function(selfp)
			if !IsValid(self.Application) then
				self.Application = vgui.Create("res_computer_application", self:GetParent():GetParent())
				self.Application.MainP = self
			end
		end
		table.insert(self.CandidateActions, self.SignUp)

		self.Polls = vgui.Create("tbfy_button", self.CandidateActionList)
		self.Polls:SetBText(RES_GetLang("Polls"))
		self.Polls.DoClick = function(selfp)
			if !IsValid(self.PollsM) then
				self.PollsM = vgui.Create("res_comp_polls", self:GetParent():GetParent())
				self.PollsM:SetSoftID(self.SoftID)
				self.PollsM.MainP = self
			end
		end
		table.insert(self.CandidateActions, self.Polls)

		if LocalPlayer():IsPCandidate() then
			self.StartPoll = vgui.Create("tbfy_button", self.CandidateActionList)
			self.StartPoll:SetBText(RES_GetLang("StartPoll"))
			self.StartPoll.DoClick = function(selfp)
				if !IsValid(self.PollCreator) then
					self.PollCreator = vgui.Create("res_comp_poll_start", self:GetParent():GetParent())
					self.PollCreator.SoftID = self:GetParent().SoftID
					self.PollCreator.MainP = self
				end
			end
			table.insert(self.CandidateActions, self.StartPoll)

			self.Resign = vgui.Create("tbfy_button", self.CandidateActionList)
			self.Resign:SetBText(RES_GetLang("Resign"))
			self.Resign.DoClick = function(selfp)
				net.Start("res_resign_election")
				net.SendToServer()

				timer.Simple(.5, function()
					self:UpdateMenu()
				end)
			end
			table.insert(self.CandidateActions, self.Resign)
		end

		self.Diagram = vgui.Create("res_computer_diagram", self.DiagramSheet)
		self.Election = true
	end
end

function PANEL:UpdateMenu()
	local StartPollExist = IsValid(self.StartPoll)
	local ResignExist = IsValid(self.Resign)

	if LocalPlayer():IsPCandidate() then
		if !StartPollExist then
			self.StartPoll = vgui.Create("tbfy_button", self.CandidateActionList)
			self.StartPoll:SetBText(RES_GetLang("StartPoll"))
			self.StartPoll.DoClick = function(selfp)
				if !IsValid(self.PollCreator) then
					self.PollCreator = vgui.Create("res_comp_poll_start", self:GetParent():GetParent())
					self.PollCreator.SoftID = self.SoftID
					self.PollCreator.MainP = self
				end
			end
			table.insert(self.CandidateActions, self.StartPoll)
		end

		if !ResignExist then
			self.Resign = vgui.Create("tbfy_button", self.CandidateActionList)
			self.Resign:SetBText(RES_GetLang("Resign"))
			self.Resign.DoClick = function(selfp)
				net.Start("res_resign_election")
				net.SendToServer()
				selfp:Remove()
			end
			table.insert(self.CandidateActions, self.Resign)
		end
	else
		if StartPollExist then
			self.StartPoll:Remove()
		end
		if ResignExist then
			self.Resign:Remove()
		end
	end

	for k,v in pairs(self.Candidates) do
		v:Remove()
	end

	self.Candidates = {}

	for k,v in pairs(RES_Candidates) do
		local Player = v.Player
		if IsValid(Player) then
			local SID = TBFY_SH:SID(Player)
			local Nick = Player:Nick()
			local CandInfo = RES_Candidates[SID]
			if CandInfo then
				local Candidate = vgui.Create("res_computer_candidate", self.CandidateList)
				Candidate:SetCandidate(Nick, SID, CandInfo, SoftID, self)
				self.Candidates[k] = Candidate
			end
		end
	end

	self:InvalidateLayout()
end

function PANEL:PerformLayout(W, H)
	if self.Election then
		self.Sheet:SetSize(W,H)

		local CandSize = W*0.7
		if IsValid(self.CandidateList) then
			self.CandidateList:SetSize(CandSize+15,H-2)
			self.CandidateList:SetPos(2,0)

			local HStart = 25
			for k,v in pairs(self.Candidates) do
				v:SetPos(5, HStart)
				v:SetSize(CandSize - 10, 15)
				HStart = HStart + 17
			end
		end

		self.CandidateActionList:SetSize(W - CandSize + 9,H-2)
		self.CandidateActionList:SetPos(CandSize + 3,0)

		local ActionW = W - CandSize - 1
		local HStart = 25
		for k,v in pairs(self.CandidateActions) do
			if IsValid(v) then
				v:SetPos(5, HStart)
				v:SetSize(ActionW - 15, 15)
				HStart = HStart + 17
			end
		end

		if IsValid(self.Diagram) then
			self.Diagram:SetSize(W,H)
			self.Diagram:SetPos(0, 0)
		end
	end
end

function PANEL:Paint(W, H)
	if !self.Election then
		draw.RoundedBox(8, 0, 0, W, H, TabListColors)
		draw.SimpleText(RES_GetLang("NoElection"), 'res_comp_header', W/2,H/2, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function PANEL:OnRemove()
	if IsValid(self.CandidateInfo) then
		self.CandidateInfo:Remove()
	end
	if IsValid(self.Application) then
		self.Application:Remove()
	end
	if IsValid(self.PollCreator) then
		self.PollCreator:Remove()
	end
	if IsValid(self.PollsM) then
		self.PollsM:Remove()
	end
end
vgui.Register("res_computer_election", PANEL)
