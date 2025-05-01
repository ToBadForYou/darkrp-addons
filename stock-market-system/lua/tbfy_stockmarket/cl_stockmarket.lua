
TBFY_STOCKS = TBFY_STOCKS or {}
TBFY_STOCKSHISTORY = TBFY_STOCKSHISTORY or {}

LocalPlayer().TBFY_Stocks = LocalPlayer().TBFY_Stocks or {}

net.Receive("stockm_update_stock", function()
	local Stock, AC, PC, V = net.ReadString(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat()

	TBFY_STOCKS[Stock] = {
		AmountChanged = math.Round(AC,2),
		PercentChanged = math.Round(PC,2),
		Value = math.Round(V,2),
	}
end)

net.Receive("stockm_update_monitors", function()
	for k,v in pairs(ents.FindByClass("tbfy_stocks_display_1")) do
		v.StockSetup = false
	end
	for k,v in pairs(ents.FindByClass("tbfy_stocks_display_2")) do
		v.StockSetup = false
	end
end)

net.Receive("stockm_send_stocks", function()
	local StocksTbl = net.ReadTable()
	TBFY_STOCKS = StocksTbl
	LocalPlayer().TBFY_Stocks = LocalPlayer().TBFY_Stocks or {}
end)

net.Receive("stockm_send_stockhistory", function()
	local Amount, When, Stock = net.ReadFloat(), net.ReadString(), LocalPlayer().StockReq
	TBFY_STOCKSHISTORY[Stock] = {}

	for i = 1, Amount do
		TBFY_STOCKSHISTORY[Stock][i] = {Value = net.ReadFloat(), Date = net.ReadString(), Sorting = net.ReadFloat()}
	end
	table.SortByMember(TBFY_STOCKSHISTORY[Stock], "Sorting", true)
	TBFY_Graph:UpdateDiagram()
end)

net.Receive("stockm_send_compiledstocks", function()
	local CompiledString = net.ReadString()

	LocalPlayer().TBFY_Stocks = LocalPlayer().TBFY_Stocks or {}
	StockM_DecompileStocks(CompiledString, LocalPlayer())
end)

net.Receive("stockm_update_playerstocks", function()
	local StockID, Amount = net.ReadFloat(), net.ReadFloat()

	LocalPlayer().TBFY_Stocks[StockID] = Amount
end)

net.Receive("stockm_update_status", function()
	local Bool = net.ReadBool()

	StockM_Open = Bool
end)

surface.CreateFont( "stockm_paneltext", {
	font = "Verdana",
	size = 17,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "stockm_stocktitle", {
	font = "Verdana",
	size = 17,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "stockm_stockval", {
	font = "Verdana",
	size = 13,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "stockm_buttontext", {
	font = "Verdana",
	size = 12,
	weight = 750,
	antialias = true,
})

local MainPanelColor = Color(255,255,255,200)
local HeaderColor = Color(50,50,50,255)
local TabListColors = Color(215,215,220,255)
local StockListColor = Color(200,200,210,255)
local ButtonColor = Color(50,50,50,255)
local ButtonColorHovering = Color(75,75,75,200)
local ButtonColorPressed = Color(150,150,150,200)
local ButtonOutline = Color(0,0,0,200)
local HeaderH = 25
local Derma = TBFY_SH.Config.Derma
local Padding = 5

local PANEL = {}

local Width, Height = 800, 500
local LineW = 50

surface.SetFont("stockm_paneltext")
local TW,TH = surface.GetTextSize("0")
TH = TH/2
function PANEL:Init()
	self.Name = ""
	self.Stock = ""
	self.Values = {1250,1000,750,500,250,0}
	self.CurSel = "Hourly"

	self.TopDPanel = vgui.Create("tbfy_comp_dpanel", self)

	self.GraphPanel = vgui.Create("DPanel", self)
	self.GraphPanel.Paint = function(selfp, W,H)
		draw.RoundedBox(8, 0, 0, W, H, StockListColor)
		draw.SimpleText(self.CurSel, "stockm_paneltext", W/2, Padding, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		surface.SetDrawColor(0,0,0,255)
		surface.DrawLine(LineW, Padding, LineW, H-10)
		surface.DrawLine(LineW, H-10, W-Padding, H-10)

		local WPos, HPos = LineW-10, H/5-Padding
		for k,v in pairs(self.Values) do
			k = k-1
			draw.SimpleText(v, "stockm_paneltext", WPos, HPos*k+Padding, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			if v != 0 then
				surface.DrawLine(LineW-Padding, HPos*k+Padding+TH, LineW+Padding, HPos*k+Padding+TH)
			end
		end
	end

	self.Graph = vgui.Create("stockm_graph", self.GraphPanel)

	self.DailyB = vgui.Create("tbfy_button", self)
	self.DailyB:SetBText("Daily")
	self.DailyB.DoClick = function()
		net.Start("stockm_request_stockhistory")
			net.WriteString(self.Stock)
			net.WriteString("daily")
		net.SendToServer()

		self.CurSel = "Daily"
	end

	self.HourlyB = vgui.Create("tbfy_button", self)
	self.HourlyB:SetBText("Hourly")
	self.HourlyB.DoClick = function()
		net.Start("stockm_request_stockhistory")
			net.WriteString(self.Stock)
			net.WriteString("hourly")
		net.SendToServer()

		self.CurSel = "Hourly"
	end
end

function PANEL:SetStock(Name, Stock)
	self.Name = Name
	self.Stock = Stock
	self.Graph.Stock = self.Stock
	self.TopDPanel:SetTitle(self.Name .. " (" .. self.Stock .. ") " .. StockM_GetLang("StockGraph"), true)
end

GW, GH = 8, 8
function PANEL:UpdateDiagram()
	local HighestVal = 0
	for k,v in pairs(TBFY_STOCKSHISTORY[self.Stock]) do
		if v.Value > HighestVal then
			HighestVal = v.Value
		end
	end
	HighestVal = math.Round((HighestVal * 2)/5)
	self.Values = {HighestVal*5,HighestVal*4,HighestVal*3,HighestVal*2,HighestVal,0}
	local Unit = (self.Graph:GetTall()-GW/2)/self.Values[1]
	self.Graph:UpdateGraph(Unit)
end

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 2, 2, W-4, H-4, Derma.CProgramBG)
end

function PANEL:PerformLayout(W, H)
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetSize(Width-4,HeaderH)
	self.TopDPanel:SetPos(2,2)

	self.GraphPanel:SetPos(5, HeaderH+5)
	self.GraphPanel:SetSize(Width-10,Height-HeaderH-10)

	self.Graph:SetPos(Padding*3+LineW, Padding+TH)
	self.Graph:SetSize(Width-35-LineW,Height-HeaderH-32.5+GW)

	self.DailyB:SetPos(Width-55, HeaderH+Padding*2)
	self.DailyB:SetSize(45,20)

	self.HourlyB:SetPos(Width-105, HeaderH+Padding*2)
	self.HourlyB:SetSize(45,20)
end
vgui.Register("stockm_graphmenu", PANEL)

local PANEL = {}

function PANEL:Init()
	self.GraphVals = {}
	self.GraphAmounts = 1
end

function PANEL:UpdateGraph(Unit)
	for k,v in pairs(self.GraphVals) do
		if IsValid(v.Panel) then
			v.Panel:Remove()
		end
	end

	self.GraphVals = {}

	self.GraphAmounts = table.Count(TBFY_STOCKSHISTORY[self.Stock])

	local NodePos = (self:GetWide()-Padding*2)/math.Clamp(self.GraphAmounts-1,1,self.GraphAmounts)
	local Num = 0
	for k,v in ipairs(TBFY_STOCKSHISTORY[self.Stock]) do
		local GraphVal = vgui.Create("stock_graphvalue", self)
		GraphVal.Val = math.Round(v.Value, 2)
		GraphVal.Date = v.Date
		self.GraphVals[Num+1] = {Panel = GraphVal, WPos = NodePos*Num+GW/2, HPos = Unit*v.Value}
		Num = Num + 1
	end
end

local BW,BH = 130,40
function PANEL:Paint(W,H)
	for k,v in pairs(self.GraphVals) do
		local NextNode = self.GraphVals[k+1]
		if NextNode then
			local SX, SY, EX, EY = v.WPos, v.HPos, NextNode.WPos, NextNode.HPos
			surface.DrawLine(SX,H-SY,EX,H-EY)
		end
	end

	for k,v in pairs(self.GraphVals) do
		local Panel = v.Panel
		if Panel:IsHovered() then
			local X,Y = Panel:GetPos()
			local AdjX = X+GW/2

			DisableClipping(true)
			draw.RoundedBox(8, AdjX-BW/2,Y-BH-10, BW, BH, HeaderColor)
			local Tri = {
				{ x = AdjX, y = Y },
				{ x = AdjX-5, y = Y-10 },
				{ x = AdjX+5, y = Y-10 }
			}

			surface.SetDrawColor(HeaderColor)
			draw.NoTexture()
			surface.DrawPoly(Tri)

			draw.SimpleText(StockM_GetLang("StockValue") .. ": " .. Panel.Val, "stockm_buttontext", AdjX, Y-BH-5, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			surface.SetFont("stockm_buttontext")
			local TW, TH = surface.GetTextSize("A")

			draw.SimpleText(StockM_GetLang("StockDate") .. ": " .. Panel.Date, "stockm_buttontext", AdjX, Y-BH-3+TH, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			DisableClipping(false)
		end
	end
end

function PANEL:PerformLayout(W,H)
	for k,v in pairs(self.GraphVals) do
		local Panel = v.Panel
		Panel:SetPos(v.WPos-GW/2, H-v.HPos-GH/2)
		Panel:SetSize(GW,GH)
	end
end
vgui.Register("stockm_graph", PANEL)

local PANEL = {}

function PANEL:Init()

end

function PANEL:Paint(W,H)
	if self:IsHovered() then
		surface.SetDrawColor(90,90,90,255)
	else
		surface.SetDrawColor(0,0,0,255)
	end
	surface.DrawRect(0,0,W,H)
end
vgui.Register("stock_graphvalue", PANEL)

local PANEL = {}

local Padding = 5
local Width, Height = 500, 540
function PANEL:Init()
	self.Name = ""
	self.Stock = ""
	self.CurVal = 0
	self.PerChange = 0
	self.ValChange = 0
	self.StockAmountOwned = 0
	self.ID = 1

	self.AmountStocks = vgui.Create("DNumSlider", self)
	self.AmountStocks:SetText(StockM_GetLang("StockAmount"))
	self.AmountStocks:SetMin(0)
	self.AmountStocks:SetMax(StockM_GetConf("STOCK_MaxStocks"))
	self.AmountStocks:SetDecimals(0)
	self.AmountStocks.Label:SetTextColor(Color(0,0,0,255))

	self.ShowGraph = vgui.Create("tbfy_button", self)
	self.ShowGraph:SetBText(StockM_GetLang("StockShowGraph"))

	self.BuyStocks = vgui.Create("tbfy_button", self)
	self.BuyStocks:SetBText(StockM_GetLang("StockBuy"))
	self.BuyStocks.DoClick = function() net.Start("stockm_buy") net.WriteFloat(self.ID) net.WriteFloat(self.AmountStocks:GetValue()) net.SendToServer() end

	self.SellStocks = vgui.Create("tbfy_button", self)
	self.SellStocks:SetBText(StockM_GetLang("StockSell"))
	self.SellStocks.DoClick = function() net.Start("stockm_sell") net.WriteFloat(self.ID) net.WriteFloat(self.AmountStocks:GetValue()) net.SendToServer() end
end

function PANEL:SetStockInfo(Name, Stock, ID, RealStock, RealOpenTimes)
	self.Name = Name
	self.Stock = Stock
	self.ID = ID
	self.RealS = RealStock
	self.RealOT = RealOpenTimes

	if TBFY_STOCKS[Stock] then
		local StockData = TBFY_STOCKS[Stock]
		self.CurVal = StockData.Value
		self.PerChange = StockData.PercentChanged
		self.ValChange = StockData.AmountChanged
		self.ShowGraph.DoClick = function(selfp)
			self.TBFY_Graph = vgui.Create("stockm_graphmenu", self.MainP:GetParent():GetParent())
			TBFY_Graph = self.TBFY_Graph
			LocalPlayer().StockReq = self.Stock
			net.Start("stockm_request_stockhistory")
				net.WriteString(self.Stock)
				net.WriteString("hourly")
			net.SendToServer()
			self.TBFY_Graph:SetStock(self.Name, self.Stock)
		end
	end
end

function PANEL:OnRemove()
	if IsValid(self.TBFY_Graph) then
		self.TBFY_Graph:Remove()
	end
end

function PANEL:PerformLayout(W,H)
	surface.SetFont("stockm_stocktitle")
	local TW, TH = surface.GetTextSize("A")
	surface.SetFont("stockm_stockval")
	local VW, VH = surface.GetTextSize("A")

	self.AmountStocks:SetPos(5,TH+VH*3+Padding*4)
	self.AmountStocks:SetSize(Width-140, 25)

	self.ShowGraph:SetPos(W-110,TH+VH*3-Padding*2)
	self.ShowGraph:SetSize(105,25)

	self.BuyStocks:SetPos(W-110,TH+VH*3+Padding*4)
	self.BuyStocks:SetSize(50,25)

	self.SellStocks:SetPos(W-55,TH+VH*3+Padding*4)
	self.SellStocks:SetSize(50,25)
end

function PANEL:Paint(W,H)
	draw.RoundedBox(8, 0, 0, W, H, TabListColors)

	local Amount = (LocalPlayer().TBFY_Stocks and LocalPlayer().TBFY_Stocks[self.ID]) or 0
	draw.SimpleText(StockM_GetLang("StockAmountOwned") .. " " .. Amount, "stockm_stockval", W-5, Padding, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

	local StockText = self.Name .. " (" .. self.Stock .. ")"
	draw.SimpleText(StockText, "stockm_stocktitle", 5, Padding, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	surface.SetFont("stockm_stocktitle")
	local TW, TH = surface.GetTextSize(StockText)

	local StockValueText = StockM_GetLang("StockValue") .. ": " .. self.CurVal
	draw.SimpleText(StockValueText, "stockm_stockval", 5, Padding*2+TH, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	surface.SetFont("stockm_stockval")
	local VW, VH = surface.GetTextSize(StockValueText)

	local Change = 0;
	if self.PerChange > 0 then
		Change = "+" .. self.PerChange .."%"
		Color1 = Color(0, 175, 0, 255)
	elseif self.PerChange == 0 then
		Change = self.PerChange .."%"
		Color1 = Color(255, 125, 0, 255)
	else
		Change = self.PerChange .."%"
		Color1 = Color(200, 0, 0, 255)
	end

	local StockChangeText = StockM_GetLang("StockChange") .. ":"
	local SW, SH = surface.GetTextSize(StockChangeText)
	draw.SimpleText(StockChangeText, "stockm_stockval", 5, Padding*3+TH + VH, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(Change, "stockm_stockval", 10+SW, Padding*3+TH+VH, Color1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	local PW, PH = surface.GetTextSize(Change)

	local Change = 0;
	if self.ValChange >= 0 then
		Change = "+" .. self.ValChange
	else
		Change = self.ValChange
	end

	draw.SimpleText("(" .. Change .. ")", "stockm_stockval", 15+SW+PW, Padding*3+TH+VH, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	draw.SimpleText(StockM_GetLang("StockStatus"), "stockm_stockval", 5, Padding*4+TH+VH*2, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	local Status = StockM_GetLang("StockClosed")
	local Color1 = Color(200, 0, 0, 255)
	if (StockM_Open and self.RealS) or (StockM_Open and !self.RealS and self.RealOT) or (!self.RealS and !self.RealOT) then
		Status = StockM_GetLang("StockOpen")
		Color1 = Color(0, 175, 0, 255)
	end

	SSW, SSH = surface.GetTextSize(StockM_GetLang("StockStatus"))
	draw.SimpleText(Status, "stockm_stockval", Padding*2+SSW, Padding*4+TH+VH*2, Color1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end
vgui.Register("stockm_stock", PANEL)

local PANEL = {}

function PANEL:Init()
	self.DPanel = vgui.Create("DPanel", self)
	self.DPanel.Paint = function(selfp, W,H)
		draw.RoundedBox(8, 0, 0, W-10, H-10, StockListColor)
	end

  self.StockList = vgui.Create("DScrollPanel", self.DPanel)
	self.StockList.Stocks = {}
	self.StockList.VBar.Paint = function() end
	self.StockList.VBar.btnUp.Paint = function() end
  self.StockList.VBar.btnDown.Paint = function() end
	self.StockList.VBar.btnGrip.Paint = function() end

	for k,v in pairs(TBFY_STOCKMConfig.Stocks) do
		local Stock = vgui.Create("stockm_stock", self.StockList)
		Stock.MainP = self
		Stock:SetStockInfo(v.Name, v.Stock, k, v.RealStock, v.RealOpenTimes)
		self.StockList.Stocks[k] = Stock
	end
end

function PANEL:PerformLayout(W,H)
	self.DPanel:SetSize(W,H)
	self.DPanel:SetPos(5,5)

	self.StockList:SetPos(5,5)
  self.StockList:SetSize(W, H-20)

	local StockH = 0
	for k,v in pairs(self.StockList.Stocks) do
		v:SetPos(0,StockH)
		v:SetSize(W-20, 105)

		StockH = StockH + 110
	end
end

function PANEL:Paint(W,H)
end
vgui.Register("stockm_comp_stocks", PANEL)
