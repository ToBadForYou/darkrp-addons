
local PLAYER = FindMetaTable( "Player" )

util.AddNetworkString("collect_SendInventory")
util.AddNetworkString("collect_UpdateInventory")
util.AddNetworkString("collect_AddToCollection")
util.AddNetworkString("collect_SendCollections")
util.AddNetworkString("collect_UpdateCollections")
util.AddNetworkString("collect_dropitem")
util.AddNetworkString("collect_claimreward")
util.AddNetworkString("collect_SendRewardsClaimed")
util.AddNetworkString("collect_UpdateRewardsClaimed")
util.AddNetworkString("collect_ResetCollection")
util.AddNetworkString("collect_player_resetcollection")
util.AddNetworkString("collect_open_container")
util.AddNetworkString("collect_container_collectitem")

hook.Add("Initialize", "CreateCollectionFolderSQL", function()
	file.CreateDir("collectionsystem")
	file.CreateDir("collectionsystem/navgenpos")
	file.CreateDir("collectionsystem/manualpos")
	file.CreateDir("collectionsystem/containers")
	
	if !sql.TableExists("tbfy_collections") then
		sql.Query("CREATE TABLE tbfy_collections (steamid varchar(255), inventory varchar(255), collections varchar(255), rewardsclaimed varchar(255))")
	end	
end)

hook.Add("PlayerLoadout", "GiveCollectionBagL", function(Player)
	Player:Give("collections_bag")
end)

function PLAYER:LoadCollectionsInventory()
	self.CollectionInventory = {}
	self.Collections = {}
	self.RewardsClaimed = {}
	
	local CCompiledStrings = sql.Query( "SELECT inventory, collections, rewardsclaimed FROM tbfy_collections WHERE steamid = ".. sql.SQLStr(self:SteamID()) .."")

	if CCompiledStrings then
		local InvTbl = CCompiledStrings[1].inventory
		local CollTbl = CCompiledStrings[1].collections
		local RClaimedTbl = CCompiledStrings[1].rewardsclaimed
		
		self:DecompileInventoryString(InvTbl)
		self:DecompileCollectionsString(CollTbl)
		self:DecompileRClaimedString(RClaimedTbl)
		
		net.Start("collect_SendInventory")
			net.WriteString(InvTbl)
		net.Send(self)
		net.Start("collect_SendCollections")
			net.WriteString(CollTbl)
		net.Send(self)
		net.Start("collect_SendRewardsClaimed")
			net.WriteString(RClaimedTbl)
		net.Send(self)		
	else
		sql.Query( "INSERT INTO tbfy_collections (`steamid`, `inventory`, `collections`, rewardsclaimed)VALUES ('"..self:SteamID().."', '0', '0', '0')" )	
		net.Start("collect_SendInventory")
			net.WriteString("0")
		net.Send(self)
		net.Start("collect_SendCollections")
			net.WriteString("0")
		net.Send(self)
		net.Start("collect_SendRewardsClaimed")
			net.WriteString("0")
		net.Send(self)		
	end  	
end

function PLAYER:SaveCPlayerCollections()
    local CompiledString = self:CompileCCollections()

	sql.Query("UPDATE tbfy_collections SET collections='"..CompiledString.."' WHERE steamid='"..self:SteamID().."'")
end

function PLAYER:CompileCCollections()
    local CompiledString = ""
	
	for k,v in pairs(self.Collections) do
		local IDString = ""
		for i, n in pairs(v) do
			IDString = IDString .. n .. ":"
		end
	    CompiledString = CompiledString .. k .. "," .. IDString .. ";"
	end

	return CompiledString
end

function PLAYER:SaveCPlayerInv()
    local CompiledString = self:CompileCInventory()

	sql.Query("UPDATE tbfy_collections SET inventory='"..CompiledString.."' WHERE steamid='"..self:SteamID().."'")
end

function PLAYER:CompileCInventory()
    local CompiledString = ""
	
	for k,v in pairs(self.CollectionInventory) do
	    CompiledString = CompiledString .. k .. "," .. v .. ";"
	end

	return CompiledString
end

