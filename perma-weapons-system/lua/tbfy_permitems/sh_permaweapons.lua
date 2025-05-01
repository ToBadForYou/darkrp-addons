
local PLAYER = FindMetaTable( "Player" )

function PLAYER:PermAdminAccess()
	return PermItemsConfig.AdminAccessCustomCheck(self)
end

function PLAYER:CanAffordPermItem(Cost)
	if PermItemsConfig.Currency == "darkrpwallet" then
	    return self:canAfford(Cost)
	elseif PermItemsConfig.Currency == "ps1" then
		return self:PS_GetPoints() >= Cost
	elseif PermItemsConfig.Currency == "pcurrency" then
		return self:GetPCurrencyAmount() >= Cost
	else
		DarkRP.notify(self, 1, 4, "Incorrect currency type set in config, contact server owner.")
        return false
	end
end

function PLAYER:GetPCurrencyAmount()
	return self.PCurrency
end

function PLAYER:GetCurrencyAmount()
	if PermItemsConfig.Currency == "darkrpwallet" then
	    return DarkRP.formatMoney(self:getDarkRPVar("money"))
	elseif PermItemsConfig.Currency == "ps1" then
		return self:PS_GetPoints()
	elseif PermItemsConfig.Currency == "pcurrency" then
		return self:GetPCurrencyAmount()
	else
        return 0
	end
end

function PLAYER:HasPermWeapon(CatID, ID, Offline)
	if Offline then
		if self.MWeps[CatID] and self.MWeps[CatID][ID] then
			return true
		else
			return false
		end
	else
		if self.PermWeapons[CatID] and self.PermWeapons[CatID][ID] then
			return true
		else
			return false
		end
	end
end

function PLAYER:HasPermEntities(CatID, ID, Offline)
	if Offline then
		if self.MEnts[CatID] and self.MEnts[CatID][ID] then
			return true
		else
			return false
		end
	else
		if self.PermEntities[CatID] and self.PermEntities[CatID][ID] then
			return true
		else
			return false
		end
	end
end

function PLAYER:DecompileWeaponString(CompiledString)
 	self.PermWeapons = self.PermWeapons or {}

	local PWeapons = string.Explode(";", CompiledString);

	for k, v in pairs(PWeapons) do
		local SplitIDPT = string.Explode(",", v);
		if #SplitIDPT > 1 then
		    local CatID, ID = tonumber(SplitIDPT[1]), tonumber(SplitIDPT[2])
		    self.PermWeapons[CatID] = self.PermWeapons[CatID] or {}
			self.PermWeapons[CatID][ID] = ID
		end
	end
end

function PLAYER:DecompileEntitiesString(CompiledString)
 	self.PermEntities = self.PermEntities or {}

	local PEntities = string.Explode(";", CompiledString);

	for k, v in pairs(PEntities) do
		local SplitIDPT = string.Explode(",", v);
		if #SplitIDPT > 1 then
		    local CatID, ID = tonumber(SplitIDPT[1]), tonumber(SplitIDPT[2])
		    self.PermEntities[CatID] = self.PermEntities[CatID] or {}
			self.PermEntities[CatID][ID] = ID
		end
	end
end

hook.Add("CanProperty", "permwepents_CanTool", function(Player, property, ent)
	if Player:SteamID() == ent:GetNWString("tbfy_SID") and ent:GetNWBool("tbfy_perment") then
		return true
	end
end)
