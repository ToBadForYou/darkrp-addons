
resource.AddWorkshop("1524991866")

util.AddNetworkString("res_open_application")
util.AddNetworkString("res_edit_podium")
util.AddNetworkString("res_save_settings_podium")
util.AddNetworkString("res_edit_poster")
util.AddNetworkString("res_save_settings_poster")
util.AddNetworkString("res_signup_election")
util.AddNetworkString("res_resign_election")
util.AddNetworkString("res_printer")
util.AddNetworkString("res_request_print")
util.AddNetworkString("res_update_print")
util.AddNetworkString("res_SendPosterInfo")
util.AddNetworkString("res_removeposter")
util.AddNetworkString("res_update_phase")
util.AddNetworkString("res_open_ballotmenu")
util.AddNetworkString("res_ballot_candidate")
util.AddNetworkString("res_update_candidate")
util.AddNetworkString("res_remove_candidate")
util.AddNetworkString("res_update_votes")
util.AddNetworkString("res_poster_options")
util.AddNetworkString("res_pickup_poster")
util.AddNetworkString("res_delete_poster")
util.AddNetworkString("res_startpoll")
util.AddNetworkString("res_update_poll")

local PLAYER = FindMetaTable("Player")
local RES_Conf = RES_Config
RES_CandidatesInfo = RES_CandidatesInfo or {}
RES_PhaseTimer = RES_PhaseTimer or 0

local UID = 76561197989708503
function PLAYER:RES_PlacePoster(Pos, Ang)
	local PostInfo = self.RES_Posters[1]

	if PostInfo then
		local Poster = ents.Create("res_campaign_poster")
		Poster:SetPos(Pos)
		Poster:SetAngles(Ang)
		Poster:Spawn()
		if !Poster:IsInWorld() then
			Poster:Remove()
			TBFY_Notify(self, 1, 4, RES_GetLang("PositionBlocked"))
			return
		end
		Poster.PosterPlaced = true
		Poster:GetPhysicsObject():EnableMotion(false)
		Poster:SetupPValuesInput(self, PostInfo.N, PostInfo.T, PostInfo.DT, PostInfo.BG, PostInfo.DTC)

		self.RES_Posters[1] = nil

		if table.Count(self.RES_Posters) < 1 then
			self:StripWeapon("res_poster")
		end
		self.RES_Posters = table.ClearKeys(self.RES_Posters)

		net.Start("res_removeposter")
		net.Send(self)
	end
end

function PLAYER:RES_GivePoster(PName, PText, DType, BGC, DC)
	if !self:HasWeapon("res_poster") then
		self:Give("res_poster")
	end

	self.RES_Posters = self.RES_Posters or {}
	self.RES_Posters = table.ClearKeys(self.RES_Posters)
	local Index = table.Count(self.RES_Posters)+1
	self.RES_Posters[Index] = {N = PName, T = PText, DT = DType, BG = BGC, DTC = DC}

	net.Start("res_SendPosterInfo")
		net.WriteString(PName)
		net.WriteString(PText)
		net.WriteFloat(DType)
		net.WriteVector(BGC)
		net.WriteVector(DC)
	net.Send(self)
end

function RES_UpdatePhase(Phase,Time)
	if UID then
		RES_Phase = Phase
		RES_PhaseTimer = Time

		net.Start("res_update_phase")
			net.WriteFloat(Phase)
			net.WriteFloat(Time)
		net.Broadcast()
	end
end

function RES_DepositVote(Ballot)
	local VoteFor = Ballot.SelectedID
	local Owner = Ballot:GetEOwner()

	local VoterSID = TBFY_SH:SID(Owner)
	if !RES_Voters[VoterSID] then
		RES_AddVote(VoteFor, Owner)
	else
		TBFY_Notify(activator, 1, 4, RES_GetLang("VotedBallotRemoved"))
	end

	Ballot:Remove()
end

function RES_AddVote(VoteFor, Voter, Poll)
	local VoterSID = TBFY_SH:SID(Voter)
	RES_Voters[VoterSID] = true

	local TotVotes
	if Poll then
		local PollTbl = RES_Polls[RES_CurrentPoll]
		if PollTbl then
			if PollTbl.Options[VoteFor] then
				RES_Polls[RES_CurrentPoll].Options[VoteFor].Votes = PollTbl.Options[VoteFor].Votes + 1
				TotVotes = RES_Polls[RES_CurrentPoll].Options[VoteFor].Votes
			end
		end
	elseif RES_Candidates[VoteFor] then
		RES_Candidates[VoteFor][VoterSID] = true
		Voter.VotedSID = VoteFor
		TotVotes = table.Count(RES_Candidates[VoteFor])
	end

	if TotVotes then
		net.Start("res_update_votes")
			net.WriteBool(Poll)
			if Poll then
				net.WriteFloat(RES_CurrentPoll)
				net.WriteFloat(VoteFor)
			else
				net.WriteString(VoteFor)
			end
			net.WriteFloat(TotVotes)
		net.Broadcast()
	end
