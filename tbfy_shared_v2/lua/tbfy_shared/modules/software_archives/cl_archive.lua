
TBFY_SH.GArchives_Updated = TBFY_SH.GArchives_Updated or {}

net.Receive("tbfy_archive_senddata", function()
	local SoftID, SID, ArchAmount = net.ReadString(), net.ReadString(), net.ReadUInt(4)
	local CTime = os.time()

	TBFY_SH.GArchives_Updated[SID] = TBFY_SH.GArchives_Updated[SID] or {}
	for i = 1, ArchAmount do
		local ID, ShouldUpdate = net.ReadUInt(4), net.ReadBool()
		if ShouldUpdate then
			local Tbl = {}

			local DataAmount = net.ReadUInt(32)
			for index = 1, DataAmount do
				local Act, Reason, Time = net.ReadString(), net.ReadString(), CTime-net.ReadUInt(32)
				Tbl[index] = {actor = Act, reason = Reason, time = Time}
			end

			TBFY_SH.GArchives_Updated[SID][ID] = Tbl
		end
	end
end)

local Derma = TBFY_SH.Config.Derma

local PANEL = {}

function PANEL:Init()
	self.Actor = vgui.Create("tbfy_label", self)
	self.Actor:SetFont("tbfy_archives_text")
	self.Actor:SetAlignX(TEXT_ALIGN_LEFT)
	self.Actor:SetDisplayHoverText(true)

	self.Reason = vgui.Create("tbfy_label", self)
	self.Reason:SetFont("tbfy_archives_text")
	self.Reason:SetDisplayHoverText(true)

	self.Time = vgui.Create("tbfy_label", self)
	self.Time:SetFont("tbfy_archives_text")
	self.Time:SetAlignX(TEXT_ALIGN_RIGHT)
	self.Time:SetDisplayHoverText(true)
end

function PANEL:SetC()
	self.OColor = true
end

local function SecondsToDays(Time)
	local Mins, Hours, Days = Time/60, Time/(60*60), Time/(60*60*24)
	if Days >= 1 then
		return math.Round(Days) .. " days ago"
	elseif Hours >= 1 then
		return math.Round(Hours) .. " hours ago"
	else
		return math.Round(Mins) .. " minutes ago"
	end
end

function PANEL:SetInfo(Tbl)
	self.Actor:SetText(Tbl.actor)
	self.Reason:SetText(Tbl.reason)
	self.Time:SetText(SecondsToDays(Tbl.time))
end

function PANEL:Paint(W,H)
	if self.OColor then
		draw.RoundedBox(4, 0, 0, W, H, Derma.ArchiveColor2)
	end

	//draw.SimpleText(self.Actor, "tbfy_archives_text", 8, H/2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	//draw.SimpleText(self.Reason, "tbfy_archives_text", W/2, H/2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	//draw.SimpleText(self.Time, "tbfy_archives_text", W-5, H/2, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

function PANEL:PerformLayout(W,H)
	self.Actor:SetPos(8, 0)
	self.Actor:SetSize(W/3-13, 30)

	self.Reason:SetPos(W/2-W/6, 0)
	self.Reason:SetSize(W/3, 30)

	self.Time:SetPos(W - W/3+5, 0)
	self.Time:SetSize(W/3-10, 30)
end
vgui.Register("tbfy_archive_infoline", PANEL)

local PANEL = {}

function PANEL:Init()
	self.VBar.Paint = function() end
	self.VBar.btnUp.Paint = function() end
	self.VBar.btnDown.Paint = function() end
	self.VBar.btnGrip.Paint = function() end
	self.Elements = {}
	self.ID = 1
end

function PANEL:SetAData(Parent, Data, ID)
	self.ID = ID

	if Data and Data[ID] then
		if #Data[ID] > 1 then
			table.sort(Data[ID], function (P1, P2)
				if !P1 or !P1.time then return false end
				if !P2 or !P2.time then return true end

				return P1.time < P2.time
			end)
		end

		local InfoH = 18
		for k,v in pairs(Data[ID]) do
			local InfoLine = vgui.Create("tbfy_archive_infoline", self)
			InfoLine:SetInfo(v)
			local rest = k%2
			if rest == 0 then
				InfoLine:SetC()
			end
			InfoLine:SetPos(0, InfoH)
			InfoLine:SetSize(self:GetWide(), 25)
			InfoH = InfoH + 25
			self.Elements[k] = InfoLine
		end
	end
end

