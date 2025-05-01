include('shared.lua')

function ENT:Initialize ()
end

surface.CreateFont("res_poster_head", {
	font = "Verdana",
	size = 50,
	weight = 500,
	antialias = true,
})

surface.CreateFont("res_poster_text", {
	font = "Verdana",
	size = 35,
	weight = 500,
	antialias = true,
})

local Frame = Material("tbfy/posters/post_env.png")
local Paper = Material("tbfy/c_poster2.png")
local scale = .06
local AmountX = 266
local AmountX2 = 233
function ENT:DrawCPoster(Pos)
	local Name = self:GetPName()
	local PText = self:GetPText()
	local DType = self:GetDType()
	local BGColor = self:GetBackGColor()
	local DecalColor = self:GetDecalColor()

	local DTbl = RES_Config.PosterDecals[DType]
	draw.RoundedBox(0, 0, 0, 500, 750, Color(BGColor.x*255, BGColor.y*255, BGColor.z*255, 255))
	surface.SetMaterial(Paper)
	surface.SetDrawColor(BGColor.x*255, BGColor.y*255, BGColor.z*255, 255)
	surface.DrawTexturedRect(0, 0, 500, 750)
	if DTbl and DTbl.Mat then
		surface.SetMaterial(DTbl.Mat)
	else
		surface.SetMaterial(Frame)
	end
	surface.SetDrawColor(DecalColor.x*255, DecalColor.y*255, DecalColor.z*255, 255)
	surface.DrawTexturedRect(0, 0, 500, 750)
	draw.SimpleText(Name, "res_poster_head", 250, 160, Color(255,255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	local EntR = self:GetRight()
	local CutW = EntR*AmountX*scale
	local CutW2 = EntR*AmountX2*scale
	render.PushCustomClipPlane(EntR, (EntR):Dot(self:GetPos()-CutW))
	render.PushCustomClipPlane(-EntR, (-EntR):Dot(self:GetPos()+CutW2))
	
	render.EnableClipping(true)
		local MLines = string.Explode("\n", PText)
		for k,v in pairs(MLines) do
			draw.SimpleText(v, "res_poster_text", 250, 250+(30*(k-1)), Color(255,255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		end
	render.PopCustomClipPlane()
	render.PopCustomClipPlane()
	
	render.EnableClipping(false)
end

function ENT:Draw()	
	--self:DrawModel()
	local Pos, Ang = self:GetPos()+self:GetRight()*15+self:GetUp()*25+self:GetForward()*0, self:GetAngles()
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), -90)

	cam.Start3D2D( Pos, Ang, scale)
        self:DrawCPoster(Pos, Ang)
	cam.End3D2D()	
end

function ENT:OnRemove( )
end	
