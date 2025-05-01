TOOL.Category		= "ToBadForYou" 
TOOL.Name		= "#Farming Locations" 
TOOL.Command		= nil 
TOOL.ConfigName		= ""
TOOL.UID = {{ user_id }}

TOOL.Information = {
	{name = "left", stage = 0},
	{name = "left_next", stage = 1},
	{name = "left_accept", stage = 2},
	{name = "right_cancel", stage = 2}
};

TOOL.ClientConVar[ "drawareas" ] = "1"
TOOL.ClientConVar[ "name" ] = ""

if CLIENT then 
	language.Add( "Tool.farmingpos.name", "Farming Location Tool" ) 
	language.Add( "Tool.farmingpos.desc", "Setup farming areas for maps that don't support the material" ) 
	language.Add("Tool.farmingpos.left", "Select a start pos.");
	language.Add("Tool.farmingpos.left_next", "Now select a end pos.");
	language.Add("Tool.farmingpos.left_accept", "Accept and save area.");
	language.Add("Tool.farmingpos.right_cancel", "Cancel.");	
	language.Add("Tool.farmingpos.drawareas", "Should all areas draw?");	
	language.Add("Tool.farmingpos.AreaName", "Area Name");		
end 

function TOOL:LeftClick( trace ) 
	if trace.Entity && trace.Entity:IsPlayer() then return false end 
	if CLIENT then return true end 

	if SERVER && attach && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then return false end 
	 
	local Player = self:GetOwner()
	 
	if (self:GetStage() == 0) then
	    Player:SetNWVector("Pos1", trace.HitPos+Vector(0,0,2))
		self:SetStage(1);
	elseif self:GetStage() == 1 then
	    Player:SetNWVector("Pos2", trace.HitPos+Vector(0,0,2))
		self:SetStage(2);
	elseif self:GetStage() == 2 then
	    local Pos1, Pos2, Name = Player:GetNWVector("Pos1"), Player:GetNWVector("Pos2"), self:GetClientInfo("name")
		table.insert(FarmingAreas, {Pos1,Pos2,Name})

		for k,v in pairs(player.GetAll()) do
		    if v:IsAdmin() then
			    net.Start("Farming_SendAreaInfoSingle")
				    net.WriteVector(Pos1)
					net.WriteVector(Pos2)
					net.WriteString(Name)
				net.Send(v)
			end
		end
			
		Player:SetNWVector("Pos1", Vector(0,0,0))
		Player:SetNWVector("Pos2", Vector(0,0,0))
	    self:SetStage(0)
    end	
	 
	return true
  
end 
  
function TOOL:RightClick( trace ) 
  
	if trace.Entity && trace.Entity:IsPlayer() then return false end 
	if CLIENT then return true end 
	 
	if SERVER && attach && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then return false end 
	
	local Player = self:GetOwner()	
	
	if self:GetStage() == 2 then
		Player:SetNWVector("Pos1", Vector(0,0,0))
		Player:SetNWVector("Pos2", Vector(0,0,0))
	    self:SetStage(0)
	end
end 
  
function TOOL.BuildCPanel( CPanel )  
	CPanel:AddControl( "Header", { Text = "#Tool.farmingpos.name", Description	= "#Tool.farmingpos.desc" }  ) 
	CPanel:AddControl( "CheckBox", { Label = "#Tool.farmingpos.drawareas", Command = "farmingpos_drawareas", Help = false } )	
	CPanel:AddControl( "TextBox", { Label = "#Tool.farmingpos.AreaName", Command = "farmingpos_name", MaxLenth = "20" } )
end 

function TOOL:Deploy()
    local Player = self:GetOwner()

	Player:SetNWVector("Pos1", Vector(0,0,0))
	Player:SetNWVector("Pos2", Vector(0,0,0))	
end

function TOOL:Holster()
	local Player = self:GetOwner()
	if CLIENT then
	    LocalPlayer().DrawFarmAreas = false
	end
	Player:SetNWVector("Pos1", Vector(0,0,0))
	Player:SetNWVector("Pos2", Vector(0,0,0))	
end

if CLIENT then
function TOOL:Think()
	if !LocalPlayer().DrawFarmAreas then
	    LocalPlayer().DrawFarmAreas = true
	end
	
	if LocalPlayer().DrawAreas != self:GetClientInfo("drawareas") then
		LocalPlayer().DrawAreas = self:GetClientInfo("drawareas")
	end
end

hook.Add( "PostDrawOpaqueRenderables", "Draw_Farming_Areas", function()
    if LocalPlayer():IsAdmin() and LocalPlayer().DrawFarmAreas then
	    local Pos1, Pos2 = LocalPlayer():GetNWVector("Pos1"),LocalPlayer():GetNWVector("Pos2")
		if Pos1 != Vector(0,0,0) and Pos2 != Vector(0,0,0) then			
			render.DrawLine( Pos1, Vector(Pos1.x,Pos2.y,Pos1.z), Color(0,255,0,255), true)
			render.DrawLine( Vector(Pos1.x,Pos2.y,Pos1.z), Vector(Pos2.x,Pos2.y,Pos1.z), Color(0,255,0,255), true)
			render.DrawLine( Pos1, Vector(Pos2.x,Pos1.y,Pos1.z), Color(0,255,0,255), true)
			render.DrawLine( Vector(Pos2.x,Pos1.y,Pos1.z), Vector(Pos2.x,Pos2.y,Pos1.z), Color(0,255,0,255), true)
		end
		if LocalPlayer().DrawAreas == "1" then
			for k,v in pairs(FarmingAreas) do
				Pos1, Pos2, Name = v[1], v[2], v[3]
				render.DrawLine( Pos1, Vector(Pos1.x,Pos2.y,Pos1.z), Color(0,255,0,255), true)
				render.DrawLine( Vector(Pos1.x,Pos2.y,Pos1.z), Vector(Pos2.x,Pos2.y,Pos1.z), Color(0,255,0,255), true)
				render.DrawLine( Pos1, Vector(Pos2.x,Pos1.y,Pos1.z), Color(0,255,0,255), true)
				render.DrawLine( Vector(Pos2.x,Pos1.y,Pos1.z), Vector(Pos2.x,Pos2.y,Pos1.z), Color(0,255,0,255), true)
				
				cam.Start3D2D(Pos1, Angle(0,0,0), 0.5)
				    draw.SimpleText(Name, "default", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				cam.End3D2D()		
			end
		end
	end
end)
end