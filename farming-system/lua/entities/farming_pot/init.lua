AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/stormeffect/drug_plantpot1a.mdl")	
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	
	self.SpawnT = CurTime()
	self.StartGrow = 0
	self.Growing = false
	self.DGrowing = false
	self.Dead = false
end

function ENT:Use( activator, caller )

end

function ENT:Think ( )
    if self.Dead then return end
	
	if self.Growing then
	    if (CurTime() - self.Entity.GrowTime) >= self.Entity.StartGrow then
			self.DGrowing = true
			self.Growing = false
		end
	elseif self.SpawnT + 60 < CurTime() and !self.Growing and !self.DGrowing then 
	    self:Remove()
	end	
end

function ENT:Harvested()
    local ShouldDie = RandomPercent(self.PlantTable.DeathChance)
	
	if ShouldDie then
		net.Start("Farming_DeathPlant")
		    net.WriteEntity(self)
		net.Broadcast()	
		
		self.Dead = true
		
		timer.Simple(FarmingDeathTimer, function() self:SetModel("models/stormeffect/drug_plantpot1a.mdl") self.Growing = false self.Dead = false self.DGrowing = false end)
	else
	    self.StartGrow = CurTime()
		self.GrowTime = self.PlantTable.PotGrowFTime
	    self.DGrowing = false
		self.Growing = true	
        self.FruitAmount = math.random(self.PlantTable.MinFruits, self.PlantTable.MaxFruits)		
		
		net.Start("Farming_ResetPlant")
		    net.WriteEntity(self)
			net.WriteFloat(self.FruitAmount)
		net.Broadcast()			
	end
end

function ENT:Touch(TouchEnt)
    if self.Entity.Touched and self.Entity.Touched > CurTime() then return ; end
	self.Entity.Touched = CurTime() + 2;
	if self.Growing or self.DGrowing or self.Dead then return end
	
	local CurPlants = 0
	for k,v in pairs(ents.FindByClass("farming_plot")) do
		if v.SID == self.SID and v.ID and !v.Dead then
		    CurPlants = CurPlants + 1
		end
	end
	
	for k,v in pairs(ents.FindByClass("farming_pot")) do
		if v.SID == self.SID and v.ID and !v.Dead then
		    CurPlants = CurPlants + 1
		end
	end	

	if CurPlants >= FarmingMaxPlants then return end
	
	if TouchEnt:GetClass() == "farming_seed" and FarmingDatabase[TouchEnt.ID].Pot then
		self:SetModel("models/stormeffect/drug_plantpot2a.mdl")
		self:SetAngles(Angle(0,0,0))
		self:GetPhysicsObject():EnableMotion(false)
		self.ID = TouchEnt.ID
		self.PlantTable = FarmingDatabase[TouchEnt.ID]
		self.StartGrow = CurTime()
		self.GrowTime = self.PlantTable.PotGrowPTime + self.PlantTable.PotGrowFTime
		self.Growing = true
		self.FruitAmount = math.random(self.PlantTable.MinFruits, self.PlantTable.MaxFruits)
		
		net.Start("Farming_SendPlant")
		    net.WriteEntity(self)
			net.WriteString(self.ID)
			net.WriteBool(true)
			net.WriteFloat(self.FruitAmount)
		net.Broadcast()	
		
		timer.Simple(self.PlantTable.PotGrowPTime-0.5, function() self:SetAngles(Angle(0,0,0)) self:GetPhysicsObject():EnableMotion(false) end)
		TouchEnt:Remove()
	end
end