end

function RES_DoubleWinners(SameAmount)
	for k,v in pairs(RES_Candidates) do
		if !SameAmount[k] then
			local Player = RES_CandidatesInfo[k].Player
			Player:changeTeam(RES_GetConf("JOBS_DefaultJob"), true, true)

			RES_Candidates[k] = nil
			RES_CandidatesInfo[k] = nil

			net.Start("res_remove_candidate")
				net.WriteString(k)
			net.Broadcast()
		end
	end

	for k,v in pairs(ents.FindByClass("res_ballot")) do
		v:Remove()
	end

	for k,v in pairs(player.GetAll()) do
		TBFY_Notify(v, 1, 4, RES_GetLang("DoubleWinner"))
	end

	RES_StartVotingPeriod()
end

function RES_CalculateResults()
	local Winner = nil
	local WinningVotes = 0
	local SameAmount = {}
	for k,v in pairs(RES_Candidates) do
		if table.Count(v) > WinningVotes then
			WinningVotes = table.Count(v)
			Winner = k
		elseif table.Count(v) == WinningVotes then
			if Winner then
				SameAmount[k] = table.Count(v)
				SameAmount[Winner] = WinningVotes
			elseif !Winner then
				WinningVotes = table.Count(v)
				Winner = k
			end
		end
	end

	for k,v in pairs(SameAmount) do
		if v < WinningVotes then
			SameAmount[k] = nil
		end
	end

	if table.Count(SameAmount) <= 1 then
		return Winner, WinningVotes, false
	else
		return Winner, WinningVotes, SameAmount
	end
end

function RES_FinishElection()
	RES_UpdatePhase(0,0)

	for k,v in pairs(ents.FindByClass("res_ballot")) do
		v:Remove()
	end

	local MostVotes, VoteAmount, DoubleWinners = RES_CalculateResults()
	if DoubleWinners then
		RES_DoubleWinners(DoubleWinners)
		return
	end

	local AllPlayers = player.GetAll()
	local Winner = nil
	for k,v in pairs(AllPlayers) do
		local SID = TBFY_SH:SID(v)
		if RES_Candidates[SID] then
			if SID == MostVotes then
				Winner = v
				v:changeTeam(RES_GetConf("JOBS_ElectionJob"), true, true)
			else
				v:changeTeam(RES_GetConf("JOBS_DefaultJob"), true, true)
			end
		end
	end

	for k,v in pairs(AllPlayers) do
		TBFY_Notify(v, 1, 4, string.format(RES_GetLang("WinnerSelected"), Winner:Nick(), VoteAmount))
	end

	RES_Candidates = {}
	RES_CandidatesInfo = {}
	RES_Polls = {}
	RES_CurrentPoll = nil

	net.Start("res_update_candidate")
		net.WriteBool(true)
	net.Broadcast()

	net.Start("res_startpoll")
		net.WriteFloat(0)
	net.Broadcast()

	if timer.Exists("RES_PollPeriod") then
		timer.Remove("RES_PollPeriod")
	end

	for k,v in pairs(ents.FindByClass("res_campaign_poster")) do
		v:Remove()
	end
end

function RES_AttemptRemoveFromElection(Player, Args)
	if Player:RESAdminAccess() or Player:CanKickFromElection() then
		if !Args then return "" end
		local SplitString = string.Split(Args, " ")

		local Nick = string.lower(SplitString[1]);
		local PFound = false
		for k, v in pairs(player.GetAll()) do
			if (string.find(string.lower(v:Nick()), Nick)) then
				PFound = v;
				break;
			end
		end

		RES_RemoveFromElection(TBFY_SH:SID(PFound), PFound)
		TBFY_Notify(Player, 1, 4, string.format(RES_GetLang("RemovedFromElection"),PFound:Nick()))
	end
	return ""
end

net.Receive("res_resign_election", function(len, Player)
	if Player:IsPCandidate() then
		RES_RemoveFromElection(TBFY_SH:SID(Player), Player)
		TBFY_SH:SendMessage(Player, "Election", RES_GetLang("Resigned"))
	end
end)

