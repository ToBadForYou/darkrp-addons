include('shared.lua')
function ENT:Think ()	
end

function ENT:Draw()
	self:DrawModel()	
	
    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    local contents = self:Getcontents() or ""
	local Amount = tostring(self:Getcount()) or ""
    if Amount == "0" then Amount = "" end
	
    surface.SetFont("HUDNumber5")
    local TextWidth = surface.GetTextSize(contents)
    local TextWidth2 = surface.GetTextSize(Amount)

    cam.Start3D2D(Pos + Ang:Up() * 25, Ang, 0.2)
        draw.WordBox(2, -TextWidth * 0.5 + 5, -30, contents, "HUDNumber5", Color(140, 0, 0, 100), Color(255, 255, 255, 255))
        draw.WordBox(2, -TextWidth2 * 0.5 + 5, 18, Amount, "HUDNumber5", Color(140, 0, 0, 100), Color(255, 255, 255, 255))
    cam.End3D2D()

    Ang:RotateAroundAxis(Ang:Forward(), 90)
end

function ENT:OnRemove( )
end	
