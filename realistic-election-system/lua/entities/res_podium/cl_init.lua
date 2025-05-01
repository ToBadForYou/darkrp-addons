include('shared.lua')

function ENT:Initialize ()
end

surface.CreateFont("res_podium_head", {
	font = "Verdana",
	size = 50,
	weight = 500,
	antialias = true,
})

surface.CreateFont("res_podium_text", {
	font = "Verdana",
	size = 36,
	weight = 500,
	antialias = true,
})

local Decals = Material("tbfy/podium/pod_env.png")
function ENT:Draw()	
	self:DrawModel()
	
	local Pos, Ang = self:GetPos()+self:GetRight()*-15.1+self:GetUp()*58+self:GetForward()*15, self:GetAngles()
	Ang:RotateAroundAxis(Ang:Forward(), -90)
	Ang:RotateAroundAxis(Ang:Up(), 180)

	local Name = self:GetPName()
	local Slogan = self:GetSlogan()
	local DType = self:GetDType()
	local BGColor = self:GetBackGColor()
	local DecalColor = self:GetDecalColor()
	if LocalPlayer().EditingPodium and LocalPlayer().LastPodium == self then
		local PSettings = LocalPlayer().CS_PodiumSettings
		Name = PSettings.N
		Slogan = PSettings.S
		DType = PSettings.D
		BGColor = PSettings.BGc
		DecalColor = PSettings.Dc
	end
	
	local DTbl = RES_Config.PodiumDecals[DType]
	cam.Start3D2D( Pos, Ang, .06)
		draw.RoundedBox(0, 0, 0, 500, 218, Color(BGColor.x*255, BGColor.y*255, BGColor.z*255, 255))
		if DTbl and DTbl.Mat then
			surface.SetMaterial(DTbl.Mat)
		else
			surface.SetMaterial(Decals)
		end
		surface.SetDrawColor(DecalColor.x*255, DecalColor.y*255, DecalColor.z*255, 255)
		surface.DrawTexturedRect(0, 0, 500, 217)		
        draw.SimpleText(Name, "res_podium_head", 250, 80, Color(255,255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText(Slogan, "res_podium_text", 250, 150, Color(255,255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function ENT:OnRemove( )
end