function RES_RemoveFromElection(SID, Player, NoJobSwitch)
	if RES_Candidates[SID] then
		RES_Candidates[SID] = nil
		RES_CandidatesInfo[SID] = nil

		net.Start("res_remove_candidate")
			net.WriteString(SID)
		net.Broadcast()

		if IsValid(Player) and !NoJobSwitch then
			Player:changeTeam(RES_GetConf("JOBS_DefaultJob"), true, true)
		end

		for k,v in pairs(ents.FindByClass("res_campaign_poster")) do
			if v:GetEOwner() == Player then
				v:Remove()
			end
		end

		if RES_GetPhase() != 0 and RES_GetCandiatesNum() <= 0 then
			RES_CancelElection()
		end
	end
end

function RES_CancelElection()
	RES_UpdatePhase(0,0)

	for k,v in pairs(ents.FindByClass("res_ballot")) do
		v:Remove()
	end

	if RES_IsCampaignPhase() then
		timer.Destroy("RES_CampaignPeriod")
	elseif RES_IsVotePhase() then
		timer.Destroy("RES_VotingPeriod")
	end

	RES_Candidates = {}
	RES_CandidatesInfo = {}
	RES_Polls = {}
	RES_CurrentPoll = nil

	net.Start("res_update_candidate")
		net.WriteBool(true)
	net.Broadcast()

	net.Start("res_startpoll")
		net.WriteFloat(0)
	net.Broadcast()

	if timer.Exists("RES_PollPeriod") then
		timer.Remove("RES_PollPeriod")
	end

	for k,v in pairs(ents.FindByClass("res_campaign_poster")) do
		v:Remove()
	end

	for k,v in pairs(player.GetAll()) do
		TBFY_Notify(v, 1, 4, RES_GetLang("ElectionCanceled"))
	end
end

function RES_StartVotingPeriod()
	local Timer = RES_GetConf("ELECTION_VotePeriod") * 60
	RES_UpdatePhase(2,CurTime()+Timer)
	RES_Voters = {}
	timer.Create("RES_VotingPeriod", Timer, 1, RES_FinishElection)

	for k,v in pairs(player.GetAll()) do
		TBFY_Notify(v, 1, 4, RES_GetLang("VoteStarted2"))
		TBFY_Notify(v, 1, 4, RES_GetLang("VoteStarted"))
	end
end

function RES_StartElection()
	local Timer = RES_GetConf("ELECTION_CampaignPeriod") * 60
	RES_UpdatePhase(1,CurTime()+Timer)
	timer.Create("RES_CampaignPeriod", Timer, 1, RES_StartVotingPeriod)

	for k,v in pairs(player.GetAll()) do
		TBFY_Notify(v, 1, 4, RES_GetLang("CampaignStarted2"))
		TBFY_Notify(v, 1, 4, RES_GetLang("CampaignStarted"))
	end
end

function RES_UpdateElectionStatus()
	local CReq = RES_GetConf("ELECTION_CandidatesRequired")
	if RES_GetCandiatesNum() >= CReq then
		RES_StartElection()
	end
end

function PLAYER:SignUpForElection(Initials, Colors, Slogan, Agenda)
	local SID = TBFY_SH:SID(self)

	RES_Candidates = RES_Candidates or {}
	RES_Candidates[SID] = {}
	RES_CandidatesInfo[SID] = {Player = self, Initials = Initials, Colors = Colors, Slogan = Slogan, Agenda = Agenda}
	self:changeTeam(RES_GetConf("JOBS_CandidateJob"), true, true)

	net.Start("res_update_candidate")
		net.WriteBool(false)
		net.WriteString(SID)
		net.WriteEntity(self)
		net.WriteString(Initials)
		net.WriteFloat(Colors[1])
		net.WriteFloat(Colors[2])
		net.WriteFloat(Colors[3])
		net.WriteString(Slogan)
		net.WriteString(Agenda)
	net.Broadcast()

	RES_UpdateElectionStatus()

	TBFY_SH:SendMessage(self, RES_GetLang("Election"), RES_GetLang("Signedup"))
end

function PLAYER:RES_HasVoted()
	return RES_Voters[TBFY_SH:SID(self)]
end

