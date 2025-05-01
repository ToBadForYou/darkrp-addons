
TBFY_SH.PC_INFO = TBFY_SH.PC_INFO or {}

net.Receive("tbfy_comp_login", function()
	local SID, PC, CorrectPW = net.ReadString(), net.ReadEntity(), net.ReadBool()
	if IsValid(PC) and CorrectPW then
		local Avatar, Wallpaper, TimeType, Username = net.ReadString(), net.ReadString(), net.ReadFloat(), net.ReadString()
		local ASoft, LoginS = net.ReadFloat(), TBFY_LastPCUI
		LocalPlayer().TBFY_Comp = {SID = SID, PC = PC, Software = {}, PCType = PC:GetPCType()}

		TBFY_LastPCUI = vgui.Create("tbfy_computer_desktop")
		for i = 1, ASoft do
			local SoftID = net.ReadString()
			if TBFY_SH.CSoftwares[SoftID] then
				TBFY_LastPCUI:AddSoftware(SoftID)
			end
		end

		if IsValid(TBFY_LastPCUI) then
			TBFY_LastPCUI:UpdateCData(Avatar, Wallpaper, TimeType, Username)
		end
		timer.Simple(.5, function()
			if IsValid(LoginS) then LoginS:Remove() end
		end)
	else
		TBFY_LastPCUI:IncorrectPW()
	end
end)

net.Receive("tbfy_comp_loginscreen", function()
	local PCType = net.ReadFloat()

	TBFY_LastPCUI = vgui.Create("tbfy_computer_loginscreen")
	if PCType == 1 then
		local Logo = net.ReadString()
		TBFY_LastPCUI:SetGovPC(Logo)
	else
		local AccountsA = net.ReadFloat()
		TBFY_LastPCUI:SetupNonGovPC()
		for i = 1, AccountsA do
			local SID, UN, Av = net.ReadString(), net.ReadString(), net.ReadString()
			TBFY_LastPCUI:AddAccount(SID,UN, Av)
		end
	end
end)

net.Receive("tbfy_computer_cmd", function()
	if IsValid(TBFY_CMDW) then
		local Executeable, Command, DAmount = net.ReadString(), net.ReadString(), net.ReadFloat()
		local Data = {}
		for i = 1, DAmount do
			Data[i] = net.ReadString()
		end

		TBFY_CMDW:ServerResponse(Executeable, Command, Data)
	end
end)

net.Receive("tbfy_computer_updateentities", function()
	local ID = net.ReadString()
	local TblA = net.ReadFloat()
	local Data = {}
	for i = 1, TblA do
		local Type = net.ReadString()
		local EntA = net.ReadFloat()
		Data[Type] = {}
		for E = 1, EntA do
			table.insert(Data[Type], net.ReadEntity())
		end
	end
	TBFY_LastPCUI:UpdateSoftware(ID, Data)
end)

net.Receive("tbfy_toggle_software", function()
	local ID, SoftwareID, Toggle = net.ReadString(), net.ReadString(), net.ReadBool()
	local Input = {SoftID = SoftwareID, Toggle = Toggle}

	TBFY_LastPCUI:UpdateSoftware(ID, Input)
	if Toggle then
		TBFY_LastPCUI:AddSoftware(SoftwareID)
	else
		TBFY_LastPCUI:RemoveSoftware(SoftwareID)
	end
end)

local Derma = TBFY_SH.Config.Derma

local GTick, RErr, Gradient = Material("tobadforyou/tbfy_tick.png"), Material("tobadforyou/tbfy_error.png"), Material("vgui/gradient-d")
local GSize, ISize, Padding, TPad, THStart = 42, 32, 5, 30, 32
local OutlineC = Color(0,0,0,255)
local LArrow = Material("tobadforyou/tbfy_comp_logina.png", "smooth")
local StartI = Material("tobadforyou/tbfy_computer_start.png", "smooth")
local CMD = Material("tobadforyou/tbfy_options.png", "smooth")
local LBoxW, LBW = 175, 23
local Padd = 5
local CBG = Material("tobadforyou/tbfy_computer_bg.png")
local GovMat = Material("tobadforyou/tbfy_computer_governmentpc.png", "smooth")
local GovS = 240
local TimeTypes = {
	[1] = {TextFormat = "00-24, Minute/Month/Year", Format = "%H:%M-%d/%m/%Y"},
	[2] = {TextFormat = "00-24, Month/Minute/Year", Format = "%H:%M-%m/%d/%Y"},
	[3] = {TextFormat = "00-12 AM/PM, Minute/Month/Year", Format = "%I:%M %p-%d/%m/%Y"},
	[4] = {TextFormat = "00-12 AM/PM, Month/Minute/Year", Format = "%I:%M %p-%m/%d/%Y"},
}

function TBFY_SH:FindSoftID(Panel)
	if Panel.SoftID then
		return Panel.SoftID
	elseif Panel:GetParent() then
		return TBFY_SH:FindSoftID(Panel:GetParent())
	else
		return false
	end
end

local PANEL = {}

function PANEL:Init()
	local CurrD = TBFY_SH.PC_INFO

	self.UserN = vgui.Create("DTextEntry", self)
	self.UserN:SetPlaceholderText(CurrD.Username)
	self.UserN:SetDrawBackground(false)
	self.UserN:SetDrawBorder(false)
	self.UserN:SetFont("tbfy_computer_programtitle")

	self.Wallpaper = vgui.Create("tbfy_imgur", self)
	self.Wallpaper:SetImgurID(CurrD.Wallpaper)

	self.WallpaperID = vgui.Create("DTextEntry", self)
	self.WallpaperID:SetPlaceholderText("Imgur ID")

	self.WPButton = vgui.Create("tbfy_button", self)
	self.WPButton:SetBText("Set")
	self.WPButton.DoClick = function()
		if self.WallpaperID:GetValue() != "" then
			self.Wallpaper:SetImgurID(self.WallpaperID:GetValue())
		end
	end

	self.Avatar = vgui.Create("tbfy_CircularAvatar", self)
	self.Avatar:SetImgurID(CurrD.Avatar)

	self.AvatarID = vgui.Create("DTextEntry", self)
	self.AvatarID:SetPlaceholderText("Imgur ID")

	self.AvButton = vgui.Create("tbfy_button", self)
	self.AvButton:SetBText("Set")
	self.AvButton.DoClick = function()
		if self.AvatarID:GetValue() != "" then
			self.Avatar:SetImgurID(self.AvatarID:GetValue())
		end
	end

	self.TimeType = vgui.Create("DComboBox", self)
	for k,v in ipairs(TimeTypes) do
		self.TimeType:AddChoice(v.TextFormat)
	end
	self.TimeType:ChooseOptionID(CurrD.TimeType)

	self.TopFrame = vgui.Create("tbfy_comp_dpanel", self)
	self.TopFrame:SetTitle("Account Customization", false)

	self.SaveSettings = vgui.Create("tbfy_button", self)
	self.SaveSettings:SetBText(TBFY_GetLang("SaveSettings"))
	self.SaveSettings:SetBFont("tbfy_computer_window_letters")
	self.SaveSettings:SetBoxColor(Color(20,20,20,255), Color(20,20,20,240), Color(20,20,20,230))
	self.SaveSettings.DoClick = function()
		local WP, AV, TT, UN = self.WallpaperID:GetValue(), self.AvatarID:GetValue(), self.TimeType:GetSelectedID(), self.UserN:GetValue()
		if WP != "" then
			self:GetParent().Wallpaper:SetImgurID(self.WallpaperID:GetValue())
		end
		if AV != "" then
			self.MenuAvatar:SetImgurID(self.AvatarID:GetValue())
		end
		if TT != 0 then
			self:GetParent().TimeType = TT
		end

		net.Start("tbfy_computer_run")
			net.WriteString("")
			net.WriteString("AccountDetails")
			net.WriteString(WP)
			net.WriteString(AV)
			net.WriteFloat(TT or 1)
			net.WriteString(UN)
		net.SendToServer()
	end
end