function PLAYER:CompileCClaimedR()
    local CompiledString = ""
	
	for k,v in pairs(self.RewardsClaimed) do
	    CompiledString = CompiledString .. v .. ","
	end

	return CompiledString
end

function PLAYER:SaveCPlayerRewardsClaimed()
    local CompiledString = self:CompileCClaimedR()

	sql.Query("UPDATE tbfy_collections SET rewardsclaimed='"..CompiledString.."' WHERE steamid='"..self:SteamID().."'")
end

function PLAYER:GiveCItem(ID,Amount)
	self.CollectionInventory[ID] = self.CollectionInventory[ID] or 0
	self.CollectionInventory[ID] = self.CollectionInventory[ID] + Amount
	
	net.Start("collect_UpdateInventory")
		net.WriteFloat(ID)
		net.WriteFloat(Amount)
	net.Send(self)
	
	self:SaveCPlayerInv()
end

function PLAYER:RemoveCItem(ID,Amount)
	self.CollectionInventory[ID] = self.CollectionInventory[ID] or 0
	self.CollectionInventory[ID] = self.CollectionInventory[ID] - Amount
	if self.CollectionInventory[ID] <= 0 then self.CollectionInventory[ID] = nil end
	
	net.Start("collect_UpdateInventory")
		net.WriteFloat(ID)
		net.WriteFloat(-Amount)
	net.Send(self)
	
	self:SaveCPlayerInv()
end

hook.Add("PlayerInitialSpawn", "SetupCollectionInventory", function(Player)
	timer.Simple(3, function()
		Player:LoadCollectionsInventory()
	end)
	
	local PlayerAmount = #player.GetAll()
	local ISpawnTimer = TBFY_CollectConfig.SpawnTimer
	local ICSpawnTimer = TBFY_CollectConfig.SpawnTimerContainer
	local MaxReductionTimer = TBFY_CollectConfig.MaxTimerReduction
	
	local CollAdjustISpawn = math.Clamp(ISpawnTimer - (ISpawnTimer*(TBFY_CollectConfig.PlayerAdjustTimer*PlayerAmount)), ISpawnTimer*MaxReductionTimer, ISpawnTimer)
	local CollAdjustICSpawn = math.Clamp(ICSpawnTimer - (ICSpawnTimer*(TBFY_CollectConfig.PlayerAdjustTimerContainer*PlayerAmount)), ICSpawnTimer*MaxReductionTimer, ISpawnTimer)
	
	if timer.Exists("collection_itemspawner") then
		timer.Adjust("collection_itemspawner", CollAdjustISpawn, 0, CollectionSpawnRandomLoot)
	end
	if timer.Exists("collection_itemspawner_container") then
		timer.Adjust("collection_itemspawner_container", CollAdjustICSpawn, 0, CollectionSpawnRandomLootContainer)
	end
end)

hook.Add("PlayerDisconnected", "AdjustTimersCollDC", function()
	local PlayerAmount = #player.GetAll()
	local ISpawnTimer = TBFY_CollectConfig.SpawnTimer
	local ICSpawnTimer = TBFY_CollectConfig.SpawnTimerContainer
	local MaxReductionTimer = TBFY_CollectConfig.MaxTimerReduction
	
	local CollAdjustISpawn = math.Clamp(ISpawnTimer + (ISpawnTimer*(TBFY_CollectConfig.PlayerAdjustTimer*PlayerAmount)), ISpawnTimer*MaxReductionTimer, ISpawnTimer)
	local CollAdjustICSpawn = math.Clamp(ICSpawnTimer + (ICSpawnTimer*(TBFY_CollectConfig.PlayerAdjustTimerContainer*PlayerAmount)), ICSpawnTimer*MaxReductionTimer, ISpawnTimer)
	
	if timer.Exists("collection_itemspawner") then
		timer.Adjust("collection_itemspawner", CollAdjustISpawn, 0, CollectionSpawnRandomLoot)
	end
	if timer.Exists("collection_itemspawner_container") then
		timer.Adjust("collection_itemspawner_container", CollAdjustICSpawn, 0, CollectionSpawnRandomLootContainer)
	end
end)

