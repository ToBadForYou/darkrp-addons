
local PLAYER = FindMetaTable("Player")
RES_Candidates = RES_Candidates or {}
RES_Polls = {}

local CatName = "Realistic Elections"
local CatID = "relections"

TBFY_SH:RegisterLanguage(CatID)
local Language = RES_Config.LanguageToUse
include("tbfy_relections/language/" .. Language .. ".lua");
if SERVER then
	AddCSLuaFile("tbfy_relections/language/" .. Language .. ".lua");
end

function RES_GetLang(ID)
	return TBFY_SH:GetLanguage(CatID, ID)
end

function RES_GetConf(ID)
	return TBFY_SH:FetchConfig(CatID, ID)
end

function PLAYER:RESAdminAccess()
	return RES_Config.AdminAccessCustomCheck(self)
end

function RES_GetCandiatesNum()
	return team.NumPlayers(RES_GetConf("JOBS_CandidateJob"))
end

function PLAYER:IsPCandidate()
	return self:Team() == RES_GetConf("JOBS_CandidateJob")
end

function PLAYER:CanKickFromElection()
	return RES_GetConf("JOBS_CanRemoveFromElection")[self:Team()]
end

function RES_IsWaitPhase()
	return RES_Phase == 0
end

function RES_IsCampaignPhase()
	return RES_Phase == 1
end

function RES_IsVotePhase()
	return RES_Phase == 2
end

function RES_GetPhase()
	return RES_Phase
end

function RES_NoElectionJob()
  local Amount = team.NumPlayers(RES_GetConf("JOBS_ElectionJob"))
	return Amount < 1
end

function PLAYER:GetCPostersAmount()
	local Amount = 0
	for k,v in pairs(ents.FindByClass("res_campaign_poster")) do
		Amount = Amount + 1
	end

	return Amount
end

hook.Add("loadCustomDarkRPItems", "res_initshared_postdarkrp", function()
	for k,v in pairs(RES_Config.RemoveFromElectionChatCommands) do
		if SERVER then
			DarkRP.defineChatCommand(v, RES_AttemptRemoveFromElection)
		end
		DarkRP.declareChatCommand{
			command = v,
			description = "Remove Player From Election",
			delay = 1,
		}
	end
end)

