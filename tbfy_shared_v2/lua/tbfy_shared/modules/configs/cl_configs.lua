
function TBFY_SH:RequestConfig(CatID)
	net.Start("tbfy_request_configs")
		net.WriteString(CatID)
		net.WriteBool(true)
	net.SendToServer()
end

net.Receive("tbfy_update_c_config", function()
	local AName, Amount = net.ReadString(), net.ReadFloat()
	for i = 1, Amount do
		local ID, Type = net.ReadString(), net.ReadString()
		local Val = nil
		if Type == "Bool" then
			Val = net.ReadBool()
		elseif Type == "Number" or Type == "Job" then
			Val = net.ReadFloat()
		elseif Type == "Jobs" then
			Val = {}
			local Amount = net.ReadFloat()
			for i = 1, Amount do
				Val[net.ReadFloat()] = true
			end
		elseif Type == "SWEPs" then
			Val = {}
			local Amount = net.ReadFloat()
			for i = 1, Amount do
				Val[net.ReadString()] = true
			end
		elseif Type == "SWEP" or Type == "Text" or "TextOptions" then
			Val = net.ReadString()
		end
		TBFY_SH.Configs[AName][ID].Val = Val
	end
end)

net.Receive("tbfy_request_configs", function()
	local Amount = net.ReadFloat()

	local ConfD = {}
	for i = 1, Amount do
		local ID, Type = net.ReadString(), net.ReadString()
		local Val = nil
		if Type == "Bool" then
			Val = net.ReadBool()
		elseif Type == "Number" or Type == "Job" then
			Val = net.ReadFloat()
		elseif Type == "Jobs" then
			Val = {}
			local Amount = net.ReadFloat()
			for i = 1, Amount do
				Val[net.ReadFloat()] = true
			end
		elseif Type == "SWEPs" then
			Val = {}
			local Amount = net.ReadFloat()
			for i = 1, Amount do
				Val[net.ReadString()] = true
			end
		elseif Type == "SWEP" or Type == "Text" or Type == "TextOptions" then
			Val = net.ReadString()
		end
		ConfD[ID] = Val
	end

	if IsValid(TBFY_LASTConfig) then
		TBFY_LASTConfig:LoadConfigs(ConfD)
	end
end)

local Derma = TBFY_SH.Config.Derma

local PANEL = {}

function PANEL:Init()
	self.ID = ""
	self.Desc = ""
end

