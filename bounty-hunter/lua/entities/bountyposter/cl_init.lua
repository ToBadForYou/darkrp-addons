include('shared.lua')

surface.CreateFont( "BB_WantedPosterTextName", {
	font = "Sitka Banner Bold",
	size = 25,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "BB_WantedPosterTextBounty", {
	font = "Sitka Banner Bold",
	size = 25,
	weight = 500,
	antialias = true,
} )

net.Receive("AddNewBountyPoster", function()
    local Ent, Nick, Bounty = net.ReadEntity(),net.ReadString(),net.ReadFloat()
	
	Ent.Name = Nick
	Ent.Bounty = Bounty
end)

net.Receive("UpdateBountyPoster", function()
    local Ent, Bounty = net.ReadEntity(),net.ReadFloat()
	
	Ent.Bounty = Bounty
end)

function ENT:Initialize ()
    self.Name = ""
	self.Bounty = 0
end

function ENT:Think ()	

end

local Frame = Material("bountyframe.png")
function ENT:DrawBounty(Pos, Ang)
 	surface.SetMaterial(Frame)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, 180, 300)
	
	draw.SimpleText(self.Name, "BB_WantedPosterTextName",90,90,color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	draw.SimpleText("Press E to", "BB_WantedPosterTextName",90,150,color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	draw.SimpleText("start bounty", "BB_WantedPosterTextName",90,175,color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	draw.SimpleText("$" .. self.Bounty, "BB_WantedPosterTextBounty",90,280,color_black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)	   
end

function ENT:Draw()	
	local Pos, Ang = self:GetPos()+self:GetRight()*5+self:GetUp()*9, self:GetAngles()
	Ang:RotateAroundAxis( Ang:Forward(), 90 )
	Ang:RotateAroundAxis( Ang:Right(), -90 )

	cam.Start3D2D( Pos, Ang, .06)
        self:DrawBounty(Pos, Ang)
	cam.End3D2D()
end

function ENT:OnRemove( )
 
end	
