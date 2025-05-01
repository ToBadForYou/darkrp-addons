TBFY_SH.TheoryTests = TBFY_SH.TheoryTests or {}
TBFY_SH.TheoryTestItems = TBFY_SH.TheoryTestItems or {}
TBFY_SH.TheoryTestPlayers = TBFY_SH.TheoryTestPlayers or {}

function TBFY_SH:RegisterTheoryTest(ID, Name)
	TBFY_SH.TheoryTests[ID] = {Name = Name}
	TBFY_SH.TheoryTestItems[ID] = TBFY_SH.TheoryTestItems[ID] or {}
	TBFY_SH.RegTheory = ID
end

function TBFY_SH:AddTheoryQuestion(Tbl)
		local ID = TBFY_SH.RegTheory
		local CurA = #TBFY_SH.TheoryTests[ID] + 1
		Tbl.ID = CurA
		TBFY_SH.TheoryTests[ID][CurA] = Tbl
end

function TBFY_SH:AddTheoryTestItem(ID, Tbl)
	TBFY_SH.TheoryTestItems[ID] = TBFY_SH.TheoryTestItems[ID] or {}
	local CurA = #TBFY_SH.TheoryTestItems[ID] + 1
	TBFY_SH.TheoryTestItems[ID][CurA] = Tbl
end

function TBFY_SH:PlayerHasTheory(SID, Test, ItemID)
	if !TBFY_SH.TheoryTestPlayers[SID] or !TBFY_SH.TheoryTestPlayers[SID][Test] then
		return false
	else
		return TBFY_SH.TheoryTestPlayers[SID][Test][ItemID]
	end
end

function TBFY_SH:ToggleCompileTheory(Value, Compile, SID)
	if Compile then
		Value.string = nil
		local SaveString = ""
		for k,v in pairs(Value) do
			SaveString = SaveString .. k .. ":"
			for id, bool in pairs(v) do
				SaveString = SaveString .. id .. ":"
			end
			SaveString = string.TrimRight(SaveString, ":")
			SaveString = SaveString .. ";"
		end
		TBFY_SH.TheoryTestPlayers[SID].string = SaveString
	else
		local Tests = string.Explode(";", Value);

		for k, v in pairs(Tests) do
			local Items = string.Explode(":", v);
			local CatID
			for index,Item in pairs(Items) do
				if Item != "" then
					if index == 1 then
						CatID = Item
						TBFY_SH.TheoryTestPlayers[SID][CatID] = TBFY_SH.TheoryTestPlayers[SID][CatID] or {}
					else
						TBFY_SH.TheoryTestPlayers[SID][CatID][tonumber(Item)] = true
					end
				end
			end
		end
	end
end
