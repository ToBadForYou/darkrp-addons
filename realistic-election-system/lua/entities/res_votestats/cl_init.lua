include('shared.lua')

function ENT:Initialize ()
end

surface.CreateFont("res_stats_boardhead", {
	size = 100,
	weight = 500,
	antialias = false,
	shadow = false,
	font = "arial"
})

surface.CreateFont("res_stats_board_candidates", {
	size = 65,
	weight = 100,
	antialias = false,
	shadow = false,
	font = "arial"
})

surface.CreateFont("res_stats_boardsub", {
	size = 45,
	weight = 100,
	antialias = false,
	shadow = false,
	font = "arial"
})

surface.CreateFont("res_board_initials", {
	size = 25,
	weight = 100,
	antialias = false,
	shadow = false,
	font = "arial"
})

function ENT:Draw()
	self:DrawModel()

	local W,H = 1890, 940
	local MaxCandidates = RES_GetConf("ELECTION_MaxCandidates")
	local TotPlayers = table.Count(player.GetAll())
	local TotVotes = 0
	local PerVotes = ((H*0.75)/TotPlayers)*-1
	local Candidates = RES_Candidates

	local pos = self:GetPos();
	local ang = self:GetAngles();
	pos = pos + self.Entity:GetUp()*1.57 + self.Entity:GetForward()*-47 + self.Entity:GetRight()*94.5
	ang:RotateAroundAxis(ang:Up(), 90);

	local Hs = H*0.9
	local TotW = (W-50)/MaxCandidates
	local TotH = (H-160)/MaxCandidates
	if RES_IsVotePhase() then
		cam.Start3D2D( pos, ang, .1);
			draw.RoundedBox(8, 0, 0, W, H, Color(230,230,230,255))
			draw.SimpleText(RES_GetLang("CurrentVotes"), 'res_stats_boardhead', W/2,10, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			surface.SetDrawColor(0,0,0,255)
			surface.DrawLine(0,Hs,W,Hs)

			local WStart = 25
			for k,v in pairs(Candidates) do
				local Padding = TotW*0.3
				local BarSize = TotW*0.7
				surface.SetDrawColor(v.Colors[1],v.Colors[2],v.Colors[3],255)
				draw.SimpleText(v.Initials, 'res_board_initials', WStart+BarSize/2,Hs+5, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				surface.DrawRect(WStart, Hs, BarSize, PerVotes*v.Votes)
				TotVotes = TotVotes + v.Votes
				WStart = WStart + TotW
			end

			local VotePercent = math.Round((TotVotes/TotPlayers)*100)
			VotePercent = VotePercent .. "%"
			draw.SimpleText(RES_GetLang("TotalVotes") .. TotVotes, 'res_stats_boardsub', 10,10, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(string.format(RES_GetLang("VoterTurnout"), VotePercent), 'res_stats_boardsub', 10,50, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		cam.End3D2D();
	elseif RES_IsCampaignPhase() then
		cam.Start3D2D( pos, ang, .1);
			draw.RoundedBox(8, 0, 0, W, H, Color(230,230,230,255))
			if RES_CurrentPoll then
				local CurrPoll = RES_Polls[RES_CurrentPoll]
				draw.SimpleText(CurrPoll.Question, 'res_stats_boardhead', W/2,10, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

				surface.SetDrawColor(0,0,0,255)
				surface.DrawLine(0,Hs,W,Hs)

				local WStart = 25
				for k,v in pairs(CurrPoll.Options) do
					local Padding = TotW*0.3
					local BarSize = TotW*0.7
					surface.SetDrawColor(0,0,0,255)
					local splitResults = TBFY_cutLength(v.Option, TotW-10, "res_comp_diagram_poll")
					for i, text in pairs(splitResults) do
						draw.SimpleText(text, 'res_board_initials', WStart+BarSize/2,Hs+((i-1)*10), Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					end

					surface.DrawRect(WStart, Hs, BarSize, PerVotes*v.Votes)
					TotVotes = TotVotes + v.Votes
					WStart = WStart + TotW
				end

				local VotePercent = math.Round((TotVotes/TotPlayers)*100)
				VotePercent = VotePercent .. "%"
				draw.SimpleText(RES_GetLang("TotalVotes") .. TotVotes, 'res_stats_boardsub', 10,10, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.SimpleText(string.format(RES_GetLang("VoterTurnout"), VotePercent), 'res_stats_boardsub', 10,50, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			else
				draw.SimpleText(RES_GetLang("NoPoll"), 'res_stats_boardhead', W/2,H/2, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		cam.End3D2D();
	elseif !RES_NoElectionJob() then
		cam.Start3D2D(pos, ang, .1);
			draw.RoundedBox(8, 0, 0, W, H, Color(230,230,230,255))
			draw.SimpleText(RES_GetLang("NoElection"), 'res_stats_boardhead', W/2,H/2, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D();
	else
		local CandAmount = RES_GetCandiatesNum()
		local CandPerLine = 10
		local RowsReq = CandAmount/CandPerLine
		cam.Start3D2D(pos, ang, .1);
			draw.RoundedBox(8, 0, 0, W, H, Color(230,230,230,255))
			draw.SimpleText(RES_GetLang("CurrentCandidates"), 'res_stats_boardhead', W/2,10, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			local WToCalc = W/2
			local RowType = 1
			if RowsReq > 1 then
				WToCalc = W/3
				RowType = 2
			end
			local Num, Row, HStart = 0, 1, 150
			for k,v in pairs(Candidates) do
				local Player = v.Player
				if IsValid(Player) then
					draw.SimpleText(Player:Nick(), 'res_stats_board_candidates', WToCalc*Row,HStart+80*Num, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					if RowType == 1 then
						Num = Num + 1
					else
						if Row == 1 then
							Row = 2
						else
							Row = 1
							Num = Num + 1
						end
					end
				end
			end
		cam.End3D2D();
	end
end

function ENT:OnRemove( )
end
