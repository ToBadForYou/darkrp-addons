
TBFY_SH.SetupTbl = TBFY_SH.SetupTbl or {}

function TBFY_SH.SetupCategory(self, CatName)
	TBFY_SH.SetupTbl[CatName] = TBFY_SH.SetupTbl[CatName] or {}
	TBFY_SH.SetupTbl[CatName].Ents = TBFY_SH.SetupTbl[CatName].Ents or {}
	TBFY_SH.SetupTbl[CatName].Buttons = TBFY_SH.SetupTbl[CatName].Buttons or {}
end

function TBFY_SH.SetupEntity(self, CatName, Name, Entity, Model, Offs, SEnts, NoGEnt, AngAdj)
	TBFY_SH.SetupTbl[CatName].Ents[Entity] = {N = Name, M = Model, CFuncL = nil, CFuncR = nil, CFuncDraw = nil, CFuncThink = nil, Offset = Offs, SEnts = SEnts, NoGhost = NoGEnt, AngAdj = AngAdj}
end

function TBFY_SH.SetupCustomFunctionL(self, CatName, Entity, Func)
	TBFY_SH.SetupTbl[CatName].Ents[Entity].CFuncL = Func
end

function TBFY_SH.SetupCustomFunctionR(self, CatName, Entity, Func)
	TBFY_SH.SetupTbl[CatName].Ents[Entity].CFuncR = Func
end

function TBFY_SH.SetupCustomFunctionDraw(self, CatName, Entity, Func)
	TBFY_SH.SetupTbl[CatName].Ents[Entity].CFuncDraw = Func
end

function TBFY_SH.SetupCustomFunctionThink(self, CatName, Entity, Func)
	TBFY_SH.SetupTbl[CatName].Ents[Entity].CFuncThink = Func
end

function TBFY_SH.SetupCMDButton(self, CatName, Name, CMD, CFunc)
	TBFY_SH.SetupTbl[CatName].Buttons[Name] = {CMD = CMD, CFunc = CFunc}
end

net.Receive("tbfy_update_computer", function()
	local Menu = LocalPlayer().TBFY_EditComputer
	if IsValid(Menu) then
		local Name, PCType, Soft, Jobs = net.ReadString(), net.ReadFloat(), net.ReadString(), net.ReadString()

		local ESoftString = string.Explode(":", Soft)
		local SoftTbl = {}
		for k,v in pairs(ESoftString) do
			if v != "" then
				SoftTbl[v] = true
			end
		end

		local EJobIDString = string.Explode(":", Jobs)
		local JobTbl = {}
		for k,v in pairs(EJobIDString) do
			if v != "" then
				JobTbl[tonumber(v)] = true
			end
		end

		Menu:UpdateComputerSettings(Name, PCType, SoftTbl, JobTbl)
	end
end)

local Derma = TBFY_SH.Config.Derma

local PANEL = {}

function PANEL:AddSheet(label, panel, material)

	if (!IsValid(panel)) then return end

	local Sheet = {}

	Sheet.Button = vgui.Create("tbfy_button", self.Navigation)

	Sheet.Button:SetImage(material)
	Sheet.Button.Target = panel
	Sheet.Button:Dock(TOP)
	Sheet.Button:SetBText(label)
	Sheet.Button:DockMargin( 0, 1, 0, 0 )

	Sheet.Button.DoClick = function()
		self:SetActiveButton(Sheet.Button)
	end

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetVisible( false )

	table.insert(self.Items, Sheet)

	if (!IsValid(self.ActiveButton)) then
		self:SetActiveButton(Sheet.Button)
	end

end
vgui.Register("tbfy_DColumnSheet", PANEL, "DColumnSheet")

