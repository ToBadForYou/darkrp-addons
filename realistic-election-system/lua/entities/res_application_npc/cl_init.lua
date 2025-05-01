include('shared.lua')

surface.CreateFont("res_npc_text", {
	font = "Verdana",
	size = 50,
	weight = 500,
	antialias = true,
})

function ENT:Initialize ()
	local Data = RES_Config.NPCData[self:GetClass()]
	self.aps = Data.TextRotationSpeed
	self.lastRot = CurTime()
	self.curRot = 0
	
	self.Font = Data.TextFont
	self.Text = Data.Text
	self.TextColor = Data.TextColor
	self.TextBGColor = Data.TextBackgroundColor
end

function ENT:Draw()
	self.curRot = self.curRot + (self.aps * (CurTime() - self.lastRot))
	if (self.curRot > 360) then self.curRot = self.curRot - 360 end
	self.lastRot = CurTime()
	
	local Maxs = self:LocalToWorld(self:OBBMaxs())
	local EntPos = self:GetPos()
	local TextPos = Vector(EntPos.x,EntPos.y,Maxs.z+8)
	local Text = self.Text
	local Font = self.Font
	surface.SetFont(Font)
	local W,H = surface.GetTextSize(Text)
	surface.SetDrawColor(self.TextBGColor)
	
	cam.Start3D2D(TextPos, Angle(180, self.curRot, -90), .1)
		surface.DrawRect(-W/2,-H/2,W,H)
		draw.SimpleText(Text, Font, 0, 0, self.TextColor, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	cam.End3D2D()	
	cam.Start3D2D(TextPos, Angle(180, self.curRot + 180, -90), .1)
		draw.SimpleText(Text, Font, 0, 0, self.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()

	self:DrawModel()	
end

function ENT:OnRemove( )
end	