function PANEL:SetConfig(ID, Data, Value)
	self.ID = ID
	self.Desc = Data.Desc

	self.Type = Data.Type

	if self.Type == "Bool" then
		local ValToSet = Value

		if ValToSet == nil then
			ValToSet = Data.Default
		end

		self.ToggleB = vgui.Create("tbfy_button_toggle", self)
		self.ToggleB:SetSliderInfo(12, 0.17)
		self.ToggleB:SetToggleInfo("Enabled", Derma.WColor, Derma.GBGColor, "Disabled", Derma.WColor, Derma.RBGColor, nil, true, ValToSet)
		self.Val = ValToSet
		self.ToggleB.OnValueChanged = function(selfp, Val)
			self.Val = Val
			self.Adjusted = true
		end
	elseif self.Type == "Number" then
		local Vals = Data.Default
		local ValToSet = Value or Vals.Val

		self.NumberInput = vgui.Create("DNumSlider", self)
		self.NumberInput.PerformLayout = function() self.NumberInput.Label:SetSize(0,0) end
		self.NumberInput:SetMin(Vals.Min)
		self.NumberInput:SetMax(Vals.Max)
		self.NumberInput:SetDecimals(Vals.Decimals)
		self.NumberInput:SetValue(ValToSet)
		self.NumberInput:SetDark(true)
		self.Val = ValToSet
		self.NumberInput.OnValueChanged = function(selfp, Val)
			self.Val = math.Round(Val)
			self.Adjusted = true
		end
	elseif self.Type == "Jobs" then
		local ValToSet = Value or Data.Default

		self.SetupJobs = vgui.Create("tbfy_button", self)
		self.SetupJobs:SetBText("Setup Jobs")
		self.SetupJobs.DoClick = function()
				local JobsConf = vgui.Create("tbfy_config_jobs")
				JobsConf:UpdateJobs(ID, ValToSet, self)
		end
	elseif self.Type == "SWEPs" then
		local ValToSet = Value or Data.Default

		self.SetupSWEPs = vgui.Create("tbfy_button", self)
		self.SetupSWEPs:SetBText("Setup SWEPs")
		self.SetupSWEPs.DoClick = function()
				local SWEPsConf = vgui.Create("tbfy_config_sweps")
				SWEPsConf:UpdateSWEPs(ID, ValToSet, self)
		end
	elseif self.Type == "Job" then
		local ValToSet = Value or Data.Default

		self.SelectJob = vgui.Create("DComboBox", self)
		local AllJobs = team.GetAllTeams()
		//Get rid off unassigned/spec/joining
		AllJobs[0] = nil
		AllJobs[1001] = nil
		AllJobs[1002] = nil
		for k,v in pairs(AllJobs) do
			local Selected = false
			if k == ValToSet then
				Selected = true
			end
			self.SelectJob:AddChoice(v.Name,k, Selected)
		end
		self.SelectJob.OnSelect = function(selfp, index, value, data)
			self.Val = data
			self.Adjusted = true
		end
	elseif self.Type == "SWEP" then
		local ValToSet = Value or Data.Default

		self.SelectSWEP = vgui.Create("DComboBox", self)
		local AllSWEPs = weapons.GetList()
		for k,v in pairs(AllSWEPs) do
			local Selected = false
			if v.ClassName == ValToSet then
				Selected = true
			end
			self.SelectSWEP:AddChoice(v.ClassName,v.ClassName, Selected)
		end
		self.SelectSWEP.OnSelect = function(selfp, index, value, data)
			self.Val = data
			self.Adjusted = true
		end
	elseif self.Type == "Text" then
		local ValToSet = Value or Data.Default

		self.TextInput = vgui.Create("DTextEntry", self)
		self.TextInput:SetValue(ValToSet)
		self.TextInput:SetUpdateOnType(true)
		self.TextInput.OnValueChange = function(selfp, value)
			self.Val = value
			self.Adjusted = true
		end
	elseif self.Type == "TextOptions" then
		local Vals = Data.Default
		local ValToSet = Value or Vals.Val

		self.TextOption = vgui.Create("DComboBox", self)
		for k,v in pairs(Vals.Options) do
			local Selected = false
			if v.ID == ValToSet then
				Selected = true
			end
			self.TextOption:AddChoice(v.Name,v.ID, Selected)
		end
		self.TextOption.OnSelect = function(selfp, index, value, data)
			self.Val = data
			self.Adjusted = true
		end
	end
end

function PANEL:PerformLayout(W,H)
	if self.ToggleB then
		self.ToggleB:SetPos(W-80, H/2-12.5)
		self.ToggleB:SetSize(75,25)
	elseif self.NumberInput then
		self.NumberInput:SetPos(W-125, H/2-12.5)
		self.NumberInput:SetSize(125,25)
	elseif self.SetupJobs then
		self.SetupJobs:SetPos(W-80, H/2-12.5)
		self.SetupJobs:SetSize(75, 25)
	elseif self.SetupSWEPs then
		self.SetupSWEPs:SetPos(W-80, H/2-12.5)
		self.SetupSWEPs:SetSize(75, 25)
	elseif self.SelectJob then
		self.SelectJob:SetPos(W-105, H/2-12.5)
		self.SelectJob:SetSize(95,25)
	elseif self.SelectSWEP then
		self.SelectSWEP:SetPos(W-105, H/2-12.5)
		self.SelectSWEP:SetSize(95,25)
	elseif self.TextInput then
		self.TextInput:SetPos(W-105, H/2-12.5)
		self.TextInput:SetSize(95,25)
	elseif self.TextOption then
		self.TextOption:SetPos(W-105, H/2-12.5)
		self.TextOption:SetSize(95,25)
	end
