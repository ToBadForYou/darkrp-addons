
surface.CreateFont( "collections_headlines", {
	font = "Verdana",
	size = 15,
	weight = 1000,
	antialias = true,
})

net.Receive("collect_ResetCollection", function()
	local CID = net.ReadFloat()
	
	LocalPlayer().Collections[CID] = {}
end)

net.Receive("collect_SendInventory", function()
	local InvTbl = net.ReadString()
	
	LocalPlayer().CollectionInventory = {}
	LocalPlayer():DecompileInventoryString(InvTbl)
end)

net.Receive("collect_SendCollections", function()
	local CollTbl = net.ReadString()
	
	LocalPlayer().Collections = {}
	LocalPlayer():DecompileCollectionsString(CollTbl)
end)

net.Receive("collect_UpdateInventory", function()
	local ID, Amount = net.ReadFloat(), net.ReadFloat()
	if Amount > 0 then
		surface.PlaySound(TBFY_CollectConfig.PickupItemSound);
	elseif Amount < 0 then
		surface.PlaySound(TBFY_CollectConfig.DropItemSound);
	end
	
	LocalPlayer().CollectionInventory[ID] = LocalPlayer().CollectionInventory[ID] or 0
	LocalPlayer().CollectionInventory[ID] = LocalPlayer().CollectionInventory[ID] + Amount
	if LocalPlayer().CollectionInventory[ID] <= 0 then
		LocalPlayer().CollectionInventory[ID] = nil
	end
end)

net.Receive("collect_UpdateCollections", function()
	local CID, ID = net.ReadFloat(), net.ReadFloat()

	LocalPlayer().Collections[CID] = LocalPlayer().Collections[CID] or {}
	table.insert(LocalPlayer().Collections[CID], ID)
end)

net.Receive("collect_SendRewardsClaimed", function()
	local RClaimedTbl = net.ReadString()
	
	LocalPlayer().RewardsClaimed = {}
	LocalPlayer():DecompileRClaimedString(RClaimedTbl)
end)

net.Receive("collect_UpdateRewardsClaimed", function()
	local CID = net.ReadFloat()
	
	LocalPlayer().RewardsClaimed = LocalPlayer().RewardsClaimed or {}
	table.insert(LocalPlayer().RewardsClaimed, CID)
end)

net.Receive("collect_open_container", function()
	local ContainerItems = net.ReadTable()
	
	local ContainerMenu = vgui.Create("collections_container")
	ContainerMenu:SetCollItems(ContainerItems)
end)

local MainPanelColor = Color(255,255,255,200)
local HeaderColor = Color(50,50,50,255)
local CollectionsListColor = Color(215,215,220,255)
local ButtonColor = Color(50,50,50,255)
local ButtonColorHovering = Color(75,75,75,200)
local ButtonColorPressed = Color(150,150,150,200)
local ButtonOutline = Color(0,0,0,200)
local SlotsColor = Color(255,255,255,255)
local SlotsOutlineColor = Color(195,195,215,255)

local PANEL = {}

function PANEL:Init()
	self.ButtonText = ""
	self.BColor = ButtonColor
	self:SetText("")
end

function PANEL:UpdateColours()

	if self:IsDown() or self.m_bSelected then self.BColor = ButtonColorPressed return end
	if self.Hovered and !self:GetDisabled() then self.BColor = ButtonColorHovering return end

	self.BColor = ButtonColor
	return
end

function PANEL:SetBText(Text)
	self.ButtonText = Text
end

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, self.BColor)
	draw.SimpleText(self.ButtonText, "collections_headlines", W/2, H/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )   
end
vgui.Register( "collections_button", PANEL, "DButton")

local PANEL = {}

function PANEL:Init()
end

function PANEL:Paint(W,H)
	draw.RoundedBox(8, 0, 0, W, H, SlotsOutlineColor)
	draw.RoundedBox(8, 2, 2, H-4, H-4, SlotsColor)
end
vgui.Register( "collections_slot", PANEL)

local PANEL = {}

