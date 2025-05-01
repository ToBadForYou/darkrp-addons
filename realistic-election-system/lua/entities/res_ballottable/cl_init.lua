include('shared.lua')

surface.CreateFont("res_help_text", {
	size = 20,
	weight = 100,
	antialias = false,
	shadow = false,
	font = "arial"
})

function ENT:Initialize ()
end

local BallotInfo = Material("tbfy/ballot_information.png")
function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos();
	local ang = self:GetAngles();
	pos = pos + self.Entity:GetUp() *29.7 + self.Entity:GetForward()*1 + self.Entity:GetRight()*-12

	local W,H = 200, 250
	cam.Start3D2D( pos, ang, .1);
		surface.SetMaterial(BallotInfo)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(0, 0, W, H)
	cam.End3D2D();
end

function ENT:OnRemove( )
end