end

function PANEL:Paint(W, H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.SecondPanelColor)
	draw.SimpleText(self.ID, "tbfy_config_name", 5, 5, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(self.Desc, "tbfy_config_desc", 5, 25, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_config", PANEL)

local PANEL = {}

function PANEL:Init()
	self:MakePopup()
	self.AddonN = ""
	self.ConfigsB = {}

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(8, 0, 0, W, H, Derma.HeaderColor, true, true, false, false)
		draw.SimpleText(self.AddonN .. " - Configs", "tbfy_header", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.ConfList = vgui.Create("DScrollPanel", self)
	self.ConfList.Paint = function(selfp, W, H)
	end
	self.ConfList.VBar.Paint = function() end
	self.ConfList.VBar.btnUp.Paint = function() end
	self.ConfList.VBar.btnDown.Paint = function() end
	self.ConfList.VBar.btnGrip.Paint = function() end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function()
		self:Remove()
	end
end

function PANEL:SetConfigs(AID, AName)
	TBFY_LASTConfig = self

	net.Start("tbfy_request_configs")
		net.WriteString(AID)
	net.SendToServer()

	self.AddonN = AName
	self.AID = AID
end

function PANEL:LoadConfigs(ConfD)
	local Confs = TBFY_SH.Configs[self.AID]
	if Confs then
		local IDs = {}
		for k,v in pairs(Confs) do
			table.insert(IDs, k)
		end
		table.sort(IDs, function(a, b) return a:upper() < b:upper() end)
		for k,v in ipairs(IDs) do
			local Conf = vgui.Create("tbfy_config", self.ConfList)
			Conf:SetConfig(v, Confs[v], ConfD[v])
			self.ConfigsB[k] = Conf
		end
	end
	self.CloseButton.DoClick = function(selfp)
		local NewConf = {}
		for k,v in pairs(self.ConfigsB) do
			if v.Adjusted then
				NewConf[v.ID] = {Type = v.Type, Val = v.Val}
			end
		end

		local ConfA = table.Count(NewConf)
		net.Start("tbfy_update_config")
			net.WriteString(self.AID)
			net.WriteFloat(ConfA)
			for k,v in pairs(NewConf) do
				net.WriteString(k)
				net.WriteString(v.Type)
				if v.Type == "Bool" then
					net.WriteBool(v.Val)
				elseif v.Type == "Number" or v.Type == "Job" then
					net.WriteFloat(v.Val)
				elseif v.Type == "Jobs" then
					local Amount = table.Count(v.Val)
					net.WriteFloat(Amount)
					for id,bool in pairs(v.Val) do
						net.WriteFloat(id)
					end
				elseif v.Type == "SWEPs" then
					local Amount = table.Count(v.Val)
					net.WriteFloat(Amount)
					for id,bool in pairs(v.Val) do
						net.WriteString(id)
					end
				elseif v.Type == "SWEP" or v.Type == "Text" or v.Type == "TextOptions" then
					net.WriteString(v.Val or "")
				end
			end
		net.SendToServer()

		self:Remove()
	end
end

local Width, Height = 600, 500
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetSize(W,Derma.HeaderH)

	self.ConfList:SetPos(0, Derma.HeaderH)
	self.ConfList:SetSize(W+10, H-Derma.HeaderH-5)

	local Hstart = 5
	for k,v in pairs(self.ConfigsB) do
		v:SetPos(5,Hstart)
		v:SetSize(W-10,45)
		Hstart = Hstart + 50
	end

	self.CloseButton:SetPos(Width-25,3)
	self.CloseButton:SetSize(20, 20)
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(4, 0, Derma.HeaderH, W, H-Derma.HeaderH, Derma.MainPanelColor, false, false, true, true)
end
vgui.Register("tbfy_edit_config", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self:MakePopup()

	self.AllowedJobs = {}
	self.Title = ""
	self.Parent = nil

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(8, 0, 0, W, H, Derma.HeaderColor, true, true, false, false)
		draw.SimpleText(self.Title, "tbfy_header", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
			self.AllowedJobs[JobID] = nil
		else
			CurV = TBFY_GetLang("Yes")
			self.AllowedJobs[JobID] = true
		end
		if IsValid(self.Parent) then
			self.Parent.Val = self.AllowedJobs
			self.Parent.Adjusted = true
		end
		Line:SetColumnText(2, CurV)
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function()
		self:Remove()
	end
end

function PANEL:UpdateJobs(ID, ConfigJobs, Parent)
	self.Title = ID
	self.Parent = Parent
	self.AllowedJobs = ConfigJobs

	local AllJobs = team.GetAllTeams()
	//Get rid off unassigned/spec/joining
	AllJobs[0] = nil
	AllJobs[1001] = nil
	AllJobs[1002] = nil
	for k,v in pairs(AllJobs) do
		local Text = TBFY_GetLang("No")
		if ConfigJobs[k] then
			Text = TBFY_GetLang("Yes")
		end
		local Line = self.JobsA:AddLine(v.Name, Text)
		Line.JobID = k
	end
end

local Width, Height = 250, 300
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetSize(W,Derma.HeaderH)

	self.JobsA:SetPos(5,Derma.HeaderH+5)
	self.JobsA:SetSize(W-10, Height - Derma.HeaderH - 10)

	self.CloseButton:SetPos(Width-25,3)
	self.CloseButton:SetSize(20, 20)
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(4, 0, Derma.HeaderH, W, H-Derma.HeaderH, Derma.MainPanelColor, false, false, true, true)
end
vgui.Register("tbfy_config_jobs", PANEL, "DFrame")

local PANEL = {}
function PANEL:Init()
	self:MakePopup()

	self.AllowedSWEPs = {}
	self.Title = ""
	self.Parent = nil

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(8, 0, 0, W, H, Derma.HeaderColor, true, true, false, false)
		draw.SimpleText(self.Title, "tbfy_header", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.SWEPA = vgui.Create("DListView", self)
	self.SWEPA:SetMultiSelect(false)
	self.SWEPA:AddColumn(TBFY_GetLang("SWEP"))
	self.SWEPA:AddColumn(TBFY_GetLang("Allowed"))
	self.SWEPA.OnRowSelected = function(selfp, Index, Line)
		local CurV = Line:GetValue(2)
		local SWEPClass = Line.SWEPClass
		if CurV == TBFY_GetLang("Yes") then
			CurV = TBFY_GetLang("No")
			self.AllowedSWEPs[SWEPClass] = nil
		else
			CurV = TBFY_GetLang("Yes")
			self.AllowedSWEPs[SWEPClass] = true
		end
		if IsValid(self.Parent) then
			self.Parent.Val = self.AllowedSWEPs
			self.Parent.Adjusted = true
		end
		Line:SetColumnText(2, CurV)
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function()
		self:Remove()
	end
end

function PANEL:UpdateSWEPs(ID, ConfigSWEPs, Parent)
	self.Title = ID
	self.Parent = Parent
	self.AllowedSWEPs = ConfigSWEPs

	local AllSWEPs = weapons.GetList()
	for k,v in pairs(AllSWEPs) do
		local Text = TBFY_GetLang("No")
		if ConfigSWEPs[v.ClassName] then
			Text = TBFY_GetLang("Yes")
		end
		local Line = self.SWEPA:AddLine(v.ClassName, Text)
		Line.SWEPClass = v.ClassName
	end
end

local Width, Height = 250, 300
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetSize(W,Derma.HeaderH)

	self.SWEPA:SetPos(5,Derma.HeaderH+5)
	self.SWEPA:SetSize(W-10, Height - Derma.HeaderH - 10)

	self.CloseButton:SetPos(Width-25,3)
	self.CloseButton:SetSize(20, 20)
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(4, 0, Derma.HeaderH, W, H-Derma.HeaderH, Derma.MainPanelColor, false, false, true, true)
end
vgui.Register("tbfy_config_sweps", PANEL, "DFrame")