local Actor = {
[1] = "Wanted by",
[2] = "Warrant by",
[3] = "Arrested by",
}

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.ArchiveColor)
	draw.SimpleText(Actor[self.ID], "tbfy_archives_subheader", 5, 5, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("Reason", "tbfy_archives_subheader", W/2, 5, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	draw.SimpleText("Time", "tbfy_archives_subheader", W-5, 5, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_archive_infofiller", PANEL, "DScrollPanel")

local PANEL = {}

function PANEL:Init()
	self.Name = ""
	self.SID = ""
	self.Job = ""
	self.Selected = ""
	self.ButtonTBL = {}

	self.InfoPanel = vgui.Create("DPanel", self)
	self.InfoPanel.Paint = function(selfp, W, H)
	end

	self.ButtonList = vgui.Create("DScrollPanel", self)
	self.ButtonList.VBar.Paint = function() end
	self.ButtonList.VBar.btnUp.Paint = function() end
	self.ButtonList.VBar.btnDown.Paint = function() end
	self.ButtonList.VBar.btnGrip.Paint = function() end

	for k,v in pairs(TBFY_SH.GArchiveTypes) do
		local CButton = vgui.Create("tbfy_button", self.ButtonList)
		CButton:SetBText(v.Name)
		CButton:SetBFont("tbfy_archives_button")
		CButton.DoClick = function() self.Selected = v.Name self:SetInfoPType(v.ID) end
		self.ButtonTBL[v.ID] = CButton
	end
end

function PANEL:SetInfoPType(ID)
	if IsValid(self.InfoFiller) then
		self.InfoFiller:Remove()
	end

	local GArch = TBFY_SH.GArchiveTypes[ID]
	if GArch then
		local Parent = self:GetParent()
		local W,H = self.InfoPanel:GetWide(), self.InfoPanel:GetTall()
		if GArch.UI then
			self.InfoFiller = vgui.Create(GArch.UI, self.InfoPanel)
			self.InfoFiller:SetSize(W,H)
			self.InfoFiller:InitData(self.Player, Parent, ID)
		else
			self.InfoFiller = vgui.Create("tbfy_archive_infofiller", self.InfoPanel)
			self.InfoFiller:SetSize(W,H)
			self.InfoFiller:SetAData(Parent, TBFY_SH.GArchives_Updated[self.SID], ID)
		end
	end
end

function PANEL:SetPInfo(Player)
	if !self:IsVisible() then
		self:SetVisible(true)
	end

	self.Name = Player:Nick()
	self.SID = TBFY_SH:SID(Player)
	self.Player = Player
	self.Job = Player:getDarkRPVar("job")

	if IsValid(self.InfoFiller) then
		self.InfoFiller:Remove()
		self.Selected = ""
	end
end

function PANEL:Paint(W,H)
	W = W - 30

	draw.RoundedBox(4, 0, 0, W, H, Derma.TabListColors)

	surface.SetFont("tbfy_archives_header")
	local Name = self.Name
	local TW, TH = surface.GetTextSize(Name)
	local BW, BH = TW+10, TH+5

	draw.RoundedBox(8, (W*0.75-35)/2-BW/2, 5, BW, BH, Derma.HeaderColor)
	draw.SimpleText(Name, "tbfy_archives_header", (W*0.75-35)/2, Derma.HeaderH/2+2.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.SimpleText("SteamID: " .. self.SID, "tbfy_archives_button", 5, Derma.HeaderH+15, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("Job: " .. self.Job, "tbfy_archives_button", 5, Derma.HeaderH+30, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	draw.SimpleText(self.Selected, "tbfy_archives_header", W*0.75/2-5, 75, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

function PANEL:PerformLayout(W,H)
	self.ButtonList:SetPos(W*0.75-35,0)
	self.ButtonList:SetSize(W*0.25, H-5)

	self.InfoPanel:SetPos(5,75)
	self.InfoPanel:SetSize(W*0.75-45, H-80)

	local ButtonH = 5
	for k,v in pairs(self.ButtonTBL) do
		v:SetPos(0,ButtonH)
		v:SetSize(self.ButtonList:GetWide(), 25)

		ButtonH = ButtonH + 30
	end
end
vgui.Register("tbfy_archive_info", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self.ButtonTBL = {}

	self.ButtonList = vgui.Create("DScrollPanel", self)
	self.ButtonList.Paint = function(selfp, W, H)
		draw.RoundedBox(4, 0, 0, W-15, H, Derma.TabListColors)
	end
	self.ButtonList.VBar.Paint = function() end
	self.ButtonList.VBar.btnUp.Paint = function() end
	self.ButtonList.VBar.btnDown.Paint = function() end
	self.ButtonList.VBar.btnGrip.Paint = function() end

	self.InformationPanel = vgui.Create("tbfy_archive_info", self)
	self.InformationPanel:SetVisible(false)

	local PlayersSorted = player.GetAll()
	table.sort(PlayersSorted, function (P1, P2)
		if (!P1) then return false; end
		if (!P2) then return true; end

		local P1S = string.lower(P1:Nick());
		local P2S = string.lower(P2:Nick());

		return P1S < P2S
	end)

	self.CachedPlayer = {}
	for k,v in pairs(PlayersSorted) do
		local CButton = vgui.Create("tbfy_button", self.ButtonList)
		CButton:SetBText(v:Nick())
		CButton:SetBFont("tbfy_archives_button")
		CButton.DoClick = function()
			local SID = TBFY_SH:SID(v)
			if !self.CachedPlayer[SID] then
				self.CachedPlayer[SID] = true
				net.Start("tbfy_computer_run")
					net.WriteString(self.SoftID)
					net.WriteString(SID)
				net.SendToServer()
			end
			self.InformationPanel:SetPInfo(v)
		end

		self.ButtonTBL[k] = CButton
	end
end

function PANEL:UpdateData(Data)
end

function PANEL:PerformLayout(W, H)
	self.InformationPanel:SetPos(W*0.2-5,1)
	self.InformationPanel:SetSize(W*0.8+32,H-5)

	self.ButtonList:SetPos(5,1)
	self.ButtonList:SetSize(W*0.2, H-5)

	local ButtonH = 5
	for k,v in pairs(self.ButtonTBL) do
		v:SetPos(5,ButtonH)
		v:SetSize(self.ButtonList:GetWide()-25, 25)

		ButtonH = ButtonH + 26
	end
end

function PANEL:Paint(W, H)
end
vgui.Register("tbfy_comp_archive", PANEL)
