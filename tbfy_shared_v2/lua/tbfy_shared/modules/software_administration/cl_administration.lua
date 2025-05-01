
local Derma = TBFY_SH.Config.Derma

local PANEL = {}

function PANEL:Init()
	self.PIcon = vgui.Create("ModelImage", self)

	self.Wanted = vgui.Create("tbfy_button", self)
  self.Wanted:SetBText(TBFY_GetLang("Wanted"))
  self.Wanted.DoClick = function()
    local Req = nil
    if !self.Wanted.Status then
  	   Req = vgui.Create("tbfy_comp_reqdata")
    end
		local Func = function()
			net.Start("tbfy_computer_run")
				net.WriteString(self.Parent.MainP.SoftID)
				net.WriteString("")
				net.WriteString("Wanted")
				net.WriteEntity(self.Player)
        if IsValid(Req) then
  				net.WriteString(Req.TextEntry:GetValue())
        end
			net.SendToServer()
		end
    if Req then
  		Req:Setup(TBFY_GetLang("SetWanted"), "Reason", "OK", true, "Cancel", "String", Func)
    else
      Func()
    end
	end

	self.Warrant = vgui.Create("tbfy_button", self)
	self.Warrant:SetBText(TBFY_GetLang("Warrant"))
  self.Warrant.DoClick = function()
    local Req = nil
    if !self.Warrant.Status then
  	   Req = vgui.Create("tbfy_comp_reqdata")
    end
		local Func = function(text)
			net.Start("tbfy_computer_run")
				net.WriteString(self.Parent.MainP.SoftID)
				net.WriteString("")
				net.WriteString("Warrant")
				net.WriteEntity(self.Player)
        if IsValid(Req) then
  				net.WriteString(text)
        end
			net.SendToServer()
		end
    if Req then
  		Req:Setup(TBFY_GetLang("SetWarrant"), "Reason", "OK", true, "Cancel", "String", Func)
    else
      Func()
    end
	end

	self.Gunlicense = vgui.Create("tbfy_button", self)
	self.Gunlicense:SetBText("Grant Gunlicense")
	self.Gunlicense.DoClick = function()
		net.Start("tbfy_computer_run")
			net.WriteString(self.Parent.MainP.SoftID)
			net.WriteString("")
      net.WriteString("Gunlicense")
			net.WriteEntity(self.Player)
		net.SendToServer()
	end
end

function PANEL:SetPlayer(Player)
	self.Player = Player
	self.Nick = Player:Nick()
	self.Job = Player:getDarkRPVar("job")
	self.PIcon:SetModel(Player:GetModel())
	self.PIcon.PaintOver = function(selfp, W, H)
		surface.SetDrawColor(Color(0,0,0,180))
		surface.DrawOutlinedRect(0,0,W,H)
	end

  self.Wanted.Status = !Player:isWanted()
  self.Wanted.Think = function()
		if IsValid(self.Player) then
	    local Wanted = self.Player:isWanted()
	    if Wanted != self.Wanted.Status then
	      if !Wanted then
	        self.Wanted:SetBText("Wanted")
	      else
	        self.Wanted:SetBText("Unwanted")
	      end
	      self.Wanted.Status = Wanted
	    end
		end
  end

  self.Warrant.Status = !Player:DKRP_isWarranted()
  self.Warrant.Think = function()
		if IsValid(self.Player) then
	    local Warrant = self.Player:DKRP_isWarranted()
	    if Warrant != self.Warrant.Status then
	      if !Warrant then
	        self.Warrant:SetBText("Warrant")
	      else
	        self.Warrant:SetBText("Unwarrant")
	      end
	      self.Warrant.Status = Warrant
	    end
		end
  end

  self.Gunlicense.Status = !Player:getDarkRPVar("HasGunlicense")
  self.Gunlicense.Think = function()
		if IsValid(self.Player) then
	    local Gunlic = self.Player:getDarkRPVar("HasGunlicense")
	    if Gunlic != self.Gunlicense.Status then
	      if !Gunlic then
	        self.Gunlicense:SetBText("Grant Gunlicense")
	      else
	        self.Gunlicense:SetBText("Revoke Gunlicense")
	      end
	      self.Gunlicense.Status = Gunlic
	    end
	  end
	end
