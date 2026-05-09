
local FA_Config = TBFY_FAConfig

net.Receive("fa_send_licenses", function()
	local LString, Steamid = net.ReadString(),net.ReadString()

	DecompileFALicenses(LString,Steamid)
end)

net.Receive("fa_update_practical_license", function()
	local SteamID, LID, NewValue = net.ReadString(), net.ReadFloat(), net.ReadFloat()

	FALICENSE_PLAYERDB[SteamID] = FALICENSE_PLAYERDB[SteamID] or {}
	FALICENSE_PLAYERDB[SteamID][LID] = FALICENSE_PLAYERDB[SteamID][LID] or {}
	FALICENSE_PLAYERDB[SteamID][LID] = {Practical = NewValue, Carry = FALICENSE_PLAYERDB[SteamID][LID].Carry or 0, Sell = FALICENSE_PLAYERDB[SteamID][LID].Sell or 0}
end)

net.Receive("fa_update_carry_license", function()
	local SteamID, LID, NewValue = net.ReadString(), net.ReadFloat(), net.ReadFloat()

	FALICENSE_PLAYERDB[SteamID] = FALICENSE_PLAYERDB[SteamID] or {}
	FALICENSE_PLAYERDB[SteamID][LID] = FALICENSE_PLAYERDB[SteamID][LID] or {}
	FALICENSE_PLAYERDB[SteamID][LID] = {Practical = FALICENSE_PLAYERDB[SteamID][LID].Practical or 0, Carry = NewValue, Sell = FALICENSE_PLAYERDB[SteamID][LID].Sell or 0}
end)

net.Receive("fa_update_sell_license", function()
	local SteamID, LID, NewValue = net.ReadString(), net.ReadFloat(), net.ReadFloat()

	FALICENSE_PLAYERDB[SteamID] = FALICENSE_PLAYERDB[SteamID] or {}
	FALICENSE_PLAYERDB[SteamID][LID] = FALICENSE_PLAYERDB[SteamID][LID] or {}
	FALICENSE_PLAYERDB[SteamID][LID] = {Practical = FALICENSE_PLAYERDB[SteamID][LID].Practical or 0, Carry = FALICENSE_PLAYERDB[SteamID][LID].Carry or 0, Sell = NewValue}
end)

FA_Instructors = FA_Instructors or {}
net.Receive("fa_update_instructor", function()
	local SteamID, Instructor = net.ReadString(), net.ReadBool()

	if Instructor then
		FA_Instructors[SteamID] = true
	else
		FA_Instructors[SteamID] = nil
	end
end)

net.Receive("fa_start_practical_test", function()
	local LID, ScoreReq, StageAmount = net.ReadFloat(), net.ReadFloat(), net.ReadFloat()

	LocalPlayer().FA_DoingPractical = LID
	LocalPlayer().FA_ScoreCur = 0
	LocalPlayer().FA_ScoreReq = ScoreReq
	LocalPlayer().FA_StageCur = 1
	LocalPlayer().FA_StageAmount = StageAmount
	LocalPlayer().FA_PracticalStart = CurTime() + FALICENSE_DATABASE[LID].PracticalTime
end)

