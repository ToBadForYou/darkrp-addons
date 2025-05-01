
local PANEL = {}

function PANEL:Init()	
	self:ShowCloseButton(false)
	self:SetTitle("")   
	self:MakePopup()

	self.ClientModelTable = {}
	self.FruitTable = {}
	self.Selected = nil
	self.Fruits = 1
	
    self.ListLayout = vgui.Create("DListLayout", self)
	
    self.CheckPot = vgui.Create( "DCheckBoxLabel") 
    self.CheckPot:SetText( "Setup for pot (Prints different variables)" )	
    self.CheckPot:SetValue( 0 )
	self.ListLayout:Add(self.CheckPot)		
	
    self.EntitySelect = vgui.Create( "DComboBox" )
    self.EntitySelect:SetValue( "Select Entity" )
    self.EntitySelect.OnSelect = function( panel, index, value )
		self.Selected = self.ClientModelTable[index]
    end	
	self.ListLayout:Add(self.EntitySelect)		

	//Setting up Client models
	local trace = {};
	trace.start = LocalPlayer():GetShootPos();
	trace.endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector()*200;
	trace.filter = LocalPlayer();
	local tRes = util.TraceLine(trace);		
	
	self.OriginalPos = tRes.HitPos
	
	self.PlantModel = ClientsideModel("models/props/de_inferno/tree_small.mdl", RENDERGROUP_OPAQUE)
	self.PlantModel:SetMoveType( MOVETYPE_NONE )
	self.PlantModel:SetSolid( SOLID_NONE )
	self.PlantModel:SetPos(tRes.HitPos)
	self.PlantModel.Name = "Plant Model"
	self.PlantModel.Size = {1,Vector(1,1,1)}
	table.insert(self.ClientModelTable, self.PlantModel)
	
	self.ContainerModel = ClientsideModel("models/props_phx/construct/metal_angle360.mdl", RENDERGROUP_OPAQUE)
	self.ContainerModel:SetMoveType( MOVETYPE_NONE )
	self.ContainerModel:SetSolid( SOLID_NONE )
	self.ContainerModel:SetPos(tRes.HitPos)	
	self.ContainerModel:SetColor(Color(125,83,63,255))
	self.ContainerModel:SetMaterial("phoenix_storms/potato")
    self.ContainerModel.Name = "Container Model"	
	table.insert(self.ClientModelTable, self.ContainerModel)
	
	self.CheckPot.OnChange = function(Pself, Value)
        if Value then
		    self.ContainerModel:SetColor(Color(255,255,255,255))
			self.ContainerModel:SetModel("models/stormeffect/drug_plantpot2a.mdl")
		else
		    self.ContainerModel:SetModel("models/props_phx/construct/metal_angle360.mdl")
			self.ContainerModel:SetColor(Color(125,83,63,255))
		end
	end	
	
	self.Fruit = ClientsideModel("models/props/de_inferno/crate_fruit_break_gib2.mdl", RENDERGROUP_OPAQUE)
	self.Fruit:SetMoveType( MOVETYPE_NONE )
	self.Fruit:SetSolid( SOLID_NONE )
	self.Fruit:SetPos(tRes.HitPos)	
	self.Fruit.Name = "Fruit " .. self.Fruits	
	self.Fruit.Size = {1,Vector(1,1,1)}
	table.insert(self.ClientModelTable, self.Fruit)
	table.insert(self.FruitTable, self.Fruit)
	
	//Position Cat
	self.PositionOptions = vgui.Create( "DCollapsibleCategory")
	self.PositionOptions:SetLabel("Position")	
	self.PositionOptions:SetExpanded( 0 )	
	self.ListLayout:Add(self.PositionOptions)
	
	self.ListLayoutPosition = vgui.Create("DListLayout", self)

	self.PosX = vgui.Create("DNumSlider")
	self.PosX:SetText("PosX")
	self.PosX:SetMin(-100)
	self.PosX:SetMax(100)
	self.PosX:SetDecimals(0)
	self.PosX:SetValue(0)	
	self.ListLayoutPosition:Add(self.PosX) 

	self.PosY = vgui.Create("DNumSlider")
	self.PosY:SetText("PosY")
	self.PosY:SetMin(-100)
	self.PosY:SetMax(100)
	self.PosY:SetDecimals(0)
	self.PosY:SetValue(0)
	self.ListLayoutPosition:Add(self.PosY) 

	self.PosZ = vgui.Create("DNumSlider")
	self.PosZ:SetText("PosZ")
	self.PosZ:SetMin(-10)
	self.PosZ:SetMax(300)
	self.PosZ:SetDecimals(0)
	self.PosZ:SetValue(0)
	self.ListLayoutPosition:Add(self.PosZ) 	
	
	self.PosX.OnValueChanged = function(panel, value)
 	    if !self.Selected then return end
		self.Selected:SetPos(self.OriginalPos+Vector(value,self.PosY:GetValue(),self.PosZ:GetValue()))         
	end		
	self.PosY.OnValueChanged = function(panel, value)
 	    if !self.Selected then return end
		self.Selected:SetPos(self.OriginalPos+Vector(self.PosX:GetValue(),value,self.PosZ:GetValue()))      
	end			
	self.PosZ.OnValueChanged = function(panel, value)
 	    if !self.Selected then return end
		self.Selected:SetPos(self.OriginalPos+Vector(self.PosX:GetValue(),self.PosY:GetValue(),value))         
	end			
		
	self.PositionOptions:SetContents(self.ListLayoutPosition)		
	
    //Model Cat	
	self.ModelOptions = vgui.Create( "DCollapsibleCategory")
	self.ModelOptions:SetLabel("Model Options")	
	self.ModelOptions:SetExpanded( 0 )	
	self.ListLayout:Add(self.ModelOptions)
	
	self.ListLayoutModel = vgui.Create("DListLayout", self)
	
	self.ModelScale = vgui.Create("DNumSlider")
	self.ModelScale:SetText("Scale")
	self.ModelScale:SetMin(0)
	self.ModelScale:SetMax(2)
	self.ModelScale:SetDecimals(2)
	self.ModelScale:SetValue(1)
	
	self.ListLayoutModel:Add(self.ModelScale) 
	
	self.ModelScaleX = vgui.Create("DNumSlider")
	self.ModelScaleX:SetText("ScaleX")
	self.ModelScaleX:SetMin(0)
	self.ModelScaleX:SetMax(2)
	self.ModelScaleX:SetDecimals(2)
	self.ModelScaleX:SetValue(1)
	self.ListLayoutModel:Add(self.ModelScaleX)	
	
	self.ModelScaleY = vgui.Create("DNumSlider")
	self.ModelScaleY:SetText("ScaleY")
	self.ModelScaleY:SetMin(0)
	self.ModelScaleY:SetMax(2)
	self.ModelScaleY:SetDecimals(2)
	self.ModelScaleY:SetValue(1)
	self.ListLayoutModel:Add(self.ModelScaleY) 	

	self.ModelScaleZ = vgui.Create("DNumSlider")
	self.ModelScaleZ:SetText("ScaleZ")
	self.ModelScaleZ:SetMin(0)
	self.ModelScaleZ:SetMax(2)
	self.ModelScaleZ:SetDecimals(2)
	self.ModelScaleZ:SetValue(1)
	self.ListLayoutModel:Add(self.ModelScaleZ)	
	
	
	self.ModelScale.OnValueChanged = function(panel, value)
 	    if !self.Selected then return end  
		local mat = Matrix()
		mat:Scale(value*Vector(self.ModelScaleX:GetValue(),self.ModelScaleY:GetValue(),self.ModelScaleZ:GetValue()))
		self.Selected:EnableMatrix("RenderMultiply", mat)	
        self.Selected.Size = {value, Vector(self.ModelScaleX:GetValue(),self.ModelScaleY:GetValue(),self.ModelScaleZ:GetValue())}		
	end		
	self.ModelScaleX.OnValueChanged = function(panel, value)
 	    if !self.Selected then return end
		local mat = Matrix()
		mat:Scale(self.ModelScale:GetValue()*Vector(value,self.ModelScaleY:GetValue(),self.ModelScaleZ:GetValue()))
		self.Selected:EnableMatrix("RenderMultiply", mat)	
        self.Selected.Size = {self.ModelScale:GetValue(), Vector(value,self.ModelScaleY:GetValue(),self.ModelScaleZ:GetValue())}		
	end		
	self.ModelScaleY.OnValueChanged = function(panel, value)
 	    if !self.Selected then return end
		local mat = Matrix()
		mat:Scale(self.ModelScale:GetValue()*Vector(self.ModelScaleX:GetValue(),value,self.ModelScaleZ:GetValue()))
		self.Selected:EnableMatrix("RenderMultiply", mat)		
		self.Selected.Size = {self.ModelScale:GetValue(), Vector(self.ModelScaleX:GetValue(),value,self.ModelScaleZ:GetValue())}	
	end				
	self.ModelScaleZ.OnValueChanged = function(panel, value)
 	    if !self.Selected then return end
		local mat = Matrix()
		mat:Scale(self.ModelScale:GetValue()*Vector(self.ModelScaleX:GetValue(),self.ModelScaleY:GetValue(),value))
		self.Selected:EnableMatrix("RenderMultiply", mat)	
        self.Selected.Size = {self.ModelScale:GetValue(), Vector(self.ModelScaleX:GetValue(),self.ModelScaleY:GetValue(),value)}			
	end		
	
	self.ModelToSetLabel = vgui.Create("DLabel")
	self.ModelToSetLabel:SetText("Model")
	self.ListLayoutModel:Add(self.ModelToSetLabel)
	
	self.ModelToSet = vgui.Create("DTextEntry")
	self.ModelToSet:SetValue('')
	self.ModelToSet.OnTextChanged = function()		
		local NewModel = self.ModelToSet:GetValue();
		
		if file.Exists(NewModel, "GAME") then
			if !self.Selected then return end
			
			self.Selected:SetModel(NewModel)
			
			if self.Selected == self.Fruit then
			    for k,v in pairs(self.FruitTable) do
				    v:SetModel(NewModel)
				end
			end
		end	
	end			
	self.ListLayoutModel:Add(self.ModelToSet)

	self.ModelOptions:SetContents(self.ListLayoutModel)		
	
    //Buttons	
	self.AddFruit = vgui.Create("DButton")
	self.AddFruit:SetText("Add Fruit")
	self.AddFruit.DoClick = function()
	    self.Fruits = self.Fruits + 1
		local Fruit = ClientsideModel("models/props/de_inferno/crate_fruit_break_gib2.mdl", RENDERGROUP_OPAQUE)
		Fruit:SetMoveType( MOVETYPE_NONE )
		Fruit:SetSolid( SOLID_NONE )
		Fruit:SetPos(tRes.HitPos)	
    	Fruit.Name = "Fruit " .. self.Fruits	
		table.insert(self.ClientModelTable, Fruit)
		table.insert(self.FruitTable, Fruit)
		
		self.EntitySelect:AddChoice("Fruit " .. self.Fruits)
	end
	self.ListLayout:Add(self.AddFruit)	
	
	self.PrintButton = vgui.Create("DButton")
	self.PrintButton:SetText("Print to console")
	self.PrintButton.DoClick = function() self:PrintPlantTable() end
	self.ListLayout:Add(self.PrintButton)		
	
	self.HideButton = vgui.Create("DButton")
	self.HideButton:SetText("Hide (Run command again to reopen)")
	self.HideButton.DoClick = function() RunConsoleCommand("farming_setupplant") end
	self.ListLayout:Add(self.HideButton)	
	
	self.CloseButton = vgui.Create("DButton")
	self.CloseButton:SetText("Close")
	self.CloseButton.DoClick = function() self:CleanUp() end
	self.ListLayout:Add(self.CloseButton)
	
	for k,v in pairs(self.ClientModelTable) do
	    self.EntitySelect:AddChoice(v.Name)
	end
