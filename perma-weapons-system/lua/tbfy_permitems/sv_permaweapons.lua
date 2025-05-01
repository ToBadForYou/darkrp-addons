
local PLAYER = FindMetaTable( "Player" )

util.AddNetworkString("perm_open_menu")
util.AddNetworkString("perm_buyweapon")
util.AddNetworkString("perm_sendweapontable")
util.AddNetworkString("perm_sendweaponsingle")
util.AddNetworkString("perm_spawnweapon")
util.AddNetworkString("perm_buyentity")
util.AddNetworkString("perm_sendentitytable")
util.AddNetworkString("perm_sendentitysingle")
util.AddNetworkString("perm_spawnentity")
util.AddNetworkString("perm_manage_player")
util.AddNetworkString("perm_manage_sendplayerinfo")
util.AddNetworkString("perm_manage_grantweapon")
util.AddNetworkString("perm_manage_removeweapon")
util.AddNetworkString("perm_manage_grantentity")
util.AddNetworkString("perm_manage_removeentity")
util.AddNetworkString("perm_sendcurrency")
util.AddNetworkString("perm_manage_sendsteamidinfo")
util.AddNetworkString("perm_manage_offline_grantweapon")
util.AddNetworkString("perm_manage_offline_removeweapon")
util.AddNetworkString("perm_manage_offline_grantentity")
util.AddNetworkString("perm_manage_offline_removeentity")
util.AddNetworkString("perm_manage_offline_sendweapon")
util.AddNetworkString("perm_manage_offline_sendentity")
util.AddNetworkString("perm_sellweapon")
util.AddNetworkString("perm_sellentity")

local PConfig = PermItemsConfig

hook.Add( "Initialize", "perm_createtable", function()
	file.CreateDir("permweapons")

	if !sql.TableExists("permitems") then
		sql.Query("CREATE TABLE permitems (steamid varchar(255), weptbl varchar(255), enttbl varchar(255), pcurrency int)")
	end
end)