local Width, Height = 300, 445
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	local HStart = Derma.HeaderH

	self.UserN:SetPos(5,5+Derma.HeaderH)
	self.UserN:SetSize(W-10,25)
	HStart = HStart + 25

	self.Avatar:SetPos(5,HStart)
	self.Avatar:SetSize(125,125)

	local AvW, AvH = self.Avatar:GetWide(), self.Avatar:GetTall()+5

	self.AvatarID:SetPos(5,HStart+AvH-5)
	self.AvatarID:SetSize(AvW*0.8,20)

	self.AvButton:SetPos(5+AvW*0.8,HStart+AvH-5)
	self.AvButton:SetSize(AvW*0.2, 20)

	self.TimeType:SetPos(10+AvW, HStart+AvH-5)
	self.TimeType:SetSize(W-15-AvW, 20)

	self.Wallpaper:SetPos(5,HStart+148)
	self.Wallpaper:SetSize(Width - 10,200)

	local WPW, WPH = self.Wallpaper:GetWide(), self.Wallpaper:GetTall()+1

	self.WallpaperID:SetPos(5,HStart+WPH+148)
	self.WallpaperID:SetSize(WPW*0.8,20)

	self.WPButton:SetPos(5+WPW*0.8,HStart+WPH+148)
	self.WPButton:SetSize(WPW*0.2, 20)

	self.TopFrame:SetSize(W-4,Derma.HeaderH)
	self.TopFrame:SetPos(2,2)

	self.SaveSettings:SetPos(5,H-25)
	self.SaveSettings:SetSize(W-10, 20)