net.Receive("res_signup_election", function(len, Player)
	if RES_Phase != 0 then return end
	if !RES_NoElectionJob() then return end
	if Player:IsPCandidate() then
		TBFY_SH:SendMessage(Player, RES_GetLang("Election"), RES_GetLang("AlreadyPCandidate"))
		return
	end

	local MaxCand, CurCand = RES_GetConf("ELECTION_MaxCandidates"), RES_GetCandiatesNum()
	if CurCand < MaxCand then
		local Initials, r,g,b, Slogan, Agenda = net.ReadString(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadString(), net.ReadString()
		Player:SignUpForElection(Initials, {r,g,b}, Slogan, Agenda)
	else
		TBFY_SH:SendMessage(Player, RES_GetLang("Election"), RES_GetLang("NoSignUp"))
	end
end)

net.Receive("res_save_settings_podium", function(len, Player)
	local Podium = Player.LastPodium
	if IsValid(Podium) and (Podium:GetEOwner() == Player or (!IsValid(Podium:GetEOwner()) and Player:RESAdminAccess())) then
		local N, S, D, BGr, BGg, BGb, Dr, Dg, Db = net.ReadString(), net.ReadString(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat()

		Podium:SetPName(N)
		Podium:SetSlogan(S)
		Podium:SetDType(D)
		Podium:SetBackGColor(Vector(BGr, BGg, BGb))
		Podium:SetDecalColor(Vector(Dr, Dg, Db))
	end
end)

net.Receive("res_save_settings_poster", function(len, Player)
	local Poster = Player.LastPoster
	if IsValid(Poster) and Poster:GetEOwner() == Player then
		local N, Text, D, BGr, BGg, BGb, Dr, Dg, Db = net.ReadString(), net.ReadString(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat()

		Poster:SetPName(N)
		Poster:SetPText(Text)
		Poster:SetDType(D)
		Poster:SetBackGColor(Vector(BGr, BGg, BGb))
		Poster:SetDecalColor(Vector(Dr, Dg, Db))
	end
end)

net.Receive("res_request_print", function(len, Player)
	local Printer = Player.LastPPrinter
	if IsValid(Printer) then
		Printer:AttemptPrintPoster(Player)
	end
end)

net.Receive("res_ballot_candidate", function(len, Player)
	local Candidate = net.ReadString()
	local Ballot = Player.Ballot
	if IsValid(Ballot) then
		Ballot.SelectedID = Candidate

		local VoteStand = Ballot.VoteStand
		if IsValid(VoteStand) then
			VoteStand.Ballot = nil
		end
		Ballot.VoteStand = nil
		Ballot:GetPhysicsObject():EnableMotion(true)
	end
end)

net.Receive("res_pickup_poster", function(len, Player)
	local Poster = Player.RES_LastPosterE
	if IsValid(Poster) and Poster:GetEOwner() == Player then
		Player:RES_GivePoster(Poster:GetPName(),Poster:GetPText(),Poster:GetDType(),Poster:GetBackGColor(),Poster:GetDecalColor())
		Poster:Remove()
	end
end)

net.Receive("res_delete_poster", function(len, Player)
	local Poster = Player.RES_LastPosterE
	if IsValid(Poster) and Poster:GetEOwner() == Player then
		Poster:Remove()
	end
end)

local PhysgunWH = {
	["res_campaign_poster_table"] = true,
	["res_podium"] = true,
	["res_printer"] = true
}
hook.Add("playerBoughtCustomEntity", "res_assign_entsowner", function(Player, EntTbl, Ent)
	if IsValid(Ent) and PhysgunWH[Ent:GetClass()] then
		Ent:SetEOwner(Player)
	end
end)

hook.Add("PhysgunPickup", "res_allow_physgun", function(Player, Ent)
	if Ent.RESPEnt and Ent:GetEOwner() == Player and PhysgunWH[Ent:GetClass()] then
		return true
	end
end)

hook.Add("OnPlayerChangedTeam", "res_OnChangeJob", function(Player, OldT, NewT)
	if OldT == RES_GetConf("JOBS_CandidateJob") then
		RES_RemoveFromElection(TBFY_SH:SID(Player), Player, true)
	end
end)

local TGBlacklist = {"res_votingstand", "res_votingbooth","res_application_npc","res_votestats","res_ballottable"}
hook.Add("CanTool", "RES_DisableRemovingEntsTool", function(Player, trace, tool)
	local ent = trace.Entity
	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:RESAdminAccess() then
			return false
		end
	end
end)

hook.Add("CanProperty", "RES_DisableRemovingEntsProperty", function(Player, stringproperty, ent)
	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:RESAdminAccess() then
			return false
		end
	end
end)

hook.Add("canPocket", "RES_RestrictPocketing", function(Player, Ent)
    if table.HasValue(TGBlacklist, Ent:GetClass()) then
	    return false, "You can't put that in your pocket!"
	end
end)

hook.Add("playerArrested", "RES_playerArrested", function(Player)
	if RES_GetConf("ELECTION_RemoveOnArrest") then
		RES_RemoveFromElection(TBFY_SH:SID(Player), Player)
	end
end)

hook.Add("PlayerDeath", "RES_PlayerDeath", function(Player)
	if RES_GetConf("ELECTION_RemoveOnDeath") then
		RES_RemoveFromElection(TBFY_SH:SID(Player), Player)
	end
end)

hook.Add("PlayerInitialSpawn", "RES_InitialSpawn", function(Player)
	net.Start("res_update_phase")
		net.WriteFloat(RES_Phase)
		net.WriteFloat(RES_PhaseTimer)
	net.Send(Player)

	for k,v in pairs(RES_CandidatesInfo) do
		net.Start("res_update_candidate")
			net.WriteBool(false)
			net.WriteString(k)
			net.WriteEntity(v.Player)
			net.WriteString(v.Initials)
			net.WriteFloat(v.Colors[1])
			net.WriteFloat(v.Colors[2])
			net.WriteFloat(v.Colors[3])
		net.Send(Player)

		local AmountVotes = table.Count(RES_Candidates[k])
		net.Start("res_update_votes")
			net.WriteBool(false)
			net.WriteString(k)
			net.WriteFloat(AmountVotes)
		net.Send(Player)
	end

	if RES_CurrentPoll then
		local CurrPoll = RES_Polls[RES_CurrentPoll]
		if CurrPoll then
			net.Start("res_startpoll")
				net.WriteFloat(RES_CurrentPoll)
				net.WriteString(CurrPoll.Question)
				net.WriteFloat(table.Count(CurrPoll.Options))
				for k,v in pairs(CurrPoll.Options) do
					net.WriteFloat(k)
					net.WriteString(v.Option)
				end
			net.Send(Player)
		end
	end
end)

hook.Add("PlayerDisconnected", "RES_PlayerDisconnected", function(Player)
	RES_RemoveFromElection(TBFY_SH:SID(Player), Player, true)
end)

function RES_FinishPoll()
	RES_Voters = {}
	RES_CurrentPoll = nil

	net.Start("res_update_poll")
	net.Broadcast()

	for k,v in pairs(player.GetAll()) do
		TBFY_Notify(v, 1, 4, RES_GetLang("PollEnded"))
	end
end

function RES_StartPoll(Question, Options)
	local NextID = table.Count(RES_Polls) + 1

	RES_Voters = {}
	RES_Polls[NextID] = {Question = Question, Options = Options}
	RES_CurrentPoll = NextID

	net.Start("res_startpoll")
		net.WriteFloat(NextID)
		net.WriteString(Question)
		net.WriteFloat(table.Count(Options))
		for k,v in pairs(Options) do
			net.WriteFloat(k)
			net.WriteString(v.Option)
		end
	net.Broadcast()

	local Timer = RES_GetConf("ELECTION_PollTime") * 60
	timer.Create("RES_PollPeriod", Timer, 1, RES_FinishPoll)

	for k,v in pairs(player.GetAll()) do
		TBFY_Notify(v, 1, 4, RES_GetLang("PollStarted"))
	end
end

function TBFY_SH:RESElectionSoftware(Player, SoftID)
	local Type = net.ReadString()
	if Type == "Vote" or Type == "PollVote" then
		local PSID = TBFY_SH:SID(Player)
		if !RES_Voters[PSID] then
			if Type == "PollVote" then
				local VoteFor = net.ReadFloat()
				RES_AddVote(VoteFor, Player, true)
			else
				local VoteFor = net.ReadString()
				RES_AddVote(VoteFor, Player)
			end
			TBFY_SH:SendMessage(Player, RES_GetLang("Election"), RES_GetLang("VoteSuccessful"))
		else
			TBFY_SH:SendMessage(Player, "", RES_GetLang("AlreadyVoted"))
		end
	elseif Type == "StartPoll" then
		if !RES_IsCampaignPhase() or !Player:IsPCandidate() or RES_CurrentPoll then return end
		local Question, OptionsAmount = net.ReadString(), net.ReadFloat()
		local Options = {}
		for i = 1, OptionsAmount do
			local AnswerOption = net.ReadString()
			Options[i] = {Option = AnswerOption, Votes = 0}
		end

		RES_StartPoll(Question, Options)
		TBFY_SH:SendMessage(Player, RES_GetLang("Poll"), RES_GetLang("PollStarted"))
	end
end
