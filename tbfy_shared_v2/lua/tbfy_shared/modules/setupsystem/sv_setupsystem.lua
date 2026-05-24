
util.AddNetworkString("tbfy_spawn_entity")
util.AddNetworkString("tbfy_spawn_computer")
util.AddNetworkString("tbfy_update_computer")
util.AddNetworkString("tbfy_remove_ent")

TBFY_SH.AInfo = TBFY_SH.AInfo or {}

function TBFY_SH.SetupAddonInfo(self, AName, AdminCheck, Tbl)
	if !TBFY_SH.AInfo[AName] then
		file.CreateDir(AName)
		for k,v in pairs(Tbl) do
			if !v.NoSave then
				file.CreateDir(AName .. "/" .. v.Folder)
				TBFY_SH:SpawnAddonEntity(AName, v.Folder, v.Class, v.LoadFunc, v.MultiplyEnts)
			end
		end
		TBFY_SH.AInfo[AName] = TBFY_SH.AInfo[AName] or {}
		TBFY_SH.AInfo[AName].ACheck = AdminCheck
		TBFY_SH.AInfo[AName].SEnts = Tbl
	end
end

function TBFY_SH.SpawnAddonEntity(self, AName, Folder, Class, LoadFunc, MultiplyEnts)
	local CurrentMap = string.lower(game.GetMap())

	local EntSTbl = {}
	if file.Exists(AName .. "/" .. Folder .. "/" .. CurrentMap .. ".txt" ,"DATA") then
		EntSTbl = util.JSONToTable(file.Read(AName .. "/" .. Folder .. "/" .. CurrentMap .. ".txt"))
	end
	for k,v in pairs(EntSTbl) do
		if LoadFunc then
			LoadFunc(v)
		else
			local EClass = Class
			if MultiplyEnts then
				EClass = v.Class
			end
			local Ent = ents.Create(EClass)
			Ent:SetPos(v.Pos)
			Ent:SetAngles(v.Angles)
			if Ent.GetEName then
				Ent:SetEName(v.Name)
			end
			Ent:Spawn()

			local Phys = Ent:GetPhysicsObject()
			if Phys then
				Phys:EnableMotion(false)
			end
		end
	end
end

function TBFY_SH.RespawnAddonEntities(self, AName)
	if TBFY_SH.AInfo[AName] then
		local Tbl = TBFY_SH.AInfo[AName].SEnts
		for k,v in pairs(Tbl) do
			if !v.NoSave then
				TBFY_SH:SpawnAddonEntity(AName, v.Folder, v.Class, v.LoadFunc, v.MultiplyEnts)
			end
		end
	end
end

local function EDataToTbl(Ent, SClass, CSaveFunc)
	local EntIns = {}
	if SClass then
		EntIns.Class = Ent:GetClass()
	end
	EntIns.Pos = Ent:GetPos()
	EntIns.Angles = Ent:GetAngles()

	if Ent.GetEName then
		EntIns.Name = Ent:GetEName()
	end

	if CSaveFunc then
		EntIns = CSaveFunc(Ent, EntIns)
	end
	return EntIns
end

concommand.Add("save_tbfy_ent", function(ply, cmd, args)
	if len(args) < 2 then return end
	TBFY_SH:SaveEnt(ply, args[1], args[2])
end)

