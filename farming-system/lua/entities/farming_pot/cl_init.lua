include('shared.lua')

net.Receive("Farming_SendPlant", function() 
    local Ent, ID, Growing, FruitAmount = net.ReadEntity(), net.ReadString(), net.ReadBool(), net.ReadFloat()
	
	Ent.ID = ID
	Ent.SGrow = CurTime()
	Ent.Growing = Growing
	Ent.DGrow = false
	Ent.PlantTable = FarmingDatabase[ID]
	Ent.FSGrow = 0
	Ent.FGrow = false
	Ent.FruitTable = {}
	Ent.MaxFruits = FruitAmount
end)

net.Receive("Farming_DeathPlant", function()
	local Ent = net.ReadEntity()	
	
	if Ent.FruitTable then
		for k,v in pairs(Ent.FruitTable) do
	    	v:Remove()
		end
	end
	
	Ent.SDead = CurTime()
	Ent.Dead = true
end)

net.Receive("Farming_ResetPlant", function()	
	local Ent, FruitAmount = net.ReadEntity(), net.ReadFloat()
	
	if Ent.FruitTable then
		for k,v in pairs(Ent.FruitTable) do
	    	v:Remove()
		end
	end	
	
	Ent.DGrow = false
	Ent.FSGrow = CurTime()
	Ent.FGrow = false
	Ent.FruitTable = {}
	Ent.MaxFruits = FruitAmount
end)

function ENT:Draw()
	self:DrawModel()	
end

function ENT:StartGrowingFruit()
    local PlantTable = self.PlantTable
	
	for i = 1, self.MaxFruits do
		local Fruit = ClientsideModel(PlantTable.ProduceModel, RENDERGROUP_OPAQUE);
		Fruit:PhysicsInit( SOLID_NONE )
		Fruit:SetMoveType( MOVETYPE_NONE )
		Fruit:SetSolid( SOLID_NONE )	    
		
		Fruit:SetPos(self.Entity:GetPos() + PlantTable.PotFruitPos[i])
		Fruit:SetParent(self.Entity)
		table.insert(self.FruitTable, Fruit)
	end
	
	self.FSGrow = CurTime()
	self.FGrow = true
end

function ENT:Think ()
	if !self.Growing then return end
	if self.Dead then
	    local DPercent = (CurTime() - self.SDead)/FarmingDeathTimer
		if DPercent <= 1 then
			if IsValid(self.Plant) then
				self.Plant:SetColor(Color(255 - 160*DPercent,255-160*DPercent,255-160*DPercent,255))
			end
		elseif DPercent >= 1 then
            self.Growing = false
            self.Plant:Remove()			
		end
		return
	end
	
	local PlantTable = self.PlantTable
	
	if ( !self.Plant || !self.Plant:IsValid() ) then		
		self.Plant = ClientsideModel(PlantTable.PlantModel, RENDERGROUP_OPAQUE);
		self.Plant:PhysicsInit( SOLID_NONE )
		self.Plant:SetMoveType( MOVETYPE_NONE )
		self.Plant:SetSolid( SOLID_NONE )
		self.Plant:SetAngles( Angle(0,0,0) )
		self.Plant:SetPos( self.Entity:GetPos()+PlantTable.PotPlantPos )
		self.Plant:SetParent(self.Entity)		
	end

	if !self.DGrow then
		local GrowthPercent = (CurTime() - self.SGrow) / PlantTable.PotGrowPTime;
		if GrowthPercent <= 1 and self.Plant then
			local VScaling = Vector(PlantTable.PotPlantSize[2].x*GrowthPercent,PlantTable.PotPlantSize[2].y*GrowthPercent,PlantTable.PotPlantSize[2].z*GrowthPercent)

			local mat = Matrix()
			mat:Scale(PlantTable.PotPlantSize[1] * VScaling)
			self.Plant:EnableMatrix("RenderMultiply", mat)
		elseif GrowthPercent >= 1 then
	    	self.DGrow = true
			self:StartGrowingFruit()
		end
	end
	
	if self.FGrow then
		local GrowthPercent = (CurTime() - self.FSGrow) / PlantTable.PotGrowFTime;
	
		if GrowthPercent <= 1 then
			local VScaling = Vector(PlantTable.PotFruitSize[2].x*GrowthPercent,PlantTable.PotFruitSize[2].y*GrowthPercent,PlantTable.PotFruitSize[2].z*GrowthPercent)

			local mat = Matrix()
			mat:Scale(PlantTable.PotFruitSize[1] * VScaling)
			
            for k,v in pairs(self.FruitTable) do			
				if IsValid(v) then
				    v:EnableMatrix("RenderMultiply", mat)
                end				
            end		
		end
	end
end

function ENT:OnRemove( )
	if (IsValid(self.Plant)) then
		self.Plant:Remove();
	end	
	if self.FruitTable then
		for k,v in pairs(self.FruitTable) do
	    	v:Remove()
		end
	end
end