function PANEL:Init()
	self.ItemIcon = vgui.Create( "ModelImage" , self)
end

function PANEL:Paint(W,H)
	draw.RoundedBox(8, 0, 0, W, H, SlotsOutlineColor)
	draw.RoundedBox(8, 2, 2, H-4, H-4, SlotsColor)
end

function PANEL:PerformLayout(W,H)
	self.ItemIcon:SetSize(W-5,H-5)
	self.ItemIcon:SetPos(2.5,2.5)
end

function PANEL:SetItemInfo(Model)

	self.ItemIcon:SetModel(Model) 	

end
vgui.Register( "collections_item", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Amount = 0
	self.ID = 0
	self.ItemIcon = vgui.Create( "ModelImage" , self)
	self.ItemIcon.OnMouseReleased = self.OnMouseReleased
	self.ItemIcon.OnMousePressed = self.OnMousePressed
	self.ItemIcon.DoRightClick = self.DoRightClick
	self.ItemIcon.P = self
end

function PANEL:Paint(W,H)
	draw.RoundedBox(8, 0, 0, W, H, SlotsOutlineColor)
	draw.RoundedBox(8, 2, 2, H-4, H-4, SlotsColor)
	draw.SimpleTextOutlined(self.Amount, "default", 3, 7.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER,1,Color(0,0,0,255))
end

function PANEL:PerformLayout(W,H)
	self.ItemIcon:SetSize(W-10,H-10)
	self.ItemIcon:SetPos(5,5)
end

function PANEL:SetItemInfo(ID, Amount)
	local ItemTbl = COLLECTION_ITEMSDB[ID]
	self.ItemIcon:SetModel(ItemTbl[1]) 	
	self.Amount = Amount
	self.ID = ID
end

function PANEL:DoRightClick()
	local MPanel = self.P or self
	local ID = MPanel.ID
	
	local Options = vgui.Create("DMenu")
	Options:AddOption("Drop Item", function()
		if CollectionSpawnLimit() then LocalPlayer():ChatPrint("Collection Item limit reached on the map, wait for despawns.") return end
		if LocalPlayer().CItemDropCD and LocalPlayer().CItemDropCD > CurTime() then LocalPlayer():ChatPrint("You can drop another item in: " .. math.Round(LocalPlayer().CItemDropCD - CurTime()) .. " seconds.") return end
		LocalPlayer().CItemDropCD = CurTime() + TBFY_CollectConfig.DropItemCD
		
		net.Start("collect_dropitem")
			net.WriteFloat(ID)
		net.SendToServer()
		MPanel.Amount = MPanel.Amount - 1
		if MPanel.Amount <= 0 then 
			local MainP = MPanel.MainPanel
			MainP.ItemList[MPanel.ID] = nil
			MPanel:Remove()
			MainP:PerformLayout()
		end		
	end)
	
	local AddCollection = Options:AddSubMenu( "Add to collection" )
	for k,v in pairs(COLLECTION_COLLCETIONSDB) do
		local CID = k
		if CollectionHasID(CID, ID) and !LocalPlayer():CollectionHasID(CID,ID) and !LocalPlayer():CollectionIsFinished(CID) then
			AddCollection:AddOption(v[1], function() 
				if !CollectionHasID(CID, ID) or !LocalPlayer():HasCItem(ID) then return end
				net.Start("collect_AddToCollection")
					net.WriteFloat(CID)
					net.WriteFloat(ID)
				net.SendToServer()
				MPanel.Amount = MPanel.Amount - 1
				if MPanel.Amount <= 0 then 
					local MainP = MPanel.MainPanel
					MainP.ItemList[MPanel.ID] = nil
					MPanel:Remove()
					MainP:PerformLayout()
				end
			end)
		end
	end

	Options:Open()
end

function PANEL:OnMousePressed(mousecode)	
	self:MouseCapture(true);
	self.Depressed = true;
end

function PANEL:OnMouseReleased(mousecode)
	self:MouseCapture(false);
	
	if !self.Depressed then return end
	
	self.Depressed = nil
	
	if mousecode == MOUSE_RIGHT then self:DoRightClick() end
end
vgui.Register( "collections_inv_item", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Name = ""
	self.ItemsH = 0
	self.SlotsH = 0
	self.ItemsReq = 0
	self.RewardText = ""

	self.DPanelItems = vgui.Create("DPanel", self)
	self.DPanelItems.Paint = function(selfp, W,H) end
	self.DPanelItems.Items = {}	
	
	self.DPanelSlots = vgui.Create("DPanel", self)
	self.DPanelSlots.Paint = function(selfp, W,H) end
	self.DPanelSlots.Slots = {}
end

function PANEL:SetCollection(Name, IDTable, ItemsReq, CID, RewardText)
	self.Name = Name
	self.ItemsReq = ItemsReq
	self.RewardText = RewardText
	
	for k,v in pairs(IDTable) do
		self.DPanelItems.Items[k] = vgui.Create("collections_item", self.DPanelItems)
		self.DPanelItems.Items[k]:SetItemInfo(COLLECTION_ITEMSDB[v][1])
	end		
	
	local InCollection = 1
	if LocalPlayer().Collections[CID] then
		for k,v in pairs(LocalPlayer().Collections[CID]) do
			self.DPanelSlots.Slots[k] = vgui.Create("collections_item", self.DPanelSlots)
			self.DPanelSlots.Slots[k]:SetItemInfo(COLLECTION_ITEMSDB[v][1])
			InCollection = InCollection + 1
		end
	end	

	if LocalPlayer():CollectionIsFinished(CID) then
		self.ClaimRewardButton = vgui.Create("collections_button", self)
		if LocalPlayer():HasCClaimedReward(CID) then
			if TBFY_CollectConfig.ResetOnClaimed then
				self.ClaimRewardButton:SetBText("Reset Collection")
				self.ClaimRewardButton.DoClick = function() net.Start("collect_player_resetcollection") net.WriteFloat(CID) net.SendToServer() self.ClaimRewardButton:SetBText("REOPEN MENU") self.ClaimRewardButton:SetEnabled(false) end
			else
				self.ClaimRewardButton:SetBText("Reward Claimed")
				self.ClaimRewardButton:SetEnabled(false)
			end
		else
			self.ClaimRewardButton:SetBText("Claim Reward")
			self.ClaimRewardButton.DoClick = function() net.Start("collect_claimreward") net.WriteFloat(CID) net.SendToServer() self.ClaimRewardButton:SetBText("Reward Claimed") self.ClaimRewardButton:SetEnabled(false) end
		end
	else
		for i = InCollection, self.ItemsReq do
			self.DPanelSlots.Slots[i] = vgui.Create("collections_slot", self.DPanelSlots)
		end		
	end
end

function PANEL:Paint(W,H)
	local Header = 25
	
	draw.RoundedBoxEx(8, 0, 0, W, Header, HeaderColor, true, true, false, false)	
	draw.SimpleText(self.Name, "collections_headlines", W/2, Header/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )	

	draw.RoundedBoxEx(4, 0, Header, W, H-Header, CollectionsListColor,false,false,true,true)
	
	draw.SimpleText("Collection Items", "collections_headlines", W/2, self.ItemsH-5, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )	
	draw.SimpleText("Items Collected", "collections_headlines", W/2, self.SlotsH-10, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )	
	
	local HChanger = 15
	if self.ClaimRewardButton then
		HChanger = 42.5
	end	
	draw.SimpleText("Reward: " .. self.RewardText, "collections_headlines", W/2, H-HChanger, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )	
end

local SlotAmountsLine = 8
function PANEL:PerformLayout(W,H)
	local Padding = 5
	local Rows = math.ceil(#self.DPanelSlots.Slots/SlotAmountsLine)
	local CenterMissing = SlotAmountsLine-(#self.DPanelSlots.Slots-SlotAmountsLine*(Rows-1))
	local WAvailable = W-Padding*3+1
	local SlotsSize = (WAvailable/SlotAmountsLine)
	local PSlotsHRequired = SlotsSize*Rows
	
	local NumSlots = 0
	local CRow = Rows-1
	local MissingW = 0
	for k,v in pairs(self.DPanelSlots.Slots) do
		if NumSlots >= SlotAmountsLine then
			NumSlots = 0
			CRow = CRow - 1
		end
		if CRow == 0 then
			MissingW = CenterMissing * SlotsSize/2
		end
		v:SetPos(Padding+SlotsSize*(NumSlots)+MissingW,CRow*SlotsSize+Padding)
		v:SetSize(SlotsSize-Padding,SlotsSize-Padding)
		NumSlots = NumSlots + 1
	end
	
	local HChanger = 20
	if self.ClaimRewardButton then
		self.ClaimRewardButton:SetPos(W/2-62.5,H-30)
		self.ClaimRewardButton:SetSize(125,25)
		HChanger = HChanger + 25
	end	
	
	local StartH = self:GetTall()-PSlotsHRequired-Padding*2-HChanger
	self.DPanelSlots:SetPos(Padding,StartH)
	self.DPanelSlots:SetSize(WAvailable+Padding-1, PSlotsHRequired+Padding)	
	self.SlotsH = StartH
	
	Rows = math.ceil(#self.DPanelItems.Items/SlotAmountsLine)
	PSlotsHRequired = SlotsSize*Rows
	CenterMissing = SlotAmountsLine-(#self.DPanelItems.Items-SlotAmountsLine*(Rows-1))
	
	local NumSlots = 0
	local CRow = 0
	MissingW = 0
	for k,v in pairs(self.DPanelItems.Items) do
		if NumSlots >= SlotAmountsLine then
			NumSlots = 0
			CRow = CRow +1
		end
		if CRow == Rows-1 then
			MissingW = CenterMissing * SlotsSize/2
		end
		v:SetPos(Padding+SlotsSize*(NumSlots)+MissingW,CRow*SlotsSize+Padding)
		v:SetSize(SlotsSize-Padding,SlotsSize-Padding)
		NumSlots = NumSlots + 1
	end
	
	StartH = 40	
	self.DPanelItems:SetPos(Padding,StartH)
	self.DPanelItems:SetSize(WAvailable+Padding-1, PSlotsHRequired+Padding)	
	self.ItemsH = StartH
end
vgui.Register( "collections_dpanel", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()	
	self:ShowCloseButton(false)
	self:SetTitle("")   
	self:MakePopup()

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H) 
		draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)	
		draw.SimpleText("Collection Overview", "collections_headlines", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )		
	end	
	
	self.CollectionList = vgui.Create("DScrollPanel", self)
	self.CollectionList.Paint = function(selfp, W, H)
		draw.RoundedBox(4, 0, 0, W-15, H, CollectionsListColor)
	end
	
	self.CollectionList.VBar.Paint = function() end
	self.CollectionList.VBar.btnUp.Paint = function() end
    self.CollectionList.VBar.btnDown.Paint = function() end	
	self.CollectionList.VBar.btnGrip.Paint = function() end	
	
	self.ButtonTBL = {}
	for k,v in pairs(COLLECTION_COLLCETIONSDB) do
		local CButton = vgui.Create("collections_button", self.CollectionList)
		CButton:SetBText(v[1])
		CButton.DoClick = function() end	
		
		local CPanel = vgui.Create("collections_dpanel", self)
		CPanel:SetCollection(v[1],v[2],v[3],k,v[4])
		CPanel:SetVisible(false)
		CButton.CPanel = CPanel
		self.ButtonTBL[k] = CButton
		CButton.DoClick = function() self:SetPVisible(CPanel) end
	end
	self.ButtonTBL[1].CPanel:SetVisible(true)
	
	self.CloseButton = vgui.Create("collections_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end		
end

function PANEL:SetPVisible(PanelToView)
	for k,v in pairs(self.ButtonTBL) do
		v.CPanel:SetVisible(false)
	end
	PanelToView:SetVisible(true)
end

local HeaderH = 25	
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
	self.CollectionList:SetPos(5,HStart)
	self.CollectionList:SetSize(Width*0.25+15, Height-HeaderH-10)
	
	local ButtonH = 5
	for k,v in pairs(self.ButtonTBL) do
		v:SetPos(5,ButtonH)
		v:SetSize(self.CollectionList:GetWide()-25, 25)	
		
		local CPanel = v.CPanel
		CPanel:SetPos(Width*0.25+10,HStart)
		CPanel:SetSize(Width*0.75-15,Height-HeaderH-10)	
		ButtonH = ButtonH + 30
	end
	
	self.CloseButton:SetPos(Width-HeaderH,HeaderH/2-9)
	self.CloseButton:SetSize(20, 20)	
end
vgui.Register("collections_mainmenu", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()	
	self:ShowCloseButton(false)
	self:SetTitle("")   
	self:MakePopup()

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H) 
		draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)	
		draw.SimpleText("Collection Bag", "collections_headlines", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )		
	end	
	
	self.PanelList = vgui.Create("DScrollPanel", self);
	self.PanelList.Paint = function(selfp, W,H)
		draw.RoundedBox(8, 0, 0, W-15, H, CollectionsListColor)	
	end	
	
	self.PanelList.VBar.Paint = function() end
	self.PanelList.VBar.btnUp.Paint = function() end
    self.PanelList.VBar.btnDown.Paint = function() end	
	self.PanelList.VBar.btnGrip.Paint = function() end
	
	self.ItemList = {}
	for k,v in pairs(LocalPlayer().CollectionInventory) do 
		if !v then return end
		local Item = vgui.Create("collections_inv_item",self.PanelList)
		Item:SetItemInfo(k,v)
		self.ItemList[k] = Item 
		Item.MainPanel = self
	end
	
	self.CloseButton = vgui.Create("collections_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end		
end

local HeaderH = 25	
function PANEL:Paint(W,H)
	draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, MainPanelColor,false,false,true,true)	
end

local SlotsPerLine = 10
local Width, Height = 600, 400
function PANEL:PerformLayout()	
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)
	
    self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(Width,HeaderH)	
	
	self.PanelList:SetPos(5,HeaderH+5)
	self.PanelList:SetSize(Width+5,Height-HeaderH-10)
	
	local Rows = math.ceil(#self.ItemList/SlotsPerLine)
	local WAvailable = self.PanelList:GetWide()-15
	local ItemSize = WAvailable/SlotsPerLine
	
	local NumSlots = 0
	local CRow = 0
	for k,v in pairs(self.ItemList) do
		if NumSlots >= SlotsPerLine then
			NumSlots = 0
			CRow = CRow + 1
		end
		v:SetPos(ItemSize*(NumSlots),CRow*ItemSize)
		v:SetSize(ItemSize,ItemSize)
		NumSlots = NumSlots + 1
	end	
	
	self.CloseButton:SetPos(Width-HeaderH,HeaderH/2-9)
	self.CloseButton:SetSize(20, 20)	
end
vgui.Register("collections_inventory", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self.Amount = 0
	self.ID = 0
	self.ItemIcon = vgui.Create( "ModelImage" , self)
	self.ItemIcon.OnMouseReleased = self.OnMouseReleased
	self.ItemIcon.OnMousePressed = self.OnMousePressed
	self.ItemIcon.DoRightClick = self.DoRightClick
	self.ItemIcon.P = self
end

function PANEL:Paint(W,H)
	draw.RoundedBox(8, 0, 0, W, H, SlotsOutlineColor)
	draw.RoundedBox(8, 2, 2, H-4, H-4, SlotsColor)
	draw.SimpleTextOutlined(self.Amount, "default", 3, 7.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER,1,Color(0,0,0,255))
end

function PANEL:PerformLayout(W,H)
	self.ItemIcon:SetSize(W-10,H-10)
	self.ItemIcon:SetPos(5,5)
end

function PANEL:SetItemInfo(ID, Amount)
	local ItemTbl = COLLECTION_ITEMSDB[ID]
	self.ItemIcon:SetModel(ItemTbl[1]) 	
	self.Amount = Amount
	self.ID = ID
end

function PANEL:DoRightClick()
	local MPanel = self.P or self
	local ID = MPanel.ID
	
	local Options = vgui.Create("DMenu")
	Options:AddOption("Collect One", function()
		net.Start("collect_container_collectitem")
			net.WriteFloat(ID)
			net.WriteFloat(1)
		net.SendToServer()
		MPanel.Amount = MPanel.Amount - 1
		if MPanel.Amount <= 0 then 
			local MainP = MPanel.MainPanel
			MainP.ItemList[MPanel.ID] = nil
			MPanel:Remove()
			MainP:PerformLayout()
		end		
	end)
	
	Options:AddOption("Collect All", function()
		net.Start("collect_container_collectitem")
			net.WriteFloat(ID)
			net.WriteFloat(MPanel.Amount)
		net.SendToServer()
		MPanel.Amount = MPanel.Amount - MPanel.Amount
		if MPanel.Amount <= 0 then 
			local MainP = MPanel.MainPanel
			MainP.ItemList[MPanel.ID] = nil
			MPanel:Remove()
			MainP:PerformLayout()
		end		
	end)	

	Options:Open()
end

function PANEL:OnMousePressed(mousecode)	
	self:MouseCapture(true);
	self.Depressed = true;
end

function PANEL:OnMouseReleased(mousecode)
	self:MouseCapture(false);
	
	if !self.Depressed then return end
	
	self.Depressed = nil
	
	if mousecode == MOUSE_RIGHT then self:DoRightClick() end
end
vgui.Register( "collections_container_item", PANEL)

local PANEL = {}

function PANEL:Init()	
	self:ShowCloseButton(false)
	self:SetTitle("")   
	self:MakePopup()

    self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H) 
		draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)	
		draw.SimpleText("Container", "collections_headlines", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )		
	end	
	
	self.PanelList = vgui.Create("DScrollPanel", self);
	self.PanelList.Paint = function(selfp, W,H)
		draw.RoundedBox(8, 0, 0, W-15, H, CollectionsListColor)	
	end	
	
	self.PanelList.VBar.Paint = function() end
	self.PanelList.VBar.btnUp.Paint = function() end
    self.PanelList.VBar.btnDown.Paint = function() end	
	self.PanelList.VBar.btnGrip.Paint = function() end
	
	self.ItemList = {}
	
	self.CloseButton = vgui.Create("collections_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton.DoClick = function() self:Remove() end		
end

function PANEL:SetCollItems(ItemTable)
	for k,v in pairs(ItemTable) do 
		if !v then return end
		local Item = vgui.Create("collections_container_item",self.PanelList)
		Item:SetItemInfo(k,v)
		self.ItemList[k] = Item 
		Item.MainPanel = self
	end
end

local HeaderH = 25	
function PANEL:Paint(W,H)
	draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, MainPanelColor,false,false,true,true)	
end

local SlotsPerLine = 5
local Width, Height = 300, 200
function PANEL:PerformLayout()	
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)
	
    self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(Width,HeaderH)	
	
	self.PanelList:SetPos(5,HeaderH+5)
	self.PanelList:SetSize(Width+5,Height-HeaderH-10)
	
	local Rows = math.ceil(#self.ItemList/SlotsPerLine)
	local WAvailable = self.PanelList:GetWide()-15
	local ItemSize = WAvailable/SlotsPerLine
	
	local NumSlots = 0
	local CRow = 0
	for k,v in pairs(self.ItemList) do
		if NumSlots >= SlotsPerLine then
			NumSlots = 0
			CRow = CRow + 1
		end
		v:SetPos(ItemSize*(NumSlots),CRow*ItemSize)
		v:SetSize(ItemSize,ItemSize)
		NumSlots = NumSlots + 1
	end	
	
	self.CloseButton:SetPos(Width-HeaderH,HeaderH/2-9)
	self.CloseButton:SetSize(20, 20)	
end
vgui.Register("collections_container", PANEL, "DFrame")