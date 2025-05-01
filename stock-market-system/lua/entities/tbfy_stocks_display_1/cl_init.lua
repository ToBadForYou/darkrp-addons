include("shared.lua")  

surface.CreateFont( "stockm_display_value", {
	font = "Verdana",
	size = 100,
	weight = 500,
	antialias = true,
})
surface.CreateFont( "stockm_display_change", {
	font = "Verdana",
	size = 50,
	weight = 500,
	antialias = true,
})

function ENT:Initialize( )
	self.DrawStocksTbl = {}
	self.StockSetup = false
	self.LineWidth = 0
end  

function ENT:SetupStocks()
	local Stocks = TBFY_STOCKMConfig.Stocks
	local StocksData = TBFY_STOCKS or {}

	if table.Count(Stocks) > table.Count(StocksData) then return end
	
	self.StockSetup = true
	
	local Space = 5;
	local CurLineWidth = 5;
	for k,v in pairs(Stocks) do
		if !StocksData[v.Stock] then return end
		local StockData = StocksData[v.Stock]
		
		local Change = 0;
		if StockData.PercentChanged > 0 then
			Change = "▲+" .. StockData.PercentChanged .."%"
			Color1 = Color(0, 255, 0, 255);
		elseif StockData.PercentChanged == 0 then
			Change = "■" .. StockData.PercentChanged .."%"
			Color1 = Color(255, 125, 0, 255);	
		else
			Change = "▼" .. StockData.PercentChanged .."%"
			Color1 = Color(255, 0, 0, 255);
		end

		surface.SetFont("stockm_display_value")
		local StockName = v.Name .. ": " .. StockData.Value
		Width1, Height1 = surface.GetTextSize(StockName)	
		surface.SetFont("stockm_display_change")
		Width2, Height2 = surface.GetTextSize(Change)
		
		self.DrawStocksTbl[v.Stock] = {NameVal = StockName, PercentChange = Change, PercentColor = Color1, WPos = CurLineWidth, WPos2 = CurLineWidth + Width1 + Space}
		CurLineWidth = CurLineWidth + Width1 + Width2 + Space*2
	end
	self.LineWidth = CurLineWidth
end

local scale = .1
local sx = 1900
local multiplier = 250
function ENT:DrawTranslucent()
	if !self.StockSetup then self:SetupStocks() return end

	local pos, ang = self:GetPos(), self:GetAngles()
	ang:RotateAroundAxis(self:GetUp(), 90)
 
	local right = self:GetRight()
	local cw = right*sx*scale	
	
	local OBBMaxs = self:OBBMaxs()
	OBBMaxs = Vector(OBBMaxs.x,OBBMaxs.y,-OBBMaxs.z)
	local pos1 = self:LocalToWorld(OBBMaxs);
	local ang1 = self:GetAngles();
	
    ang1:RotateAroundAxis(ang1:Up(), -90);	
 	local W,H = 3800, 200
	local TextW = self.LineWidth
	cam.Start3D2D(pos1, ang1, scale)
		render.PushCustomClipPlane(right, right:Dot( pos-cw ))
		render.PushCustomClipPlane(-right, (-right):Dot( pos+cw ))	
		render.EnableClipping( true )
			
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,W,H)								

		local x = math.fmod(SysTime() * multiplier,TextW+W)
		for k,v in pairs(self.DrawStocksTbl) do
			draw.SimpleText(v.NameVal, "stockm_display_value", (v.WPos + x) - TextW, 100, Color(255, 255, 255, 255), 0, 1);
			draw.SimpleText(v.PercentChange, "stockm_display_change", (v.WPos2 + x) - TextW, 100, v.PercentColor, 0, 1);
		end
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		render.EnableClipping(false)	
	cam.End3D2D()
end