end

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 2, 2, W-4, H-4, Derma.CProgramBG)

	--draw.SimpleText("Wallpaper", "tbfy_header", 205/2, Derma.HeaderH+5, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	--draw.SimpleText("Avatar", "tbfy_header", 210+205/2, Derma.HeaderH+5, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_setup_profile", PANEL)

local PANEL = {}

function PANEL:Init()
	self.PC = LocalPlayer().TBFY_Comp.PC

	self.ToggleFirewall = vgui.Create("tbfy_button_toggle", self)
	self.ToggleFirewall:SetSliderInfo(12, 0.17)
	self.ToggleFirewall:SetBMode(true)
	self.ToggleFirewall:SetToggleInfo("ON", Derma.WColor, Derma.GBGColor, "OFF", Derma.WColor, Derma.RBGColor, "GetFirewall", self.PC:GetFirewall(), true)
	self.ToggleFirewall:SetServerCheck(self.PC, nil)
	self.ToggleFirewall.DoClick = function() net.Start("tbfy_computer_run") net.WriteString("") net.WriteString("ToggleFalkwall") net.SendToServer() end

	if LocalPlayer().TBFY_Comp.PCType == 1 then
		self.ResetIP = vgui.Create("tbfy_button", self)
		self.ResetIP:SetBText("Reset IP")
		self.ResetIP.DoClick = function() net.Start("tbfy_computer_run") net.WriteString("") net.WriteString("ResetIP") net.SendToServer() end

		self.ResetPW = vgui.Create("tbfy_button", self)
		self.ResetPW:SetBText("Reset Password")
		self.ResetPW.DoClick = function() net.Start("tbfy_computer_run") net.WriteString("") net.WriteString("ResetPassword") net.SendToServer()end
	end
end

function PANEL:UpdateData(Data)
end

function PANEL:PerformLayout(W, H)
	local BSize = 80

	self.ToggleFirewall:SetPos(W-Padding*2-BSize, THStart+TPad-10)
	self.ToggleFirewall:SetSize(BSize,20)

	if IsValid(self.ResetIP) then
		self.ResetIP:SetPos(W-Padding*2-BSize, THStart+TPad*2-10)
		self.ResetIP:SetSize(BSize,20)
	end

	if IsValid(self.ResetPW) then
		self.ResetPW:SetPos(W-Padding*2-BSize, THStart+TPad*3-10)
		self.ResetPW:SetSize(BSize, 20)
	end
end

function PANEL:Paint(W, H)
	local FMode = true
	local IP = ""
	local PC = self.PC
	if IsValid(PC) then
		FMode = PC:GetFirewall()
		IP = PC:GetIP()
	end

	local Mat = GTick
	local Status = "Online"
	local FCol, GColor = Color(0,200,0,255), Color(0,100,0,255)
	if !FMode then
		Mat = RErr
		Status = "Offline"
		FCol, GColor = Color(200,0,0,255), Color(100,0,0,255)
	end
	surface.SetDrawColor(GColor)
	surface.DrawRect(Padding, Padding, GSize, GSize)
	surface.SetMaterial(Gradient)
	surface.SetDrawColor(FCol)
	surface.DrawTexturedRect(Padding, Padding, GSize, GSize)

	surface.SetMaterial(Mat)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(GSize+Padding*2, Padding*2, ISize, ISize)
	draw.SimpleText("Private Network", "tbfy_computer_firewall_title", GSize+ISize+Padding*4, ISize/2+Padding*2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("CONNECTED", "tbfy_computer_firewall_title", W-Padding*2, ISize/2+Padding*2, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	surface.SetDrawColor(OutlineC)
	surface.DrawOutlinedRect(Padding,Padding,W-10,GSize)
	surface.DrawOutlinedRect(Padding,Padding,W-10,H-10)

	draw.SimpleText("Falkwall State: " .. Status, "tbfy_computer_firewall", 15, THStart+TPad, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("IP Adress: " .. IP, "tbfy_computer_firewall", 15, THStart+TPad*2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("Password: ********", "tbfy_computer_firewall", 15, THStart+TPad*3, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end
vgui.Register("tbfy_comp_firewall", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Name = ""
	self.Icon = nil
	self.Desc = ""
end

function PANEL:SetSoftware(ID)
	local SData = TBFY_SH.CSoftwares[ID]
	self.Name = SData.Name
	self.Icon = SData.Icon
	self.Desc = SData.Desc

	self.DownloadB = vgui.Create("tbfy_button", self)
	self.DownloadB:SetBText("Install")
	self.DownloadB.DoClick = function()
		net.Start("tbfy_computer_run")
			net.WriteString("")
			net.WriteString("ToggleSoftware")
			net.WriteBool(true)
			net.WriteString(ID)
		net.SendToServer()
	end
end

function PANEL:SetInstalled()
	self.DownloadB:SetBText("Installed")
	self.DownloadB:SetDisabled(true)
end

function PANEL:SetUnInstalled()
	self.DownloadB:SetBText("Install")
	self.DownloadB:SetDisabled(false)
end

function PANEL:UpdateAction(Toggle)
	if Toggle then
		self:SetInstalled()
	else
		self:SetUnInstalled()
	end
end

function PANEL:PerformLayout(W, H)
	self.DownloadB:SetPos(W-60,H-30)
	self.DownloadB:SetSize(55,25)
end

function PANEL:Paint(W, H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 1, 1, W-2, H-2, Derma.SoftwareBorderColor)

	if self.Icon then
		surface.SetMaterial(self.Icon)
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(5, 5, H-10, H-10)
	end

	draw.SimpleText(self.Name, "tbfy_falkstore_title", W/2, 5, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText(self.Desc, "tbfy_falkstore_desc", W/2, H/2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
vgui.Register("tbfy_comp_falkstore_software", PANEL)

local PANEL = {}

function PANEL:Init()
	self.SoftwareList = vgui.Create("DScrollPanel", self)
	self.SoftwareList.Paint = function(selfp, W, H)
	end
	self.SoftwareList.VBar.Paint = function() end
	self.SoftwareList.VBar.btnUp.Paint = function() end
	self.SoftwareList.VBar.btnDown.Paint = function() end
	self.SoftwareList.VBar.btnGrip.Paint = function() end

	self.Softwares = {}
	local SoftwaresInstalled = LocalPlayer().TBFY_Comp.Software
	for k,v in pairs(TBFY_SH.CSoftwares) do
		if v.Downloadable then
			local Software = vgui.Create("tbfy_comp_falkstore_software", self.SoftwareList)
			Software:SetSoftware(k)
			if SoftwaresInstalled[k] then
				Software:SetInstalled()
			end
			self.Softwares[k] = Software
		end
	end
end

function PANEL:UpdateData(Data)
	if Data then
		local ID = Data.SoftID
		if self.Softwares[ID] then
			self.Softwares[ID]:UpdateAction(Data.Toggle)
		end
	end
end

function PANEL:PerformLayout(W, H)
	self.SoftwareList:SetPos(5,0)
	self.SoftwareList:SetSize(W+5,H-10)

	local HStart = 5
	for k,v in pairs(self.Softwares) do
		v:SetPos(0,HStart)
		v:SetSize(self.SoftwareList:GetWide()-15, 70)
		HStart = HStart + 75
	end
end

function PANEL:Paint(W, H)
	--draw.SimpleText("UNDER CONSTRUCTION", "tbfy_computer_firewall_title", W/2, H/2-50, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	--draw.SimpleText("WILL BE INCLUDED IN FUTURE UPDATES", "tbfy_computer_firewall_title", W/2, H/2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
vgui.Register("tbfy_comp_falkstore", PANEL)

local PANEL = {}

function PANEL:Init()
	self.MainP = self:GetParent()
	self.Dragged = false

	self:SetPaintBackground(true)

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)

	self.btnClose = vgui.Create("DButton", self)
	self.btnClose:SetText("")
	self.btnClose.DoClick = function(button) self.MainP:Remove() end
	self.btnClose.Paint = function(panel, w, h) derma.SkinHook("Paint", "WindowCloseButton", panel, w, h) end

	self.btnMaxim = vgui.Create("DButton", self)
	self.btnMaxim:SetText("")
	self.btnMaxim.DoClick = function(button) self.MainP:Remove() end
	self.btnMaxim.Paint = function(panel, w, h) derma.SkinHook("Paint", "WindowMaximizeButton", panel, w, h) end
	self.btnMaxim:SetDisabled(true)

	self.btnMinim = vgui.Create("DButton", self)
	self.btnMinim:SetText("")
	self.btnMinim.DoClick = function(button) self.MainP:Remove() end
	self.btnMinim.Paint = function(panel, w, h) derma.SkinHook("Paint", "WindowMinimizeButton", panel, w, h) end
	self.btnMinim:SetDisabled(true)
	self.btnMinim.MainP = self.MainP

	self.lblTitle = vgui.Create("DLabel", self)
	self.lblTitle:SetFont("tbfy_computer_programtitle")
end

function PANEL:ShowButtonsOnly()
	self.lblTitle:SetText("")
	self:SetPaintBackground(false)
end

function PANEL:SetMinimizeFunction(Func)
		self.btnMinim.DoClick = Func
		self.btnMinim:SetDisabled(false)
end

function PANEL:SetFont(Font)
	self.lblTitle:SetFont(Font)
end

function PANEL:SetTitle(Name, Center)
	self.lblTitle:SetText(Name)
	self.lblTitle:SizeToContents()
	self.TitleCentered = Center
end

function PANEL:SetIcon(str)
	if !IsValid(self.imgIcon) then
		self.imgIcon = vgui.Create( "DImage", self )
	end

	if IsValid(self.imgIcon) then
		self.imgIcon:SetMaterial(Material(str))
	end
end

function PANEL:Think()
	if self.Dragged and IsValid(self.MainP) and input.IsMouseDown(MOUSE_LEFT) then
		local MX, MY = gui.MouseX(), gui.MouseY()
		self.MainP:SetPos(MX - self.CX, MY - self.CY)
	elseif self.Dragged then
		self.Dragged = false
	end
end

function PANEL:OnMousePressed(keyCode)
	if keyCode == MOUSE_LEFT then
		self.CX, self.CY  = self:CursorPos()
		self.Dragged = true
		self.MainP:RequestFocus()
	end
end

function PANEL:OnMouseReleased(keyCode)
	if keyCode == MOUSE_LEFT then
		self.Dragged = false
	end
end

function PANEL:PerformLayout(W, H)
	local titlePush = 0
	local hasIcon = IsValid(self.imgIcon)

	if hasIcon then
		self.imgIcon:SetSize(16, 16)
		titlePush = 16
	end

	self.btnClose:SetPos(self:GetWide() - 31 - 4, 0)
	self.btnClose:SetSize( 31, 24 )

	self.btnMaxim:SetPos(self:GetWide() - 31 * 2 - 4, 0)
	self.btnMaxim:SetSize(31, 24)

	self.btnMinim:SetPos(self:GetWide() - 31 * 3 - 4, 0)
	self.btnMinim:SetSize(31, 24)

	local LabelWPos = 8 + titlePush
	local w, h = self.lblTitle:GetSize()
	if self.TitleCentered then
		LabelWPos = W/2-w/2+titlePush/2
	end
	if hasIcon then
		self.imgIcon:SetPos(LabelWPos - w/2 + 8 + titlePush/2, 5)
	end
	self.lblTitle:SetPos(LabelWPos, 4)
end
vgui.Register("tbfy_comp_dpanel", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self.TopFrame = vgui.Create("tbfy_comp_dpanel", self)
end

function PANEL:SetProgram(Name, UI, W, H, SoftID)
	if SoftID then
		self.SoftID = SoftID
	end

	if IsValid(self.Software) then
		self.Software:Remove()
	end

	self.TopFrame:SetTitle(Name, true)
	local func = function(selfp) selfp.MainP:SetVisible(false) end
	self.TopFrame:SetMinimizeFunction(func)

	self:SetSize(W,H)
	self.Name = Name

	local Parent = self:GetParent()
	self:SetPos(Parent:GetWide()/2-W/2, Parent:GetTall()/2-H/2)
	self.Software = vgui.Create(UI, self)
	self.Software:SetSize(W-6, H-Derma.HeaderH-8)
	self.Software:SetPos(3, Derma.HeaderH+5)
	self.Software.SoftID = SoftID
end

function PANEL:Paint(W, H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 2, 2, W-4, H-4, Derma.CProgramBG)
end

function PANEL:PerformLayout(W,H)
	self.TopFrame:SetSize(W-4,Derma.HeaderH)
	self.TopFrame:SetPos(2,2)
end

function PANEL:OnRemove()
	if IsValid(self.QBarIcon) then
		self.QBarIcon:Remove()
	end
end
vgui.Register("tbfy_comp_program", PANEL)

local PANEL = {}

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawRect(1,1,w-2,h-2)
	derma.SkinHook("Paint", "TextEntry", self, w, h)
	return false
end
vgui.Register("tbfy_comp_log", PANEL, "DTextEntry")

local PANEL = {}

local Shutdown = Material("tobadforyou/tbfy_comp_powerb.png", "smooth")
local Settings = Material("tobadforyou/tbfy_comp_settings.png", "smooth")
local IconS = 36
local Padding = 1
function PANEL:Init()
	self.ALogo = vgui.Create("tbfy_CircularAvatar", self)
	self.ALogo:SetImgurID()

	self.ProfileB = vgui.Create("tbfy_button", self)
	self.ProfileB:SetPicture(false, false, true, 0)
	self.ProfileB:SetBoxColor(Color(25, 25, 25, 0), Color(150, 150, 150, 100), Color(200, 200, 200, 100))
	self.ProfileB.DoClick = function()
		if !IsValid(self:GetParent().PSettings) then
			self:GetParent().PSettings = vgui.Create("tbfy_setup_profile", self:GetParent())
			self:GetParent().PSettings.MenuAvatar = self.ALogo
		end
	end

	self.Settings = vgui.Create("tbfy_button", self)
	self.Settings:SetPicture(Settings, false, true, 5)
	self.Settings:SetBoxColor(Color(25, 25, 25, 0), Color(150, 150, 150, 100), Color(200, 200, 200, 100))
	self.Settings.DoClick = function()
		if LocalPlayer():IsAdmin() then
			if !IsValid(self:GetParent().ASettings) then
				self:GetParent().ASettings = vgui.Create("tbfy_edit_computer", self:GetParent())
			end
		end
	end

	self.PowerOff = vgui.Create("tbfy_button", self)
	self.PowerOff:SetPicture(Shutdown, false, true, 5)
	self.PowerOff:SetBoxColor(Color(25, 25, 25, 0), Color(150, 150, 150, 100), Color(200, 200, 200, 100))
	self.PowerOff.DoClick = function()
		local Menu = DermaMenu()
		local Logout = Menu:AddOption("Logout", function() self:Logout() end)
		Logout:SetIcon("icon16/door_out.png")
		local Shutdown = Menu:AddOption("Shutdown", function() self:GetParent():Remove() end)
		Shutdown:SetIcon("icon16/exclamation.png")

		Menu:SetPos(self.PowerOff:GetPos())
		Menu:Open()
	end
end

function PANEL:Logout()
	net.Start("tbfy_logout")
	net.SendToServer()

	self:GetParent():Remove()
end

function PANEL:PerformLayout(W,H)
	self.ALogo:SetPos(2,H+2-IconS*3-Padding)
	self.ALogo:SetSize(IconS-4,IconS-4)

	self.ProfileB:SetPos(0,H-IconS*3-Padding)
	self.ProfileB:SetSize(IconS,IconS)

	self.Settings:SetPos(0,H-IconS*2-Padding)
	self.Settings:SetSize(IconS,IconS)

	self.PowerOff:SetPos(0,H-IconS-Padding)
	self.PowerOff:SetSize(IconS,IconS)
end

local CStartM = Material("vgui/gradient-l")
function PANEL:Paint(W, H)
	surface.SetDrawColor(0, 0, 0, 225)
	surface.DrawRect(0, 0, W, H)
	surface.SetMaterial(CStartM)
	surface.SetDrawColor(10, 10, 10, 200)
	surface.DrawTexturedRect(0, 0, W, H)
end
vgui.Register("tbfy_comp_startmenu", PANEL)

local AllowedExec = {
["hack.exe"] = {Start = function(Panel)
	Panel.Running = "hack.exe"
	Panel:AddTLines("Input IP adress and user ID to initialize hacking sequence: ", true)
end,
Input = function(Panel, Args)
	Panel.CurLine = Panel.CurLine + 1
	if Panel.Puzzle then
		local Solution = Args[1]
		net.Start("tbfy_computer_cmd")
			net.WriteString("hack.exe")
			net.WriteString("")
			net.WriteString("2")
			net.WriteString(Solution)
		net.SendToServer()
	else
		local IP, ID = Args[1], Args[2]
		Panel:AddTLines("Initializing hacking sequence for " .. IP or "")
		net.Start("tbfy_computer_cmd")
			net.WriteString("hack.exe")
			net.WriteString("")
			net.WriteString("1")
			net.WriteString(IP or "")
			net.WriteString(ID or "")
		net.SendToServer()
	end
end,
ServerResponse = function(Panel, Data)
	local Stage = Data[1]
	if Stage == "1" then
		local Puzzle = Data[2]
		if Puzzle != "" then
			Panel.Puzzle = true
			Panel:AddTLines(Puzzle)
			Panel:AddTLines("", true)
		else
			Panel.Running = nil
			Panel:AddTLines("Hacking Initialization failed! - " .. Data[3])
			Panel:AddTLines("")
			Panel:RootLine()
		end
	elseif Stage == "2" then
		local Puzzle, Complete = Data[2], Data[3]
		if Complete == "Yes" then
			Panel.Running = nil
			Panel:AddTLines("Hack Successful - Falkwall offline")
			Panel.Puzzle = false
			Panel:AddTLines("")
			Panel:RootLine()
		elseif Puzzle != "" then
			Panel:AddTLines(Puzzle)
			Panel:AddTLines("", true)
		else
			Panel.Running = nil
			Panel:AddTLines("Hack failed - Incorrect input")
			Panel.Puzzle = false
			Panel:AddTLines("")
			Panel:RootLine()
		end
	end
end
},
}
local DataTypes = {
["accounts"] = true,
["password"] = true,
}
local Commands = {
["commands"] = {Run = function(Panel)
	Panel:AddTLines("")
	Panel:AddTLines("Available Commands:")
	Panel:AddTLines("connect <IP>")
	Panel:AddTLines("execute <NAME.exe>")
	Panel:AddTLines("ipconfig")
	Panel:AddTLines("retrieve <DATA>")
	Panel:AddTLines("")
	Panel:RootLine()
end,
ServerResponse = function(Panel, Data)
end},
["ipconfig"] = {Run = function(Panel)
	net.Start("tbfy_computer_cmd")
		net.WriteString("")
		net.WriteString("ipconfig")
	net.SendToServer()
end,
ServerResponse = function(Panel, Data)
	Panel:AddTLines("")
	Panel:AddTLines("Connection Information:")
	Panel:AddTLines("  IPv6 Adress . . . . . . fe80::8d2c:54ad:7eeb:a6dc%13")
	Panel:AddTLines("  IPv4 Adress . . . . . . " .. Data[1])
	Panel:AddTLines("  Subnet Mask . . . . . . 255.255.255.0")
	Panel:AddTLines("  Default Gateway . . . . 192.168.0.1")
	Panel:AddTLines("")
	Panel:RootLine()
end},
["connect"] = {Run = function(Panel, Args)
	local IP = Args[2] or ""
	Panel:AddTLines("Attempting connection to " .. IP)
	net.Start("tbfy_computer_cmd")
		net.WriteString("")
		net.WriteString("connect")
		net.WriteString(IP)
	net.SendToServer()
end,
ServerResponse = function(Panel, Data)
	local CorrectIP = Data[1]
	if CorrectIP == "No" then
		Panel:AddTLines("Connection error - Invalid IP")
		Panel:AddTLines("")
		Panel:RootLine()
	else
		Panel.Connected = true
		Panel:AddTLines("Connection successful! - Connected")
		Panel:AddTLines("")
		Panel:RootLine()
	end
end},
["execute"] = {Run = function(Panel, Args)
	local Program = Args[2]
	if AllowedExec[Program] then
		AllowedExec[Program].Start(Panel)
	elseif Program then
		Panel:AddTLines("'" .. Program .. "' is not recognized as an executeable file")
		Panel:AddTLines("")
		Panel:RootLine()
	else
		Panel:RootLine()
	end
end,
ServerResponse = function(Panel, Data)
end},
["retrieve"] = {Run = function(Panel, Args)
	local DType, ID = Args[2], Args[3]
	if !Panel.Connected then
		Panel:AddTLines("Retrieving data error - Not connected")
		Panel:AddTLines("")
		Panel:RootLine()
	elseif DataTypes[DType] then
		Panel:AddTLines("Retrieving data: " .. DType)
		net.Start("tbfy_computer_cmd")
			net.WriteString("")
			net.WriteString("retrieve")
			net.WriteString(DType)
			if ID then
				net.WriteString(ID)
			end
		net.SendToServer()
	elseif DType then
		Panel:AddTLines("'" .. DType .. "' is not recognized as a data type")
		Panel:AddTLines("")
		Panel:RootLine()
	else
		Panel:RootLine()
	end
end,
ServerResponse = function(Panel, Data)
	local AccA = tonumber(Data[1])
	if AccA > 0 then
		local Num = 2
		local Tbl = {}
		for i = 1, AccA do
			local ID, UN, PW = Data[Num], Data[Num+1], Data[Num+2]
			Tbl[ID] = {UN = UN, PW = PW}
			Num = Num + 3
		end
		for k,v in pairs(Tbl) do
			Panel:AddTLines(" " .. k .. ". Username: " .. v.UN .. ", Password: " .. v.PW)
		end
	else
		Panel:AddTLines(Data[2])
	end
	Panel:AddTLines("")
	Panel:RootLine()
end}
}

local PANEL = {}

local CMDHead = 30
function PANEL:Init()
	TBFY_CMDW = self

	self:SetKeyboardInputEnabled(true)

	self.RLine = 0
	self.CurLine = 1
	self.TextHis = {}

	self.StartLine = true
	self.Typing = ""
end

function PANEL:SetupCMD()
	local Width, Height = ScrW()*0.35, ScrH()*0.4
	self:SetPos(5,5)
	self:SetSize(Width, Height)
	local Lines = math.floor((Height-CMDHead-1)/12)

	self.MaxLines = Lines
	self:AddTLines("Falk OS [Version 1.0.0]")
	self:AddTLines("Copyright 2019 Falk Studios. All rights reserved.")
	self:AddTLines("Type 'commands' for available commands")
	self:AddTLines("")
	self:RootLine()

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton:SetBFont("tbfy_computer_font_login")
	self.CloseButton:SetBoxColor(Color(255,255,255,0), Color(255,255,255,200), Color(255,255,255,255))
	self.CloseButton:SetBTextColor(Color(0,0,0,255))
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:RootLine()
	self:AddTLines("C:/Users/Root>", true)
end

function PANEL:AddTLines(Text, Skip)
	self.TextHis[self.CurLine] = self.TextHis[self.CurLine] or ""
	self.TextHis[self.CurLine] = Text

	local CurLines = table.Count(self.TextHis)
	if CurLines > self.MaxLines then
		self.RLine = self.RLine + 1
		self.TextHis[self.RLine] = false
	end

	if !Skip then
		self.CurLine = self.CurLine + 1
	end
end

function PANEL:ServerResponse(Exe, Command, Data)
	if Exe != "" then
		AllowedExec[Exe].ServerResponse(self, Data)
	elseif Commands[Command] then
		Commands[Command].ServerResponse(self, Data)
	end
end

function PANEL:InputExecuteable(Text)
	self.TextHis[self.CurLine] = self.TextHis[self.CurLine] or ""
	self.TextHis[self.CurLine] = self.TextHis[self.CurLine] .. Text
	self.Typing = ""

	local Args = string.Explode(" ", Text)
	AllowedExec[self.Running].Input(self, Args)
end

function PANEL:InputCommand(Text)
	self.TextHis[self.CurLine] = self.TextHis[self.CurLine] or ""
	self.TextHis[self.CurLine] = self.TextHis[self.CurLine] .. Text
	self.Typing = ""

	local Args = string.Explode(" ", Text)

	if Commands[Args[1]] then
		self.CurLine = self.CurLine + 1
		Commands[Args[1]].Run(self, Args)
	else
		self.CurLine = self.CurLine + 1
		self:AddTLines("'" .. Text .. "' is not recognized as a command")
		self:AddTLines("")
		self:RootLine()
	end
end

local Numpad = {
	[37] = 0,
	[38] = 1,
	[39] = 2,
	[40] = 3,
	[41] = 4,
	[42] = 5,
	[43] = 6,
	[44] = 7,
	[45] = 8,
	[46] = 9,
}
function PANEL:OnKeyCodePressed(Key)
	if Key == KEY_ENTER and self.Typing != "" then
		if self.Running then
			self:InputExecuteable(self.Typing)
		else
			self:InputCommand(self.Typing)
		end
	elseif Key == KEY_BACKSPACE then
		local Amount = string.len(self.Typing)
		self.Typing = string.sub(self.Typing, 1, Amount-1)
	elseif Key == KEY_SPACE then
		self.Typing = self.Typing .. " "
	elseif Key > 0 and Key < 47 or Key == KEY_PERIOD then
		local KName = Numpad[Key] or input.GetKeyName(Key)
		self.Typing = self.Typing .. KName
	end
end

function PANEL:PerformLayout(W, H)
	if IsValid(self.CloseButton) then
		self.CloseButton:SetPos(W-CMDHead-1,1)
		self.CloseButton:SetSize(CMDHead-1,CMDHead-2)
	end
end

local CMDIcon = Material("icon16/application_xp_terminal.png")
function PANEL:Paint(W, H)
	surface.SetDrawColor(Color(225,225,225,255))
	surface.DrawRect(0,0,W,CMDHead)

	surface.SetDrawColor(Color(0,0,0,255))
	surface.DrawRect(0,CMDHead,W,H-CMDHead)

	surface.SetDrawColor(Color(50,50,50,175))
	surface.DrawOutlinedRect(0,0,W,CMDHead)
	surface.DrawOutlinedRect(0,0,W,H)

	surface.SetDrawColor(255,255,255, 255)
	surface.SetMaterial(CMDIcon)
	surface.DrawTexturedRect(6,6,CMDHead-12,CMDHead-12)

	draw.SimpleText("Command Prompt", "tbfy_computer_cmdtitle", CMDHead, CMDHead/2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local HStart = CMDHead
	for k,v in ipairs(self.TextHis) do
		if v then
			draw.SimpleText(v, "tbfy_computer_cmd", 5, HStart, Color(225, 225, 225, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			HStart = HStart + 12
		end
	end

	surface.SetFont("tbfy_computer_cmd")
	local Txt = ""
	if self.TextHis[self.CurLine] then
		Txt = self.TextHis[self.CurLine]
	end
	local TW = surface.GetTextSize(Txt)
	HStart = HStart -12

	draw.SimpleText(self.Typing, "tbfy_computer_cmd", 5+TW, HStart, Color(225, 225, 225, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	local TypingW = surface.GetTextSize(self.Typing)
	local Alpha = 200
	local Calc = 200 * math.abs(math.sin(CurTime() * 2.5))
	if Calc < 150 then
		Alpha = 0
	end
	draw.SimpleText("_", "tbfy_computer_cmd", 5+TW+TypingW, HStart, Color(225, 225, 225, Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_comp_cmd", PANEL)

local PANEL = {}

function PANEL:Init()

end

function PANEL:PerformLayout(W,H)

end

function PANEL:Paint(W, H)
	surface.SetDrawColor(0, 0, 0, 225)
	surface.DrawRect(0, 0, W, H)
end
vgui.Register("tbfy_comp_quickbar", PANEL)

local PANEL = {}

local QuickBarH = 41
function PANEL:Init()
	self:SetSkin("FalkOS")

	self.PList = {}
	self.Softwares = {}
	self.TimeType = 1

	self:MakePopup()
	self:SetTitle("")
	self:SetDraggable(false)
	self:ShowCloseButton(false)

	self.Wallpaper = vgui.Create("tbfy_imgur", self)
	self.Wallpaper:SetZPos(-1)
	self.Wallpaper:SetImgurID(CBG)

	self.QuickBar = vgui.Create("tbfy_comp_quickbar", self)
	self.QuickBar:SetZPos(2)

	self.StartMenu = vgui.Create("tbfy_comp_startmenu", self)
	self.StartMenu:SetZPos(1)
	self.StartMenu:SetVisible(false)

	self.StartButton = vgui.Create("tbfy_button", self)
	self.StartButton.DoClick = function() self.StartMenu:SetVisible(!self.StartMenu:IsVisible()) end
	self.StartButton:SetPicture(StartI, false, true, 0)
	self.StartButton:SetZPos(3)
end

function PANEL:UpdateCData(Avatar, Wallpaper, TimeType, Username)
	TBFY_SH.PC_INFO = {Username = Username, Avatar = Avatar, Wallpaper = Wallpaper, TimeType = TimeType}
	if Avatar != "" then
		self.StartMenu.ALogo:SetImgurID(Avatar)
	end
	if Wallpaper != "" then
		self.Wallpaper:SetImgurID(Wallpaper)
	end
	if TimeType != 0 then
		self.TimeType = TimeType
	end
end

function PANEL:UpdateSoftware(ID, Data)
	local Program = self.Softwares[ID]
	if Program and IsValid(Program.Program) then
		Program.Program.Software:UpdateData(Data)
	end
end

function PANEL:AddSoftware(SoftID)
	local SoftData = TBFY_SH.CSoftwares[SoftID]

	if SoftData then
		local CIcon = vgui.Create("tbfy_button", self)
		CIcon:SetBText(SoftData.Name)
		CIcon:SetPicture(SoftData.Icon, true, true, 0)
		CIcon:SetBoxColor(Derma.CB, Derma.CBHover, Derma.CBPress)
		CIcon:SetCIcon()
		CIcon.DoClick = function()
			local Program = self.Softwares[SoftID]
			if Program and IsValid(Program.Program) then
				Program.Program:RequestFocus()
				return
			end

			if SoftData.OverrideProgram then
				Program = vgui.Create(SoftData.UI, self)
				Program.SoftID = SoftID
				Program:SetSize(SoftData.W, SoftData.H)
				Program:PostCreation()
			else
				Program = vgui.Create("tbfy_comp_program", self)
				Program:SetProgram(SoftData.Name, SoftData.UI, SoftData.W, SoftData.H, SoftID)
			end

			local QBarIcon = vgui.Create("tbfy_button", self)
			QBarIcon:SetSize(QuickBarH, QuickBarH)
			QBarIcon:SetPicture(SoftData.Icon, true, true, 5)
			QBarIcon:SetBoxColor(Derma.CB, Derma.CBHover, Derma.CBPress)
			QBarIcon.DoClick = function()
				if IsValid(Program) then
					Program:SetVisible(true)
					Program:RequestFocus()
					return
				end
			end
			QBarIcon:SetZPos(3)
			Program.QBarIcon = QBarIcon
			self.Softwares[SoftID] = {Program = Program, QBarIcon = QBarIcon}
		end
		CIcon.DoRightClick = function()
			local Menu = DermaMenu()
			Menu:AddOption("Uninstall", function() net.Start("tbfy_computer_run") net.WriteString("") net.WriteString("ToggleSoftware") net.WriteBool(false) net.WriteString(SoftID) net.SendToServer() end)
			Menu:Open()
			Menu:SetPos(gui.MousePos())
		end
		CIcon:SetBFont("tbfy_computer_icon")
		CIcon:SetZPos(0)

		self.PList[SoftID] = CIcon
		LocalPlayer().TBFY_Comp.Software[SoftID] = true
	end
end

function PANEL:RemoveSoftware(SoftID)
	local Soft = self.PList[SoftID]
	self.PList[SoftID] = nil
	LocalPlayer().TBFY_Comp.Software[SoftID] = nil
	Soft:Remove()
end

function PANEL:PaintOver(W,H)
	draw.RoundedBox(8, 48, H-38, 1, 36, Color(40,40,40,185))

	local Country = system.GetCountry()
	local TDate = os.date(TimeTypes[self.TimeType].Format)
	local TStrings = string.Explode("-", TDate)
	surface.SetFont("tbfy_computer_icon")
	local WT,HT = surface.GetTextSize(TStrings[1])
	local WT2,HT2 = surface.GetTextSize(TStrings[2])

	draw.SimpleText(Country, "tbfy_country", W-25-WT2, H-QuickBarH/2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	draw.SimpleText(TStrings[1], "tbfy_computer_icon", W-10, H-QuickBarH/2-1, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(TStrings[2], "tbfy_computer_icon", W-10, H-QuickBarH/2+1, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

function PANEL:PerformLayout()
	local Width, Height = ScrW(), ScrH()
	self:SetSize(Width, Height)

	self.Wallpaper:SetPos(0,0)
	self.Wallpaper:SetSize(Width, Height)

	local Hstart = 5
	local xPos = 0
	for k,v in pairs(self.PList) do
		v:SetPos(5 + (90*xPos),Hstart)
		v:SetSize(85,85)
		Hstart = Hstart + 90
		if Height-QuickBarH - 85 < Hstart then
			Hstart = 5
			xPos = xPos + 1
		end
	end

	self.StartMenu:SetPos(0,Height-41-Height/2)
	self.StartMenu:SetSize(Width*0.3,Height/2)

	self.StartButton:SetPos(10, Height-37)
	self.StartButton:SetSize(32, 32)

	local StartW = 60
	for k,v in pairs(self.Softwares) do
		if IsValid(v.QBarIcon) then
			v.QBarIcon:SetPos(StartW, Height-QuickBarH)
			StartW = StartW + QuickBarH + 5
		end
	end

	self.QuickBar:SetPos(0, Height-QuickBarH)
	self.QuickBar:SetSize(Width, QuickBarH)
end

function PANEL:OnRemove()
	gui.EnableScreenClicker(false)
end
vgui.Register("tbfy_computer_desktop", PANEL, "DFrame")

local PANEL = {}

local W,H = 190,170
function PANEL:Init()
	self:SetPos(ScrW()/2-W/2, ScrH()/2-H/2)
	self:SetSize(W,H)

	self:MakePopup()
	self:SetTitle("")
	self:SetDraggable(true)
	self:ShowCloseButton(false)

	self.UserName = vgui.Create("DTextEntry", self)
	self.UserName:SetPlaceholderText("1-10 Characters")

	self.Password = vgui.Create("DTextEntry", self)
	self.Password:SetPlaceholderText("1-10 Characters")

	self.SaveButton = vgui.Create("tbfy_button", self)
	self.SaveButton:SetBText(TBFY_GetLang("SaveSettings"))
	self.SaveButton:SetBoxColor(Color(255,255,255,150), Color(255,255,255,225), Color(255,255,255,255))
	self.SaveButton:SetBTextColor(Color(0,0,0,255))
	self.SaveButton.DoClick = function()
		local UN, PW = self.UserName:GetValue(), self.Password:GetValue()
		local ULen, PLen = string.len(UN), string.len(PW)
		local TMsg = ""

		if ULen < 1 then
			TMsg = "Too short Username!"
		elseif PLen < 1 then
			TMsg = "Too short Password!"
		elseif ULen > 10 then
			TMsg = "Too long Username!"
		elseif PLen > 10 then
			TMsg = "Too long Password!"
		end

		if TMsg != "" then
			TBFY_SH:SendMessage(TMsg, "ERROR")
		else
			net.Start("tbfy_manage_accountinfo")
				net.WriteString(UN)
				net.WriteString(PW)
			net.SendToServer()

			self:Remove()
		end
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton:SetBoxColor(Color(255,255,255,0), Color(255,255,255,200), Color(255,255,255,255))
	self.CloseButton:SetBTextColor(Color(0,0,0,255))
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:PerformLayout(W,H)
	self.UserName:SetPos(5, CMDHead+25)
	self.UserName:SetSize(W-10,25)

	self.Password:SetPos(5, CMDHead+75)
	self.Password:SetSize(W-10,25)

	self.SaveButton:SetPos(5, H-30)
	self.SaveButton:SetSize(W-10, 25)

	self.CloseButton:SetPos(W-CMDHead-1,1)
	self.CloseButton:SetSize(CMDHead-1,CMDHead-2)
end

function PANEL:Paint(W, H)
	surface.SetDrawColor(Color(225,225,225,255))
	surface.DrawRect(0,0,W,CMDHead)

	surface.SetDrawColor(Color(0,0,0,255))
	surface.DrawRect(0,CMDHead,W,H-CMDHead)

	surface.SetDrawColor(Color(50,50,50,175))
	surface.DrawOutlinedRect(0,0,W,CMDHead)
	surface.DrawOutlinedRect(0,0,W,H)

	draw.SimpleText(TBFY_GetLang("AccountManager"), "tbfy_computer_cmdtitle", 5, CMDHead/2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(TBFY_GetLang("Username") .. ":", "tbfy_computer_amanager_text", 5, CMDHead+5, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(TBFY_GetLang("Password") .. ":", "tbfy_computer_amanager_text", 5, CMDHead+55, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_comp_account_manager", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self.Name = ""
	self.ALogo = vgui.Create("tbfy_CircularAvatar", self)
	self.ALogo:SetImgurID()
	self.ClickArea = vgui.Create("tbfy_button", self)
	self.ClickArea:SetBoxColor(Color(255, 255, 255, 0), Color(0, 0, 0, 100), Color(0, 0, 0, 150))
	self.ClickArea.DoClick = function()
		if !self.CurSelc then
			self:GetParent():GetParent():GetParent():ProfClicked(self)
		end
	end
end

function PANEL:UpdateBColor()
	if self.CurSelc then
		self.ClickArea:SetBoxColor(Color(0, 0, 0, 150), Color(0, 0, 0, 150), Color(0, 0, 0, 150))
	else
		self.ClickArea:SetBoxColor(Color(255, 255, 255, 0), Color(0, 0, 0, 100), Color(0, 0, 0, 150))
	end
	self.ClickArea:UpdateColours()
end

function PANEL:SetupData(Name, SID, Av)
	self.Name = Name
	self.SID = SID
	self.Av = Av
	self.ALogo:SetImgurID(Av)
end

function PANEL:PerformLayout(W,H)
	local AvS = H*0.8
	self.ALogo:SetPos(5, H*.1)
	self.ALogo:SetSize(AvS, AvS)

	surface.SetFont("tbfy_computer_font_login_text")
	local NameW = surface.GetTextSize(self.Name)
	local ClickW = AvS+NameW+20
	self.ClickArea:SetSize(ClickW,H)
end

function PANEL:Paint(W, H)
	draw.SimpleText(self.Name, "tbfy_computer_font_login_text", H*0.8+10, H/2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end
vgui.Register("tbfy_comp_login_user", PANEL)

local PANEL = {}

function PANEL:Init()
	self:SetSkin("FalkOS")
	self.PList = {}
	self:MakePopup()
	self:SetTitle("")
	self:SetDraggable(false)
	self:ShowCloseButton(false)
	self:SetKeyboardInputEnabled(true)
	self.CurUData = nil

	self.PowerOff = vgui.Create("tbfy_button", self)
	self.PowerOff:SetPicture(Shutdown, false, false, 0)
	self.PowerOff.DoClick = function() self:Remove() end

	self.ALogo = vgui.Create("tbfy_CircularAvatar", self)
	self.ALogo:SetImgurID()

	self.LoginBox = vgui.Create("tbfy_comp_log", self)
	self.LoginBox:SetDrawBackground(false)
	self.LoginBox:SetPlaceholderText(TBFY_GetLang("Password"))

	self.LoginButton = vgui.Create("tbfy_button", self)
	self.LoginButton.DoClick = function()
		local UN = ""
		local SID = ""
		if self.CurUData then
			UN = self.CurUData.Name
			SID = self.CurUData.SID
		elseif IsValid(self.UserBox) then
			UN = self.UserBox:GetValue()
		end
		local PW = self.LoginBox:GetValue()
		net.Start("tbfy_comp_login")
			net.WriteString(UN)
			net.WriteString(PW)
			net.WriteString(SID)
		net.SendToServer()
	end
	self.LoginButton:SetPicture(LArrow, false, true, 2)
	self.LoginButton:SetBoxColor(Color(14, 77, 147, 255), Color(14, 77, 160, 175), Color(14, 77, 200, 200))

	self.CMD = vgui.Create("tbfy_button", self)
	self.CMD:SetPicture(CMD, false, false, 0)
	self.CMD.DoClick = function()
		if !IsValid(TBFY_CMDW) then
			TBFY_CMDW = vgui.Create("tbfy_comp_cmd", self)
			TBFY_CMDW:SetupCMD()
		end
	end

	self.ExtUsers = vgui.Create("DScrollPanel", self)
	self.ExtUsers.Paint = function(selfp, W, H)
	end
	self.ExtUsers.VBar.Paint = function() end
	self.ExtUsers.VBar.btnUp.Paint = function() end
	self.ExtUsers.VBar.btnDown.Paint = function() end
	self.ExtUsers.VBar.btnGrip.Paint = function() end
	self.ExtUsers:SetVisible(false)
end

function PANEL:OnKeyCodePressed(Key)
	if IsValid(TBFY_CMDW) then
		TBFY_CMDW:OnKeyCodePressed(Key)
	end
end

function PANEL:IncorrectPW()
	TBFY_SH:SendMessage("LOGIN ERROR", "INCORRECT PASSWORD")
end

function PANEL:SetGovPC(Logo)
	self.GovPC = true
	if Logo and Logo != "" then
		self.ALogo:SetImgurID(Logo)
	end
end

function PANEL:UnSelectProfs()
	for k,v in pairs(self.CompUsers) do
		v.CurSelc = false
		v:UpdateBColor()
	end
end

function PANEL:ProfClicked(Prof)
	if !self.GovPC then
		self:UnSelectProfs()

		self.CurUData = {Name = Prof.Name, SID = Prof.SID}
		self.ALogo:SetImgurID(Prof.Av)
		Prof.CurSelc = true
		Prof:UpdateBColor()
		self.UserBox:SetVisible(false)
		self:PerformLayout()
		self.OptionText.ProfSelected = true
		self.OptionText:SetBText(TBFY_GetLang("DifferentAccount"))
	end
end

function PANEL:LoginDiffUser()
	self:UnSelectProfs()
	self.CurUData = nil
	self.OptionText.ProfSelected = false
	self.OptionText:SetBText(TBFY_GetLang("CreateModifyAccount"))
	self.UserBox:SetVisible(true)
	self.ALogo:SetImgurID()
	self:PerformLayout()
end

function PANEL:OpenAccountM()
	if !IsValid(self.AccountM) then
		self.AccountM = vgui.Create("tbfy_comp_account_manager", self)
	else
		self.AccountM:MakePopup()
	end
end

local UserH = 40
function PANEL:SetupNonGovPC(Users)
	self.UserBox = vgui.Create("tbfy_comp_log", self)
	self.UserBox:SetDrawBackground(false)
	self.UserBox:SetPlaceholderText(TBFY_GetLang("Username"))

	self.OptionText = vgui.Create("tbfy_button", self)
	self.OptionText.DoClick = function(selfp)
		if selfp.ProfSelected then
			self:LoginDiffUser()
		else
			self:OpenAccountM()
		end
	end
	self.OptionText:SetBoxColor(Color(14, 77, 147, 0), Color(14, 77, 160, 0), Color(14, 77, 200, 0))
	self.OptionText:SetBFont("tbfy_computer_font_login_text")
	self.OptionText:SetBText(TBFY_GetLang("CreateModifyAccount"))

	self.CompUsers = {}
	self.ExtUsers:SetVisible(true)
end

function PANEL:AddAccount(SID,UN, Av)
	local User = vgui.Create("tbfy_comp_login_user", self.ExtUsers)
	User:SetupData(UN, SID, Av)
	self.CompUsers[SID] = User
end

function PANEL:Paint(W,H)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(0,0,W,H)

	surface.SetMaterial(CBG)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(2, 2, W-4, H-4)

	local HPos = H/2+Padd
	local LogBOutW, LogBOutWS = W/2-LBoxW/2-LBW/2, LBoxW+LBW+1
	if self.GovPC then
		HPos = H/2+Padd+GovS/4
		draw.SimpleText(TBFY_GetLang("GovPCLogin"), "tbfy_computer_font_login", W/2, H/2+GovS/4, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	else
		if IsValid(self.UserBox) and !self.UserBox:IsVisible() and self.CurUData then
			draw.SimpleText(self.CurUData.Name, "tbfy_computer_font_login", W/2, H/2+5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			HPos = HPos + 5
		else
			HPos = HPos + 5
			surface.SetDrawColor(0, 0, 0, 225)
			surface.DrawOutlinedRect(W/2-LBoxW/2-LBW/2,H/2-16,LBoxW,25)
			surface.DrawOutlinedRect(W/2+LBoxW/2-LBW/2,HPos-LBW/2-1,LBW+2,LBW+2)

			LogBOutWS = LBoxW
		end
	end

	surface.SetDrawColor(0, 0, 0, 225)
	surface.DrawOutlinedRect(LogBOutW,HPos,LogBOutWS,25)
end

function PANEL:PerformLayout()
	local Width, Height = ScrW(), ScrH()
	self:SetPos(0, 0)
	self:SetSize(Width, Height)

	self.PowerOff:SetPos(Width-52,Height-52)
	self.PowerOff:SetSize(32, 32)

	local MiddleW, MiddleH = Width/2, Height/2

	local LogButW, LogButH = MiddleW+LBoxW/2-LBW/2, MiddleH+Padd+1
	local CAv = 155
	local Offset = 25
	if self.GovPC then
		MiddleH = MiddleH+GovS/4
		LogButH = MiddleH+Padd+1
		CAv = 250
		Offset = -20
	elseif self.UserBox:IsVisible() and !self.CurUData then
		MiddleH = MiddleH + 5
		LogButH = LogButH - LBW/2+4
		LogButW = LogButW + 1

		self.UserBox:SetPos(MiddleW-LBoxW/2-LBW/2, MiddleH-21)
		self.UserBox:SetSize(LBoxW, 25)

		self.OptionText:SetPos(Width/2-70,MiddleH+40)
		self.OptionText:SetSize(130,15)
	else
		MiddleH = MiddleH + 5
		LogButH = LogButH + 5
		self.OptionText:SetSize(160,15)
	end

	self.ALogo:SetPos(MiddleW-CAv/2, Height/2-CAv-Offset)
	self.ALogo:SetSize(CAv, CAv)

	self.LoginBox:SetPos(MiddleW-LBoxW/2-LBW/2, MiddleH+Padd)
	self.LoginBox:SetSize(LBoxW,25)

	self.LoginButton:SetPos(LogButW, LogButH)
	self.LoginButton:SetSize(LBW,LBW)

	self.CMD:SetPos(Width-99, Height-52)
	self.CMD:SetSize(32,32)

	if self.CompUsers then
		local UAmount = table.Count(self.CompUsers)
		local ExtUW, ExtUH = Width*.2, math.Clamp(UserH*UAmount, 0, Height*.4)
		self.ExtUsers:SetSize(ExtUW, ExtUH)
		self.ExtUsers:SetPos(5,Height-5-ExtUH)
		local HStart = 0
		for k,v in pairs(self.CompUsers) do
			v:SetSize(ExtUW, UserH)
			v:SetPos(0, HStart)
			HStart = HStart + UserH
		end
	end
end

function PANEL:OnRemove()
	gui.EnableScreenClicker(false)
end
vgui.Register("tbfy_computer_loginscreen", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self:SetSkin("FalkOS")

	self:MakePopup()
	self:SetTitle("")
	self:SetDraggable(false)
	self:ShowCloseButton(false)
	self:SetBackgroundBlur(true)
	self:SetDrawOnTop(true)
	self:DoModal()

	self.InnerPanel = vgui.Create("DPanel", self)
	self.InnerPanel:SetPaintBackground(false)

	self.Text = vgui.Create("DLabel", self.InnerPanel)
	self.Text:SetText("Text")
	self.Text:SetContentAlignment(5)

	self.ButtonPanel = vgui.Create("DPanel", self)
	self.ButtonPanel:SetTall(30)
	self.ButtonPanel:SetPaintBackground(false)

	self.Button = vgui.Create("DButton", self.ButtonPanel)
	self.Button:SetText(TBFY_GetLang("OK"))
	self.Button:SizeToContents()
	self.Button:SetTall(20)
	self.Button:SetWide(self.Button:GetWide() + 20)
	self.Button:SetPos(5, 5)
	self.Button.DoClick = function() self:Close() end
end

function PANEL:Setup(Title, Text, OkButton, Request, CancelB, Type, OkFunc)
	self:SetTitle(Title)
	self.Text:SetText(Text)
	self.Text:SizeToContents()
	self.Button:SetText(OkButton)

	local w, h = self.Text:GetSize()
	local H = h + 25 + 45 + 10
	local TextH = -5
	if Request then
		w = math.max(w, 400)
		H = H + 30
		TextH = 35
	end

	if CancelB then
		self.ButtonCancel = vgui.Create("DButton", self.ButtonPanel)
		self.ButtonCancel:SetText(TBFY_GetLang("Cancel"))
		self.ButtonCancel:SizeToContents()
		self.ButtonCancel:SetTall(20)
		self.ButtonCancel:SetWide(self.Button:GetWide() + 20)
		self.ButtonCancel:SetPos(5, 5)
		self.ButtonCancel:SetText(CancelB)
		self.ButtonCancel.DoClick = function() self:Close() end
		self.ButtonCancel:MoveRightOf(self.Button, 5)

		self.ButtonPanel:SetWide(self.Button:GetWide() + 5 + self.ButtonCancel:GetWide() + 10)
	else
		self.ButtonPanel:SetWide(self.Button:GetWide() + 5)
	end

	self:SetSize(w + 50, H)
	self:Center()

	self.InnerPanel:StretchToParent(5, 25, 5, 45)

	self.Text:StretchToParent(5, 5, 5, TextH)

	local TextEntVal = ""
	if Request then
		self.TextEntry = vgui.Create("DTextEntry", self.InnerPanel)
		self.TextEntry:SetText("")
		self.TextEntry.OnEnter = function() self:Close() end

		self.TextEntry:StretchToParent(5, nil, 5, nil)
		self.TextEntry:AlignBottom(5)

		self.TextEntry:RequestFocus()
		self.TextEntry:SelectAllText(true)
	end

	self.ButtonPanel:CenterHorizontal()
	self.ButtonPanel:AlignBottom(8)

	if Type == "Numeric" then
		self.TextEntry:SetNumeric(true)
	end
	if OkFunc then
		self.Button.DoClick = function()
			local TEntVal = ""
			if IsValid(self.TextEntry) then
				TEntVal = self.TextEntry:GetValue()
			end
			OkFunc(TEntVal)
			self:Close()
		end
	end
end
vgui.Register("tbfy_comp_reqdata", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	local LP = LocalPlayer()
	LP.TBFY_EditComputer = self

	net.Start("tbfy_update_computer")
		net.WriteString("")
	net.SendToServer()

	LP.TBFY_EData = {}
	LP.TBFY_EData.SoftID = {}
	LP.TBFY_EData.JobID = {}

	self.TopFrame = vgui.Create("tbfy_comp_dpanel", self)
	self.TopFrame:SetTitle(TBFY_GetLang("ComputerSettings"), false)

	self.SEName = vgui.Create("DTextEntry", self)
	self.SEName:SetText(TBFY_GetLang("InputUniqueName"))
	self.SEName:SetUpdateOnType(true)
	self.SEName.OnValueChange = function(panel, value)
		LP.TBFY_EData.EName = value
	end

	self.PCType = vgui.Create("DComboBox", self)
	self.PCType:AddChoice("Government")
	self.PCType:AddChoice("Public")
	self.PCType:AddChoice("Private")
	--self.PCType:SetTextColor(Color(0,0,0,255))
	self.PCType.OnSelect = function(selfp, Index, Val)
		LP.TBFY_EData.PCType = Index
	end

	self.Softwares = vgui.Create("DListView", self)
	self.Softwares:SetMultiSelect(false)
	self.Softwares:AddColumn(TBFY_GetLang("Software"))
	self.Softwares:AddColumn(TBFY_GetLang("Installed"))

	self.Softwares.OnRowSelected = function(selfp, Index, Line)
		local CurV = Line:GetValue(2)
		local SoftID = Line.SoftID
		if CurV == TBFY_GetLang("Yes") then
			CurV = TBFY_GetLang("No")
			LP.TBFY_EData.SoftID[SoftID] = nil
		else
			CurV = TBFY_GetLang("Yes")
			LP.TBFY_EData.SoftID[SoftID] = true
		end
		Line:SetColumnText(2, CurV)
	end

	self.JobsA = vgui.Create("DListView", self)
	self.JobsA:SetMultiSelect(false)
	self.JobsA:AddColumn(TBFY_GetLang("Job"))
	self.JobsA:AddColumn(TBFY_GetLang("Allowed"))
	self.JobsA.OnRowSelected = function(selfp, Index, Line)
		local CurV = Line:GetValue(2)
		local JobID = Line.JobID
		if CurV == TBFY_GetLang("Yes") then
			CurV = TBFY_GetLang("No")
			LP.TBFY_EData.JobID[JobID] = nil
		else
			CurV = TBFY_GetLang("Yes")
			LP.TBFY_EData.JobID[JobID] = true
		end
		Line:SetColumnText(2, CurV)
	end

	self.SaveSettings = vgui.Create("tbfy_button", self)
	self.SaveSettings:SetBText(TBFY_GetLang("SaveSettings"))
	self.SaveSettings:SetBFont("tbfy_computer_window_letters")
	self.SaveSettings:SetBoxColor(Color(20,20,20,255), Color(20,20,20,240), Color(20,20,20,230))
	self.SaveSettings.DoClick = function()
		local SoftS = ""
		if LP.TBFY_EData.SoftID then
			for k,v in pairs(LP.TBFY_EData.SoftID) do
				SoftS = SoftS .. k .. ":"
			end
		end
		local JobIDS = ""
		if LP.TBFY_EData.JobID then
			for k,v in pairs(LP.TBFY_EData.JobID) do
				JobIDS = JobIDS .. k .. ":"
			end
		end

		net.Start("tbfy_update_computer")
			net.WriteString(LP.TBFY_EData.EName)
			net.WriteFloat(LP.TBFY_EData.PCType)
			net.WriteString(SoftS)
			net.WriteString(JobIDS)
		net.SendToServer()

		if IsValid(TBFY_LastPCUI) then
			TBFY_LastPCUI:Remove()
		end
	end
end

function PANEL:UpdateComputerSettings(Name, PCType, Soft, Jobs)
	local LP = LocalPlayer()

	LP.TBFY_EData.EName = Name
	self.SEName:SetText(Name)

	LP.TBFY_EData.PCType = PCType
	self.PCType:ChooseOptionID(PCType)

	LP.TBFY_EData.SoftID = Soft

	local TypeNames = {"Government", "Public"}
	for k,v in pairs(TBFY_SH.CSoftwares) do
		if !v.Default and v.PCType and (v.PCType[1] or v.PCType[2]) then
			local Text = TBFY_GetLang("No")
			if Soft[k] then
				Text = TBFY_GetLang("Yes")
			end

			local Name = v.Name
			if v.PCType then
				Name = Name .. " ("
				for k,v in pairs(v.PCType) do
					if k != 3 then
						Name = Name .. TypeNames[k] .. ","
					end
				end
				Name = string.sub(Name, 1, string.len(Name) - 1) .. ")"
			end

			local Line = self.Softwares:AddLine(Name, Text)
			Line.SoftID = k
		end
	end

	LP.TBFY_EData.JobID = Jobs
	local AllJobs = team.GetAllTeams()
	//Get rid off unassigned/spec/joining
	AllJobs[0] = nil
	AllJobs[1001] = nil
	AllJobs[1002] = nil
	for k,v in pairs(AllJobs) do
		local Text = TBFY_GetLang("No")
		if Jobs[k] then
			Text = TBFY_GetLang("Yes")
		end
		local Line = self.JobsA:AddLine(v.Name, Text)
		Line.JobID = k
	end
end

local Width, Height = 250, 450
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopFrame:SetSize(W-4,Derma.HeaderH)
	self.TopFrame:SetPos(2,2)

	local WS = W/2-20
	self.SEName:SetPos(WS, Derma.HeaderH+5)
	self.SEName:SetSize(125,25)

	self.PCType:SetPos(W/2-105/2,Derma.HeaderH+35)
	self.PCType:SetSize(105, 25)

	self.Softwares:SetPos(5,Derma.HeaderH+65)
	self.Softwares:SetSize(W-10,125)

	self.JobsA:SetPos(5,Derma.HeaderH+195)
	self.JobsA:SetSize(W-10, 195)

	self.SaveSettings:SetPos(6, H-31)
	self.SaveSettings:SetSize(W-12, 25)
end

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 2, 2, W-4, H-4, Derma.CProgramBG)

	draw.SimpleText(TBFY_GetLang("Identifier") .. ":", "tbfy_header", W/2-25, Derma.HeaderH+7.5, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_edit_computer", PANEL)
