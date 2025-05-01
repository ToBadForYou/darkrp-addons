include("shared.lua")

function ENT:Think ()
	if !self.Screen or !self.Screen:IsValid() then
		self.Screen = ClientsideModel("models/props/cs_office/computer.mdl", RENDERGROUP_OPAQUE);
		self.Screen:PhysicsInit(SOLID_NONE)
		self.Screen:SetMoveType(MOVETYPE_NONE)
		self.Screen:SetSolid(SOLID_NONE)
		self.Screen:SetAngles(self:GetAngles())
		self.Screen:SetPos(self:GetPos()+self:GetUp()*31+self:GetForward()*-2)
		self.Screen:SetParent(self)
		self.Screen:SetNoDraw(true)
	end
	if !self.Computer or !self.Computer:IsValid() then
		self.Computer = ClientsideModel("models/props/cs_office/computer_caseB.mdl", RENDERGROUP_OPAQUE);
		self.Computer:PhysicsInit(SOLID_NONE)
		self.Computer:SetMoveType(MOVETYPE_NONE)
		self.Computer:SetSolid(SOLID_NONE)
		self.Computer:SetAngles(self:GetAngles())
		self.Computer:SetPos(self:GetPos()+self:GetRight()*-27)
		self.Computer:SetParent(self)
	end
end

local PC, GovPC, NoPic = Material("tobadforyou/pc.png"),Material("tobadforyou/govpc.png"), Material("vgui/avatar_default")
function ENT:Draw()
	self:DrawModel()
	self.Screen:DrawModel()

	local pos = self:GetPos()+self:GetUp()*55.6 + self:GetRight()*10.85 + self:GetForward()*-1.7
	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Up(),90)
	ang:RotateAroundAxis(ang:Forward(),90)

	local Status = self:GetScreenStatus()
	local Mat = PC
	local avatar
	if Status == 2 then
		Mat = GovPC
		avatar = TBFY_SH.GetImgurImage(self:GetAvatarID())
	elseif Status == 3 then
		Mat = TBFY_SH.GetImgurImage(self:GetWallpaperID())
	end

	if !Mat then
		Mat = PC
	end

	if !avatar then
		avatar = NoPic
	end

	cam.Start3D2D(pos, ang, .1);
		surface.SetMaterial(Mat)
		surface.SetDrawColor(Color(255,255,255,255))
		surface.DrawTexturedRect(0, 0, 207, 157)

		if Status == 2 then
			surface.SetMaterial(avatar)
			surface.DrawTexturedRect(86, 48, 35, 35)
		end
	cam.End3D2D();
end

function ENT:OnRemove( )
	if IsValid(self.Screen) then
		self.Screen:Remove()
	end
	if IsValid(self.Computer) then
		self.Computer:Remove()
	end
end
