
hook.Add("Initialize", "FarmingInit", function()
	file.CreateDir("farming_system")
	file.CreateDir("farming_system/farmingareas")
	file.CreateDir("farming_system/farmingnpc")

    FarmingAreas = {}

	local CurrentMap = string.lower(game.GetMap())

	if file.Exists( "farming_system/farmingareas/" .. CurrentMap .. ".txt" ,"DATA") then
		FarmingAreas = util.JSONToTable(file.Read( "farming_system/farmingareas/" .. CurrentMap .. ".txt" ))
	end
end)

hook.Add("PlayerInitialSpawn", "SendFarmingAreasToPlayers", function(Player)
	net.Start("Farming_SendAreaInfo")
	    net.WriteTable(FarmingAreas)
	net.Send(Player)
end)

util.AddNetworkString("Farming_SendPlant")
util.AddNetworkString("Farming_ResetPlant")
util.AddNetworkString("Farming_DeathPlant")
util.AddNetworkString("Farming_Buyermenu")
util.AddNetworkString("Farming_SellFruits")
util.AddNetworkString("Farming_SendAreaInfo")
util.AddNetworkString("Farming_SendAreaInfoSingle")
util.AddNetworkString("Farming_RemoveArea")
util.AddNetworkString("Farming_SaveAreas")
util.AddNetworkString("Farming_AreaManager")
util.AddNetworkString("Farming_BoxMenu")
util.AddNetworkString("Farming_BoxEat")
util.AddNetworkString("Farming_BoxHarvest")

local function farmingBoxAction(Player, action)
	local box = Player.lastFarmingBox
	if IsValid(box) and box:GetPos():Distance(Player:GetPos()) < 150 then
		if action == 1 then
			box:Harvest()
		else
			box:EatFruit(Player)
		end
	end
end

net.Receive("Farming_BoxHarvest", function(len, Player)
	farmingBoxAction(Player, 1)
end)

net.Receive("Farming_BoxEat", function(len, Player)
	farmingBoxAction(Player, 2)
end)

concommand.Add("save_farmingnpcs", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	local NPCTbl = {}
	for k,v in pairs(ents.FindByClass("farming_buyer")) do
	local tr = util.TraceLine( {
		start = v:GetPos(),
		endpos = v:GetPos()-Vector(0,0,50),
		filter = {"farming_buyer"}
	} )


		local NPCIns = {}
		NPCIns.Pos = tr.HitPos
		NPCIns.Angles = v:GetAngles()
		table.insert(NPCTbl,NPCIns)
	end

	local CurrentMap = string.lower(game.GetMap())
	file.Write("farming_system/farmingnpc/" .. CurrentMap .. ".txt", util.TableToJSON(NPCTbl))

	DarkRP.notify(Player, 1, 4, "Successfully saved " .. #NPCTbl .. " NPCs.")
end)

hook.Add( "InitPostEntity", "FarmingBuyerSpawn", function()
	local CurrentMap = string.lower(game.GetMap())

	local NPCLocTable = {}
	if file.Exists( "farming_system/farmingnpc/" .. CurrentMap .. ".txt" ,"DATA") then
		NPCLocTable = util.JSONToTable(file.Read( "farming_system/farmingnpc/" .. CurrentMap .. ".txt" ))
	end

	for k,v in pairs(NPCLocTable) do
		local FNPC = ents.Create("farming_buyer")
		FNPC:SetPos(v.Pos)
		FNPC:SetAngles(v.Angles)
		FNPC:Spawn()
	end
end)

net.Receive("Farming_SellFruits", function(len, Player)
   	local eyeTrace = Player:GetEyeTrace();
	local NPC = eyeTrace.Entity

	if !NPC or !IsValid(NPC) then return end
	if NPC:GetClass() != "farming_buyer" then return end
	if NPC:GetPos():Distance(Player:GetPos()) > 250 then return end

	local ID = net.ReadString()

	local Amount = 0
	for k,v in pairs(ents.FindInSphere(NPC:GetPos(), FarmingBuyerRange)) do
		if v:GetClass() == "farming_storage" and v.ID and v.ID == ID then
			Amount = Amount+v:Getcount()
			v:Remove()
		end
	end

	local PriceEach =  FarmingDatabase[ID].SellPrice
	local TotalProfit = Amount*PriceEach

	DarkRP.notify(Player, 1, 4, "You successfully sold " .. Amount .. " " .. ID .. " for a total amount of $" .. TotalProfit)
	Player:addMoney(TotalProfit)

	if LevelSystemConfiguration then //Check for Vrondakis level system
		OPlayer:addXP(TotalProfit*(FarmingSellPercentageXP/100), true)
	end
	if RS6CONFIG then
		self:AddExperience(TotalProfit*(FarmingSellPercentageXP/100),"Farming")
	end
end)

hook.Add("playerBoughtCustomEntity", "SetupSeedID", function(Player, EntTable, Ent, Price)
    if Ent:GetClass() == "farming_seed" then
	    Ent.ID = EntTable.seedid
	elseif Ent:GetClass() == "farming_storage" then
        Ent:Setcontents("Empty")
        Ent.ID = nil
	end
end)

local TGBlacklist = {"farming_buyer"}
hook.Add("CanTool", "DisableRemovingFarmingEnts", function(Player, trace, tool)
    local ent = trace.Entity

	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:IsAdmin() then
			return false
		end
	end
end)

hook.Add("CanProperty", "DisableRemovingFarmingEntsProperty", function(Player, stringproperty, ent)
	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:IsAdmin() then
			return false
		end
	end
end)

PocketBL = {"farming_plot","farming_buyer"}
hook.Add("canPocket", "RestrictPocketing", function(Player, Ent)
    if table.HasValue(PocketBL, Ent:GetClass()) then
	    return false, "You can't put that in your pocket!"
	end
end)

hook.Add( "PhysgunPickup", "AllowMoveSeed",function(Player,Ent)
    if Ent:GetClass() == "farming_seed" and Player.SID == Ent.SID then
	    return true
	elseif Ent:GetClass() == "farming_plot" then
	    return false
	end
end)

function RandomPercent(Percent)
    local Roll = math.random(0 ,100)
	if Percent > Roll then
	    return true
	else
        return false
    end
end

net.Receive("Farming_RemoveArea", function(len, Player)
    if !Player:IsAdmin() then return end

    local ID = net.ReadFloat()

	FarmingAreas[ID] = nil

	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
		    net.Start("Farming_RemoveArea")
		        net.WriteFloat(ID)
		    net.Send(v)
	    end
	end
end)

net.Receive("Farming_SaveAreas", function(len, Player)
    if !Player:IsAdmin() then return end

	local FarmingTbl = net.ReadTable()

	local CurrentMap = string.lower(game.GetMap())
	file.Write("farming_system/farmingareas/" .. CurrentMap .. ".txt", util.TableToJSON(FarmingTbl))

	DarkRP.notify(Player, 1, 4, "Successfully saved " .. #FarmingTbl .. " Farming Areas.")
end)

hook.Add("PlayerSay", "farming_checkchatcommands", function(Player, Text)
	if Player:IsAdmin() then
		if table.HasValue(FarmingManagerChatCommand, Text) then
			net.Start("Farming_AreaManager")
			net.Send(Player)
			return ""
		end
	end
end)
