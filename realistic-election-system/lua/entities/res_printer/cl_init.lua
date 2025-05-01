include('shared.lua')

local target = 750
local Frame = Material("res_app_form.png")
net.Receive("res_update_print", function()
	local Ent, Bool = net.ReadEntity(), net.ReadBool()
	
	Ent.current = 0
	Ent.Printing = Bool
end)

function ENT:Initialize()
	self.Printing = false
end

function ENT:DrawCPoster(Pos, Ang)
	if self.current > 740 and self.current != 750 then 
		self.current = 750
	else
		self.current = Lerp(FrameTime()*0.6, self.current, target)
	end
	local PColor = self:GetPColor()
 	surface.SetMaterial(Frame)
	surface.SetDrawColor(PColor.x*255, PColor.y*255, PColor.z*255, 255)
	surface.DrawRect(0, 0, 500, self.current)   
end

function ENT:Draw()	
	self:DrawModel()
end

function ENT:DrawTranslucent()
	local Pos, Ang = self:GetPos()+self:GetRight()*-8+self:GetUp()*18.2+self:GetForward()*-9.5, self:GetAngles()
	
	if self.Printing then
		cam.Start3D2D(Pos, Ang, 0.06)
			self:DrawCPoster(Pos, Ang)
		cam.End3D2D()
	end
end

function ENT:OnRemove( )
end