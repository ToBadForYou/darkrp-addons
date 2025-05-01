
local PLAYER = FindMetaTable( "Player" )

function CollectionCheckPlayerAmount()
    return TBFY_CollectConfig.PlayersReq <= #player.GetAll()
end

function PLAYER:HasCClaimedReward(CID)
	return table.HasValue(self.RewardsClaimed, CID)
end

function PLAYER:CollectionIsFinished(CID)
	self.Collections[CID] = self.Collections[CID] or {}
	return #self.Collections[CID] >= COLLECTION_COLLCETIONSDB[CID][3]
end

function CollectionSpawnLimit()
	local CItemsOut = #ents.FindByClass("collection_item")
	return CItemsOut >= TBFY_CollectConfig.ItemSpawnLimit
end

function CollectionHasID(CID,ID)
	return table.HasValue(COLLECTION_COLLCETIONSDB[CID][2],ID)
end

function PLAYER:CollectionHasID(CID,ID)
	self.Collections[CID] = self.Collections[CID] or {}
	return table.HasValue(self.Collections[CID],ID)
end

function PLAYER:HasCItem(ID)
	local HasAmount = self.CollectionInventory[ID] or 0
	return HasAmount > 0
end

function PLAYER:DecompileInventoryString(CompiledString)
 	self.CollectionInventory = self.CollectionInventory or {}
	if CompiledString == "0" then return end
	
	local Inventory = string.Explode(";", CompiledString);
	
	for k, v in pairs(Inventory) do
		local SplitIDPT = string.Explode(",", v);
		if #SplitIDPT > 1 then
		    local ID, Amount = tonumber(SplitIDPT[1]), tonumber(SplitIDPT[2])
		    self.CollectionInventory[ID] = Amount
		end
	end
end

function PLAYER:DecompileCollectionsString(CompiledString)
 	self.CollectionInventory = self.CollectionInventory or {}
	if CompiledString == "0" then return end

	local Collections = string.Explode(";", CompiledString);
	
	for k, v in pairs(Collections) do
		local SplitIDPT = string.Explode(",", v);
		local CID = tonumber(SplitIDPT[1])
		if SplitIDPT[2] then
			local IDTbl = string.Explode(":", SplitIDPT[2]);
			local IDNumTbl = {}
			for i, n in pairs(IDTbl) do
				if n != "" then
					IDNumTbl[i] = tonumber(n)
				end
			end
			self.Collections[CID] = IDNumTbl
		end	
	end
end

function PLAYER:DecompileRClaimedString(CompiledString)
 	self.RewardsClaimed = self.RewardsClaimed or {}
	if CompiledString == "0" then return end
	
	local RClaimed = string.Explode(",", CompiledString);
	
	for k, v in pairs(RClaimed) do
		if v != "" then
			self.RewardsClaimed[k] = tonumber(v)
		end
	end
end

hook.Add("ShouldCollide", "collection_items_nocollision", function(ent1,ent2)
	if ent1:GetClass() == "collection_item" and !ent2:IsWorld() and !ent2:IsPlayer() then
		return false
	end
end)