local PANEL = {}

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0,Derma.Padding,W-Derma.Padding,H-Derma.Padding*2,Derma.TabListColors)
end
vgui.Register("tbfy_DPanel", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self:SetSize(50, 60)
	self.Name = ""

	self.SpawnI = vgui.Create("SpawnIcon" , self)
end

function PANEL:SetupIcon(Class, ETbl)
	self.SpawnI:Dock(FILL)
	self.SpawnI:SetModel(ETbl.M)
	self.SpawnI.DoClick = function()
		local Swep = LocalPlayer():GetActiveWeapon()
		if IsValid(Swep) then
			Swep:UpdateSelectedEnt(Class, ETbl)
		end
	end
	self.Name = ETbl.N
end

function PANEL:PaintOver(W,H)
	surface.SetFont("tbfy_entname")
	local N = self.Name
	local TW, TH = surface.GetTextSize(N)
	TW = TW + 4
	draw.RoundedBox(4, W/2-TW/2, H-TH, TW, TH, Derma.HeaderColor)
	draw.SimpleText(N, "tbfy_entname", W/2, H, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end
vgui.Register("tbfy_DEnt", PANEL)

local PANEL = {}

function PANEL:Init()
	self:MakePopup()

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(8, 0, 0, W, H, Derma.HeaderColor, true, true, false, false)
		draw.SimpleText("TBFY - Setup Tool", "tbfy_header", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.Sheet = vgui.Create("tbfy_DColumnSheet", self)

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end

	self:InitSetup()
end

local Width, Height = 500, 550
function PANEL:InitSetup()
	self.DPanels = {}
	for k,v in pairs(TBFY_SH.SetupTbl) do
		local panel = vgui.Create("tbfy_DPanel", self.Sheet)
		self.Sheet:AddSheet(k, panel)

		local EntCat = vgui.Create("DCollapsibleCategory", panel)
		EntCat:SetLabel("Entities")
		EntCat:SetExpanded(1)

		local DList = vgui.Create("DPanelList", panel)
		DList:EnableHorizontal(false)
		DList:EnableVerticalScrollbar(true)
		EntCat:SetContents(DList)

		for Class, ETbl in pairs(v.Ents) do
			local EntD = vgui.Create("tbfy_DEnt" , DList)
			EntD:SetupIcon(Class, ETbl)
			DList:AddItem(EntD)
		end

		local ButCat = vgui.Create("DPanelList", panel)
		ButCat:EnableHorizontal(false)
		ButCat:EnableVerticalScrollbar(true)
		ButCat:SetSpacing(5)

		for Name,BTbl in pairs(v.Buttons) do
			local CMDBut = vgui.Create("tbfy_button", self)
			CMDBut:SetBText(Name)
			CMDBut.DoClick = function()
				local CMD, CFunc = BTbl.CMD, BTbl.CFunc
				if CFunc then
					CFunc()
				elseif CMD then
					LocalPlayer():ConCommand(CMD)
				end
			end
			ButCat:AddItem(CMDBut)
		end

		self.DPanels[k] = {Pan = panel, Cat = EntCat, But = ButCat}
	end
end

function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetSize(W,Derma.HeaderH)

	self.Sheet:SetPos(0,Derma.HeaderH)
	self.Sheet:SetSize(W,H-Derma.HeaderH)

	for k,v in pairs(self.DPanels) do
		v.Pan:Dock(FILL)

		local PW, PH = self.Sheet.Content:GetWide()-10, self.Sheet.Content:GetTall()-35
		v.Cat:SetPos(Derma.Padding, Derma.Padding*2)
		v.Cat:SetSize(PW*0.35-Derma.Padding,PH)

		v.But:SetPos(Derma.Padding + PW*0.35, Derma.Padding*2)
		v.But:SetSize(PW*0.65-Derma.Padding, PH)
	end

	self.CloseButton:SetPos(Width-25,3)
	self.CloseButton:SetSize(20, 20)
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(4, 0, Derma.HeaderH, W, H-Derma.HeaderH, Derma.MainPanelColor, false, false, true, true)
end
vgui.Register("tbfy_selectionmenu", PANEL)

local PANEL = {}

function PANEL:Init()
	self:MakePopup()
	self.EInfo = {}

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(8, 0, 0, W, H, Derma.HeaderColor, true, true, false, false)
		draw.SimpleText("Entity Information", "tbfy_header", W/2, H/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.SEType = vgui.Create("DComboBox", self)
	self.SEType:SetValue("SELECT ENTITY")
	self.SEType.OnSelect = function(selfp, index, value)
		local IVal = self.SEType:GetOptionData(index)
		local Data = self.EInfo[IVal]
		LocalPlayer().TBFY_LastEntData = Data
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:SetEntites(AName, EName)
	local PEnts = TBFY_SH.SetupTbl[AName].Ents[EName].SEnts
	for k,v in pairs(PEnts) do
		self.SEType:AddChoice(v.Name, k)
		self.EInfo[k] = v
	end
end

local Width, Height = 250, 160
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetSize(W,Derma.HeaderH)

	local WS = W/2-20
	self.SEType:SetPos(WS, Derma.HeaderH+15)
	self.SEType:SetSize(125,25)

	self.CloseButton:SetPos(Width-25,3)
	self.CloseButton:SetSize(20, 20)
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(4, 0, Derma.HeaderH, W, H-Derma.HeaderH, Derma.MainPanelColor, false, false, true, true)
	draw.SimpleText("Entity Type:", "tbfy_header", W/2-25, Derma.HeaderH+17.5, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_select_entity_others", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self:MakePopup()
	self.EInfo = {}

	local LP = LocalPlayer()
	LP.TBFY_EData = LP.TBFY_EData or {}

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(8, 0, 0, W, H, Derma.HeaderColor, true, true, false, false)
		draw.SimpleText("Entity Information", "tbfy_header", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.SComp = vgui.Create("DComboBox", self)
	self.SComp:SetValue("SELECT COMPUTER")
	self.SComp.OnSelect = function(selfp, index, value)
		LP.TBFY_LastComp = self.SComp:GetOptionData(index)
	end
	for k, v in pairs(ents.FindByClass("tbfy_computer")) do
		self.SComp:AddChoice(v:GetEName(), v:EntIndex())
	end

	self.SEType = vgui.Create("DComboBox", self)
	self.SEType:SetValue("SELECT ENTITY")
	self.SEType.OnSelect = function(selfp, index, value)
		local IVal = self.SEType:GetOptionData(index)
		local Data = self.EInfo[IVal]
		LP.TBFY_LastEntData = Data
	end

	self.SEName = vgui.Create("DTextEntry", self)
	self.SEName:SetText("ENTER UNIQUE NAME")
	self.SEName:SetUpdateOnType(true)
	self.SEName.OnValueChange = function(panel, value)
		LP.TBFY_EData.EName = value
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:SetEntites(AName, EName)
	local PEnts = TBFY_SH.SetupTbl[AName].Ents[EName].SEnts
	for k,v in pairs(PEnts) do
		self.SEType:AddChoice(v.Name, k)
		self.EInfo[k] = v
	end
end

local Width, Height = 250, 160
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetSize(W,Derma.HeaderH)

	local WS = W/2-20
	self.SComp:SetPos(WS, Derma.HeaderH+15)
	self.SComp:SetSize(125,25)

	self.SEType:SetPos(WS, Derma.HeaderH+55)
	self.SEType:SetSize(125,25)

	self.SEName:SetPos(WS, Derma.HeaderH+95)
	self.SEName:SetSize(125,25)

	self.CloseButton:SetPos(Width-25,3)
	self.CloseButton:SetSize(20, 20)
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(4, 0, Derma.HeaderH, W, H-Derma.HeaderH, Derma.MainPanelColor, false, false, true, true)
	draw.SimpleText("Computer:", "tbfy_header", W/2-25, Derma.HeaderH+17.5, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText("Entity Type:", "tbfy_header", W/2-25, Derma.HeaderH+57.5, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText("Identifier:", "tbfy_header", W/2-25, Derma.HeaderH+97.5, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_select_entity", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self:MakePopup()
	local LP = LocalPlayer()

	LP.TBFY_EData = LP.TBFY_EData or {}
	LP.TBFY_EData.SoftID = LP.TBFY_EData.SoftID or {}
	LP.TBFY_EData.JobID = LP.TBFY_EData.JobID or {}
	LP.TBFY_EData.PCType = LP.TBFY_EData.PCType or 1

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		draw.RoundedBoxEx(4, 0, 0, W, H, Derma.HeaderColor, true, true, false, false)
		draw.SimpleText("Computer Information", "tbfy_header", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.SEName = vgui.Create("DTextEntry", self)
	self.SEName:SetText(LP.TBFY_EData.EName or "ENTER UNIQUE NAME")
	self.SEName:SetUpdateOnType(true)
	self.SEName.OnValueChange = function(panel, value)
		LP.TBFY_EData.EName = value
	end

	self.PCType = vgui.Create("DComboBox", self)
	self.PCType:AddChoice("Government", 1)
	self.PCType:AddChoice("Public", 2)
	self.PCType:AddChoice("Private", 3)
	--self.PCType:SetTextColor(Color(0,0,0,255))
	self.PCType.OnSelect = function(selfp, Index, Val, Data)
		LP.TBFY_EData.PCType = Data
	end
	self.PCType:ChooseOptionID(LP.TBFY_EData.PCType)

	self.Softwares = vgui.Create("DListView", self)
	self.Softwares:SetMultiSelect(false)
	self.Softwares:AddColumn("Software")
	self.Softwares:AddColumn("Installed")

	local TypeNames = {"Government", "Public"}
	for k,v in pairs(TBFY_SH.CSoftwares) do
		if !v.Default and v.PCType and (v.PCType[1] or v.PCType[2]) then
			local Text = TBFY_GetLang("No")
			if LP.TBFY_EData.SoftID[k] then
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
	self.Softwares.OnRowSelected = function(selfp, Index, Line)
		local CurV = Line:GetValue(2)
		local SoftID = Line.SoftID
		if CurV == TBFY_GetLang("Yes") then
			CurV = TBFY_GetLang("No")
			LocalPlayer().TBFY_EData.SoftID[SoftID] = nil
		else
			CurV = TBFY_GetLang("Yes")
			LocalPlayer().TBFY_EData.SoftID[SoftID] = true
		end
		Line:SetColumnText(2, CurV)
	end

	self.JobsA = vgui.Create("DListView", self)
	self.JobsA:SetMultiSelect(false)
	self.JobsA:AddColumn("Job")
	self.JobsA:AddColumn("Allowed")

	local Jobs = team.GetAllTeams()
	//Get rid off unassigned/spec/joining
	Jobs[0] = nil
	Jobs[1001] = nil
	Jobs[1002] = nil
	for k,v in pairs(Jobs) do
		local Text = TBFY_GetLang("No")
		if LocalPlayer().TBFY_EData.JobID[k] then
			Text = TBFY_GetLang("Yes")
		end
		local Line = self.JobsA:AddLine(v.Name, Text)
		Line.JobID = k
	end
	self.JobsA.OnRowSelected = function(selfp, Index, Line)
		local CurV = Line:GetValue(2)
		local JobID = Line.JobID
		if CurV == TBFY_GetLang("Yes") then
			CurV = TBFY_GetLang("No")
			LocalPlayer().TBFY_EData.JobID[JobID] = nil
		else
			CurV = TBFY_GetLang("Yes")
			LocalPlayer().TBFY_EData.JobID[JobID] = true
		end
		Line:SetColumnText(2, CurV)
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end
end

local Width, Height = 350, 450
function PANEL:PerformLayout(W,H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetSize(W,Derma.HeaderH)

	local WS = W/2-20
	self.SEName:SetPos(WS, Derma.HeaderH+5)
	self.SEName:SetSize(125,25)

	self.PCType:SetPos(WS, Derma.HeaderH+35)
	self.PCType:SetSize(125, 25)

	self.Softwares:SetPos(5,Derma.HeaderH+65)
	self.Softwares:SetSize(W-10,125)

	self.JobsA:SetPos(5,Derma.HeaderH+195)
	self.JobsA:SetSize(W-10,225)

	self.CloseButton:SetPos(Width-25,3)
	self.CloseButton:SetSize(20, 20)
end

function PANEL:Paint(W,H)
	draw.RoundedBoxEx(4, 0, Derma.HeaderH, W, H-Derma.HeaderH, Derma.MainPanelColor, false, false, true, true)
	draw.SimpleText("Identifier:", "tbfy_header", W/2-25, Derma.HeaderH+7.5, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText("PC Type:", "tbfy_header", W/2-25, Derma.HeaderH+37, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end
vgui.Register("tbfy_setup_computer", PANEL, "DFrame")
