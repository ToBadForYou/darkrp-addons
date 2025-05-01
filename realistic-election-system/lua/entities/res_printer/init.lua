AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( Player, tr, Class )
	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal* 28
	local SpawnAng = Player:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( Class )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()

	ent.RESPEnt = true
	ent:SetEOwner(Player)
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel("models/pcmod/kopierer.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	self.RESPEnt = true
end

function ENT:StartSound()
    self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
    self.sound:SetSoundLevel(52)
    self.sound:PlayEx(1, 100)
end

function ENT:StopPSound()
	self.sound:Stop()
end

function ENT:AttemptPrintPoster(Player)
	if !self.Printing then
		local CurPosters = Player:GetCPostersAmount()
		local MaxPosters = RES_GetConf("ELECTION_MaxPosters")
		if CurPosters >= MaxPosters then
			TBFY_Notify(Player, 1, 4, string.format(RES_GetLang("MaxPostersPrint"), MaxPosters))
		else
			local PEnt = Player.LastPoster
			if IsValid(PEnt) then
				self:PrintPoster(PEnt)
			else
				TBFY_Notify(Player, 1, 4, RES_GetLang("NoPosterTable"))
			end
		end
	end
end

function ENT:PrintPoster(PEnt)
	self.Printing = true
	self:SetPColor(PEnt:GetBackGColor())

	net.Start("res_update_print")
		net.WriteEntity(self)
		net.WriteBool(true)
	net.Broadcast()

	timer.Simple(5, function()
		if IsValid(self) then
			net.Start("res_update_print")
				net.WriteEntity(self)
				net.WriteBool(false)
			net.Broadcast()

			local Poster = ents.Create("res_campaign_poster")
			local Pos, Ang = self:GetPos()+self:GetRight()*12+self:GetUp()*18.2+self:GetForward()*5, self:GetAngles()
			Ang:RotateAroundAxis(Ang:Up(), -90)
			Ang:RotateAroundAxis(Ang:Right(), -90)

			Poster:SetPos(Pos)
			Poster:SetAngles(Ang)
			Poster:Spawn()
			Poster:SetupPValues(PEnt)

			self.Printing = false
		end
	end)
end

function ENT:Use( activator, caller )
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;

	if self:GetEOwner() == activator then
		activator.LastPPrinter = self
		net.Start("res_printer")
		net.Send(activator)
	end
end

function ENT:Think()
	if self.Printing then
		self:StartSound()
	elseif self.sound then
		self:StopPSound()
	end
end
