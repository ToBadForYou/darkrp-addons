
local PLAYER = FindMetaTable("Player")
local FA_Config = TBFY_FAConfig

local CatName = "Firearms License"
local CatID = "firearmslicense"

TBFY_SH:RegisterLanguage(CatID)
local Language = FA_Config.LanguageToUse
include("tbfy_falicense/language/" .. Language .. ".lua");
if SERVER then
	AddCSLuaFile("tbfy_falicense/language/" .. Language .. ".lua");
end

function FA_GetLang(ID)
	return TBFY_SH:GetLanguage(CatID, ID)
end

function FA_GetConf(ID)
	return TBFY_SH:FetchConfig(CatID, ID)
end

function PLAYER:FA_AdminAccess()
	return FA_Config.AdminAccessCustomCheck(self)
end

function PLAYER:FA_InstructorAccess()
	if (self:FA_IsInstructor() or !FA_GetConf("INSTRUCTOR_InstructorWhitelist")) and (!FA_GetConf("INSTRUCTOR_InstructorRestrictToJob") or (FA_GetConf("INSTRUCTOR_InstructorRestrictToJob") and self:Team() == FA_GetConf("INSTRUCTOR_InstructorJob"))) then
		return true
	else
		return false
	end
end

function FA_CheckInsAccess(ToCheck)
	return FA_Config.InstructorPermission[ToCheck]
end

function PLAYER:FA_ExamineMenuAccess()
	return FA_GetConf("APPLICATION_AllowedJobs")[self:Team()]
end

function FA_RegisterLicense(Tbl)
	local ID = #FALICENSE_DATABASE + 1
	FALICENSE_DATABASE[ID] = Tbl
	TBFY_SH:AddTheoryTestItem(Tbl.TheoryTest, {ID = ID, Name = Tbl.Name, Cost = Tbl.TheoryCost, Time = Tbl.TheoryTime, Image = Tbl.Image, Desc = Tbl.Desc, QAmount = Tbl.TheoryQuestionAmount, QRequired = Tbl.TheoryCorrectRequired})
	if SERVER then
		FA_TheoryIDs = FA_TheoryIDs or {}
		FA_TheoryIDs[Tbl.TheoryTest] = true
	end
end

function PLAYER:FA_IsInstructor()
	if !FA_Instructors then return false end
	return FA_Instructors[TBFY_SH:SID(self)]
end

function PLAYER:FAPassedPractical(LID)
	if !FALICENSE_PLAYERDB or !FALICENSE_PLAYERDB[TBFY_SH:SID(self)] then return false end

	local License = FALICENSE_PLAYERDB[TBFY_SH:SID(self)][LID]
	if !License then return false end
	local Value = License.Practical
	return tobool(Value)
end

function PLAYER:FACanCarry(LID)
	if !FALICENSE_PLAYERDB or !FALICENSE_PLAYERDB[TBFY_SH:SID(self)] then return false end

	local License = FALICENSE_PLAYERDB[TBFY_SH:SID(self)][LID]
	if !License then return false end
	local Value = License.Carry
	return tobool(Value)
end

function PLAYER:FACanSell(LID)
	if !FALICENSE_PLAYERDB or !FALICENSE_PLAYERDB[TBFY_SH:SID(self)] then return false end

	local License = FALICENSE_PLAYERDB[TBFY_SH:SID(self)][LID]
	if !License then return false end
	local Value = License.Sell
	return tobool(Value)
end

function DecompileFALicenses(LString, SteamID)
	local PFALTbl = {}
	local Licenses = string.Explode(";", LString);
	FALICENSE_PLAYERDB[SteamID] = {}

	for k, v in pairs(Licenses) do
		if !v or v == "" then return end
		local LInfo = string.Explode(":", v);
		local ID = tonumber(LInfo[1])
		local Prac = tonumber(LInfo[2]) or 0
		local CanCarry = tonumber(LInfo[3]) or 0
		local CanSell = tonumber(LInfo[4]) or 0
		if ID then
			FALICENSE_PLAYERDB[SteamID][ID] = {Practical = Prac, Carry = CanCarry, Sell = CanSell}
		end
	end
end

hook.Add("StartCommand", "fa_freezeplayer", function(Player, cmd)
	if Player.FA_DoingPractical then
		cmd:ClearMovement()
	end
end)

hook.Add("tbfy_InitSetup", "FA_InitSetup", function()
	local NPCData = TBFY_FAConfig.NPCData
	local ESaveInfo = {
		["practical_npc"] = {Class = "fa_practicaltest_npc", Folder = "practical_npc", Cond = function(Ent) return true end, ModelS = NPCData["fa_practicaltest_npc"].Model, NameS = "Practical Test", SaveS = "Save Practical Test NPC", SavedS = "Saved Practical Test NPC"},
		["application_npc"] = {Class = "fa_application_npc", Folder = "application_npc", Cond = function(Ent) return true end, ModelS = NPCData["fa_application_npc"].Model, NameS = "Application", SaveS = "Save Application NPC", SavedS = "Saved Application NPC"},
	}

	TBFY_SH:SetupConfig(CatID, "LICENSE_GrantLicenseOnTheoryComplete", "Should the firearms license be granted upon theory completition?", "Bool", false, false)

	TBFY_SH:SetupConfig(CatID, "INSTRUCTOR_InstructorWhitelist", "Enable whitelist for instructors", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "INSTRUCTOR_InstructorRestrictToJob", "Restrict granting license to a specific job", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "INSTRUCTOR_InstructorJob", "The instructor job, if INSTRUCTOR_InstructorRestrictToJob enabled", "Job", nil, true)

	TBFY_SH:SetupConfig(CatID, "APPLICATION_AllowedJobs", "The jobs that are allowed to renew license applications", "Jobs", {}, true)

	local GArchive = {
		ID = 6,
		Name = "Firearms License",
		UI = "tbfy_archive_firearmslicense"
	}
	TBFY_SH:RegisterGArchive(GArchive)

	if SERVER then
		TBFY_SH:LoadConfigs(CatID)
		TBFY_SH:SetupAddonInfo(CatID, FA_Config.AdminAccessCustomCheck, ESaveInfo)
	else
		TBFY_SH:RequestConfig(CatID)
		TBFY_SH:SetupCategory(CatName)
		TBFY_SH:SetupCMDButton(CatName, "Configs", nil, function() local Configs = vgui.Create("tbfy_edit_config") Configs:SetConfigs(CatID, CatName) end)

		for k,v in pairs(ESaveInfo) do
			TBFY_SH:SetupEntity(CatName, v.NameS, v.Class, v.ModelS, v.OffSet, v.SEnts, v.NoGEnt)
			if !v.NoSave then
				TBFY_SH:SetupCMDButton(CatName, v.SaveS, "save_tbfy_ent " .. CatID .. " " .. k)
			end
		end
	end
end)