end

function PANEL:Paint(W,H)
    surface.SetDrawColor(100,100,100,200)
	surface.DrawRect( 0, 0, W, H)
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawOutlinedRect( 0, 0, W, H )
end

local Width, Height = 350, 453.5;
function PANEL:PerformLayout()
	self:SetPos(5, 5)
	self:SetSize(Width, Height)
	
	self.ListLayout:SetPos(5,5)
	self.ListLayout:SetSize(Width-10, Height-15)
	
	self.ModelToSet:SetSize(100,20)
end

function PANEL:CleanUp()
    for k,v in pairs(self.ClientModelTable) do
        v:Remove()
	end	
	
	self:Remove()
end

function PANEL:PrintPlantTable()
local FruitVectors = ""
for k,v in pairs(self.FruitTable) do
    local LocalVector = self.ContainerModel:WorldToLocal(v:GetPos())
	FruitVectors = FruitVectors .. ",Vector(" .. LocalVector.x .. "," .. LocalVector.y .. "," .. LocalVector.z .. ")"
end
FruitVectors = string.sub(FruitVectors,2);

local PlantVector = self.ContainerModel:WorldToLocal(self.PlantModel:GetPos())

if self.CheckPot:GetChecked() == true then
	print('FarmingDatabase["FRUITNAME"] = {}\nFarmingDatabase["FRUITNAME"].ProduceModel = "' .. self.Fruit:GetModel() .. '"\nFarmingDatabase["FRUITNAME"].PlantModel = "' .. self.PlantModel:GetModel() .. '"\nFarmingDatabase["FRUITNAME"].PotPlantPos = Vector(' .. PlantVector.x .. ',' .. PlantVector.y .. ',' .. PlantVector.z .. ')\nFarmingDatabase["FRUITNAME"].PotFruitPos = {' .. FruitVectors .. '}\nFarmingDatabase["FRUITNAME"].PotPlantSize = {' .. self.PlantModel.Size[1] .. ',Vector(' .. self.PlantModel.Size[2].x .. ',' .. self.PlantModel.Size[2].y .. ',' .. self.PlantModel.Size[2].z .. ')}\nFarmingDatabase["FRUITNAME"].PotFruitSize = {' .. self.Fruit.Size[1] .. ',Vector(' .. self.Fruit.Size[2].x .. ',' .. self.Fruit.Size[2].y .. ',' .. self.Fruit.Size[2].z .. ')}\n')