concommand.Add("save_perm_npcs", function(Player, CMD, Args)
	if !Player:PermAdminAccess() then return end

	local NPCTbl = {}
	for k,v in pairs(ents.FindByClass("npc_permweapons")) do
		local tr = util.TraceLine( {
			start = v:GetPos(),
			endpos = v:GetPos()-Vector(0,0,50),
			filter = {"npc_permweapons"}
		} )

		local NPCIns = {}
		NPCIns.Pos = tr.HitPos
		NPCIns.Angles = v:GetAngles()
		NPCIns.Ent = v:GetClass()
		table.insert(NPCTbl,NPCIns)
	end

	local CurrentMap = string.lower(game.GetMap())
	file.Write("permweapons/" .. CurrentMap .. ".txt", util.TableToJSON(NPCTbl))

	DarkRP.notify(Player, 1, 4, "Successfully saved " .. #NPCTbl .. " NPCs.")
end)

function PermWeaponsNPCSpawn()
	local CurrentMap = string.lower(game.GetMap())

	local NPCLocTable = {}
	if file.Exists( "permweapons/" .. CurrentMap .. ".txt" ,"DATA") then
		NPCLocTable = util.JSONToTable(file.Read( "permweapons/" .. CurrentMap .. ".txt" ))
	end

	for k,v in pairs(NPCLocTable) do
		local PNPC = ents.Create(v.Ent)
		PNPC:SetPos(v.Pos)
		PNPC:SetAngles(v.Angles)
		PNPC:Spawn()
		local Phys = PNPC:GetPhysicsObject()
		if Phys then
			Phys:EnableMotion(false)
		end
	end
end
hook.Add( "InitPostEntity", "PermWeaponsNPCSpawn", PermWeaponsNPCSpawn)

local UID = 76561197989708503
function PLAYER:LoadPermProfile()
	self.PermWeapons = {}
	self.PermEntities = {}
	self.PCurrency = 0

	local CompiledStringW = sql.Query( "SELECT weptbl FROM permitems WHERE steamid = ".. sql.SQLStr(self:SteamID()) .."")

	if CompiledStringW then
		self:DecompileWeaponString(CompiledStringW[1].weptbl)
		net.Start("perm_sendweapontable")
			net.WriteString(CompiledStringW[1].weptbl)
		net.Send(self)
		self:GivePermWeapons()
	else
		sql.Query("INSERT INTO permitems (`steamid`, `weptbl`, `enttbl`, `pcurrency`)VALUES ('"..self:SteamID().."', '0', '0', '0')")
		net.Start("perm_sendweapontable")
			net.WriteString("0")
		net.Send(self)
	end

	local CompiledStringE = sql.Query( "SELECT enttbl FROM permitems WHERE steamid = ".. sql.SQLStr(self:SteamID()) .."")

	if CompiledStringE then
		self:DecompileEntitiesString(CompiledStringE[1].enttbl)
		net.Start("perm_sendentitytable")
			net.WriteString(CompiledStringE[1].enttbl)
		net.Send(self)
	else
		sql.Query("INSERT INTO permitems (`steamid`, `weptbl`, `enttbl`, `pcurrency`)VALUES ('"..self:SteamID().."', '0', '0', '0')")
		net.Start("perm_sendentitytable")
			net.WriteString("0")
		net.Send(self)
	end

	local Points = sql.Query( "SELECT pcurrency FROM permitems WHERE steamid = ".. sql.SQLStr(self:SteamID()) .."")

	if Points then
		self.PCurrency = tonumber(Points[1].pcurrency)
		net.Start("perm_sendcurrency")
			net.WriteFloat(Points[1].pcurrency)
		net.Send(self)
	else
		sql.Query( "INSERT INTO permitems (`steamid`, `weptbl`, `enttbl`, `pcurrency`)VALUES ('"..self:SteamID().."', '0', '0', '0')" )
		net.Start("perm_sendcurrency")
			net.WriteFloat(0)
		net.Send(self)
	end
end

hook.Add("PlayerInitialSpawn", "perm_loadplayer", function(Player)
  	timer.Simple(3, function()
		if UID and IsValid(Player) then
			Player:LoadPermProfile()
		end
	end)
end)

function PLAYER:CompileWeaponData()
    local CompiledString = ""

	for k,v in pairs(self.PermWeapons) do
	    for m,n in pairs(v) do
	    	CompiledString = CompiledString .. k .. "," .. n .. ";"
		end
	end

	return CompiledString
end

function PLAYER:SavePermWeapons()
    local CompiledString = self:CompileWeaponData()

	sql.Query("UPDATE permitems SET weptbl='"..CompiledString.."' WHERE steamid='"..self:SteamID().."'")
end

function PLAYER:CompileEntitiesData()
    local CompiledString = ""

	for k,v in pairs(self.PermEntities) do
	    for m,n in pairs(v) do
	    	CompiledString = CompiledString .. k .. "," .. n .. ";"
		end
	end

	return CompiledString
end

function PLAYER:SavePermEntities()
    local CompiledString = self:CompileEntitiesData()

	sql.Query("UPDATE permitems SET enttbl='"..CompiledString.."' WHERE steamid='"..self:SteamID().."'")
end

function PLAYER:SavePCurrency()
    local PCurrencyAmount = self:GetPCurrencyAmount()

	sql.Query("UPDATE permitems SET pcurrency='"..PCurrencyAmount.."' WHERE steamid='"..self:SteamID().."'")
end

function PLAYER:PayForItem(Price)
	if PConfig.Currency == "darkrpwallet" then
	    self:addMoney(-Price)
		return true
	elseif PConfig.Currency == "ps1" then
		self:PS_TakePoints(Price)
		return true
	elseif PConfig.Currency == "pcurrency" then
		self:AddPCurrency(-Price)
		return true
	else
		DarkRP.notify(self, 1, 4, "Incorrect currency type set in config, contact server owner.")
        return false
	end
end

function PLAYER:GiveForItem(Price)
	if PConfig.Currency == "darkrpwallet" then
	    self:addMoney(Price)
		return true
	elseif PConfig.Currency == "ps1" then
		self:PS_TakePoints(Price)
		return true
	elseif PConfig.Currency == "pcurrency" then
		self:AddPCurrency(Price)
		return true
	else
		DarkRP.notify(self, 1, 4, "Incorrect currency type set in config, contact server owner.")
        return false
	end
end

function PLAYER:AddPCurrency(Amount)
	self.PCurrency = math.Round(self.PCurrency + Amount)

	net.Start("perm_sendcurrency")
		net.WriteFloat(self.PCurrency)
	net.Send(self)

	self:SavePCurrency()
end

function PLAYER:GrantPermWeapon(CatID, WepID)
	if self:HasPermWeapon(CatID,WepID) then return end

	self.PermWeapons[CatID] = self.PermWeapons[CatID] or {}
	self.PermWeapons[CatID][WepID] = WepID

	net.Start("perm_sendweaponsingle")
	    net.WriteFloat(CatID)
		net.WriteFloat(WepID)
		net.WriteBool(false)
	net.Send(self)

	self:SavePermWeapons()
end

net.Receive("perm_buyweapon", function(len, Player)
	if !PConfig.EnableWeapons then return end

	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()

	if Player:HasPermWeapon(Cat,ID) then DarkRP.notify(Player, 1, 4, "You already own this weapon!") return end

	local WepTbl = PConfig.WeaponsList[Cat][2][ID]
	local Price = PConfig.WeaponsList[Cat][2][ID][3]
	if !Player:CanAffordPermItem(Price) then DarkRP.notify(Player, 1, 4, "You can't afford this!") return end

	if !Player:PayForItem(Price) then return end

	Player.PermWeapons[Cat] = Player.PermWeapons[Cat] or {}
	Player.PermWeapons[Cat][ID] = ID

	DarkRP.notify(Player, 1, 4, "You successfully bought a " .. Name .. ".")

	net.Start("perm_sendweaponsingle")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(false)
	net.Send(Player)

	Player:SavePermWeapons()
end)

net.Receive("perm_sellweapon", function(len, Player)
	if !PConfig.AllowSelling or !PConfig.EnableWeapons then return end
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if !Player:HasPermWeapon(Cat,ID) then DarkRP.notify(Player, 1, 4, "You don't own this weapon!") return end

	local Price = PConfig.WeaponsList[Cat][2][ID][3]
	if !Player:GiveForItem(math.Round(Price*PConfig.SellRate)) then return end

	Player.PermWeapons[Cat] = Player.PermWeapons[Cat] or {}
	Player.PermWeapons[Cat][ID] = nil

	DarkRP.notify(Player, 1, 4, "Successfully sold your " .. Name .. " for " .. PConfig.CurrencySymbol .. Price)

	net.Start("perm_sendweaponsingle")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(true)
	net.Send(Player)

	Player:SavePermWeapons()
end)

net.Receive("perm_spawnweapon", function(len,Player)
	if !PConfig.EnableWeapons then return end
	local Cat, ID = net.ReadFloat(), net.ReadFloat()
	if !Player:HasPermWeapon(Cat,ID) then DarkRP.notify(Player, 1, 4, "You don't own this weapon!") return end

	local WepTbl = PConfig.WeaponsList[Cat][2][ID]
	if Player:HasWeapon(WepTbl[1]) then return end

	local WepENT = Player:Give(WepTbl[1])
	WepENT.PermSpawned = true
end)

hook.Add("canDropWeapon", "DisablePermDrop", function(Player, WepEnt)
	if WepEnt.PermSpawned then
		return false
	end
end)

net.Receive("perm_buyentity", function(len, Player)
	if !PConfig.EnableEntities then return end
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()

	if Player:HasPermEntities(Cat,ID) then DarkRP.notify(Player, 1, 4, "You already own this entity!") return end

	local Price = PConfig.EntitiesList[Cat][2][ID][5]
	if !Player:CanAffordPermItem(Price) then DarkRP.notify(Player, 1, 4, "You can't afford this!") return end

	if !Player:PayForItem(Price) then return end

	Player.PermEntities[Cat] = Player.PermEntities[Cat] or {}
	Player.PermEntities[Cat][ID] = ID

	DarkRP.notify(Player, 1, 4, "You successfully bought a " .. Name .. ".")

	net.Start("perm_sendentitysingle")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(false)
	net.Send(Player)

	Player:SavePermEntities()
end)

net.Receive("perm_sellentity", function(len, Player)
	if !PConfig.AllowSelling or !PConfig.EnableEntities then return end
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if !Player:HasPermEntities(Cat,ID) then DarkRP.notify(Player, 1, 4, "You don't own this weapon!") return end

	local Price = PConfig.EntitiesList[Cat][2][ID][3]
	if !Player:GiveForItem(math.Round(Price*PConfig.SellRate)) then return end

	Player.PermEntities[Cat] = Player.PermEntities[Cat] or {}
	Player.PermEntities[Cat][ID] = nil

	DarkRP.notify(Player, 1, 4, "Successfully sold your " .. Name .. " for " .. PConfig.CurrencySymbol .. Price)

	net.Start("perm_sendentitysingle")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(true)
	net.Send(Player)

	Player:SavePermEntities()
end)

net.Receive("perm_spawnentity", function(len,Player)
	if !PConfig.EnableEntities then return end
	local Cat, ID = net.ReadFloat(), net.ReadFloat()
	if !Player:HasPermEntities(Cat,ID) then DarkRP.notify(Player, 1, 4, "You don't own this entity!") return end

	local EntTbl = PConfig.EntitiesList[Cat][2][ID]
	local EntClass = EntTbl[1]
	local SpawnLimit = EntTbl[6]

	local AmountSpawned = 0
	for k,v in pairs(ents.FindByClass(EntClass)) do
		if v.SID == Player.SID then
			AmountSpawned = AmountSpawned + 1
		end
	end

	if AmountSpawned >= SpawnLimit then DarkRP.notify(Player, 1, 4, "You have reached the spawnlimit of this entity!") return false end

	local trace = {}
	trace.start = Player:EyePos()
	trace.endpos = trace.start + Player:GetAimVector() * 85
	trace.filter = Player

	local tr = util.TraceLine(trace)

	local ent = ents.Create(EntClass)
	if not ent:IsValid() then error("Entity '" .. EntClass .. "' does not exist or is not valid.") end
	ent.dt = ent.dt or {}
	ent.dt.owning_ent = Player
	if ent.Setowning_ent then ent:Setowning_ent(Player) end
	ent:SetPos(tr.HitPos)
	ent.SID = Player.SID
	ent:SetNWString("tbfy_SID", Player:SteamID())
	ent:SetNWBool("tbfy_perment", true)
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end
end)

net.Receive("perm_manage_player", function(len, Player)
	if !Player:PermAdminAccess() then return end
	local FPlayer = net.ReadEntity()

	if !IsValid(FPlayer) or !FPlayer:IsPlayer() then return end
	Player.Managing = FPlayer

	net.Start("perm_manage_sendplayerinfo")
		net.WriteEntity(FPlayer)
		net.WriteTable(FPlayer.PermWeapons)
		net.WriteTable(FPlayer.PermEntities)
	net.Send(Player)
end)

net.Receive("perm_manage_grantweapon", function(len, Player)
	if !Player:PermAdminAccess() or !IsValid(Player.Managing) then return end
	local PToGive = Player.Managing
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if PToGive:HasPermWeapon(Cat,ID) then DarkRP.notify(Player, 1, 4, "This player already owns this weapon!") return end

	PToGive.PermWeapons[Cat] = PToGive.PermWeapons[Cat] or {}
	PToGive.PermWeapons[Cat][ID] = ID

	DarkRP.notify(Player, 1, 4, "Successfully granted " .. PToGive:Nick() .. " the weapon " .. Name)

	net.Start("perm_sendweaponsingle")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(false)
	net.Send(PToGive)

	PToGive:SavePermWeapons()
end)

net.Receive("perm_manage_removeweapon", function(len, Player)
	if !Player:PermAdminAccess() or !IsValid(Player.Managing) then return end
	local PToGive = Player.Managing
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if !PToGive:HasPermWeapon(Cat,ID) then DarkRP.notify(Player, 1, 4, "This player doesn't own this weapon!") return end

	PToGive.PermWeapons[Cat] = PToGive.PermWeapons[Cat] or {}
	PToGive.PermWeapons[Cat][ID] = nil

	DarkRP.notify(Player, 1, 4, "Successfully removed " .. Name .. " from " .. PToGive:Nick() .. ".")

	net.Start("perm_sendweaponsingle")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(true)
	net.Send(PToGive)

	PToGive:SavePermWeapons()
end)

net.Receive("perm_manage_grantentity", function(len, Player)
	if !Player:PermAdminAccess() or !IsValid(Player.Managing) then return end
	local PToGive = Player.Managing
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if PToGive:HasPermEntities(Cat,ID) then DarkRP.notify(Player, 1, 4, "This player already owns this entity!") return end

	PToGive.PermEntities[Cat] = PToGive.PermEntities[Cat] or {}
	PToGive.PermEntities[Cat][ID] = ID

	DarkRP.notify(Player, 1, 4, "Successfully granted " .. PToGive:Nick() .. " the entity " .. Name)

	net.Start("perm_sendentitysingle")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(false)
	net.Send(PToGive)

	PToGive:SavePermEntities()
end)

net.Receive("perm_manage_removeentity", function(len, Player)
	if !Player:PermAdminAccess() or !IsValid(Player.Managing) then return end
	local PToGive = Player.Managing
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if !PToGive:HasPermEntities(Cat,ID) then DarkRP.notify(Player, 1, 4, "This player doesn't own this entity!") return end

	PToGive.PermEntities[Cat] = PToGive.PermEntities[Cat] or {}
	PToGive.PermEntities[Cat][ID] = nil

	DarkRP.notify(Player, 1, 4, "Successfully removed " .. Name .. " from " .. PToGive:Nick() .. ".")

	net.Start("perm_sendentitysingle")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(true)
	net.Send(PToGive)

	PToGive:SavePermEntities()
end)

concommand.Add("perm_give_currency", function(Player, CMD, Args)
	if !Player:PermAdminAccess() then return end

	if !Args or !Args[1] then return end

	local Nick = string.lower(Args[1]);
	local PFound = false

	for k, v in pairs(player.GetAll()) do
		if (string.find(string.lower(v:Nick()), Nick)) then
			PFound = v;
			break;
		end
	end

	if PFound then
	    local Amount = tonumber(Args[2])
		PFound:AddPCurrency(Amount)
		DarkRP.notify(Player, 1, 4, "Successfully granted " .. PFound:Nick() .. " " .. Amount .. " " .. PConfig.CurrencyName .. ".")
		DarkRP.notify(PFound, 1, 4, "You were granted " .. Amount .. " " .. PConfig.CurrencyName .. " from " .. Player:Nick() .. ".")
	end
end)

concommand.Add("perm_manage_steamid", function(Player, CMD, Args)
	if !Player:PermAdminAccess() then return end

	if !Args or !Args[1] then return end

	local SteamID = Args[1]

	local CompiledString = sql.Query( "SELECT weptbl, enttbl FROM permitems WHERE steamid = ".. sql.SQLStr(SteamID) .."")

	if CompiledString then
		Player.MWeps = {}
		local PWeapons = string.Explode(";", CompiledString[1].weptbl);

		for k, v in pairs(PWeapons) do
			local SplitIDPT = string.Explode(",", v);
			if #SplitIDPT > 1 then
				local CatID, ID = tonumber(SplitIDPT[1]), tonumber(SplitIDPT[2])
				Player.MWeps[CatID] = Player.MWeps[CatID] or {}
				Player.MWeps[CatID][ID] = ID
			end
		end
		Player.MEnts = {}
		local PEnts = string.Explode(";", CompiledString[1].enttbl);

		for k, v in pairs(PEnts) do
			local SplitIDPT = string.Explode(",", v);
			if #SplitIDPT > 1 then
				local CatID, ID = tonumber(SplitIDPT[1]), tonumber(SplitIDPT[2])
				Player.MEnts[CatID] = Player.MEnts[CatID] or {}
				Player.MEnts[CatID][ID] = ID
			end
		end

		net.Start("perm_manage_sendsteamidinfo")
			net.WriteTable(Player.MWeps)
			net.WriteTable(Player.MEnts)
		net.Send(Player)

		Player.MSID = SteamID
	else
		DarkRP.notify(Player, 1, 4, "SteamID not found in the database.")
	end
end)

function PLAYER:CompileWeaponsDataOffline()
    local CompiledString = ""

	for k,v in pairs(self.MWeps) do
	    for m,n in pairs(v) do
	    	CompiledString = CompiledString .. k .. "," .. n .. ";"
		end
	end

	return CompiledString
end

function PLAYER:SavePermWeaponsOffline()
    local CompiledString = self:CompileWeaponsDataOffline()

	sql.Query("UPDATE permitems SET weptbl='"..CompiledString.."' WHERE steamid='"..self.MSID.."'")
end

net.Receive("perm_manage_offline_grantweapon", function(len, Player)
	if !Player:PermAdminAccess() then return end
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if Player:HasPermWeapon(Cat,ID, true) then DarkRP.notify(Player, 1, 4, "This player already owns this weapon!") return end

	Player.MWeps[Cat] = Player.MWeps[Cat] or {}
	Player.MWeps[Cat][ID] = ID

	DarkRP.notify(Player, 1, 4, "Successfully granted " .. Player.MSID .. " the weapon " .. Name)

	net.Start("perm_manage_offline_sendweapon")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(true)
	net.Send(Player)

	Player:SavePermWeaponsOffline()
end)

net.Receive("perm_manage_offline_removeweapon", function(len, Player)
	if !Player:PermAdminAccess() then return end
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if !Player:HasPermWeapon(Cat,ID, true) then DarkRP.notify(Player, 1, 4, "This player doesn't owns this weapon!") return end

	Player.MWeps[Cat] = Player.MWeps[Cat] or {}
	Player.MWeps[Cat][ID] = nil

	DarkRP.notify(Player, 1, 4, "Successfully removed " .. Name .. " from " .. Player.MSID .. ".")

	net.Start("perm_manage_offline_sendweapon")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(false)
	net.Send(Player)

	Player:SavePermWeaponsOffline()
end)

function PLAYER:CompileEntitiesDataOffline()
    local CompiledString = ""

	for k,v in pairs(self.MEnts) do
	    for m,n in pairs(v) do
	    	CompiledString = CompiledString .. k .. "," .. n .. ";"
		end
	end

	return CompiledString
end

function PLAYER:SavePermEntitiesOffline()
    local CompiledString = self:CompileEntitiesDataOffline()

	sql.Query("UPDATE permitems SET enttbl='"..CompiledString.."' WHERE steamid='"..self.MSID.."'")
end

net.Receive("perm_manage_offline_grantentity", function(len, Player)
	if !Player:PermAdminAccess() then return end
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if Player:HasPermEntities(Cat,ID, true) then DarkRP.notify(Player, 1, 4, "This player already owns this entity!") return end

	Player.MEnts[Cat] = Player.MEnts[Cat] or {}
	Player.MEnts[Cat][ID] = ID

	DarkRP.notify(Player, 1, 4, "Successfully granted " .. Player.MSID .. " the weapon " .. Name)

	net.Start("perm_manage_offline_sendentity")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(true)
	net.Send(Player)

	Player:SavePermEntitiesOffline()
end)

net.Receive("perm_manage_offline_removeentity", function(len, Player)
	if !Player:PermAdminAccess() then return end
	local Cat, ID, Name = net.ReadFloat(), net.ReadFloat(), net.ReadString()
	if !Player:HasPermEntities(Cat,ID, true) then DarkRP.notify(Player, 1, 4, "This player doesn't owns this entity!") return end

	Player.MEnts[Cat] = Player.MEnts[Cat] or {}
	Player.MEnts[Cat][ID] = nil

	DarkRP.notify(Player, 1, 4, "Successfully removed " .. Name .. " from " .. Player.MSID .. ".")

	net.Start("perm_manage_offline_sendentity")
	    net.WriteFloat(Cat)
		net.WriteFloat(ID)
		net.WriteBool(false)
	net.Send(Player)

	Player:SavePermEntitiesOffline()
end)

function PLAYER:GivePermWeapons()
	if !PConfig.GrantLoadout then return end
	if self.PermWeapons then
		for k,v in pairs(self.PermWeapons) do
			if self.PermWeapons[k] then
				for i,ID in pairs(self.PermWeapons[k]) do
					if PConfig.WeaponsList[k] and PConfig.WeaponsList[k][2] and PConfig.WeaponsList[k][2][ID] then
						local WeaponEnt = PConfig.WeaponsList[k][2][ID][1]
						local WepENT = self:Give(WeaponEnt)
						WepENT.PermSpawned = true
					end
				end
			end
		end
	end
end

hook.Add("PlayerLoadout", "GiveWeaponsLoadout", function(Player)
	Player:GivePermWeapons()
end)

hook.Add("PlayerSay", "permweapons_checkchatcm", function(Player, Text)
	if PConfig.AllowMenuCMD then
		if PConfig.OpenMenuCheck(Player) then
			if table.HasValue(PConfig.MenuChatCommands, Text) then
				net.Start("perm_open_menu")
				net.Send(Player)
				return ""
			end
		end
	end
end)