hook.Add("tbfy_InitSetup","RES_InitSetup",function()
	local NPCData = RES_Config.NPCData
	local ESaveInfo = {
		["res_application_npc"] = {Class = "res_application_npc", Folder = "application_npc", Cond = function(Ent) return true end, ModelS = NPCData["res_application_npc"].Model, NameS = "Application NPC", SaveS = "Save Application NPC", SavedS = "Saved Application NPC"},
		["res_ballottable"] = {Class = "res_ballottable", Folder = "ballottable", Cond = function(Ent) return true end, ModelS = "models/props/CS_militia/wood_table.mdl", NameS = "Ballot Table", SaveS = "Save Ballot Table", SavedS = "Saved Ballot Table"},
		["res_ballotinbox"] = {Class = "res_ballotinbox", Folder = "ballotinbox", Cond = function(Ent) return true end, ModelS = "models/props_street/mail_dropbox.mdl", NameS = "Ballot Inbox", SaveS = "Save Ballot Inbox", SavedS = "Saved Ballot Inbox"},
		["res_votingbooth"] = {Class = "res_votingbooth", Folder = "votingbooth", Cond = function(Ent) return true end, ModelS = "models/sterling/tbfy_votingbooth.mdl", NameS = "Voting Booth", SaveS = "Save Voting Booth", SavedS = "Saved Voting Booth"},
		["res_votestats"] = {Class = "res_votestats", Folder = "votestats", Cond = function(Ent) return true end, ModelS = "models/hunter/plates/plate2x4.mdl", NameS = "Vote Stats", SaveS = "Save Vote Stats", SavedS = "Saved Vote Stats"},
		["res_podium"] = {Class = "res_podium", Folder = "podium", Cond = function(Ent) return true end, ModelS = "models/alec/atom_smasher/alec_trump_podium_01b.mdl", NameS = "Podium", SaveS = "Save Podium", SavedS = "Saved Podium",
			LoadFunc = function(Data)
				local Podium = ents.Create("res_podium")
				Podium:SetPos(Data.Pos)
				Podium:SetAngles(Data.Angles)
				Podium:Spawn()
				Podium:SetPName(Data.PName)
				Podium:SetSlogan(Data.Slogan)
				Podium:SetDType(Data.DType)
				Podium:SetBackGColor(Data.BackGCol)
				Podium:SetDecalColor(Data.DecalCol)
			end,
			SaveFunc = function(Ent, Tbl)
				Tbl.PName = Ent:GetPName()
				Tbl.Slogan = Ent:GetSlogan()
				Tbl.DType = Ent:GetDType()
				Tbl.BackGCol = Ent:GetBackGColor()
				Tbl.DecalCol = Ent:GetDecalColor()
				return Tbl
			end
		},
	}

		local Software = {
			ID = "res_election",
			Name = "Election",
			Func = "RESElectionSoftware",
			Desc = "Used for eletronical voting.",
			Default = false,
			GovPC = false,
			Downloadable = true,
			UI = "res_computer_election",
			Icon = Material("tbfy/res_computer_election.png"),
			W = 600,
			H = 400,
			Children = nil,
			AEnts = nil
		}
		TBFY_SH:RegisterCSoftware(Software)

	TBFY_SH:SetupConfig(CatID, "ELECTION_MaxCandidates", "Maximum amount of candidates allowed", "Number", {Val = 6, Decimals = 0, Max = 15, Min = 2}, true)
	TBFY_SH:SetupConfig(CatID, "ELECTION_CandidatesRequired", "How many candidates required in order to start an election", "Number", {Val = 2, Decimals = 0, Max = 10, Min = 2}, false)
	TBFY_SH:SetupConfig(CatID, "ELECTION_CampaignPeriod", "How long the campaign phase should be (Set in minutes)", "Number", {Val = 10, Decimals = 0, Max = 300, Min = 1}, false)
	TBFY_SH:SetupConfig(CatID, "ELECTION_VotePeriod", "How long the voting phase should be (Set in minutes)", "Number", {Val = 5, Decimals = 0, Max = 120, Min = 1}, false)
	TBFY_SH:SetupConfig(CatID, "ELECTION_PollTime", "How long should each poll last? (Set in minutes)", "Number", {Val = 5, Decimals = 0, Max = 300, Min = 1}, false)
	TBFY_SH:SetupConfig(CatID, "ELECTION_RemoveOnDeath", "Should candidates be removed from election upon death?", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "ELECTION_RemoveOnArrest", "Should candidates be removed from election upon arrest?", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "ELECTION_MaxPosters", "Maximum amount of posters allowed", "Number", {Val = 5, Decimals = 0, Max = 10, Min = 0}, false)
	TBFY_SH:SetupConfig(CatID, "ELECTION_MaxPollOptions", "Maximum amount of poll options allowed", "Number", {Val = 4, Decimals = 0, Max = 10, Min = 0}, true)

	TBFY_SH:SetupConfig(CatID, "JOBS_CandidateJob", "The job used for candidates", "Job", 1, true)
	TBFY_SH:SetupConfig(CatID, "JOBS_DefaultJob", "The job set to players who were candidates but did not win the election", "Job", 1, false)
	TBFY_SH:SetupConfig(CatID, "JOBS_ElectionJob", "The job set to the player who has won the election", "Job", 1, true)
	TBFY_SH:SetupConfig(CatID, "JOBS_CanRemoveFromElection", "The jobs that are allowed to remove candidates from election", "Jobs", {}, false)

	if SERVER then
		TBFY_SH:LoadConfigs(CatID)
		TBFY_SH:SetupAddonInfo(CatID, RES_Config.AdminAccessCustomCheck, ESaveInfo)
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

		TBFY_SH:SetupCustomFunctionThink(CatName, "res_ballottable", function(SWEP)
			local Player = SWEP.Owner
			local PTrace = Player:GetEyeTrace()
			local GEnt = SWEP.GhostEnt

			if IsValid(GEnt) then
				GEnt:SetPos(PTrace.HitPos)
				local Ang = Player:GetAngles()
				GEnt:SetAngles(Angle(0,Ang.y-90,0))
			end
		end)

		TBFY_SH:SetupCustomFunctionThink(CatName, "res_votestats", function(SWEP)
			local Player = SWEP.Owner
			local PTrace = Player:GetEyeTrace()
			local GEnt = SWEP.GhostEnt

			if IsValid(GEnt) then
				GEnt:SetPos(PTrace.HitPos+Vector(0,0,47.5))
				local Ang = Player:GetAngles()
				GEnt:SetAngles(Angle(90,Ang.y,180))
			end
		end)
	end
end)