else
	print('FarmingDatabase["FRUITNAME"] = {}\nFarmingDatabase["FRUITNAME"].ProduceModel = "' .. self.Fruit:GetModel() .. '"\nFarmingDatabase["FRUITNAME"].PlantModel = "' .. self.PlantModel:GetModel() .. '"\nFarmingDatabase["FRUITNAME"].PlantPos = Vector(' .. PlantVector.x .. ',' .. PlantVector.y .. ',' .. PlantVector.z .. ')\nFarmingDatabase["FRUITNAME"].FruitPos = {' .. FruitVectors .. '}\nFarmingDatabase["FRUITNAME"].PlantSize = {' .. self.PlantModel.Size[1] .. ',Vector(' .. self.PlantModel.Size[2].x .. ',' .. self.PlantModel.Size[2].y .. ',' .. self.PlantModel.Size[2].z .. ')}\nFarmingDatabase["FRUITNAME"].FruitSize = {' .. self.Fruit.Size[1] .. ',Vector(' .. self.Fruit.Size[2].x .. ',' .. self.Fruit.Size[2].y .. ',' .. self.Fruit.Size[2].z .. ')}\n')
end

print("Remember to replace FRUITNAME and add the missing variables!")
end

vgui.Register( "farming_setupplant", PANEL, "DFrame")
concommand.Add("farming_setupplant", function()
	if IsValid(SetupPlantMenu) then
		local Toggle = !SetupPlantMenu:IsVisible();
	    SetupPlantMenu:SetVisible(Toggle);
	else
		SetupPlantMenu = vgui.Create("farming_setupplant") 
	end
end)