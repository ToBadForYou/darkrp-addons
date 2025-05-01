
local PConfig = PermItemsConfig

net.Receive("perm_sendweapontable", function()

    local WTblS = net.ReadString()

	LocalPlayer():DecompileWeaponString(WTblS)
end)

net.Receive("perm_sendweaponsingle", function()

    local CatID,ID, Remove = net.ReadFloat(),net.ReadFloat(), net.ReadBool()

	if Remove then
		LocalPlayer().PermWeapons[CatID] = LocalPlayer().PermWeapons[CatID] or {}
		LocalPlayer().PermWeapons[CatID][ID] = nil
	else
		LocalPlayer().PermWeapons[CatID] = LocalPlayer().PermWeapons[CatID] or {}
		LocalPlayer().PermWeapons[CatID][ID] = ID
	end
end)

net.Receive("perm_sendentitytable", function()

    local WTblS = net.ReadString()

	LocalPlayer():DecompileEntitiesString(WTblS)
end)

net.Receive("perm_sendentitysingle", function()
    local CatID,ID, Remove = net.ReadFloat(),net.ReadFloat(), net.ReadBool()

	if Remove then
		LocalPlayer().PermEntities[CatID] = LocalPlayer().PermEntities[CatID] or {}
		LocalPlayer().PermEntities[CatID][ID] = nil
	else
		LocalPlayer().PermEntities[CatID] = LocalPlayer().PermEntities[CatID] or {}
		LocalPlayer().PermEntities[CatID][ID] = ID
	end
end)

net.Receive("perm_manage_sendplayerinfo", function()
	local Player, WepTbl, EntTbl = net.ReadEntity(),net.ReadTable(),net.ReadTable()

	Player.PermWeapons = WepTbl
	Player.PermEntities = EntTbl
	LocalPlayer().Managing = Player

	local ManageMenu = vgui.Create("perm_manage_Player")
end)

net.Receive("perm_sendcurrency", function()
	local Points = net.ReadFloat()

	LocalPlayer().PCurrency = Points
end)

net.Receive("perm_manage_sendsteamidinfo", function()
	local WepTbl, EntTbl = net.ReadTable(), net.ReadTable()

	LocalPlayer().MWeps = WepTbl
	LocalPlayer().MEnts = EntTbl

	local ManageMenu = vgui.Create("perm_manage_offline_player")
end)

net.Receive("perm_manage_offline_sendweapon", function()

    local CatID,ID, Remove = net.ReadFloat(),net.ReadFloat(), net.ReadBool()

	if Remove then
		LocalPlayer().MWeps[CatID] = LocalPlayer().MWeps[CatID] or {}
		LocalPlayer().MWeps[CatID][ID] = nil
	else
		LocalPlayer().MWeps[CatID] = LocalPlayer().MWeps[CatID] or {}
		LocalPlayer().MWeps[CatID][ID] = ID
	end
end)

net.Receive("perm_manage_offline_sendentity", function()
    local CatID,ID, Remove = net.ReadFloat(),net.ReadFloat(), net.ReadBool()

	if Remove then
		LocalPlayer().MEnts[CatID] = LocalPlayer().MEnts[CatID] or {}
		LocalPlayer().MEnts[CatID][ID] = nil
	else
		LocalPlayer().MEnts[CatID] = LocalPlayer().MEnts[CatID] or {}
		LocalPlayer().MEnts[CatID][ID] = ID
	end
end)

local FontToUse = PConfig.Font
surface.CreateFont( "PermCats", {
	font = FontToUse,
	size = 17,
	weight = 750,
	antialias = true,
} )

local FrameColor = PConfig.FrameColor
local FrameOutline = PConfig.FrameOutline
local HeaderColor = PConfig.HeaderColor
local ColorBoxes = PConfig.ColorBoxes
local ColorBoxesOutlines = PConfig.ColorBoxesOutlines
local ButtonColor = PConfig.ButtonColor
local ButtonColorHovering = PConfig.ButtonColorHovering
local ButtonColorPressed = PConfig.ButtonColorPressed

local PANEL = {}

function PANEL:Init()
	self.ButtonText = ""
	self.BColor = ButtonColor
	self:SetText("")
end