net.Receive("collect_AddToCollection", function(len, Player)
	local CID, ID = net.ReadFloat(), net.ReadFloat()

	if !CollectionHasID(CID, ID) or !Player:HasCItem(ID) or Player:CollectionHasID(CID,ID) or Player:CollectionIsFinished(CID) then return end
	local CName = COLLECTION_COLLCETIONSDB[CID][1]
	
	Player.Collections[CID] = Player.Collections[CID] or {}
	table.insert(Player.Collections[CID], ID)
	
	net.Start("collect_UpdateCollections")
		net.WriteFloat(CID)
		net.WriteFloat(ID)
	net.Send(Player)	
	
	Player:PrintMessage(HUD_PRINTTALK, "You successfully added an item to the " .. CName .. ".")
	Player:SaveCPlayerCollections()
	Player:RemoveCItem(ID, 1)
end)

net.Receive("collect_dropitem", function(len, Player)
	if CollectionSpawnLimit() then return end
	if Player.CItemDropCD and Player.CItemDropCD > CurTime() then Player:PrintMessage(HUD_PRINTTALK, "You can drop another item in: " .. math.Round(Player.CItemDropCD - CurTime()) .. " seconds.") return end
	
	Player.CItemDropCD = CurTime() + TBFY_CollectConfig.DropItemCD
	
	local ID = net.ReadFloat()
	if !Player:HasCItem(ID) then return end

	Player:RemoveCItem(ID, 1)
	
	local Tr = {};
		Tr.start = Player:GetShootPos();
		Tr.endpos = Player:GetShootPos() + Player:GetAimVector() * 50;
		Tr.filter = Player;
	local TRes = util.TraceLine(Tr);	
	
	local CItem = ents.Create("collection_item")
	CItem:SetPos(TRes.HitPos)
	CItem:SetModel(COLLECTION_ITEMSDB[ID][1])
	CItem.CID = ID
	CItem:Spawn()
end)

net.Receive("collect_claimreward", function(len, Player)
	local CID = net.ReadFloat()
	if !Player:CollectionIsFinished(CID) or Player:HasCClaimedReward(CID) then return end
	
	if TBFY_CollectConfig.ResetOnClaimed then
		Player.Collections[CID] = {}
		Player:SaveCPlayerCollections()
		
		net.Start("collect_ResetCollection")
			net.WriteFloat(CID)
		net.Send(Player)
	else
		table.insert(Player.RewardsClaimed, CID)
		Player:SaveCPlayerRewardsClaimed()
		
		net.Start("collect_UpdateRewardsClaimed")
			net.WriteFloat(CID)
		net.Send(Player)		
	end
	
	local CTbl = COLLECTION_COLLCETIONSDB[CID]
	local CName = CTbl[1]
	local CRewardText = CTbl[4]
	
	CTbl[5](Player)
	
	Player:PrintMessage(HUD_PRINTTALK, "You successfully claimed " .. CRewardText .. " as a reward from " .. CName .. ".")
end)

net.Receive("collect_player_resetcollection", function(len, Player)
	local CID = net.ReadFloat()
	if !Player:CollectionIsFinished(CID) or !TBFY_CollectConfig.ResetOnClaimed then return end
	
	Player.Collections[CID] = {}
	Player:SaveCPlayerCollections()
		
	net.Start("collect_ResetCollection")
		net.WriteFloat(CID)
	net.Send(Player)	
end)

local function CollSpawnContainers()
	local CurrentMap = string.lower(game.GetMap())
	
	local ContainerLocs = {}
	if file.Exists("collectionsystem/containers/" .. CurrentMap .. ".txt" ,"DATA") then
		ContainerLocs = util.JSONToTable(file.Read("collectionsystem/containers/" .. CurrentMap .. ".txt" ))
	end

	for k,v in pairs(ContainerLocs) do		
		local CContainer = ents.Create("collection_container")
		CContainer:SetPos(v[1])
		CContainer:SetAngles(v[2])
		CContainer:SetModel(v[3])
		CContainer:Spawn()	
	end			
end
hook.Add("InitPostEntity", "SpawnInCollContainers", CollSpawnContainers)

hook.Add("PostCleanupMap", "RespawnContainers_Collection", function()
	CollSpawnContainers()
end)