function TBFY_SH:SaveEnt(ply, addonName, entityClass)
	if !addonName || !entityClass then return end

	local addonInfo = TBFY_SH.AInfo[addonName]
	if !addonInfo || !addonInfo.ACheck || !addonInfo.ACheck(ply) then return end

	local entInfo = addonInfo.SEnts[entityClass]
	if !entInfo then return end

	local EntsTbl = {}
	if entInfo.MultiplyEnts then
		for index,Ents in pairs(entInfo.SEnts) do
			for k,v in pairs(ents.FindByClass(Ents.Ent)) do
				local entJson = EDataToTbl(v, true, entInfo.SaveFunc)
				table.insert(EntsTbl, entJson)
			end
		end
	else
		for k,v in pairs(ents.FindByClass(entInfo.Class)) do
			if entInfo.Cond(v) then
				local entJson = EDataToTbl(v, false, entInfo.SaveFunc)
				table.insert(EntsTbl, entJson)
			end
		end
	end
	local CurrentMap = string.lower(game.GetMap())
	file.Write(addonName .. "/" .. entInfo.Folder .. "/" .. CurrentMap .. ".txt", util.TableToJSON(EntsTbl))

	TBFY_Notify(ply, 1, 4, string.format(entInfo.SavedS, #EntsTbl))
end

net.Receive("tbfy_spawn_entity", function(len, Player)
	if !Player:TBFY_AdminAccess() then return end

	if Player.NextTBFYAction and Player.NextTBFYAction > CurTime() then return end
	Player.NextTBFYAction = CurTime() + 1

	local Ent, Pos, Ang, Name = net.ReadString(), net.ReadVector(), net.ReadAngle(), net.ReadString()
	local CDataA = net.ReadFloat()

	local NewE = ents.Create(Ent)
	NewE.SBy = Player
	NewE:SetPos(Pos)
	NewE:SetAngles(Ang)
	if NewE.SetEName then
		NewE:SetEName(Name)
	end
	NewE:Spawn()
	NewE:GetPhysicsObject():EnableMotion(false)

	for i = 1, CDataA do
		local TblString = net.ReadString()
		local Type = net.ReadString()
		local Data = nil

		if Type == "String" then
			Data = net.ReadString()
		elseif Type == "Float" then
			Data = net.ReadFloat()
		elseif Type == "Table" then
			Data = net.ReadTable()
		end
		if Data then
			NewE[TblString] = Data
		end
	end

	if NewE.TBFY_OnSpawn then
		NewE:TBFY_OnSpawn()
	end

	Player.LastEntC = NewE
end)

net.Receive("tbfy_spawn_computer", function(len, Player)
	if !Player:TBFY_AdminAccess() then return end

	if Player.NextTBFYAction and Player.NextTBFYAction > CurTime() then return end
	Player.NextTBFYAction = CurTime() + 1

	local Pos, Ang, Name, PCType, Softwares, JobIDs = net.ReadVector(), net.ReadAngle(), net.ReadString(), net.ReadFloat(), net.ReadString(), net.ReadString()

	local ESoftString = string.Explode(":", Softwares)
	local SoftTbl = {}
	for k,v in pairs(ESoftString) do
		if v != "" then
			SoftTbl[v] = true
		end
	end
	for k,v in pairs(TBFY_SH.CSoftwares) do
		if ((v.PCType and v.PCType[PCType]) or !v.PCType) and v.Default then
			SoftTbl[k] = true
		end
	end

	local EJobIDString = string.Explode(":", JobIDs)
	local JobIDTbl = {}
	for k,v in pairs(EJobIDString) do
		if v != "" then
			JobIDTbl[tonumber(v)] = true
		end
	end

	local NewE = ents.Create("tbfy_computer")
	NewE.SBy = Player
	NewE:SetPos(Pos)
	NewE:SetAngles(Ang)
	NewE:SetEName(Name)
	NewE:Spawn()
	NewE:GetPhysicsObject():EnableMotion(false)
	NewE.Softwares = SoftTbl
	NewE.JobsAllowed = JobIDTbl
	NewE:InitPCType(PCType)
end)

net.Receive("tbfy_update_computer", function(len, Player)
	if Player.NextTBFYAction and Player.NextTBFYAction > CurTime() then return end
	Player.NextTBFYAction = CurTime() + .05
	if !Player:TBFY_AdminAccess() then return end

	local PC = Player.TBFY_UsedPC
	if !IsValid(PC) then return end

	local EName, PCType, Soft, Jobs = net.ReadString(), net.ReadFloat(), net.ReadString(), net.ReadString()
	if EName == "" then
		local SoftS = ""
		for k,v in pairs(PC.Softwares) do
			SoftS = SoftS .. ":" .. k
		end

		local JobS = ""
		for k,v in pairs(PC.JobsAllowed) do
			JobS = JobS .. ":" .. k
		end

		net.Start("tbfy_update_computer")
			net.WriteString(PC:GetEName())
			net.WriteFloat(PC:GetPCType())
			net.WriteString(SoftS)
			net.WriteString(JobS)
		net.Send(Player)
	else
		if EName then
			PC:SetEName(EName)
		end
		if PCType != nil then
			PC:InitPCType(PCType)
		end
		if Soft then
			local ESoftString = string.Explode(":", Soft)
			local SoftTbl = {}
			for k,v in pairs(ESoftString) do
				if v != "" then
					SoftTbl[v] = true
				end
			end
			for k,v in pairs(TBFY_SH.CSoftwares) do
				if v.PCType and v.PCType[PC:GetPCType()] and v.Default then
					SoftTbl[k] = true
				end
			end
			PC.Softwares = SoftTbl
		end
		if Jobs then
			local EJobIDString = string.Explode(":", Jobs)
			local JobIDTbl = {}
			for k,v in pairs(EJobIDString) do
				if v != "" then
					JobIDTbl[tonumber(v)] = true
				end
			end
			PC.JobsAllowed = JobIDTbl
		end

		TBFY_SH:SendMessage(Player, "", TBFY_GetLang("SettingsSaved"))

		Player:ExitVehicle()
	end
end)

net.Receive("tbfy_remove_ent", function(len, Player)
	if !Player:TBFY_AdminAccess() then return end

	if Player.NextTBFYAction and Player.NextTBFYAction > CurTime() then return end
	Player.NextTBFYAction = CurTime() + 1

	local Ent = net.ReadEntity()
	if IsValid(Ent) and Ent.TBFYEnt then
		Ent:Remove()
	end
end)
