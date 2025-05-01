TBFY_SH.Configs = TBFY_SH.Configs or {}

function TBFY_SH:SetupConfig(AName, ID, Desc, Type, Default, UpdateC)
	TBFY_SH.Configs[AName] = TBFY_SH.Configs[AName] or {}
	TBFY_SH.Configs[AName][ID] = {Desc = Desc, Type = Type, Default = Default, UpdateC = UpdateC}
end

function TBFY_SH:FetchConfig(AName, ID)
	local AConf = TBFY_SH.Configs[AName]
	if AConf then
		local Conf = AConf[ID]
		local Val = Conf and Conf.Val
		if Val == nil then
			local NotLoaded = CLIENT and !AConf.Loaded
			local loadCode = 0
			if NotLoaded then
				loadCode = -1
			end
			if Conf.Type == "Number" or Conf.Type == "TextOptions" then
				return Conf.Default.Val, loadCode
			else
				return Conf.Default, loadCode
			end
		else
			return Val, 1
		end
	end
	return 0, -1
end