local Coll_SpawnPoses = {}
hook.Add("Initialize", "collections_SetupSpawnPos", function()
	local CurrentMap = string.lower(game.GetMap())
	
	local SpawnPosesNav = {}
	if file.Exists( "collectionsystem/navgenpos/" .. CurrentMap .. ".txt" ,"DATA") then
		SpawnPosesNav = util.JSONToTable(file.Read( "collectionsystem/navgenpos/" .. CurrentMap .. ".txt" ))
	end
	table.Add(Coll_SpawnPoses,SpawnPosesNav)
	
	local SpawnPosesMan = {}
	if file.Exists( "collectionsystem/manualpos/" .. CurrentMap .. ".txt" ,"DATA") then
		SpawnPosesMan = util.JSONToTable(file.Read( "collectionsystem/manualpos/" .. CurrentMap .. ".txt" ))
	end
	table.Add(Coll_SpawnPoses,SpawnPosesMan)	
end)

local function COLLECTION_RandomItem()
	local RNumber = math.random(1,100)
	local ItemDatabase = COLLECTION_ITEMSDB
	
	local PossibleItems = {}
	local CurID = 1
	for k,v in pairs(ItemDatabase) do
		if v[2] >= RNumber then
			PossibleItems[CurID] = k
			CurID = CurID + 1
		end
	end
	local FinalRandomItem = PossibleItems[math.random(#PossibleItems)]
	
	return FinalRandomItem
end

local function CollectionSpawnRandomLoot()
	if #Coll_SpawnPoses < 1 or CollectionSpawnLimit() or !CollectionCheckPlayerAmount() then print("Not enough players, spawnlimit reached or no spawnposes found.") return end
		
	local SpawnPos = Coll_SpawnPoses[math.random(#Coll_SpawnPoses)]
	local RID = COLLECTION_RandomItem()
	local RandomItem = COLLECTION_ITEMSDB[RID]
		
	local CItem = ents.Create("collection_item")
	CItem:SetPos(SpawnPos)
	CItem:SetModel(RandomItem[1])
	CItem.CID = RID
	CItem:Spawn()	
end
if TBFY_CollectConfig.ItemSpawning then
	timer.Create("collection_itemspawner", TBFY_CollectConfig.SpawnTimer, 0, CollectionSpawnRandomLoot)
end

local function CollectionSpawnRandomLootContainer()
	if !CollectionCheckPlayerAmount() then print("Not enough players to spawn in containers.") return end
		
	local AllContainers = ents.FindByClass("collection_container")
	if #AllContainers < 1 then print("No containers put out on the map.") return end
	local RandomContainer = AllContainers[math.random(#AllContainers)]
		
	local ItemsInContainer = 0
	for k,v in pairs(RandomContainer.CollItems) do
		ItemsInContainer = ItemsInContainer + v
	end
		
	if ItemsInContainer < TBFY_CollectConfig.ContainerMaxItems then
		local RID = COLLECTION_RandomItem()
		local RandomItem = COLLECTION_ITEMSDB[RID]
			
		RandomContainer.CollItems = RandomContainer.CollItems or {}
		RandomContainer.CollItems[RID] = RandomContainer.CollItems[RID] or 0
		RandomContainer.CollItems[RID] = RandomContainer.CollItems[RID] + 1
	end
end
if TBFY_CollectConfig.ItemSpawningContainers then
	timer.Create("collection_itemspawner_container", TBFY_CollectConfig.SpawnTimerContainer, 0, CollectionSpawnRandomLootContainer)
end

local coll_ISpawnsSave = {}
concommand.Add("collect_add_spawnpos", function(Player)
	if !Player:IsSuperAdmin() then return end
	local Pos = Player:GetPos() + Vector(0,0,15)
	table.insert(coll_ISpawnsSave, Pos)

	Player:PrintMessage(HUD_PRINTTALK, "Spawn pos added. (Remember to save)")
end)

concommand.Add("collect_save_spawnpos", function(Player)
	if !Player:IsSuperAdmin() then return end

	local CurrentMap = string.lower(game.GetMap())	
	file.Write("collectionsystem/manualpos/" .. CurrentMap .. ".txt", util.TableToJSON(coll_ISpawnsSave))
	
	Player:PrintMessage(HUD_PRINTTALK, "Spawn poses saved.")
	Player:PrintMessage(HUD_PRINTTALK, "Remember to restart in order for the spawnposes to be loaded.")
end)

concommand.Add("collect_generate_spawnpos", function(Player)
	if !Player:IsSuperAdmin() then return end
	if #navmesh.GetAllNavAreas() == 0 then Player:PrintMessage(HUD_PRINTTALK, "Generate navmesh before generating spawn positions!") return end
	local PosTbl = {}
	for k,v in pairs(navmesh.GetAllNavAreas()) do	
		local Pos = v:GetRandomPoint()+Vector(0,0,10)
		local tr = util.TraceLine({
			start = Pos,
			endpos = Pos + Vector(0,0,20000),
			filter = function(ent) if ent:IsWorld() then return true end end
		})
		if tr.HitSky then
			PosTbl[k] = Pos
		end
	end
	local CurrentMap = string.lower(game.GetMap())	
	file.Write("collectionsystem/navgenpos/" .. CurrentMap .. ".txt", util.TableToJSON(PosTbl))
	Player:PrintMessage(HUD_PRINTTALK, "Spawnposes saved.")
	Player:PrintMessage(HUD_PRINTTALK, "Remember to restart in order for the spawnposes to be loaded.")
end)

local coll_ContainersSpawnSaves = {}
concommand.Add("collect_setcontainer", function(Player)
	if !Player:IsSuperAdmin() then return end
	local Container = Player:GetEyeTrace().Entity
	if !IsValid(Container) or Container:GetClass() != "prop_physics" then return end
	local Pos, Ang, model = Container:GetPos(), Container:GetAngles(), Container:GetModel()
	
	table.insert(coll_ContainersSpawnSaves, {Pos, Ang, model})
	Container:Remove()
	
	local CContainer = ents.Create("collection_container")
	CContainer:SetPos(Pos)
	CContainer:SetAngles(Ang)
	CContainer:SetModel(model)
	CContainer:Spawn()	
	
	Player:PrintMessage(HUD_PRINTTALK, "Container spawn added. (Remember to save)")
end)

concommand.Add("collect_save_containers", function(Player)
	if !Player:IsSuperAdmin() then return end

	local CurrentMap = string.lower(game.GetMap())	
	file.Write("collectionsystem/containers/" .. CurrentMap .. ".txt", util.TableToJSON(coll_ContainersSpawnSaves))
	
	Player:PrintMessage(HUD_PRINTTALK, "Container spawnposes saved.")
	Player:PrintMessage(HUD_PRINTTALK, "Remember to restart in order for the spawnposes to be loaded.")
end)

net.Receive("collect_container_collectitem", function(len, Player)
	local IDToCollect, Amount = net.ReadFloat(), net.ReadFloat()
	local Container = Player.LastContainer
	
	if !IsValid(Container) or Container:GetPos():Distance(Player:GetPos()) > 200 then return false end 	
	if !Container.CollItems[IDToCollect] or Container.CollItems[IDToCollect] < 1 then return false end
	if Container.CollItems[IDToCollect] < Amount then return end
	
	Container.CollItems[IDToCollect] = Container.CollItems[IDToCollect] - Amount
	if Container.CollItems[IDToCollect] < 1 then
		Container.CollItems[IDToCollect] = nil
	end
	
	Player:GiveCItem(IDToCollect, Amount)
end)

local TGBlacklist = {"collection_container", "collection_item"}
hook.Add("CanTool", "DisableRemovingCollEntsTool", function(Player, trace, tool)
    local ent = trace.Entity
 
	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:IsSuperAdmin() then
			return false
		end
	end
end)

hook.Add("CanProperty", "DisableRemovingCollEntsProperty", function(Player, stringproperty, ent)
	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:IsSuperAdmin() then
			return false
		end
	end
end)

hook.Add("canPocket", "CollRestrictPocketing", function(Player, Ent)
    if table.HasValue(TGBlacklist, Ent:GetClass()) then
	    return false, "You can't put that in your pocket!"
	end
end)