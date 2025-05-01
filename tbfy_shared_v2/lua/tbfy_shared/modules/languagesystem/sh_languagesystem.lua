TBFY_SH.Languages = TBFY_SH.Languages or {}

function TBFY_SH:RegisterLanguage(Addon)
	TBFY_SH.Languages[Addon] = TBFY_SH.Languages[Addon] or {}
	TBFY_SH.CurLangAddon = Addon
end

function TBFY_SH:AddLanguage(ID, Text)
	local Addon = TBFY_SH.CurLangAddon
	TBFY_SH.Languages[Addon][ID] = Text
end

function TBFY_SH:GetLanguage(Addon, ID)
	local Lang = TBFY_SH.Languages[Addon]
	if Lang and Lang[ID] then
		return Lang[ID]
	else
		return ""
	end
end

local CatName = "TBFY Shared"
local MFolder = "tbfy_shared"

TBFY_SH:RegisterLanguage(MFolder)
local Language = TBFY_SH.Config.LanguageToUse
include("tbfy_shared/language/" .. Language .. ".lua");
if SERVER then
	AddCSLuaFile("tbfy_shared/language/" .. Language .. ".lua");
end

function TBFY_GetLang(ID)
	return TBFY_SH:GetLanguage(MFolder, ID)
end
