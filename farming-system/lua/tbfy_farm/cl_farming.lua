
FarmingAreas = {}

net.Receive("Farming_AreaManager", function()

	local AreaManager = vgui.Create("farming_areamanager")
	AreaManager:UpdateAreas()
end)

net.Receive("Farming_Buyermenu", function()
    local NPC = net.ReadEntity()

	local FarmingBuyMenu = vgui.Create("farming_buymenu")
	FarmingBuyMenu:SetupCrates(NPC)
end)

net.Receive("Farming_SendAreaInfoSingle", function()
    local Pos1, Pos2, Name = net.ReadVector(), net.ReadVector(), net.ReadString()

	table.insert(FarmingAreas, {Pos1,Pos2,Name})
end)

net.Receive("Farming_SendAreaInfo", function()
    local AreaTbl = net.ReadTable()

	FarmingAreas = AreaTbl
end)

net.Receive("Farming_RemoveArea", function()
    local ID = net.ReadFloat()

	FarmingAreas[ID] = nil
end)

net.Receive("Farming_BoxMenu", function()
	local boxMenu = vgui.Create("DMenu")
	boxMenu:AddOption("Harvest nearby fruit", function() net.Start("Farming_BoxHarvest") net.SendToServer() end)
	boxMenu:AddOption("Eat a fruit", function() net.Start("Farming_BoxEat") net.SendToServer() end)
	boxMenu:Open()

	boxMenu:SetPos(ScrW()/2,ScrH()/2)
end)

surface.CreateFont( "farming_npc_text", {
	font = "Verdana",
	size = 50,
	weight = 500,
	antialias = true,
})

local PANEL = {}

function PANEL:Init()
    self.ID = ""
	self.Price = 0
	self.Amount = 0

	self.ModelPanel = vgui.Create("DModelPanel", self)
	self.ModelPanel:SetSize(60,60)
	self.ModelPanel:SetPos(0,10)
	self.ModelPanel:SetFOV(30)

	self.SellButton = vgui.Create("DButton", self)
	self.SellButton:SetText("Sell")
	self.SellButton:SetTextColor(Color(200,200,200,255))
	self.SellButton:SetSize(60,20)
	self.SellButton.Paint = function()
		local W,H = self.SellButton:GetWide(), self.SellButton:GetTall()
		derma.SkinHook( "Paint", "Button", self.SellButton, W, H )
		surface.SetDrawColor(50,50,50,200)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, W, H )
	end
	self.SellButton:SetPos(200/2-10,55)
end