function PANEL:UpdateColours()

	if self:IsDown() or self.m_bSelected then self.BColor = ButtonColorPressed return end
	if self.Hovered then self.BColor = ButtonColorHovering return end

	self.BColor = ButtonColor
	return
end

function PANEL:SetBText(Text)
	self.ButtonText = Text
end

function PANEL:Paint(W,H)
	surface.SetDrawColor(self.BColor)
	surface.DrawRect( 0, 0, W, H)
	surface.SetDrawColor(ColorBoxesOutlines)
	surface.DrawOutlinedRect( 0, 0, W, H )
	draw.SimpleText(self.ButtonText, FontToUse, W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
vgui.Register( "perm_button", PANEL, "DButton")

local PANEL = {}

function PANEL:Init()
   	self.Name = ""
	self.Desc = ""
	self.Cost = "Price: 0" .. PConfig.CurrencySymbol

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function()
		local W,H = self.TopDPanel:GetWide(), self.TopDPanel:GetTall()
		surface.SetDrawColor(HeaderColor)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor(ColorBoxesOutlines)
		surface.DrawOutlinedRect( 0, 0, W, H )
		draw.SimpleText(self.Name, FontToUse, W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.BuyItem = vgui.Create("perm_button", self)

	self.WModel = vgui.Create( "ModelImage", self )
end

function PANEL:Paint(W,H)
	surface.SetDrawColor(HeaderColor)
	surface.DrawRect( 0, 0, W, H)
	surface.SetDrawColor(ColorBoxesOutlines)
	surface.DrawOutlinedRect( 0, 0, W, H )
	draw.SimpleText(self.Desc, FontToUse, W/2, H/2+7.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText(self.Cost, FontToUse, W-5, H/2-5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
end

function PANEL:SetInfo(Model, Name, Desc, Cost, CatID, ID, AM, Offline)
	self.WModel:SetModel(Model)

	self.Name = Name
	if !AM and !Offline then
		self.Desc = Desc
		self.Cost = "Price: " .. Cost .. PConfig.CurrencySymbol

		self.BuyItem:SetBText("Purchase")
		self.BuyItem.DoClick = function() if !LocalPlayer():CanAffordPermItem(Cost) then LocalPlayer():ChatPrint("You can't afford this!") return end net.Start("perm_buyweapon") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle()  end
	else
		self.Cost = ""
		self.H = 10
		self.BuyItem:SetBText("Give")
		if Offline then
			self.BuyItem.DoClick = function() net.Start("perm_manage_offline_grantweapon") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle()  end
		else
			self.BuyItem.DoClick = function() net.Start("perm_manage_grantweapon") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle()  end
		end
	end
end

function PANEL:SetEInfo(Model, Name, Desc, Cost, CatID, ID, AM, Offline)
	self.WModel:SetModel(Model)

	self.Name = Name
	if !AM and !Offline then
		self.Desc = Desc
		self.Cost = "Price: " .. Cost .. PConfig.CurrencySymbol

		self.BuyItem:SetBText("Purchase")
		self.BuyItem.DoClick = function() if !LocalPlayer():CanAffordPermItem(Cost) then LocalPlayer():ChatPrint("You can't afford this!") return end net.Start("perm_buyentity") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle()  end
	else
		self.Cost = ""
		self.H = 10
		self.BuyItem:SetBText("Give")
		if Offline then
			self.BuyItem.DoClick = function() net.Start("perm_manage_offline_grantentity") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle()  end
		else
			self.BuyItem.DoClick = function() net.Start("perm_manage_grantentity") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle()  end
		end
	end
end

function PANEL:SetEOInfo(Model, Name, Desc, Cost, CatID, ID, AM, Offline)
	self.WModel:SetModel(Model)

	self.Name = Name
	if !AM and !Offline then
		self.Desc = Desc
		self.Cost = ""
		self.H = 10

		if PConfig.AllowSelling then
			self.SellItem = vgui.Create("perm_button", self)
			self.SellItem:SetBText("Sell")
			self.SellItem.DoClick = function() net.Start("perm_sellentity") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle() end
		end

		self.BuyItem:SetBText("Spawn")
		self.BuyItem.DoClick = function() net.Start("perm_spawnentity") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() end
	else
		self.Cost = ""
		self.H = 10
		self.BuyItem:SetBText("Remove")
		if Offline then
			self.BuyItem.DoClick = function() net.Start("perm_manage_offline_removeentity") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle() end
		else
			self.BuyItem.DoClick = function() net.Start("perm_manage_removeentity") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle() end
		end
	end
end

function PANEL:SetOInfo(Model, Name, Desc, Cost, CatID, ID, AM, Offline)
	self.WModel:SetModel(Model)

	self.Name = Name
	if !AM and !Offline then
		self.Desc = Desc
		self.Cost = ""
		self.H = 10

		if PConfig.AllowSelling then
			self.SellItem = vgui.Create("perm_button", self)
			self.SellItem:SetBText("Sell")
			self.SellItem.DoClick = function() net.Start("perm_sellweapon") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle() end
		end

		self.BuyItem:SetBText("Spawn")
		self.BuyItem.DoClick = function() net.Start("perm_spawnweapon") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() end
	else
		self.Cost = ""
		self.H = 10
		self.BuyItem:SetBText("Remove")
		if Offline then
			self.BuyItem.DoClick = function() net.Start("perm_manage_offline_removeweapon") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle() end
		else
			self.BuyItem.DoClick = function() net.Start("perm_manage_removeweapon") net.WriteFloat(CatID) net.WriteFloat(ID) net.WriteString(Name) net.SendToServer() local PPanel = self:GetParent():GetParent():GetParent() self:Remove() PPanel:Toggle() PPanel:Toggle() end
		end
	end
end

function PANEL:PerformLayout()
    local MaxW,MaxH = self:GetParent():GetWide(),self:GetParent():GetTall()

    self:SetSize(MaxW, 70)

	local HeaderH = 15

    self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(MaxW,HeaderH)

	if self.H then
		self.BuyItem:SetPos(MaxW-75, 42.5-self.H)
	else
		self.BuyItem:SetPos(MaxW-75, 42.5)
	end
	self.BuyItem:SetSize(70,20)

	if self.SellItem then
		self.BuyItem:SetPos(MaxW-75, 20)
		self.SellItem:SetPos(MaxW-75, 45)
		self.SellItem:SetSize(70,20)
	end

	self.WModel:SetPos(5,15)
    self.WModel:SetSize(55,55)
end

vgui.Register( "perm_item_info", PANEL)

local PANEL = {}

function PANEL:Init()
	self:SetExpanded(0)
	self:SetLabel("")
	self.Section = ""

	self.Header.Paint = function(pself, W,H)
		draw.SimpleText(self.Section, "PermCats", W/2, H/2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.PanelList = vgui.Create("DPanelList")
	self.PanelList:SetPadding(0);
	self.PanelList:SetAutoSize(true)
	self.PanelList:SetSpacing(0)
	self.PanelList:EnableHorizontal( false )
	self.PanelList:EnableVerticalScrollbar( true )
	self:SetContents(self.PanelList)
end

function PANEL:Paint(W,H)

end

function PANEL:SetSection(Name)
	self.Section = Name
end

function PANEL:AddWeapons(WeaponTable, CatID, AM, Offline)
	for k,v in pairs(WeaponTable) do
		local AMP = LocalPlayer().Managing
		if (!LocalPlayer():HasPermWeapon(CatID, k) and !AM and !Offline) or (!Offline and AM and AMP and !AMP:HasPermWeapon(CatID, k)) or (Offline and !LocalPlayer():HasPermWeapon(CatID, k, true)) then
			local NameToUse = "MISCONFIGURED"
			local ModelToUse = "models/error.mdl"

			if v[4] and v[5] then
				ModelToUse = v[4]
				NameToUse = v[5]
			else
				local SWEPTable = weapons.GetStored(v[1])

				if SWEPTable and istable(SWEPTable) then
					ModelToUse = SWEPTable.WorldModel
					NameToUse = SWEPTable.PrintName
				end
			end

			local Desc = v[2]
			local Price = v[3]

			local WeaponToAdd = vgui.Create("perm_item_info")
			WeaponToAdd:SetInfo(ModelToUse, NameToUse, Desc, Price, CatID, k, AM, Offline)
			self.PanelList:AddItem(WeaponToAdd)
		end
	end
	if #self.PanelList.Items < 1 then self:Remove() end
end

function PANEL:AddOWeapons(WeaponTable, CatID, AM, Offline)
	for k,v in pairs(WeaponTable) do
		local AMP = LocalPlayer().Managing
		if (LocalPlayer():HasPermWeapon(CatID, k) and !AM and !Offline) or (!Offline and AM and AMP and AMP:HasPermWeapon(CatID, k)) or (Offline and LocalPlayer():HasPermWeapon(CatID, k, true)) then
			local NameToUse = "MISCONFIGURED"
			local ModelToUse = "models/error.mdl"

			if v[4] and v[5] then
				ModelToUse = v[4]
				NameToUse = v[5]
			else
				local SWEPTable = weapons.GetStored(v[1])

				if SWEPTable and istable(SWEPTable) then
					ModelToUse = SWEPTable.WorldModel
					NameToUse = SWEPTable.PrintName
				end
			end

			local Desc = v[2]
			local Price = v[3]

			local WeaponToAdd = vgui.Create("perm_item_info")
			WeaponToAdd:SetOInfo(ModelToUse, NameToUse, Desc, Price, CatID, k, AM, Offline)
			self.PanelList:AddItem(WeaponToAdd)
		end
	end
	if #self.PanelList.Items < 1 then self:Remove() end
end

function PANEL:AddEntities(EntTable, CatID, AM, Offline)
	for k,v in pairs(EntTable) do
		local AMP = LocalPlayer().Managing
		if (!LocalPlayer():HasPermEntities(CatID, k) and !AM and !Offline) or (!Offline and AM and AMP and !AMP:HasPermEntities(CatID, k)) or (Offline and !LocalPlayer():HasPermEntities(CatID, k, true)) then
		    local Model = v[2]
			local Name = v[3]
			local Desc = v[4]
			local Price = v[5]

			local EntityToAdd = vgui.Create("perm_item_info")
			EntityToAdd:SetEInfo(Model, Name, Desc, Price, CatID, k, AM, Offline)
			self.PanelList:AddItem(EntityToAdd)
		end
	end
	if #self.PanelList.Items < 1 then self:Remove() end
end

function PANEL:AddOEntities(EntTable, CatID, AM, Offline)
	for k,v in pairs(EntTable) do
		local AMP = LocalPlayer().Managing
		if (LocalPlayer():HasPermEntities(CatID, k) and !AM and !Offline) or (!Offline and AM and AMP and AMP:HasPermEntities(CatID, k)) or (Offline and LocalPlayer():HasPermEntities(CatID, k, true)) then
		    local Model = v[2]
			local Name = v[3]
			local Desc = v[4]
			local Price = v[5]

			local EntityToAdd = vgui.Create("perm_item_info")
			EntityToAdd:SetEOInfo(Model, Name, Desc, Price, CatID, k, AM, Offline)
			self.PanelList:AddItem(EntityToAdd)
		end
	end
	if #self.PanelList.Items < 1 then self:Remove() end
end
vgui.Register( "perm_collapsible", PANEL, "DCollapsibleCategory")

local PANEL = {};

function PANEL:Init ( )
	self:SetTitle("");
	self:ShowCloseButton(false);
    self:SetDraggable(false);
    self:MakePopup()

    self.Buttons = {}

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function()
		local W,H = self.TopDPanel:GetWide(), self.TopDPanel:GetTall()
		surface.SetDrawColor(HeaderColor)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor(ColorBoxesOutlines)
		surface.DrawOutlinedRect( 0, 0, W, H )
		draw.SimpleText("Perm Weapons/Entites", FontToUse, W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

  if PConfig.EnableWeapons then
  	self.PLBW = vgui.Create( "DPanelList", self )
  	self.PLBW:SetPadding(0)
  	self.PLBW:SetSpacing(0)
  	self.PLBW:EnableHorizontal( false )
  	self.PLBW:EnableVerticalScrollbar( true )

      for k,v in pairs(PConfig.WeaponsList) do
  	    local Section = vgui.Create("perm_collapsible", self.PLBW)
  		Section:SetSection(v[1])
  		Section:AddWeapons(v[2], k)
  		self.PLBW:AddItem(Section)
      end

  	self.BuyWeapons = vgui.Create("perm_button", self)
  	self.BuyWeapons.DoClick = function() self:SetVisibleP(self.PLBW) end
  	self.BuyWeapons:SetBText("Weapons")
    table.insert(self.Buttons, self.BuyWeapons)

  	self.PLOW = vgui.Create( "DPanelList", self )
  	self.PLOW:SetPadding(0)
  	self.PLOW:SetSpacing(0)
  	self.PLOW:EnableHorizontal( false )
  	self.PLOW:EnableVerticalScrollbar( true )
  	self.PLOW:SetVisible(false)

      for k,v in pairs(PConfig.WeaponsList) do
  	    local Section = vgui.Create("perm_collapsible", self.PLOW)
  		Section:SetSection(v[1])
  		Section:AddOWeapons(v[2], k)
  		self.PLOW:AddItem(Section)
      end

  	self.OwnedWeapons = vgui.Create("perm_button", self)
  	self.OwnedWeapons.DoClick = function() self:SetVisibleP(self.PLOW) end
  	self.OwnedWeapons:SetBText("Owned Weapons")
    table.insert(self.Buttons, self.OwnedWeapons)
  end

	if PConfig.EnableEntities then
		self.PLBE = vgui.Create( "DPanelList", self )
		self.PLBE:SetPadding(0)
		self.PLBE:SetSpacing(0)
		self.PLBE:EnableHorizontal( false )
		self.PLBE:EnableVerticalScrollbar( true )
		self.PLBE:SetVisible(false)

		for k,v in pairs(PConfig.EntitiesList) do
			local Section = vgui.Create("perm_collapsible", self.PLBE)
			Section:SetSection(v[1])
			Section:AddEntities(v[2], k)
			self.PLBE:AddItem(Section)
		end

		self.BuyEntities = vgui.Create("perm_button", self)
		self.BuyEntities.DoClick = function() self:SetVisibleP(self.PLBE) end
		self.BuyEntities:SetBText("Entities")
    table.insert(self.Buttons, self.BuyEntities)

		self.PLOE = vgui.Create( "DPanelList", self )
		self.PLOE:SetPadding(0)
		self.PLOE:SetSpacing(0)
		self.PLOE:EnableHorizontal( false )
		self.PLOE:EnableVerticalScrollbar( true )
		self.PLOE:SetVisible(false)

		for k,v in pairs(PConfig.EntitiesList) do
			local Section = vgui.Create("perm_collapsible", self.PLOE)
			Section:SetSection(v[1])
			Section:AddOEntities(v[2], k)
			self.PLOE:AddItem(Section)
		end

		self.OwnedEntities = vgui.Create("perm_button", self)
		self.OwnedEntities.DoClick = function() self:SetVisibleP(self.PLOE) end
		self.OwnedEntities:SetBText("Owned Entities")
    table.insert(self.Buttons, self.OwnedEntities)
	end

	if LocalPlayer():PermAdminAccess() then
		self.AManage = vgui.Create( "DPanelList", self )
		self.AManage:SetPadding(-1)
		self.AManage:SetSpacing(-1)
		self.AManage:EnableHorizontal( false )
		self.AManage:EnableVerticalScrollbar( true )
		self.AManage:SetVisible(false)

		self.AdminTab = vgui.Create("perm_button", self)
		self.AdminTab.DoClick = function() self:SetVisibleP(self.AManage) end
		self.AdminTab:SetBText("Manage Players")
    table.insert(self.Buttons, self.AdminTab)

		local PlayersSorted = player.GetAll()
		table.sort(PlayersSorted, function ( P1, P2 )
			if (!P1) then return false; end
			if (!P2) then return true; end

			local P1S = string.lower(P1:Nick());
			local P2S = string.lower(P2:Nick());

			return P1S < P2S
		end);

		for k,v in pairs(PlayersSorted) do
			local PlayerLine = vgui.Create("perm_button", self.AManage)
			PlayerLine:SetBText(v:Nick())
			PlayerLine.DoClick = function()
				net.Start("perm_manage_player")
					net.WriteEntity(v)
				net.SendToServer()
				self:Remove()
			end
			self.AManage:AddItem(PlayerLine)
		end
	end

	self.CloseButton = vgui.Create("perm_button", self)
	self.CloseButton.DoClick = function() self:Remove() end
	self.CloseButton:SetBText("X")
end

function PANEL:SetVisibleP(PanelToVis)
  if PConfig.EnableWeapons then
  	self.PLBW:SetVisible(false)
  	self.PLOW:SetVisible(false)
  end
	if PConfig.EnableEntities then
		self.PLBE:SetVisible(false)
		self.PLOE:SetVisible(false)
	end
	if LocalPlayer():PermAdminAccess() then
		self.AManage:SetVisible(false)
	end
    PanelToVis:SetVisible(true)
end

local W,H = 500,400
function PANEL:PerformLayout ( )
	self:SetPos(ScrW()/2-W/2, ScrH()/2-H/2)
    self:SetSize(W, H)

	local HeaderH = 25

    self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(W,HeaderH)

	local Padding = 5
	local ButtonSizeW = W*0.25 - Padding*2
	local ButtonH = 20
	local PLW = W*0.75
	local PLH = H - HeaderH

  for k,v in pairs(self.Buttons) do
    v:SetPos(Padding,HeaderH+Padding*(k)+ButtonH*(k-1))
    v:SetSize(ButtonSizeW, ButtonH)
  end

  if PConfig.EnableEntities then
		self.PLBE:SetPos(Padding*2+ButtonSizeW, HeaderH)
		self.PLBE:SetSize(PLW-1,PLH-1)

		self.PLOE:SetPos(Padding*2+ButtonSizeW, HeaderH)
		self.PLOE:SetSize(PLW-1,PLH-1)
  end

  if PConfig.EnableWeapons then
    self.PLBW:SetPos(Padding*2+ButtonSizeW, HeaderH)
  	self.PLBW:SetSize(PLW-1,PLH-1)

    self.PLOW:SetPos(Padding*2+ButtonSizeW, HeaderH)
  	self.PLOW:SetSize(PLW-1,PLH-1)
  end

	if LocalPlayer():PermAdminAccess() then
		self.AManage:SetPos(Padding*2+ButtonSizeW, HeaderH)
		self.AManage:SetSize(PLW-1,PLH-1)
	end

	self.CloseButton:SetPos(W-20,Padding)
	self.CloseButton:SetSize(15, 15)
end

function PANEL:Paint(W,H)
    surface.SetDrawColor(FrameColor)
	surface.DrawRect( 0, 0, W, H)
	surface.SetDrawColor(FrameOutline)
	surface.DrawOutlinedRect( 0, 0, W, H )
	surface.DrawOutlinedRect( 0, 24, W*0.25, H-24 )
	draw.SimpleText(PConfig.CurrencyName .. ": " .. LocalPlayer():GetCurrencyAmount(), FontToUse, 10, H-5, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
end
vgui.Register("permaweapons_menu", PANEL, "DFrame");

net.Receive("perm_open_menu", function()
	vgui.Create("permaweapons_menu")
end)

local PANEL = {};

function PANEL:Init ( )
	self:SetTitle("");
	self:ShowCloseButton(false);
    self:SetDraggable(false);
    self:MakePopup()

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp,W,H)
		surface.SetDrawColor(HeaderColor)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor(ColorBoxesOutlines)
		surface.DrawOutlinedRect( 0, 0, W, H )
		draw.SimpleText("Weapons", FontToUse, W*0.25, 25/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText("Entities", FontToUse, W*0.75, 25/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    self.MiddleDPanel = vgui.Create("DPanel", self)
	self.MiddleDPanel.Paint = function(selfp,W,H)
		surface.SetDrawColor(HeaderColor)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor(ColorBoxesOutlines)
		surface.DrawOutlinedRect( 0, 0, W, H )
		draw.SimpleText("Owned Weapons", FontToUse, W*0.25, 25/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText("Owned Entities", FontToUse, W*0.75, 25/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.PLUW = vgui.Create( "DPanelList", self )
	self.PLUW:SetPadding(0)
	self.PLUW:SetSpacing(0)
	self.PLUW:EnableHorizontal( false )
	self.PLUW:EnableVerticalScrollbar( true )

    for k,v in pairs(PConfig.WeaponsList) do
	    local Section = vgui.Create("perm_collapsible", self.PLUW)
		Section:SetSection(v[1])
		Section:AddWeapons(v[2], k, true)
		self.PLUW:AddItem(Section)
    end

	self.PLOW = vgui.Create( "DPanelList", self )
	self.PLOW:SetPadding(0)
	self.PLOW:SetSpacing(0)
	self.PLOW:EnableHorizontal( false )
	self.PLOW:EnableVerticalScrollbar( true )

    for k,v in pairs(PConfig.WeaponsList) do
	    local Section = vgui.Create("perm_collapsible", self.PLOW)
		Section:SetSection(v[1])
		Section:AddOWeapons(v[2], k, true)
		self.PLOW:AddItem(Section)
    end

	self.PLUE = vgui.Create( "DPanelList", self )
	self.PLUE:SetPadding(0)
	self.PLUE:SetSpacing(0)
	self.PLUE:EnableHorizontal( false )
	self.PLUE:EnableVerticalScrollbar( true )

    for k,v in pairs(PConfig.EntitiesList) do
	    local Section = vgui.Create("perm_collapsible", self.PLUE)
		Section:SetSection(v[1])
		Section:AddEntities(v[2], k, true)
		self.PLUE:AddItem(Section)
    end

	self.PLOE = vgui.Create( "DPanelList", self )
	self.PLOE:SetPadding(0)
	self.PLOE:SetSpacing(0)
	self.PLOE:EnableHorizontal( false )
	self.PLOE:EnableVerticalScrollbar( true )

    for k,v in pairs(PConfig.EntitiesList) do
	    local Section = vgui.Create("perm_collapsible", self.PLOE)
		Section:SetSection(v[1])
		Section:AddOEntities(v[2], k, true)
		self.PLOE:AddItem(Section)
    end

	self.CloseButton = vgui.Create("perm_button", self)
	self.CloseButton.DoClick = function() self:Remove() end
	self.CloseButton:SetBText("X")
end

local W,H = 500,400
function PANEL:PerformLayout ( )
	self:SetPos(ScrW()/2-W/2, ScrH()/2-H/2)
    self:SetSize(W, H)

	local HeaderH = 25

    self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(W,HeaderH)

	local Padding = 5
	local HH = H/2 - HeaderH

    self.MiddleDPanel:SetPos(0,HeaderH+HH)
	self.MiddleDPanel:SetSize(W,HeaderH)

	self.PLUW:SetPos(0,HeaderH)
	self.PLUW:SetSize(W/2,HH)

	self.PLOW:SetPos(0,HeaderH*2+HH)
	self.PLOW:SetSize(W/2,HH)

	self.PLUE:SetPos(W/2,HeaderH)
	self.PLUE:SetSize(W/2,HH)

	self.PLOE:SetPos(W/2,HeaderH*2+HH)
	self.PLOE:SetSize(W/2,HH)

	self.CloseButton:SetPos(W-20,Padding)
	self.CloseButton:SetSize(15, 15)
end

function PANEL:Paint(W,H)
    surface.SetDrawColor(FrameColor)
	surface.DrawRect( 0, 0, W, H)
	surface.SetDrawColor(FrameOutline)
	surface.DrawOutlinedRect( 0, 0, W, H )
	local HH = H/2
	surface.DrawLine(W/2, 25, W/2, HH)
	surface.DrawLine(W/2, HH+25, W/2, HH*2)
end
vgui.Register("perm_manage_Player", PANEL, "DFrame");

local PANEL = {};

function PANEL:Init ( )
	self:SetTitle("");
	self:ShowCloseButton(false);
    self:SetDraggable(false);
    self:MakePopup()

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp,W,H)
		surface.SetDrawColor(HeaderColor)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor(ColorBoxesOutlines)
		surface.DrawOutlinedRect( 0, 0, W, H )
		draw.SimpleText("Weapons", FontToUse, W*0.25, 25/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText("Entities", FontToUse, W*0.75, 25/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    self.MiddleDPanel = vgui.Create("DPanel", self)
	self.MiddleDPanel.Paint = function(selfp,W,H)
		surface.SetDrawColor(HeaderColor)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor(ColorBoxesOutlines)
		surface.DrawOutlinedRect( 0, 0, W, H )
		draw.SimpleText("Owned Weapons", FontToUse, W*0.25, 25/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText("Owned Entities", FontToUse, W*0.75, 25/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.PLUW = vgui.Create( "DPanelList", self )
	self.PLUW:SetPadding(0)
	self.PLUW:SetSpacing(0)
	self.PLUW:EnableHorizontal( false )
	self.PLUW:EnableVerticalScrollbar( true )

    for k,v in pairs(PConfig.WeaponsList) do
	    local Section = vgui.Create("perm_collapsible", self.PLUW)
		Section:SetSection(v[1])
		Section:AddWeapons(v[2], k, false, true)
		self.PLUW:AddItem(Section)
    end

	self.PLOW = vgui.Create( "DPanelList", self )
	self.PLOW:SetPadding(0)
	self.PLOW:SetSpacing(0)
	self.PLOW:EnableHorizontal( false )
	self.PLOW:EnableVerticalScrollbar( true )

    for k,v in pairs(PConfig.WeaponsList) do
	    local Section = vgui.Create("perm_collapsible", self.PLOW)
		Section:SetSection(v[1])
		Section:AddOWeapons(v[2], k, false, true)
		self.PLOW:AddItem(Section)
    end

	self.PLUE = vgui.Create( "DPanelList", self )
	self.PLUE:SetPadding(0)
	self.PLUE:SetSpacing(0)
	self.PLUE:EnableHorizontal( false )
	self.PLUE:EnableVerticalScrollbar( true )

    for k,v in pairs(PConfig.EntitiesList) do
	    local Section = vgui.Create("perm_collapsible", self.PLUE)
		Section:SetSection(v[1])
		Section:AddEntities(v[2], k, false, true)
		self.PLUE:AddItem(Section)
    end

	self.PLOE = vgui.Create( "DPanelList", self )
	self.PLOE:SetPadding(0)
	self.PLOE:SetSpacing(0)
	self.PLOE:EnableHorizontal( false )
	self.PLOE:EnableVerticalScrollbar( true )

    for k,v in pairs(PConfig.EntitiesList) do
	    local Section = vgui.Create("perm_collapsible", self.PLOE)
		Section:SetSection(v[1])
		Section:AddOEntities(v[2], k, false, true)
		self.PLOE:AddItem(Section)
    end

	self.CloseButton = vgui.Create("perm_button", self)
	self.CloseButton.DoClick = function() self:Remove() end
	self.CloseButton:SetBText("X")
end

local W,H = 500,400
function PANEL:PerformLayout ( )
	self:SetPos(ScrW()/2-W/2, ScrH()/2-H/2)
    self:SetSize(W, H)

	local HeaderH = 25

    self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(W,HeaderH)

	local Padding = 5
	local HH = H/2 - HeaderH

    self.MiddleDPanel:SetPos(0,HeaderH+HH)
	self.MiddleDPanel:SetSize(W,HeaderH)

	self.PLUW:SetPos(0,HeaderH)
	self.PLUW:SetSize(W/2,HH)

	self.PLOW:SetPos(0,HeaderH*2+HH)
	self.PLOW:SetSize(W/2,HH)

	self.PLUE:SetPos(W/2,HeaderH)
	self.PLUE:SetSize(W/2,HH)

	self.PLOE:SetPos(W/2,HeaderH*2+HH)
	self.PLOE:SetSize(W/2,HH)

	self.CloseButton:SetPos(W-20,Padding)
	self.CloseButton:SetSize(15, 15)
end

function PANEL:Paint(W,H)
    surface.SetDrawColor(FrameColor)
	surface.DrawRect( 0, 0, W, H)
	surface.SetDrawColor(FrameOutline)
	surface.DrawOutlinedRect( 0, 0, W, H )
	local HH = H/2
	surface.DrawLine(W/2, 25, W/2, HH)
	surface.DrawLine(W/2, HH+25, W/2, HH*2)
end
vgui.Register("perm_manage_offline_player", PANEL, "DFrame");
