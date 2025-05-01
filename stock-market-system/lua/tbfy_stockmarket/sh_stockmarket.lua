
local PLAYER = FindMetaTable("Player")

local CatName = "Stock Market"
local CatID = "stockmarket"

TBFY_SH:RegisterLanguage(CatID)
local Language = TBFY_STOCKMConfig.LanguageToUse
include("tbfy_stockmarket/language/" .. Language .. ".lua");
if SERVER then
	AddCSLuaFile("tbfy_stockmarket/language/" .. Language .. ".lua");
end

function StockM_GetLang(ID)
	return TBFY_SH:GetLanguage(CatID, ID)
end

function StockM_GetConf(ID)
	return TBFY_SH:FetchConfig(CatID, ID)
end

function PLAYER:StockM_AdminAccess()
	return TBFY_STOCKMConfig.AdminAccessCustomCheck(self)
end

function PLAYER:StockM_CanAfford(Amount)
	return self:canAfford(Amount)
end

function PLAYER:StockM_CanTrade()
	return !StockM_GetConf("STOCK_RestrictToJob") or StockM_GetConf("STOCK_TraderJobs")[self:Team()]
end

function StockM_DecompileStocks(CompiledString, Player)
 	local StocksCompiled = string.Explode(";", CompiledString);

	for k, v in pairs(StocksCompiled) do
		local SplitIDPT = string.Explode(",", v);
		if #SplitIDPT > 1 then
			Player.TBFY_Stocks[tonumber(SplitIDPT[1])] = tonumber(SplitIDPT[2])
		end
	end
end

hook.Add("tbfy_InitSetup", "stockm_InitSetup", function()
	local ESaveInfo = {
		["stocks_display1"] = {Class = "tbfy_stocks_display_1", Folder = "stocksdisplay1", Cond = function(Ent) return true end, ModelS = "models/hunter/plates/plate1x8.mdl", OffSet = Vector(-10,0,0), AngAdj = Angle(-90, 180, 0), NameS = "Stock Display 1", SaveS = "Save Stock Display 1", SavedS = "Saved Stock Display 1"},
		["stocks_display2"] = {Class = "tbfy_stocks_display_2", Folder = "stocksdisplay2", Cond = function(Ent) return true end, ModelS = "models/hunter/plates/plate3x3.mdl", OffSet = Vector(-10,0,0), AngAdj = Angle(-90, 180, 0), NameS = "Stock Display 2", SaveS = "Save Stock Display 2", SavedS = "Saved Stock Display 2"},
	}

	TBFY_SH:SetupConfig(CatID, "STOCK_MaxStocks", "Maximum amount of stocks you can buy/own", "Number", {Val = 500, Decimals = 0, Max = 1000, Min = 10}, true)
	TBFY_SH:SetupConfig(CatID, "STOCK_RestrictToJob", "Restrict stock trading to specific jobs", "Bool", false, false)
	TBFY_SH:SetupConfig(CatID, "STOCK_TraderJobs", "The trader job, if STOCK_RestrictToJob is enabled", "Jobs", {}, true)

	local Software = {
		ID = "StockM",
		Name = "Stock Market",
		Desc = "Used to trade stocks.",
		Default = false,
		GovPC = false,
		Downloadable = true,
		UI = "stockm_comp_stocks",
		Icon = Material("tobadforyou/stockm_comp_stockmarket.png"),
		W = 500,
		H = 540,
		Children = nil,
		AEnts = nil
	}
	TBFY_SH:RegisterCSoftware(Software)

	if SERVER then
		TBFY_SH:LoadConfigs(CatID)
		TBFY_SH:SetupAddonInfo(CatID, TBFY_STOCKMConfig.AdminAccessCustomCheck, ESaveInfo)
	else
		TBFY_SH:RequestConfig(CatID)
		TBFY_SH:SetupCategory(CatName)
		TBFY_SH:SetupCMDButton(CatName, "Configs", nil, function() local Configs = vgui.Create("tbfy_edit_config") Configs:SetConfigs(CatID, CatName) end)

		for k,v in pairs(ESaveInfo) do
			TBFY_SH:SetupEntity(CatName, v.NameS, v.Class, v.ModelS, v.OffSet, v.SEnts, v.NoGEnt, v.AngAdj)
			if !v.NoSave then
				TBFY_SH:SetupCMDButton(CatName, v.SaveS, "save_tbfy_ent " .. CatID .. " " .. k)
			end
		end
	end
end)