net.Receive("fa_update_practical_test", function()
	local Done, NewScore, NewStage, NewScoreReq = net.ReadBool(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat()
	if Done then
		LocalPlayer().FA_DoingPractical = nil
		LocalPlayer().FA_ScoreCur = nil
		LocalPlayer().FA_ScoreReq = nil
		LocalPlayer().FA_StageCur = nil
		LocalPlayer().FA_StageAmount = nil
		LocalPlayer().FA_PracticalStart = nil
	else
		LocalPlayer().FA_ScoreCur = NewScore
		LocalPlayer().FA_StageCur = NewStage
		LocalPlayer().FA_ScoreReq = NewScoreReq
	end
end)

surface.CreateFont("fa_HUDText", {
	font = "Verdana",
	size = 20,
	weight = 1000,
	antialias = true,
})

hook.Add( "HUDPaint", "fa_PracticalTestHUD", function()
	if LocalPlayer().FA_DoingPractical then
		local TimeLeft = math.Round(LocalPlayer().FA_PracticalStart - CurTime())
		local CScore = LocalPlayer().FA_ScoreCur
		local ReqScore = LocalPlayer().FA_ScoreReq
		local CStage = LocalPlayer().FA_StageCur
		local TotalStage = LocalPlayer().FA_StageAmount

		draw.SimpleTextOutlined("Score: " .. CScore .. "/" .. ReqScore,"fa_HUDText",ScrW()/2,ScrH()/12,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM,2,Color(0,0,0,255))
		draw.SimpleTextOutlined("Stage: " .. CStage .. "/" .. TotalStage,"fa_HUDText",ScrW()/2,ScrH()/12+25,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM,2,Color(0,0,0,255))
		draw.SimpleTextOutlined("Timeleft: " .. TimeLeft .. " seconds","fa_HUDText",ScrW()/2,ScrH()/12+50,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM,2,Color(0,0,0,255))
	end
end)

net.Receive("fa_open_amanagement", function()
	vgui.Create("fa_admin_management")
end)

net.Receive("fa_open_insmanagement", function()
	vgui.Create("fa_ins_management")
end)

net.Receive("fa_practical_test_menu", function()
	vgui.Create("fa_practical_choose")
end)

net.Receive("fa_application_request_menu", function()
	vgui.Create("fa_application_request_menu")
end)

net.Receive("fa_application_examine_menu", function()
	local PlayerNicks = net.ReadTable()

	local ExamineMenu = vgui.Create("fa_application_examine_menu")
	ExamineMenu:SetPNicks(PlayerNicks)
end)

net.Receive("fa_application_send_examine_info", function()
	local AppTbl = net.ReadTable()

	local ExaminePApp = vgui.Create("fa_application_examine_player")
	ExaminePApp:SetPInfo(AppTbl)
end)

surface.CreateFont( "fa_licensetext", {
	font = "Verdana",
	size = 25,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "fa_paneltext", {
	font = "Verdana",
	size = 17,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "fa_text", {
	font = "Verdana",
	size = 14,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "fa_choose_text", {
	font = "Verdana",
	size = 13,
	weight = 500,
	antialias = true,
})

surface.CreateFont( "fa_buttontext", {
	font = "Verdana",
	size = 11,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "fa_theory_question", {
	font = "Verdana",
	size = 14,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "fa_theory_answer", {
	font = "Verdana",
	size = 12,
	weight = 500,
	antialias = true,
})

surface.CreateFont( "fa_app_headline", {
	font = "coolvetica",
	size = 25,
	weight = 500,
	antialias = true,
	underline = true,
})

surface.CreateFont( "fa_app_subhead", {
	font = "Calibri",
	size = 18,
	weight = 500,
	antialias = true,
	underline = true,
})

surface.CreateFont( "fa_app_text", {
	font = "coolvetica",
	size = 22,
	weight = 750,
	antialias = true,
})

surface.CreateFont( "fa_app_sign", {
	font = "coolvetica",
	size = 19,
	weight = 500,
	antialias = true,
})

surface.CreateFont( "fa_app_pheadline", {
	font = "coolvetica",
	size = 26,
	weight = 800,
	antialias = true,
	underline = true,
})

surface.CreateFont( "fa_app_plist", {
	font = "coolvetica",
	size = 21,
	weight = 750,
	antialias = true,
})

local MainPanelColor = Color(255,255,255,200)
local HeaderColor = Color(50,50,50,255)
local TabListColors = Color(215,215,220,255)
local LicenseListColor = Color(200,200,210,255)
local ButtonColor = Color(50,50,50,255)
local ButtonColorHovering = Color(75,75,75,200)
local ButtonColorPressed = Color(150,150,150,200)
local ButtonOutline = Color(0,0,0,200)
local HeaderH = 25

local PANEL = {}

function PANEL:Init()
	self.ButtonText = ""
	self.BColor = ButtonColor
	self:SetText("")
	self.Font = "fa_buttontext"
	self.DClickC = ButtonColorPressed
	self.DHoverC = ButtonColorHovering
	self.DButtonC = ButtonColor
end

function PANEL:UpdateColours()

	if self:IsDown() or self.m_bSelected then self.BColor = self.DClickC return end
	if self.Hovered and !self:GetDisabled() then self.BColor = self.DHoverC return end

	self.BColor = self.DButtonC
	return
end

function PANEL:SetBText(Text)
	self.ButtonText = Text
end

function PANEL:SetBFont(Font)
	self.Font = Font
end

function PANEL:SetBColors(Press,Hover,Normal)
	self.DClickC = Press
	self.DHoverC = Hover
	self.DButtonC = Normal
end

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, self.BColor)
	draw.SimpleText(self.ButtonText, self.Font, W/2, H/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
vgui.Register("fa_button", PANEL, "DButton")

local HasLMat = Material("fa_hasl.png")
local NoLMat = Material("fa_nol.png")

local MatTbl = {}
local function FetchLicenseIcon(ID)
	if !MatTbl[ID] then
		MatTbl[ID] = Material(FALICENSE_DATABASE[ID].Image)
	end
	return MatTbl[ID]
end

local PANEL = {}

function PANEL:Init()
	self.Name = ""
	self.Image = 1

	self.TButton = vgui.Create("fa_button", self)
	self.TButton.HasL = false
	self.TButton.Paint = function(selfp, W,H)
		surface.SetDrawColor(200,200,200, 255)
		if selfp.HasL then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(0,0,W,H)
	end

	self.PButton = vgui.Create("fa_button", self)
	self.PButton.HasL = false
	self.PButton.Paint = function(selfp, W,H)
		surface.SetDrawColor(200,200,200, 255)
		if selfp.HasL then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(0,0,W,H)
	end

	self.CButton = vgui.Create("fa_button", self)
	self.CButton.HasL = false
	self.CButton.Paint = function(selfp, W,H)
		surface.SetDrawColor(200,200,200, 255)
		if selfp.HasL then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(0,0,W,H)
	end

	self.SButton = vgui.Create("fa_button", self)
	self.SButton.HasL = false
	self.SButton.Paint = function(selfp, W,H)
		surface.SetDrawColor(200,200,200, 255)
		if selfp.HasL then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(0,0,W,H)
	end
end

function PANEL:SetLInfo(L)
	local LTbl = FALICENSE_DATABASE[L]
	self.Name = LTbl.Name
  self.TheoryTest = LTbl.TheoryTest
	self.Image = L
end

function PANEL:Paint(W,H)
	draw.SimpleText(self.Name, "fa_licensetext", 15, H/2, Color(0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	surface.SetDrawColor(255,255,255, 255)
	surface.SetMaterial(FetchLicenseIcon(self.Image))
	surface.DrawTexturedRect(35, 0, H*2, H)
end

function PANEL:PerformLayout(W,H)
	W = W - 15
	local LSpace = 100
	local TextW = (W-LSpace)/8
	local BSize = H / 1.5
	local BSizeD = BSize/2

	self.TButton:SetPos(LSpace+TextW-BSizeD,H/2-BSizeD+1)
	self.TButton:SetSize(BSize,BSize)

	self.PButton:SetPos(LSpace+TextW*3-BSizeD,H/2-BSizeD+1)
	self.PButton:SetSize(BSize,BSize)

	self.CButton:SetPos(LSpace+TextW*5-BSizeD,H/2-BSizeD+1)
	self.CButton:SetSize(BSize,BSize)

	self.SButton:SetPos(LSpace+TextW*7-BSizeD,H/2-BSizeD+1)
	self.SButton:SetSize(BSize,BSize)
end
vgui.Register("fa_license", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Name = ""
	self.SID = ""
	self.Job = ""

	self.InstructorB = vgui.Create("fa_button", self)
	self.InstructorB.HasL = false
	self.InstructorB.Paint = function(selfp, W,H)
		surface.SetDrawColor(200,200,200, 255)
		if selfp.HasL then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(0,0,W,H)
	end

	self.FAList = vgui.Create("DScrollPanel", self)
	self.FAList.Paint = function(selfp, W, H)
		W = W - 15
		draw.RoundedBoxEx(8, 0, 0, W, 25, HeaderColor, true, true, false, false)
		draw.SimpleText(FA_GetLang("FirearmTab"), "fa_paneltext", W/2, 25/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.RoundedBoxEx(4, 0, HeaderH, W, H-HeaderH, LicenseListColor,false,false,true,true)

		local LSpace = 100
		local TextW = (W-LSpace)/8
		draw.SimpleText(FA_GetLang("Theory"), "fa_text", LSpace+TextW, 35, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText(FA_GetLang("Practical"), "fa_text", LSpace+TextW*3, 35, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText(FA_GetLang("CanCarry"), "fa_text", LSpace+TextW*5, 35, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText(FA_GetLang("CanSell"), "fa_text", LSpace+TextW*7, 35, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.FAList.Licenses = {}
	self.FAList.VBar.Paint = function() end
	self.FAList.VBar.btnUp.Paint = function() end
  self.FAList.VBar.btnDown.Paint = function() end
	self.FAList.VBar.btnGrip.Paint = function() end

	for k,v in pairs(FALICENSE_DATABASE) do
		local License = vgui.Create("fa_license", self.FAList)
		License:SetLInfo(k)
		self.FAList.Licenses[k] = License
	end
end

function PANEL:SetPInfo(Player)
	self.Name = Player:Nick()
	self.SID = TBFY_SH:SID(Player)
	self.Job = Player:getDarkRPVar("job")

	if Player:FA_IsInstructor() then
		self.InstructorB.HasL = true
	else
		self.InstructorB.HasL = false
	end
	self.InstructorB.DoClick = function() net.Start("fa_toggle_instructor") net.WriteEntity(Player) net.SendToServer() self.InstructorB.HasL = !self.InstructorB.HasL end

	for k,v in pairs(self.FAList.Licenses) do
		if TBFY_SH:PlayerHasTheory(self.SID, v.TheoryTest, k) then
			v.TButton.HasL = true
		else
			v.TButton.HasL = false
		end
		v.TButton.DoClick = function() net.Start("fa_toggle_theory") net.WriteEntity(Player) net.WriteFloat(k) net.SendToServer() v.TButton.HasL = !v.TButton.HasL end

		if Player:FAPassedPractical(k) then
			v.PButton.HasL = true
		else
			v.PButton.HasL = false
		end
		v.PButton.DoClick = function() net.Start("fa_toggle_practical") net.WriteEntity(Player) net.WriteFloat(k) net.SendToServer() v.PButton.HasL = !v.PButton.HasL end

		if Player:FACanCarry(k) then
			v.CButton.HasL = true
		else
			v.CButton.HasL = false
		end
		v.CButton.DoClick = function()
			net.Start("fa_toggle_carry")
				net.WriteEntity(Player)
				net.WriteFloat(k)
			net.SendToServer()
			if TBFY_SH:PlayerHasTheory(self.SID, v.TheoryTest, k) and Player:FAPassedPractical(k) then
				v.CButton.HasL = !v.CButton.HasL
			end
		end

		if Player:FACanSell(k) then
			v.SButton.HasL = true
		else
			v.SButton.HasL = false
		end
		v.SButton.DoClick = function()
			net.Start("fa_toggle_sell")
				net.WriteEntity(Player)
				net.WriteFloat(k)
			net.SendToServer()
			if TBFY_SH:PlayerHasTheory(self.SID, v.TheoryTest, k) and Player:FAPassedPractical(k) then
				v.SButton.HasL = !v.SButton.HasL
			end
		end
	end
end

function PANEL:Paint(W,H)
	W = W - 30

	draw.RoundedBox(4, 0, 0, W, H, TabListColors,false,false,true,true)

	surface.SetFont("fa_paneltext")
	local Name = self.Name
	local TW, TH = surface.GetTextSize( Name )
	local BW, BH = TW+10, TH+5

	draw.RoundedBox(8, 5, 5, BW, BH, HeaderColor)
	draw.SimpleText(Name, "fa_paneltext", 10, HeaderH/2+2.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	draw.SimpleText("SteamID: " .. self.SID, "fa_text", 5, HeaderH+15, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText(FA_GetLang("Job") .. ": " .. self.Job, "fa_text", 5, HeaderH+35, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText(FA_GetLang("Instructor") .. ":", "fa_text", 5, HeaderH+55, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

function PANEL:PerformLayout(W,H)
	local WA = W - 25
	local HS = H * 0.25
	local HA = H * 0.75
	local Padding = 5

	surface.SetFont("fa_text")
	local TW, TH = surface.GetTextSize(FA_GetLang("Instructor") .. ":")

	self.InstructorB:SetPos(TW+10,HeaderH+52)
	self.InstructorB:SetSize(10,10)

	self.FAList:SetSize(WA, HA-Padding)
	self.FAList:SetPos(Padding, HS)

	local LicenseH = 50
	for k,v in pairs(self.FAList.Licenses) do
		v:SetPos(0,LicenseH)
		v:SetSize(WA, 35)

		LicenseH = LicenseH + 40
	end
end
vgui.Register("fa_ampanel", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle("")
	self:MakePopup()

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)
		draw.SimpleText(FA_GetLang("AdminManageMenu"), "fa_paneltext", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.PlayerList = vgui.Create("DScrollPanel", self)
	self.PlayerList.Paint = function(selfp, W, H)
		draw.RoundedBox(4, 0, 0, W-15, H, TabListColors)
	end

	self.PlayerList.VBar.Paint = function() end
	self.PlayerList.VBar.btnUp.Paint = function() end
    self.PlayerList.VBar.btnDown.Paint = function() end
	self.PlayerList.VBar.btnGrip.Paint = function() end

	self.InformationPanel = vgui.Create("fa_ampanel", self)

	local PlayersSorted = player.GetAll()
	table.sort(PlayersSorted, function ( P1, P2 )
		if (!P1) then return false; end
		if (!P2) then return true; end

		local P1S = string.lower(P1:Nick());
		local P2S = string.lower(P2:Nick());

		return P1S < P2S
	end);

	self.ButtonTBL = {}
	for k,v in pairs(PlayersSorted) do
		local CButton = vgui.Create("fa_button", self.PlayerList)
		CButton:SetBText(v:Nick())
		CButton:SetBFont("fa_paneltext")
		CButton.DoClick = function() self.InformationPanel:SetPInfo(v) end

		self.ButtonTBL[k] = CButton
	end
	self.InformationPanel:SetPInfo(PlayersSorted[1])

	self.CloseButton = vgui.Create("fa_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, MainPanelColor,false,false,true,true)
end

local Width, Height = 700, 500
function PANEL:PerformLayout()
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

    self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(Width,HeaderH)

	local HStart = HeaderH+5
	self.PlayerList:SetPos(5,HStart)
	self.PlayerList:SetSize(Width*0.25+15, Height-HeaderH-10)

	self.InformationPanel:SetPos(Width*0.25+10,HStart)
	self.InformationPanel:SetSize(Width*0.75+15,Height-HeaderH-10)

	local ButtonH = 5
	for k,v in pairs(self.ButtonTBL) do
		v:SetPos(5,ButtonH)
		v:SetSize(self.PlayerList:GetWide()-25, 25)

		ButtonH = ButtonH + 30
	end

	self.CloseButton:SetPos(Width-HeaderH,HeaderH/2-9)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("fa_admin_management", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle("")
	self:MakePopup()

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)
		draw.SimpleText(FA_GetLang("InstructorManageMenu"), "fa_paneltext", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.PlayerList = vgui.Create("DScrollPanel", self)
	self.PlayerList.Paint = function(selfp, W, H)
		draw.RoundedBox(4, 0, 0, W-15, H, TabListColors)
	end

	self.PlayerList.VBar.Paint = function() end
	self.PlayerList.VBar.btnUp.Paint = function() end
    self.PlayerList.VBar.btnDown.Paint = function() end
	self.PlayerList.VBar.btnGrip.Paint = function() end

	self.InformationPanel = vgui.Create("fa_ampanel", self)

	local PlayersSorted = player.GetAll()
	table.sort(PlayersSorted, function ( P1, P2 )
		if (!P1) then return false; end
		if (!P2) then return true; end

		local P1S = string.lower(P1:Nick());
		local P2S = string.lower(P2:Nick());

		return P1S < P2S
	end);

	self.ButtonTBL = {}
	for k,v in pairs(PlayersSorted) do
		local CButton = vgui.Create("fa_button", self.PlayerList)
		CButton:SetBText(v:Nick())
		CButton:SetBFont("fa_paneltext")
		CButton.DoClick = function() self.InformationPanel:SetPInfo(v) end

		self.ButtonTBL[k] = CButton
	end
	self.InformationPanel:SetPInfo(PlayersSorted[1])

	//Check Instructor settings
	self.InformationPanel.InstructorB.DoClick = function() end
	for k,v in pairs(self.InformationPanel.FAList.Licenses) do
		if !FA_CheckInsAccess("Theory") then
			v.TButton.DoClick = function() end
		end
		if !FA_CheckInsAccess("Practical") then
			v.PButton.DoClick = function() end
		end
		if !FA_CheckInsAccess("Carry") then
			v.CButton.DoClick = function() end
		end
		if !FA_CheckInsAccess("Sell") then
			v.SButton.DoClick = function() end
		end
	end

	self.CloseButton = vgui.Create("fa_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, MainPanelColor,false,false,true,true)
end

local Width, Height = 700, 500
function PANEL:PerformLayout()
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

    self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(Width,HeaderH)

	local HStart = HeaderH+5
	self.PlayerList:SetPos(5,HStart)
	self.PlayerList:SetSize(Width*0.25+15, Height-HeaderH-10)

	self.InformationPanel:SetPos(Width*0.25+10,HStart)
	self.InformationPanel:SetSize(Width*0.75+15,Height-HeaderH-10)

	local ButtonH = 5
	for k,v in pairs(self.ButtonTBL) do
		v:SetPos(5,ButtonH)
		v:SetSize(self.PlayerList:GetWide()-25, 25)

		ButtonH = ButtonH + 30
	end

	self.CloseButton:SetPos(Width-HeaderH,HeaderH/2-9)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("fa_ins_management", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self.Name = ""
	self.Image = 1
	self.Desc = ""
	self.Price = 0

	self.TButton = vgui.Create("fa_button", self)
	self.TButton.Paint = function(selfp, W,H)
		if LocalPlayer():FAPassedPractical(self.Image) then
			surface.SetDrawColor(200,200,200, 255)
			surface.SetMaterial(HasLMat)
			surface.DrawTexturedRect(0,0,15,15)
		else
			draw.RoundedBox(4, 0, 0, W, H, selfp.BColor)
			draw.SimpleText(selfp.ButtonText, self.Font, W/2, H/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
end

function PANEL:SetTInfo(L)
	local LTbl = FALICENSE_DATABASE[L]
	self.Name = LTbl.Name
	self.Image = L
	self.Desc = LTbl.Desc
	self.Price = LTbl.PracticalCost

	if LocalPlayer():FAPassedPractical(self.Image) then
		self.TButton:SetEnabled(false)
	else
		self.TButton:SetBText("$" .. self.Price)
		self.TButton.DoClick = function() if !LocalPlayer():canAfford(self.Price) then LocalPlayer():ChatPrint(FA_GetLang("CantAffordTest")) return end net.Start("fa_start_practical_test") net.WriteFloat(L) net.SendToServer() end
	end
end

function PANEL:Paint(W,H)
	draw.SimpleText(self.Name, "fa_licensetext", 5, H/2, Color(0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText(self.Desc, "fa_choose_text", H*2+35, H/2, Color(0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.SetDrawColor(255,255,255, 255)
	surface.SetMaterial(FetchLicenseIcon(self.Image))
	surface.DrawTexturedRect(25, 0, H*2, H)
end

function PANEL:PerformLayout(W,H)
	local ButtonW,ButtonH = 55,H/2
	self.TButton:SetSize(50,ButtonH)
	if LocalPlayer():FAPassedPractical(self.Image) then
		self.TButton:SetPos(W-(ButtonW/2)-22.5,ButtonH/2)
	else
		self.TButton:SetPos(W-ButtonW-15,ButtonH/2)
	end
end
vgui.Register("fa_choose_ptest", PANEL)

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle("")
	self:MakePopup()

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)
		draw.SimpleText(FA_GetLang("PracticalTestChooseTest"), "fa_paneltext", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.TheoryList = vgui.Create("DScrollPanel", self)
	self.TheoryList.Paint = function(selfp, W, H)
		W = W - 15
		draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, LicenseListColor)
	end
	self.TheoryList.Licenses = {}
	self.TheoryList.VBar.Paint = function() end
	self.TheoryList.VBar.btnUp.Paint = function() end
    self.TheoryList.VBar.btnDown.Paint = function() end
	self.TheoryList.VBar.btnGrip.Paint = function() end

	for k,v in pairs(FALICENSE_DATABASE) do
		local License = vgui.Create("fa_choose_ptest", self.TheoryList)
		License:SetTInfo(k)
		self.TheoryList.Licenses[k] = License
	end

	self.CloseButton = vgui.Create("fa_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, MainPanelColor,false,false,true,true)
end

local Width, Height = 400, 500
function PANEL:PerformLayout()
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

    self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(Width,HeaderH)

	self.TheoryList:SetSize(Width+5, Height-10)
	self.TheoryList:SetPos(5, 5)

	local LicenseH = 30
	for k,v in pairs(self.TheoryList.Licenses) do
		v:SetPos(0,LicenseH)
		v:SetSize(Width+5, 35)

		LicenseH = LicenseH + 40
	end

	self.CloseButton:SetPos(Width-HeaderH,HeaderH/2-9)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("fa_practical_choose", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self.Player = LocalPlayer()
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:SetTitle("")
	self:MakePopup()
	self.LSelected = nil

	self.LicenseList = vgui.Create("DScrollPanel", self)
	self.LicenseList.Licenses = {}
	self.LicenseList.VBar.Paint = function() end
	self.LicenseList.VBar.btnUp.Paint = function() end
    self.LicenseList.VBar.btnDown.Paint = function() end
	self.LicenseList.VBar.btnGrip.Paint = function() end

	self.LApply = vgui.Create("DComboBox", self)
	self.LApply:SetValue("None" )

	self.LIDs = {}
	for k,v in pairs(FALICENSE_DATABASE) do
		local License = vgui.Create("fa_license", self.LicenseList)
		License:SetLInfo(k)
		self.LicenseList.Licenses[k] = License

		self.LApply:AddChoice(v.Name)
		self.LIDs[v.Name] = k
	end

	self.RCButton = vgui.Create("fa_button", self)
	self.RCButton.HasL = false
	self.RCButton.Paint = function(selfp, W,H)
		if selfp.GotL then
			surface.SetDrawColor(200,200,200, 255)
		else
			surface.SetDrawColor(0,0,0, 255)
		end
		if selfp.HasL then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(0,0,W,H)
	end

	self.RSButton = vgui.Create("fa_button", self)
	self.RSButton.HasL = false
	self.RSButton.Paint = function(selfp, W,H)
		if selfp.GotL then
			surface.SetDrawColor(200,200,200, 255)
		else
			surface.SetDrawColor(0,0,0, 255)
		end
		if selfp.HasL then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(0,0,W,H)
	end

	self.SignB = vgui.Create("fa_button", self)
	self.SignB:SetBText(FA_GetLang("SignApp"))
	self.SignB:SetBFont("fa_app_sign")
	self.SignB.Paint = function(selfp, W, H) draw.SimpleText(selfp.ButtonText, selfp.Font, W/2, H/2, selfp.BColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  end
	self.SignB.DoClick = function()
		if !self.LSelected then return end
		local Carry = self.RCButton.HasL
		local Sell = self.RSButton.HasL
		if self.RCButton.GotL then
			Carry = false
		end
		if self.RSButton.GotL then
			Sell = false
		end
		if !Carry and !Sell then return end

		net.Start("fa_application_request_send")
			net.WriteFloat(self.LSelected)
			net.WriteBool(Carry)
			net.WriteBool(Sell)
		net.SendToServer()
		self:Remove()
	end

	self.CloseButton = vgui.Create("fa_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.Paint = function(selfp, W, H) draw.SimpleText(selfp.ButtonText, selfp.Font, W/2, H/2, selfp.BColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  end
	self.CloseButton.DoClick = function() self:Remove() end

	self:UpdateFA_Licenses()
end

function PANEL:UpdateFA_Licenses()
	local Player = self.Player

	for k,v in pairs(self.LicenseList.Licenses) do
		v.TButton.HasL = TBFY_SH:PlayerHasTheory(TBFY_SH:SID(Player), v.TheoryTest, k)
		v.PButton.HasL = Player:FAPassedPractical(k)
		v.CButton.HasL = Player:FACanCarry(k)
		v.SButton.HasL = Player:FACanSell(k)
	end

	self.LApply.OnSelect = function( panel, index, value )
		self.LSelected = self.LIDs[value]
		if Player:FACanCarry(self.LSelected) then
			self.RCButton.HasL = true
			self.RCButton.GotL = true
		else
			self.RCButton.HasL= false
			self.RCButton.GotL = false
			self.RCButton.DoClick = function()
				self.RCButton.HasL = !self.RCButton.HasL
			end
		end
		if Player:FACanSell(self.LSelected) then
			self.RSButton.HasL = true
			self.RSButton.GotL = true
		else
			self.RSButton.HasL = false
			self.RSButton.GotL = false
			self.RSButton.DoClick = function()
				self.RSButton.HasL = !self.RSButton.HasL
			end
		end
	end
end

local Frame = Material("fa_form.png")
function PANEL:Paint(W,H)
	surface.SetMaterial(Frame)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, W, H)

	draw.SimpleText(FA_GetLang("ApplicationHeadline"), "fa_app_headline", W/2, 25, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	local Player = self.Player
	surface.SetDrawColor(0, 0, 0, 255)
	surface.SetFont("fa_app_subhead")
	surface.DrawOutlinedRect( 15, 50, W-30, 30)
	draw.SimpleText(FA_GetLang("AppName"), "fa_app_subhead", 20, 60, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	local TW = surface.GetTextSize(FA_GetLang("AppName"))
	draw.SimpleText(Player:Nick(), "fa_app_text", 20 + TW, 65, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.DrawOutlinedRect( 15, 85, W-30, 30)
	draw.SimpleText("SteamID:", "fa_app_subhead", 20, 95, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	TW = surface.GetTextSize("SteamID:")
	draw.SimpleText(LocalPlayer():SteamID(), "fa_app_text", 20 + TW, 100, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.DrawOutlinedRect( 15, 120, W-30, 30)
	draw.SimpleText(FA_GetLang("AppOccupation"), "fa_app_subhead", 20, 130, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(FA_GetLang("AppOccupation"))
	draw.SimpleText(LocalPlayer():getDarkRPVar("job"), "fa_app_text", 20 + TW, 135, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.DrawOutlinedRect( 15, H-45, 265, 30)
	draw.SimpleText(FA_GetLang("YourSignature"), "fa_app_subhead", 20, H-35, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	draw.SimpleText(FA_GetLang("License"), "fa_app_subhead", 15, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("Theory"), "fa_app_subhead", 150, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("Practical"), "fa_app_subhead", 220, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("CanCarry"), "fa_app_subhead", 290, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("CanSell"), "fa_app_subhead", 350, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	surface.DrawOutlinedRect( 15, 375, W-30, 30)
	draw.SimpleText(FA_GetLang("ApplyLicense"), "fa_app_subhead", 20, 385, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	draw.SimpleText(FA_GetLang("Carry"), "fa_app_subhead", 290, 385, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("Sell"), "fa_app_subhead", 350, 385, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

local Width, Height = 400, 550
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.LicenseList:SetPos(15, 175)
	self.LicenseList:SetSize(W-15,200)

	local WA = self.LicenseList:GetWide()
	local LicenseH = 0
	for k,v in pairs(self.LicenseList.Licenses) do
		v:SetPos(0,LicenseH)
		v:SetSize(WA, 35)

		LicenseH = LicenseH + 40
	end

	surface.SetFont("fa_app_subhead")
	local TW = surface.GetTextSize(FA_GetLang("ApplyLicense"))

	self.LApply:SetPos(15 + TW, 380)
	self.LApply:SetSize(50,20)

	self.RCButton:SetPos(W-110, 380)
	self.RCButton:SetSize(20,20)

	self.RSButton:SetPos(W-50, 380)
	self.RSButton:SetSize(20,20)

	self.SignB:SetPos(105, H-40)
	self.SignB:SetSize(110,20)

	self.CloseButton:SetPos(Width-25,5)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("fa_application_request_menu", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:SetTitle("")
	self:MakePopup()
	self.ButtonTBL = {}

	self.PlayerList = vgui.Create("DScrollPanel", self)
	self.PlayerList.VBar.Paint = function() end
	self.PlayerList.VBar.btnUp.Paint = function() end
    self.PlayerList.VBar.btnDown.Paint = function() end
	self.PlayerList.VBar.btnGrip.Paint = function() end

	self.CloseButton = vgui.Create("fa_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.Paint = function(selfp, W, H) draw.SimpleText(selfp.ButtonText, selfp.Font, W/2, H/2, selfp.BColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  end
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:SetPNicks(NickTbl)
	for k,v in pairs(NickTbl) do
		local CButton = vgui.Create("fa_button", self.PlayerList)
		CButton:SetBText(v)
		CButton:SetBFont("fa_app_plist")
		CButton:SetBColors(Color(100,100,100,255), Color(130,130,130,255), Color(57,57,57,255))
		CButton.Paint = function(selfp, W, H) draw.SimpleText(selfp.ButtonText, selfp.Font, W/2, H/2, selfp.BColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  end
		CButton.DoClick = function() net.Start("fa_application_request_examine_info") net.WriteString(k) net.SendToServer() self:Remove() end

		self.ButtonTBL[k] = CButton
	end
end

local Frame = Material("fa_applist.png")
function PANEL:Paint(W,H)
	surface.SetMaterial(Frame)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, W, H)

	draw.SimpleText(FA_GetLang("AppExaminePList"), "fa_app_pheadline", W/2, 30, Color( 130, 130, 130, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

local Width, Height = 400, 600
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.PlayerList:SetPos(5, 55)
	self.PlayerList:SetSize(W+5, H-60)

	local ButtonH = 5
	for k,v in pairs(self.ButtonTBL) do
		surface.SetFont("fa_app_plist")
		local TW = surface.GetTextSize(v.ButtonText)

		v:SetPos(W/2-TW/2,ButtonH)
		v:SetSize(TW, 20)

		ButtonH = ButtonH + 25
	end

	self.CloseButton:SetPos(Width-25,5)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("fa_application_examine_menu", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self.Player = LocalPlayer()
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:SetTitle("")
	self:MakePopup()
	self.LID = 1
	self.LName = ""
	self.Nick = ""
	self.SID = ""

	self.LicenseList = vgui.Create("DScrollPanel", self)
	self.LicenseList.Licenses = {}
	self.LicenseList.VBar.Paint = function() end
	self.LicenseList.VBar.btnUp.Paint = function() end
    self.LicenseList.VBar.btnDown.Paint = function() end
	self.LicenseList.VBar.btnGrip.Paint = function() end

	for k,v in pairs(FALICENSE_DATABASE) do
		local License = vgui.Create("fa_license", self.LicenseList)
		License:SetLInfo(k)
		self.LicenseList.Licenses[k] = License
	end

	self.RCButton = vgui.Create("fa_button", self)
	self.RCButton.HasL = false
	self.RCButton.Paint = function(selfp, W,H)
		if selfp.GotL then
			surface.SetDrawColor(200,200,200, 255)
		else
			surface.SetDrawColor(0,0,0, 255)
		end
		if selfp.HasL then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(0,0,W,H)
	end

	self.RSButton = vgui.Create("fa_button", self)
	self.RSButton.HasL = false
	self.RSButton.Paint = function(selfp, W,H)
		if selfp.GotL then
			surface.SetDrawColor(200,200,200, 255)
		else
			surface.SetDrawColor(0,0,0, 255)
		end
		if selfp.HasL then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(0,0,W,H)
	end

	self.ApproveButton = vgui.Create("fa_button", self)
	self.ApproveButton:SetBColors(Color(0,255,0,255), Color(0,255,0,225), Color(255,255,255,0))
	self.ApproveButton.Paint = function(selfp, W, H)
		surface.SetDrawColor(selfp.BColor)
		surface.DrawRect(1,1,W-2,H-2)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0,0,W,H)
	end

	self.DisapproveButton = vgui.Create("fa_button", self)
	self.DisapproveButton:SetBColors(Color(255,0,0,255), Color(255,0,0,225), Color(255,255,255,0))
	self.DisapproveButton.Paint = function(selfp, W, H)
		surface.SetDrawColor(selfp.BColor)
		surface.DrawRect(1,1,W-2,H-2)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0,0,W,H)
	end

	self.CloseButton = vgui.Create("fa_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.Paint = function(selfp, W, H) draw.SimpleText(selfp.ButtonText, selfp.Font, W/2, H/2, selfp.BColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )  end
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:SetPInfo(App)
	if !IsValid(App.Player) then return end

	self.Player = App.Player
	self.LID = App.LID
	self.Nick = App.Nick
	self.LName = FALICENSE_DATABASE[self.LID].Name
	local Player = self.Player
	self.SID = TBFY_SH:SID(Player)

	for k,v in pairs(self.LicenseList.Licenses) do
		v.TButton.HasL = TBFY_SH:PlayerHasTheory(self.SID, v.TheoryTest, k)
		v.PButton.HasL = Player:FAPassedPractical(k)
		v.CButton.HasL = Player:FACanCarry(k)
		v.SButton.HasL = Player:FACanSell(k)
	end

	if Player:FACanCarry(self.LID) then
		self.RCButton.HasL = true
		self.RCButton.GotL = true
	else
		self.RCButton.HasL = App.Carry
		self.RCButton.GotL = false
	end
	if Player:FACanSell(self.LID) then
		self.RSButton.HasL = true
		self.RSButton.GotL = true
	else
		self.RSButton.HasL = App.Sell
		self.RSButton.GotL = false
	end

	self.ApproveButton.DoClick = function() net.Start("fa_application_action") net.WriteString(self.SID) net.WriteBool(true) net.SendToServer() self:Remove() end
	self.DisapproveButton.DoClick = function() net.Start("fa_application_action") net.WriteString(self.SID) net.WriteBool(false) net.SendToServer() self:Remove() end
end

function PANEL:Paint(W,H)
	surface.SetMaterial(Frame)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, W, H)

	draw.SimpleText(FA_GetLang("ApplicationHeadline"), "fa_app_headline", W/2, 25, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	local Player = self.Player
	surface.SetDrawColor(0, 0, 0, 255)
	surface.SetFont("fa_app_subhead")
	surface.DrawOutlinedRect( 15, 50, W-30, 30)
	draw.SimpleText(FA_GetLang("AppName"), "fa_app_subhead", 20, 60, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	local TW = surface.GetTextSize(FA_GetLang("AppName"))
	draw.SimpleText(Player:Nick(), "fa_app_text", 20 + TW, 65, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.DrawOutlinedRect( 15, 85, W-30, 30)
	draw.SimpleText("SteamID:", "fa_app_subhead", 20, 95, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	TW = surface.GetTextSize("SteamID:")
	draw.SimpleText(LocalPlayer():SteamID(), "fa_app_text", 20 + TW, 100, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.DrawOutlinedRect( 15, 120, W-30, 30)
	draw.SimpleText(FA_GetLang("AppOccupation"), "fa_app_subhead", 20, 130, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(FA_GetLang("AppOccupation"))
	draw.SimpleText(LocalPlayer():getDarkRPVar("job"), "fa_app_text", 20 + TW, 135, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.DrawOutlinedRect( 15, H-75, 260, 30)
	draw.SimpleText(FA_GetLang("Signature"), "fa_app_subhead", 20, H-65, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(FA_GetLang("Signature"))
	draw.SimpleText(self.Nick, "fa_app_text", 15 + TW, H-60, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	draw.SimpleText(FA_GetLang("License"), "fa_app_subhead", 15, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("Theory"), "fa_app_subhead", 150, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("Practical"), "fa_app_subhead", 220, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("CanCarry"), "fa_app_subhead", 290, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("CanSell"), "fa_app_subhead", 350, 160, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	surface.DrawOutlinedRect( 15, 375, W-30, 30)
	draw.SimpleText(FA_GetLang("ApplyLicense"), "fa_app_subhead", 20, 385, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	TW = surface.GetTextSize(FA_GetLang("ApplyLicense"))
	draw.SimpleText(self.LName, "fa_app_text", 15 + TW, 390, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	draw.SimpleText(FA_GetLang("Carry"), "fa_app_subhead", 290, 385, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("Sell"), "fa_app_subhead", 350, 385, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	draw.SimpleText(FA_GetLang("AppApprove"), "fa_app_subhead", 45, H-27.5, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(FA_GetLang("AppDisapprove"), "fa_app_subhead", 150, H-27.5, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local Width, Height = 400, 550
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.LicenseList:SetPos(15, 175)
	self.LicenseList:SetSize(W-15,200)

	local WA = self.LicenseList:GetWide()
	local LicenseH = 0
	for k,v in pairs(self.LicenseList.Licenses) do
		v:SetPos(0,LicenseH)
		v:SetSize(WA, 35)

		LicenseH = LicenseH + 40
	end

	surface.SetFont("fa_app_subhead")
	local TW = surface.GetTextSize(FA_GetLang("ApplyLicense"))

	self.RCButton:SetPos(W-110, 380)
	self.RCButton:SetSize(20,20)

	self.RSButton:SetPos(W-50, 380)
	self.RSButton:SetSize(20,20)

	self.ApproveButton:SetPos(15, H-40)
	self.ApproveButton:SetSize(25, 25)

	self.DisapproveButton:SetPos(120, H-40)
	self.DisapproveButton:SetSize(25, 25)

	self.CloseButton:SetPos(Width-25,5)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("fa_application_examine_player", PANEL, "DFrame")

local FAMat = Material("fa_licenseframe.png")
local PANEL = {}

function PANEL:Init()
	self.Player = nil
	self.PIcon = vgui.Create("ModelImage", self)
	self.PIcon:SetPos(19,62)
	self.PIcon:SetSize(115,128)
end

function PANEL:InitData(Player, Parent, ID)
	if IsValid(Player) then
		self.Player = Player
		self.PIcon:SetModel(Player:GetModel())
	end
end

function PANEL:Paint(W,H)
	surface.SetMaterial(FAMat)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, W, 220)

	draw.SimpleText(FA_GetLang("Carry"), "firearms_license_text", W-90+15/2, 70, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(FA_GetLang("Sell"), "firearms_license_text", W-45+15/2, 70, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

	local HStart = 70
	for k,v in pairs(FALICENSE_DATABASE) do
		surface.SetDrawColor(200,200,200, 255)
		if IsValid(self.Player) and self.Player:FACanCarry(k) then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(W-90,HStart+15/3,15,15)

		surface.SetDrawColor(200,200,200, 255)
		if IsValid(self.Player) and self.Player:FACanSell(k) then
			surface.SetMaterial(HasLMat)
		else
			surface.SetMaterial(NoLMat)
		end
		surface.DrawTexturedRect(W-45,HStart+15/3,15,15)

		surface.SetDrawColor(255,255,255, 255)
		surface.SetMaterial(FetchLicenseIcon(k))
		surface.DrawTexturedRect(W-165, HStart, 50, 25)
		HStart = HStart + 27
	end
end
vgui.Register("tbfy_archive_firearmslicense", PANEL)
