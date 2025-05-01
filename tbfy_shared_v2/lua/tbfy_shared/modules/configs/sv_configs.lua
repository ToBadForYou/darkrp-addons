util.AddNetworkString("tbfy_update_config")
util.AddNetworkString("tbfy_request_configs")
util.AddNetworkString("tbfy_update_c_config")

function TBFY_SH:LoadConfigs(AName)
	local File = "tbfy_configs/" .. AName .. ".txt"
	if file.Exists(File, "DATA") then
		local RConfs = util.JSONToTable(file.Read(File))
		for k,v in pairs(RConfs) do
			if TBFY_SH.Configs[AName][k] then
				TBFY_SH.Configs[AName][k].Val = v
			end
		end
	else
		local DefConfs = {}
		for k,v in pairs(TBFY_SH.Configs[AName]) do
			local DefVal = v.Default
			if v.Type == "Number" or v.Type == "TextOptions" then
				DefVal = v.Default.Val
			end
			v.Val = DefVal
			DefConfs[k] = DefVal
		end
		file.Write(File, util.TableToJSON(DefConfs))
	end
end

net.Receive("tbfy_update_config", function(len, Player)
	local AName, Amount = net.ReadString(), net.ReadFloat()
	local AInfo = TBFY_SH.AInfo[AName]
	if AInfo.ACheck and AInfo.ACheck(Player) and TBFY_SH.Configs[AName] then
		local CUpdate = {}
		for i = 1, Amount do
			local ID = net.ReadString()
			local Type = net.ReadString()
			local Val = nil
			if Type == "Bool" then
				Val = net.ReadBool()
			elseif Type == "Number" or Type == "Job"  then
				Val = net.ReadFloat()
			elseif Type == "Jobs" then
				Val = {}
				local Amount = net.ReadFloat()
				for i = 1, Amount do
					Val[net.ReadFloat()] = true
				end
			elseif Type == "SWEPs" then
				Val = {}
				local Amount = net.ReadFloat()
				for i = 1, Amount do
					Val[net.ReadString()] = true
				end
			elseif Type == "SWEP" or Type == "Text" or Type == "TextOptions" then
				Val = net.ReadString()
			end
			TBFY_SH.Configs[AName][ID].Val = Val
			if TBFY_SH.Configs[AName][ID].UpdateC then
				CUpdate[ID] = {Val = Val, Type = Type}
			end
		end

		local CAmount = table.Count(CUpdate)
		net.Start("tbfy_update_c_config")
			net.WriteString(AName)
			net.WriteFloat(CAmount)
			for k,v in pairs(CUpdate) do
				net.WriteString(k)
				net.WriteString(v.Type)
				if v.Type == "Bool" then
					net.WriteBool(v.Val or false)
				elseif v.Type == "Number" or v.Type == "Job" then
					net.WriteFloat(v.Val or 0)
				elseif v.Type == "Jobs" then
					if !v.Val then
						v.Val = {}
					end
					local Amount = table.Count(v.Val)
					net.WriteFloat(Amount)
					for id,bool in pairs(v.Val) do
						net.WriteFloat(id)
					end
				elseif v.Type == "SWEPs" then
					if !v.Val then
						v.Val = {}
					end
					local Amount = table.Count(v.Val)
					net.WriteFloat(Amount)
					for id,bool in pairs(v.Val) do
						net.WriteString(id)
					end
				elseif v.Type == "SWEP" or v.Type == "Text" or v.Type == "TextOptions" then
					net.WriteString(v.Val or "")
				end
			end
		net.Broadcast()

		local NewConfs = {}
		for k,v in pairs(TBFY_SH.Configs[AName]) do
			NewConfs[k] = v.Val
		end

		local File = "tbfy_configs/" .. AName .. ".txt"
		file.Write(File, util.TableToJSON(NewConfs))
	end
end)

net.Receive("tbfy_request_configs", function(len, Player)
	local AName, Client = net.ReadString(), net.ReadBool()
	local AInfo = TBFY_SH.AInfo[AName]
	local Configs = TBFY_SH.Configs[AName]

	if Client and Configs then
		local ClientConfs = {}
		for k,v in pairs(Configs) do
			if v.UpdateC then
				ClientConfs[k] = {Val = v.Val, Type = v.Type}
			end
		end

		local CAmount = table.Count(ClientConfs)
		net.Start("tbfy_update_c_config")
			net.WriteString(AName)
			net.WriteFloat(CAmount)
			for k,v in pairs(ClientConfs) do
				net.WriteString(k)
				net.WriteString(v.Type)
				if v.Type == "Bool" then
					net.WriteBool(v.Val or false)
				elseif v.Type == "Number" or v.Type == "Job" then
					net.WriteFloat(v.Val or 0)
				elseif v.Type == "Jobs" then
					if !v.Val then
						v.Val = {}
					end
					local Amount = table.Count(v.Val)
					net.WriteFloat(Amount)
					for id,bool in pairs(v.Val) do
						net.WriteFloat(id)
					end
				elseif v.Type == "SWEPs" then
					if !v.Val then
						v.Val = {}
					end
					local Amount = table.Count(v.Val)
					net.WriteFloat(Amount)
					for id,bool in pairs(v.Val) do
						net.WriteString(id)
					end
				elseif v.Type == "SWEP" or v.Type == "Text" or v.Type == "TextOptions" then
					net.WriteString(v.Val or "")
				end
			end
		net.Send(Player)
	elseif AInfo.ACheck and AInfo.ACheck(Player) and Configs then
		local Amount = table.Count(Configs)
		net.Start("tbfy_request_configs")
			net.WriteFloat(Amount)
			for k,v in pairs(Configs) do
				net.WriteString(k)
				net.WriteString(v.Type)
				if v.Type == "Bool" then
					net.WriteBool(v.Val or false)
				elseif v.Type == "Number" or v.Type == "Job" then
					net.WriteFloat(v.Val or 0)
				elseif v.Type == "Jobs" then
					if !v.Val then
						v.Val = {}
					end
					local Amount = table.Count(v.Val)
					net.WriteFloat(Amount)
					for id,bool in pairs(v.Val) do
						net.WriteFloat(id)
					end
				elseif v.Type == "SWEPs" then
					if !v.Val then
						v.Val = {}
					end
					local Amount = table.Count(v.Val)
					net.WriteFloat(Amount)
					for id,bool in pairs(v.Val) do
						net.WriteString(id)
					end
				elseif v.Type == "SWEP" or v.Type == "Text" or v.Type == "TextOptions"  then
					net.WriteString(v.Val or "")
				end
			end
		net.Send(Player)
	end
end)