function PANEL:Paint(W,H)
    surface.SetDrawColor(50,50,50,200)
	surface.DrawRect( 0, 0, W, H)
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawOutlinedRect( 0, 0, W, H )

	draw.SimpleText(self.ID, "Trebuchet24", W/1.5, 15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText("Value: $" .. self.Price, "default", 5, 65, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	draw.SimpleText("You have: " .. self.Amount, "default", W/1.5, 35, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText("Can be sold for: $" .. self.Amount*self.Price, "default", W/1.5, 45, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function PANEL:SetPTable(ID, Amount)
	local PTable = FarmingDatabase[ID]

	self.ID = ID
	self.Price = PTable.SellPrice
	self.Amount = Amount

    self.ModelPanel:SetModel(PTable.ProduceModel)
	local Middle = self.ModelPanel:GetEntity():GetBonePosition(0)
	self.ModelPanel:SetLookAt( Middle )

	self.SellButton.DoClick = function() local MainPanel = self:GetParent():GetParent():GetParent() MainPanel:RemoveCrates() net.Start("Farming_SellFruits") net.WriteString(self.ID) net.SendToServer() timer.Simple(0.1, function() MainPanel:SetupCrates(MainPanel.NPC) end) end
end

vgui.Register( "farming_fruitinfo", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle("")
	self:MakePopup()
	self.Height = 400

    self.ListLayout = vgui.Create("DScrollPanel", self)
	//Whacky workaround
	self.ListLayout.VBar.Paint = function() end
	self.ListLayout.VBar.btnUp.Paint = function() end
    self.ListLayout.VBar.btnDown.Paint = function() end
	self.ListLayout.VBar.btnGrip.Paint = function() end

	self.CloseButton = vgui.Create("DButton", self)
	self.CloseButton:SetText("Close")
	self.CloseButton.DoClick = function() self:Remove() end
	self.CloseButton:SetTextColor(Color(200,200,200,255))
	self.CloseButton.Paint = function()
		local W,H = self.CloseButton:GetWide(), self.CloseButton:GetTall()
		derma.SkinHook( "Paint", "Button", self.CloseButton, W, H )
		surface.SetDrawColor(50,50,50,200)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, W, H )
	end
end

function PANEL:RemoveCrates()
    for k,v in pairs(self.FTable) do
	    v:Remove()
	end
end

function PANEL:SetupCrates(NPC)
	local Table = {}
	for k,v in pairs(ents.FindInSphere(NPC:GetPos(), FarmingBuyerRange)) do
	    if v:GetClass() == "farming_storage" and v:Getcontents() != "Empty" then
		    local ID = v:Getcontents()
			if Table[ID] then
			    Table[ID].Amount = Table[ID].Amount + v:Getcount()
			else
				Table[ID] = {}
				Table[ID].ID = v:Getcontents()
				Table[ID].Amount = v:Getcount()
			end
		end
	end

	self.NPC = NPC
	self.FTable = {}
    local HPos = 0
	local HPanel = 0

	for k,v in pairs(Table) do
		local FruitInfo = vgui.Create("farming_fruitinfo", self.ListLayout)
		FruitInfo:SetSize(180,80)
		FruitInfo:SetPos(0, HPos)
		FruitInfo:SetPTable(v.ID,v.Amount)
		HPos = HPos+79.5
		HPanel = HPanel + 80
		table.insert(self.FTable, FruitInfo)
	end

	self.Height = math.Clamp( HPanel+35, 35, 400 )
end

function PANEL:Paint(W,H)
    surface.SetDrawColor(0,0,0,200)
	surface.DrawRect( 0, 0, W-15, H)
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 0, 0, W-15, H )
end

local Width = 205
function PANEL:PerformLayout()
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-self.Height/2)
	self:SetSize(Width, self.Height)

	self.ListLayout:SetPos(5,5)
	self.ListLayout:SetSize(Width-5, self.Height-35)

	self.CloseButton:SetPos(5,self.Height-25)
	self.CloseButton:SetSize(Width-25, 20)
end

vgui.Register("farming_buymenu", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self.Name = ""

	self.RemoveButton = vgui.Create("DButton", self)
	self.RemoveButton:SetText("Remove")
	self.RemoveButton:SetTextColor(Color(200,200,200,255))
	self.RemoveButton:SetSize(50,20)
	self.RemoveButton.Paint = function()
		local W,H = self.RemoveButton:GetWide(), self.RemoveButton:GetTall()
		derma.SkinHook( "Paint", "Button", self.RemoveButton, W, H )
		surface.SetDrawColor(50,50,50,200)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, W, H )
	end
	self.RemoveButton:SetPos(125,5)
end

function PANEL:SetArea(Name, TblID)
	self.Name = Name
    self.ID = TblID

	self.RemoveButton.DoClick = function() local MainPanel = self:GetParent():GetParent():GetParent() FarmingAreas[self.ID] = nil MainPanel:UpdateAreas() net.Start("Farming_RemoveArea") net.WriteFloat(self.ID) net.SendToServer() end
end

function PANEL:Paint(W,H)
    surface.SetDrawColor(50,50,50,200)
	surface.DrawRect( 0, 0, W, H)
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawOutlinedRect( 0, 0, W, H )

	draw.SimpleText(self.Name, "default", 5, 15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

vgui.Register( "farming_areainfo", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle("")
	self:MakePopup()
	self.Height = 300
	self.ATable = {}

    self.ListLayout = vgui.Create("DScrollPanel", self)
	//Whacky workaround
	self.ListLayout.VBar.Paint = function() end
	self.ListLayout.VBar.btnUp.Paint = function() end
    self.ListLayout.VBar.btnDown.Paint = function() end
	self.ListLayout.VBar.btnGrip.Paint = function() end

	self.SaveButton = vgui.Create("DButton", self)
	self.SaveButton:SetText("Save")
	self.SaveButton.DoClick = function() net.Start("Farming_SaveAreas") net.WriteTable(FarmingAreas) net.SendToServer() end
	self.SaveButton:SetTextColor(Color(200,200,200,255))
	self.SaveButton.Paint = function()
		local W,H = self.SaveButton:GetWide(), self.SaveButton:GetTall()
		derma.SkinHook( "Paint", "Button", self.SaveButton, W, H )
		surface.SetDrawColor(50,50,50,200)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, W, H )
	end

	self.CloseButton = vgui.Create("DButton", self)
	self.CloseButton:SetText("Close")
	self.CloseButton.DoClick = function() self:Remove() end
	self.CloseButton:SetTextColor(Color(200,200,200,255))
	self.CloseButton.Paint = function()
		local W,H = self.CloseButton:GetWide(), self.CloseButton:GetTall()
		derma.SkinHook( "Paint", "Button", self.CloseButton, W, H )
		surface.SetDrawColor(50,50,50,200)
		surface.DrawRect( 0, 0, W, H)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, W, H )
	end
end

function PANEL:UpdateAreas()
    for k,v in pairs(self.ATable) do
	    v:Remove()
	end

	self.ATable = {}

	local HPos = 0
	for k,v in pairs(FarmingAreas) do
		local AreaInfo = vgui.Create("farming_areainfo", self.ListLayout)
		AreaInfo:SetSize(180,30)
		AreaInfo:SetPos(0, HPos)
		AreaInfo:SetArea(v[3], k)
        HPos = HPos + 29
		table.insert(self.ATable, AreaInfo)
	end
end

function PANEL:Paint(W,H)
    surface.SetDrawColor(0,0,0,200)
	surface.DrawRect( 0, 0, W-15, H)
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 0, 0, W-15, H )
end

local Width = 205
function PANEL:PerformLayout()
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-self.Height/2)
	self:SetSize(Width, self.Height)

	self.ListLayout:SetPos(5,5)
	self.ListLayout:SetSize(Width-5, self.Height-35)

	local WidthA = (Width-25)/2

	self.SaveButton:SetPos(5,self.Height-25)
	self.SaveButton:SetSize(WidthA, 20)

	self.CloseButton:SetPos(5+WidthA,self.Height-25)
	self.CloseButton:SetSize(WidthA, 20)
end

vgui.Register("farming_areamanager", PANEL, "DFrame")