end

function PANEL:PerformLayout(W, H)
	local Size = H-20
	self.PIcon:SetSize(Size,Size)
	self.PIcon:SetPos(10,10)

	local ButW, ButH = 90, (H-20)/3-1
	self.Wanted:SetPos(W-ButW-5, 11)
	self.Wanted:SetSize(ButW, ButH)

	self.Warrant:SetPos(W-ButW-5, 12+ButH)
	self.Warrant:SetSize(ButW, ButH)

	self.Gunlicense:SetPos(W-ButW-5, 13+ButH*2)
	self.Gunlicense:SetSize(ButW, ButH)
end

function PANEL:Paint(W, H)
	draw.RoundedBox(4, 0, 0, W, H, Color(0,0,0,200))
	draw.RoundedBox(4, 1, 1, W-2, H-2, Derma.ArchiveColor)

	draw.SimpleText(self.Nick, "tbfy_comp_admin_pinfo", H, H/2-2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(self.Job, "tbfy_comp_admin_pinfo", H, H/2+2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_administration_player", PANEL)

local PANEL = {}

function PANEL:Init()

end

function PANEL:SetInfo(Text, Val)
	self.Text = Text
	self.Val = Val
end

function PANEL:Paint(W, H)
	surface.SetFont("tbfy_comp_overview_infotext")
	local Name = self.Text
	local TW, TH = surface.GetTextSize(Name)

	draw.SimpleText(self.Text, "tbfy_comp_overview_infotext", 0, 0, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(self.Val, "tbfy_comp_overview_infoval", TW+5, 0, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_admin_overview_info", PANEL)

local PANEL = {}

function PANEL:Init()
	self.PIcon = vgui.Create("ModelImage", self)
end

function PANEL:SetPlayer(Player)
	self.Player = Player
	self.Nick = Player:Nick()
	self.Job = Player:getDarkRPVar("job")
	self.PIcon:SetModel(Player:GetModel())
	self.PIcon.PaintOver = function(selfp, W, H)
		surface.SetDrawColor(Color(0,0,0,180))
		surface.DrawOutlinedRect(0,0,W,H)
	end
end

function PANEL:PerformLayout(W, H)
	local Size = H-2
	self.PIcon:SetSize(Size,Size)
	self.PIcon:SetPos(1,1)
end

function PANEL:Paint(W, H)
	draw.RoundedBox(4, 0, 0, W, H, Color(0,0,0,200))
	draw.RoundedBox(4, 1, 1, W-2, H-2, Derma.ArchiveColor)

	draw.SimpleText(self.Nick, "tbfy_comp_admin_pinfo", H, H/2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(self.Job, "tbfy_comp_admin_pinfo", H, H/2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_admin_overview_list", PANEL)

local PANEL = {}

function PANEL:Init()
	self.InfoP = {}
	self.WantedP = {}
	self.ArrestedP = {}
	self.GunlicenseP = {}

	self.InfoPanel = vgui.Create("DPanel", self)
	self.InfoPanel.Paint = function(selfp, W, H)
		draw.RoundedBox(4, 0, 0, W, H, Derma.TabListColors)

		surface.SetFont("tbfy_comp_admin_pinfo")
		local Name = "General"
		local TW, TH = surface.GetTextSize(Name)
		local BW, BH = TW+20, TH+3

		draw.RoundedBox(8, W/2-BW/2, 2, BW, BH, Derma.HeaderColor)
		draw.SimpleText(Name, "tbfy_archives_header", W/2, 3, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	self.InfoList = vgui.Create("DScrollPanel", self.InfoPanel)
	self.InfoList.VBar.Paint = function() end
	self.InfoList.VBar.btnUp.Paint = function() end
	self.InfoList.VBar.btnDown.Paint = function() end
	self.InfoList.VBar.btnGrip.Paint = function() end

	self.WantedPanel = vgui.Create("DPanel", self)
	self.WantedPanel.Paint = function(selfp, W, H)
		draw.RoundedBox(4, 0, 0, W, H, Derma.TabListColors)

		surface.SetFont("tbfy_comp_admin_pinfo")
		local Name = "Wanted"
		local TW, TH = surface.GetTextSize(Name)
		local BW, BH = TW+20, TH+3

		draw.RoundedBox(8, W/2-BW/2, 2, BW, BH, Derma.HeaderColor)
		draw.SimpleText(Name, "tbfy_archives_header", W/2, 3, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	self.WantedList = vgui.Create("DScrollPanel", self.WantedPanel)
	self.WantedList.VBar.Paint = function() end
	self.WantedList.VBar.btnUp.Paint = function() end
	self.WantedList.VBar.btnDown.Paint = function() end
	self.WantedList.VBar.btnGrip.Paint = function() end

	self.ArrestedPanel = vgui.Create("DPanel", self)
	self.ArrestedPanel.Paint = function(selfp, W, H)
		draw.RoundedBox(4, 0, 0, W, H, Derma.TabListColors)

		surface.SetFont("tbfy_comp_admin_pinfo")
		local Name = "Arrested"
		local TW, TH = surface.GetTextSize(Name)
		local BW, BH = TW+20, TH+3

		draw.RoundedBox(8, W/2-BW/2, 2, BW, BH, Derma.HeaderColor)
		draw.SimpleText(Name, "tbfy_archives_header", W/2, 3, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	self.ArrestedList = vgui.Create("DScrollPanel", self.ArrestedPanel)
	self.ArrestedList.VBar.Paint = function() end
	self.ArrestedList.VBar.btnUp.Paint = function() end
	self.ArrestedList.VBar.btnDown.Paint = function() end
	self.ArrestedList.VBar.btnGrip.Paint = function() end

	self.GunlicensePanel = vgui.Create("DPanel", self)
	self.GunlicensePanel.Paint = function(selfp, W, H)
		draw.RoundedBox(4, 0, 0, W, H, Derma.TabListColors)

		surface.SetFont("tbfy_comp_admin_pinfo")
		local Name = "Gun Licenses"
		local TW, TH = surface.GetTextSize(Name)
		local BW, BH = TW+20, TH+3

		draw.RoundedBox(8, W/2-BW/2, 2, BW, BH, Derma.HeaderColor)
		draw.SimpleText(Name, "tbfy_archives_header", W/2, 3, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	self.GunlicenseList = vgui.Create("DScrollPanel", self.GunlicensePanel)
	self.GunlicenseList.VBar.Paint = function() end
	self.GunlicenseList.VBar.btnUp.Paint = function() end
	self.GunlicenseList.VBar.btnDown.Paint = function() end
	self.GunlicenseList.VBar.btnGrip.Paint = function() end

	self:SetupOverview()
end

function PANEL:SetupOverview()
	local CPs, Wanted, Arrested, GL = 0, 0, 0, 0
	local Mayor = "None"
	for k,v in pairs(player.GetAll()) do
		if v:isCP() then
			CPs = CPs + 1
		end
		if v:isMayor() then
			Mayor = v:Nick()
		end
		if v:isWanted() then
			local PInfo = vgui.Create("tbfy_admin_overview_list", self.WantedList)
			PInfo:SetPlayer(v)
			self.WantedP[k] = PInfo
			Wanted = Wanted +1
		end
		if v:getDarkRPVar("Arrested") then
			local PInfo = vgui.Create("tbfy_admin_overview_list", self.ArrestedList)
			PInfo:SetPlayer(v)
			self.ArrestedP[k] = PInfo
			Arrested = Arrested + 1
		end
		if v:getDarkRPVar("HasGunlicense") then
			local PInfo = vgui.Create("tbfy_admin_overview_list", self.GunlicenseList)
			PInfo:SetPlayer(v)
			self.GunlicenseP[k] = PInfo
			GL = GL + 1
		end
	end

	local Info = vgui.Create("tbfy_admin_overview_info", self.InfoList)
	Info:SetInfo("Mayor:", Mayor)
	table.insert(self.InfoP, Info)

	local Info = vgui.Create("tbfy_admin_overview_info", self.InfoList)
	Info:SetInfo("Polices:", CPs)
	table.insert(self.InfoP, Info)

	local Info = vgui.Create("tbfy_admin_overview_info", self.InfoList)
	Info:SetInfo("Arrested:", Arrested)
	table.insert(self.InfoP, Info)

	local Info = vgui.Create("tbfy_admin_overview_info", self.InfoList)
	Info:SetInfo("Wanted:", Wanted)
	table.insert(self.InfoP, Info)

	local Info = vgui.Create("tbfy_admin_overview_info", self.InfoList)
	Info:SetInfo("Gun Licenses:", GL)
	table.insert(self.InfoP, Info)

	local Lockdown = "No"
	if GetGlobalBool("DarkRP_LockDown") then
		Lockdown = "Yes"
	end
	local Info = vgui.Create("tbfy_admin_overview_info", self.InfoList)
	Info:SetInfo("Lockdown:", Lockdown)
	table.insert(self.InfoP, Info)
end

local Pad = 2
function PANEL:PerformLayout(W, H)
	local Parent = self:GetParent()
	local PW, PH = Parent:GetWide()-10, Parent:GetTall()-22

	local ListW = PW/4
	self.InfoPanel:SetPos(1,1)
	self.InfoPanel:SetSize(ListW, PH)

	self.WantedPanel:SetPos(ListW+3,1)
	self.WantedPanel:SetSize(ListW, PH)

	self.ArrestedPanel:SetPos(ListW*2+5,1)
	self.ArrestedPanel:SetSize(ListW, PH)

	self.GunlicensePanel:SetPos(ListW*3+7,1)
	self.GunlicensePanel:SetSize(ListW, PH)

	ListW = ListW-10
	self.InfoList:SetPos(5, 25)
	self.InfoList:SetSize(ListW+15, PH-30)

	self.WantedList:SetPos(5, 25)
	self.WantedList:SetSize(ListW+15, PH-30)

	self.ArrestedList:SetPos(5, 25)
	self.ArrestedList:SetSize(ListW+15, PH-30)

	self.GunlicenseList:SetPos(5, 25)
	self.GunlicenseList:SetSize(ListW+15, PH-30)

	local HStart = 0
	for k,v in pairs(self.InfoP) do
		v:SetPos(0, HStart)
		v:SetSize(ListW, 15)
		HStart = HStart + 18
	end

	local HStart = 0
	for k,v in pairs(self.WantedP) do
		v:SetPos(0, HStart)
		v:SetSize(ListW, 35)
		HStart = HStart + 35
	end

	HStart = 0
	for k,v in pairs(self.ArrestedP) do
		v:SetPos(0, HStart)
		v:SetSize(ListW, 35)
		HStart = HStart + 35
	end

	HStart = 0
	for k,v in pairs(self.GunlicenseP) do
		v:SetPos(0, HStart)
		v:SetSize(ListW, 35)
		HStart = HStart + 35
	end
end
vgui.Register("tbfy_administration_overview", PANEL)

local PANEL = {}

function PANEL:Init()
	self.ButtonTBL = {}
	self.PlayerListTBL = {}

	self.ActionList = vgui.Create("DScrollPanel", self)
	self.ActionList.VBar.Paint = function() end
	self.ActionList.VBar.btnUp.Paint = function() end
	self.ActionList.VBar.btnDown.Paint = function() end
	self.ActionList.VBar.btnGrip.Paint = function() end

	for k,v in pairs(TBFY_SH.CompAdmin.Actions) do
		local But = vgui.Create("tbfy_button", self.ActionList)
		But:SetBText(v.Name)
		But.DoClick = function()
      local Req = nil
      local ReqD = v.ReqData
      if ReqD then
    	   Req = vgui.Create("tbfy_comp_reqdata")
      end
  		local Func = function()
  			net.Start("tbfy_computer_run")
  				net.WriteString(self.MainP.SoftID)
  				net.WriteString("Action")
  				net.WriteFloat(k)
          if IsValid(Req) then
            if ReqD.Type == "Numeric" then
							local val = tonumber(Req.TextEntry:GetValue())
							if val then
              	net.WriteFloat(val)
							end
            else
              net.WriteString(Req.TextEntry:GetValue())
            end
          end
  			net.SendToServer()
  		end
      if Req then
    		Req:Setup(ReqD.Title, ReqD.Text, ReqD.But1, true, ReqD.But2, ReqD.Type, Func)
      else
        Func()
      end
		end
		self.ButtonTBL[k] = But
	end

	self.PlayerList = vgui.Create("DScrollPanel", self)

	local PlayersSorted = player.GetAll()
	table.sort(PlayersSorted, function (P1, P2)
		if (!P1) then return false; end
		if (!P2) then return true; end

		local P1S = string.lower(P1:Nick());
		local P2S = string.lower(P2:Nick());

		return P1S < P2S
	end)

	for k,v in pairs(PlayersSorted) do
		local PlayerP = vgui.Create("tbfy_administration_player", self.PlayerList)
		PlayerP.Parent = self
		PlayerP:SetPlayer(v)
		self.PlayerListTBL[k] = PlayerP
	end
end

function PANEL:PerformLayout(W, H)
	local Parent = self:GetParent()
	local PW, PH = Parent:GetWide()-2, Parent:GetTall()-32

	self.ActionList:SetPos(0, 5)
	self.ActionList:SetSize(PW*.25+15, PH)
	local ButH = 0
	for k,v in pairs(self.ButtonTBL) do
		v:SetSize(PW*.25-10, 25)
		v:SetPos(5,ButH)
		ButH = ButH + 26
	end

	self.PlayerList:SetPos(PW*.25+2,5)
	self.PlayerList:SetSize(PW*.75, PH)

	local PlistW = self.PlayerList:GetCanvas():GetWide()
	local ButH = 0
	for k,v in pairs(self.PlayerListTBL) do
		v:SetSize(PlistW-10, 80)
		v:SetPos(5,ButH)
		ButH = ButH + 80
	end
end

function PANEL:Paint(W, H)
	local Parent = self:GetParent()
	local PW, PH = Parent:GetWide()-2, Parent:GetTall()-22

	draw.RoundedBox(4, 0, 0, PW*.25, PH, Derma.TabListColors)
	draw.RoundedBox(4, PW*.25+2, 0, PW*.75, PH, Derma.TabListColors)
end
vgui.Register("tbfy_administration_actions", PANEL)

local PANEL = {}

function PANEL:Init()
end

function PANEL:PerformLayout(W, H)
end

function PANEL:Paint(W, H)
end
vgui.Register("tbfy_administration_employees", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self.Sheet = vgui.Create("DPropertySheet", self)
	self.Sheet:SetPadding(1)
	//self.Sheet.OColor = CProgramBG

	for k,v in pairs(TBFY_SH.CompAdmin.Category) do
		local Sheet = vgui.Create(v.Child, self.Sheet)
		Sheet.MainP = self

		self.Sheet:AddSheet(v.Name, Sheet)
	end
end

function PANEL:UpdateData(Data)

end

function PANEL:PerformLayout(W, H)
	self.Sheet:SetSize(W,H)
end

function PANEL:Paint(W, H)

end
vgui.Register("tbfy_comp_administration", PANEL)
