AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( Player, tr, Class )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal* 20 + Vector(0,0,58)
	local SpawnAng = Player:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( Class )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:Initialize()
	self.Entity:SetModel("models/tbfu_noticeboard/noticeboard.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
    self.Posters = {}
	
	self:GeneratePoses()
end

function ENT:GeneratePoses()
    self.PosterPoses = {}
	self.PosterPoses.WPoses = {}
	self.PosterPoses.Taken = {{},{}}
	for i = -4, 5 do
	    table.insert(self.PosterPoses.WPoses,i * 12)
	end
end

function ENT:GenerateID(Poster)
    local UpOrDown = math.random(1,2)
	local WID = math.random(1,#self.PosterPoses.WPoses)
	local WPos = self.PosterPoses.WPoses[WID]

	if table.HasValue(self.PosterPoses.Taken[UpOrDown], WID) then
	    //All poses taken, randomize location even if poster there
		if #self.PosterPoses.Taken[1] + #self.PosterPoses.Taken[2] >= 20 then
			return WPos, math.random(-22,22)
		else
			return self:GenerateID(Poster)
		end
	end
	table.insert(self.PosterPoses.Taken[UpOrDown], WID)
	Poster.IDs = {UpOrDown,WID}

	if UpOrDown == 1 then
	    return WPos, math.random(10,28)
	elseif UpOrDown == 2 then
	    return WPos, math.random(-10,-32)
	end
end

function ENT:AddBounty(Player, Nick, Bounty, PlacedBy)
	local Poster = ents.Create("bountyposter")
	local IDPosF, IDPosU = self:GenerateID(Poster)
	
	Poster:SetMoveType(MOVETYPE_NONE)
	Poster:SetParent(self)
	local Ang = self:GetAngles()
	Ang:RotateAroundAxis( Ang:Up(), 0 )
	Poster:SetAngles(Ang)
	Poster:SetPos(self:GetPos()+self:GetRight()*(IDPosF-5.25)+self:GetForward()*1+self:GetUp()*IDPosU)
	Poster.Player = Player	
	Poster:Spawn()
	Poster.Bounty = Bounty
	Poster.Board = self
	if PlacedBy then
		Poster.PlacedBy = PlacedBy
	end
	
	self.Posters[Player:UniqueID()] = Poster
	
	//Let entity be created
	timer.Simple(.1, function()
		net.Start("AddNewBountyPoster")
	   		net.WriteEntity(Poster)
			net.WriteString(Nick)
			net.WriteFloat(Bounty)
		net.Broadcast()
	end)
	
end

function ENT:Use(activator, caller)
    if self.Entity.Touched and self.Entity.Touched > CurTime() then return ; end
	self.Entity.Touched = CurTime() + .5;
	
	if !TBFY_BHConfig.DisableManualBounty and activator:CanPlaceBounty() then
		net.Start("open_place_bounty_menu")
		net.Send(activator)
	end
end

function ENT:Think()
end

function ENT:Touch(TouchEnt)
    if self.Entity.Touched and self.Entity.Touched > CurTime() then return ; end
	self.Entity.Touched = CurTime() + 1;
end