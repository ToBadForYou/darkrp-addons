TOOL.Category		= "ToBadForYou"
TOOL.Name		= "#Target Setup"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.Information = {
	{name = "left", stage = 0},
	{name = "left_finishpos", stage = 1},
	{name = "left_next", stage = 2},
	{name = "right", stage = 2},
	{name = "reload", stage = 2}
};

TOOL.ClientConVar[ "lid" ] = "1"
TOOL.ClientConVar[ "dirx" ] = 0
TOOL.ClientConVar[ "diry" ] = 0
TOOL.ClientConVar[ "dirz" ] = 0
TOOL.ClientConVar[ "stime" ] = 1
TOOL.ClientConVar[ "stage" ] = 1

if CLIENT then
	language.Add("Tool.fa_targets.name", "FA - Target Setup Tool")
	language.Add("Tool.fa_targets.desc", "Setup targets for the firearm license practical tests.")
	language.Add("Tool.fa_targets.left", "Set Player Position")
	language.Add("Tool.fa_targets.left_finishpos", "Set Player Finish Position")
	language.Add("Tool.fa_targets.left_next", "Apply settings to target")
	language.Add("Tool.fa_targets.right", "Enable/Disable Target")
	language.Add("Tool.fa_targets.reload", "Save all targets")
	language.Add("Tool.fa_targets.licenseid", "Firearms License ID")
	language.Add("Tool.fa_targets.stage", "Targets Stage")
	language.Add("Tool.fa_targets.directiondesc", "Moving vector for targets - Higher number = moving faster")
	language.Add("Tool.fa_targets.directionx", "X (Left/Right)")
	language.Add("Tool.fa_targets.directiony", "Y (Left/Right)")
	language.Add("Tool.fa_targets.directionz", "Z (Up/Down)")
	language.Add("Tool.fa_targets.switchtime", "Switch Time")
end

function TOOL:Deploy()

end

if CLIENT then
function TOOL:CreateGhostModel(Model)
	self.GhostEnt = ClientsideModel(Model)
	self.GhostEnt:SetSubMaterial(0, "models/fa_target")
	self.GhostEnt:SetColor(Color(255,255,255,150))
end

function TOOL:UpdateGhostPos(LastEnt)

	if ( !IsValid( self.GhostEnt ) ) then return end
	self.GhostEnt:SetNoDraw(false)

	local LastTraceEnt = LastEnt
	if IsValid(LastTraceEnt) then
		self.GhostEnt:SetAngles(LastTraceEnt:GetAngles())

		local X,Y,Z,Time = tonumber(self:GetClientInfo("dirx")),tonumber(self:GetClientInfo("diry")),tonumber(self:GetClientInfo("dirz")),self:GetClientInfo("stime")
		local XVec = Vector(X,0,0):Length()*Time
		local YVec = Vector(0,Y,0):Length()*Time
		local ZVec = Vector(0,0,Z):Length()*Time
		if X < 0 then
			XVec = -XVec
		end
		if Y < 0 then
			YVec = -YVec
		end
		if Z < 0 then
			ZVec = -ZVec
		end

		self.GhostEnt:SetPos(LastTraceEnt:GetPos()+Vector(XVec,YVec,ZVec))
	end
end

function TOOL:Think()
	local Owner = self:GetOwner()
	local EntTrace = Owner:GetEyeTrace().Entity

	if IsValid(EntTrace) and EntTrace:GetClass() == "fa_target" then
		if !IsValid( self.GhostEnt ) then
			self:CreateGhostModel(EntTrace:GetModel())
		end

		self:UpdateGhostPos(EntTrace)
	elseif IsValid(self.GhostEnt) then
		self.GhostEnt:SetNoDraw(true)
	end
end
end
function TOOL:Holster()
	if IsValid(self.GhostEnt) then
		self.GhostEnt:Remove()
	end
end

function TOOL:LeftClick(trace)
	if trace.Entity && trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if SERVER && attach && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then return false end
	local Player = self:GetOwner()
	if self:GetStage() == 0 then
		self.FA_StartPos = trace.HitPos
		self:SetStage(1)
	elseif self:GetStage() == 1 then
		self.FA_FinishPos = trace.HitPos
		self:SetStage(2)
	elseif self:GetStage() == 2 then
		local Target = trace.Entity
		if IsValid(Target) and Target:GetClass() == "fa_target" then
			local LID, Stage = self:GetClientInfo("lid"), self:GetClientInfo("stage")
			Target:FA_Setup(self:GetClientInfo("dirx"),self:GetClientInfo("diry"),self:GetClientInfo("dirz"),self:GetClientInfo("stime"), Stage, LID)
			Target.FA_Pos = Target:GetPos()
			Target.FA_Ang = Target:GetAngles()

			Player.FA_Targets = Player.FA_Targets or {}
			Player.FA_Targets[LID] = Player.FA_Targets[LID] or {}
			Player.FA_Targets[LID][Stage] = Player.FA_Targets[LID][Stage] or {}
			Player.FA_Targets[LID][Stage][Target:EntIndex()] = Target
		end
	end

	return true
end

function TOOL:RightClick(trace)
	if trace.Entity && trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if SERVER && attach && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then return false end

	local Player = self:GetOwner()
	if self:GetStage() == 2 then
		local Target = trace.Entity
		if IsValid(Target) and Target:GetClass() == "fa_target" then
			if Target.Enabled then
				Target:FA_Disable()
			else
				Target:FA_Enable()
			end
		end
	end

	return true
end

function TOOL:Reload(trace)
	if trace.Entity && trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if SERVER && attach && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then return false end

	local Player = self:GetOwner()
	if self:GetStage() == 2 then
		if Player.FA_Targets then
			FA_SavePracticeTargets(Player.FA_Targets, self:GetClientInfo("lid"), self.FA_StartPos, self.FA_FinishPos)
			self:SetStage(0)
		end
	end

	return true
end

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Text = "#Tool.fa_targets.name", Description	= "#Tool.fa_targets.desc" }  )
	CPanel:AddControl( "Slider", { Label = "#Tool.fa_targets.licenseid", Type = "int", Command = "fa_targets_lid", Min = 1, Max = 5} )
	CPanel:AddControl( "Slider", { Label = "#Tool.fa_targets.stage", Type = "int", Command = "fa_targets_stage", Min = 1, Max =  15} )
	CPanel:AddControl( "Header", { Description	= "#Tool.fa_targets.directiondesc" }  )
	CPanel:AddControl( "Slider", { Label = "#Tool.fa_targets.directionx", Type = "int", Command = "fa_targets_dirx", Min = -100, Max =  100} )
	CPanel:AddControl( "Slider", { Label = "#Tool.fa_targets.directiony", Type = "int", Command = "fa_targets_diry", Min = -100, Max =  100} )
	CPanel:AddControl( "Slider", { Label = "#Tool.fa_targets.directionz", Type = "int", Command = "fa_targets_dirz", Min = -100, Max =  100} )
	CPanel:AddControl( "Slider", { Label = "#Tool.fa_targets.switchtime", Type = "int", Command = "fa_targets_stime", Min = 1, Max =  10} )
end
