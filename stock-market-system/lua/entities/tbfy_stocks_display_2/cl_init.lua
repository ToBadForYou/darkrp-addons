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
	self.LineHeight = 5
end  

function ENT:SetupStocks()
	local Stocks = TBFY_STOCKMConfig.Stocks
	local StocksData = TBFY_STOCKS or {}

	if table.Count(Stocks) > table.Count(StocksData) then return end
	
	self.StockSetup = true
	
	local Space = 5;
	local CurLineHeight = 5;
	for k,v in pairs(Stocks) do
		if !StocksData[v.Stock] then return end
		local StockData = StocksData[v.Stock]
		
		local Change = 0;
		if StockData.PercentChanged > 0 then
			Change = "▲+" .. StockData.PercentChanged .."%"
			Color1 = Color(0, 255, 0, 255);
		elseif StockData.PercentChanged == 0 then
			Change = "■" .. StockData.PercentChanged .."%"
			Color1 = Color(255, 125, 0, 255)
		else
			Change = "▼" .. StockData.PercentChanged .."%"
			Color1 = Color(255, 0, 0, 255);
		end

		surface.SetFont("stockm_display_value")
		local StockName = v.Name .. ": " .. StockData.Value
		Width1, Height1 = surface.GetTextSize(StockName)	
		surface.SetFont("stockm_display_change")
		Width2, Height2 = surface.GetTextSize(Change)
		
		self.DrawStocksTbl[v.Stock] = {NameVal = StockName, PercentChange = Change, PercentColor = Color1, HPos = CurLineHeight}
		CurLineHeight = CurLineHeight+Height1+5
	end
	self.LineHeight = CurLineHeight
end

local scale = .1
local sx = 712.5
local multiplier = 175
function ENT:DrawTranslucent()
	if !self.StockSetup then self:SetupStocks() return end

	local pos, ang = self:GetPos(), self:GetAngles()
	ang:RotateAroundAxis(self:GetUp(), 90)
 
	local up = self:GetUp()
	local right = self:GetRight()
	local forward = self:GetForward()
	local cw = forward*sx*scale	
	
	local OBBMaxs = self:OBBMaxs()
	OBBMaxs = Vector(OBBMaxs.x,OBBMaxs.y,-OBBMaxs.z)
	local pos1 = self:LocalToWorld(OBBMaxs);
	local ang1 = self:GetAngles();
	
    ang1:RotateAroundAxis(ang1:Up(), -90);	
 	local W,H = 1425, 1425
	local TextH = self.LineHeight
	cam.Start3D2D(pos1, ang1, scale)
		render.PushCustomClipPlane(forward, forward:Dot( pos-cw ))
		render.PushCustomClipPlane(-forward, (-forward):Dot( pos+cw ))	
		render.EnableClipping( true )
		
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,W,H)								

		local x = math.fmod(SysTime() * multiplier,TextH+H+25)
		for k,v in pairs(self.DrawStocksTbl) do
			draw.SimpleText(v.NameVal, "stockm_display_value", 25, (v.HPos+x)-TextH, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, 1);
			draw.SimpleText(v.PercentChange, "stockm_display_change", H-5, (v.HPos+x)-TextH, v.PercentColor, TEXT_ALIGN_RIGHT, 1);
		end
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		render.EnableClipping(false)	
	cam.End3D2D()
end