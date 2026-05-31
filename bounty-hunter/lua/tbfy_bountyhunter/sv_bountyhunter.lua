local PLAYER = FindMetaTable("Player")

util.AddNetworkString("SendBounty")
util.AddNetworkString("RemoveBountyMenu")
util.AddNetworkString("BountyFinished")
util.AddNetworkString("NewBountySound")
util.AddNetworkString("UpdateBountyMenu")
util.AddNetworkString("AddNewBountyPoster")
util.AddNetworkString("UpdateBountyPoster")
util.AddNetworkString("open_place_bounty_menu")
util.AddNetworkString("place_bounty_player")

resource.AddWorkshop("752909534")
resource.AddFile("materials/bountyframe.png")
resource.AddFile("materials/models/bountyboard.vtf")
resource.AddFile("materials/models/bountyboard.vmt")
resource.AddFile("sound/bountyfixed.mp3")

local BHConfig = TBFY_BHConfig

hook.Add("Initialize", "CreateBountyFolder", function()
	file.CreateDir("bountysystem")
	file.CreateDir("bountysystem/bountyboard")
end)

hook.Add("bLogs_FullyLoaded","BH_bLogsInit",function()
	if ((not GAS or not GAS.Logging) and bLogs) then
		local MODULE = bLogs:Module()

		MODULE.Category = "ToBadForYou"
		MODULE.Name     = "Bounty Hunter"
		MODULE.Colour   = Color(100,40,45)

		MODULE:Hook("BH_Claimbounty","bh_claimbounty",function(BH, Player, BountyA)
			local BPlayer, TPlayer = bLogs:FormatPlayer(BH), bLogs:FormatPlayer(Player)
			LogText = BPlayer .. " claimed a bounty of $" .. BountyA .. " on " .. TPlayer .. "'s head!",

			MODULE:Log(LogText)
		end)

		MODULE:Hook("BH_Startbounty","bh_startbounty",function(BH, Player)
			local BPlayer, TPlayer = bLogs:FormatPlayer(BH), bLogs:FormatPlayer(Player)
			LogText = BPlayer .. " started a bounty hunt on " .. TPlayer .. "s head.",

			MODULE:Log(LogText)
		end)

		bLogs:AddModule(MODULE)
	end
end)

concommand.Add("save_bountyboard", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	local BBTbl = {}
	for k,v in pairs(ents.FindByClass("bountyboard")) do
		local BBIns = {}
		BBIns.Pos = v:GetPos()
		BBIns.Angles = v:GetAngles()
		table.insert(BBTbl,BBIns)
	end

	local CurrentMap = string.lower(game.GetMap())
	file.Write("bountysystem/bountyboard/" .. CurrentMap .. ".txt", util.TableToJSON(BBTbl))

	TBFY_Notify(Player, 1, 4, "Successfully saved " .. #BBTbl .. " Bounty Boards.")
end)

function SpawnBountyBoards()
	local CurrentMap = string.lower(game.GetMap())

	local BBTbl = {}
	if file.Exists( "bountysystem/bountyboard/" .. CurrentMap .. ".txt" ,"DATA") then
		BBTbl = util.JSONToTable(file.Read( "bountysystem/bountyboard/" .. CurrentMap .. ".txt" ))
	end

	for k,v in pairs(BBTbl) do
		local BBEnt = ents.Create("bountyboard")
		BBEnt:SetPos(v.Pos)
		BBEnt:SetAngles(v.Angles)
		BBEnt:Spawn()
		BBEnt:SetMoveType(MOVETYPE_NONE)
	end
end
hook.Add("InitPostEntity", "BountyBoardSpawn", SpawnBountyBoards)

function BH_AnnounceBounty(Player)
	if BHConfig.PlayBountySound then
		net.Start("NewBountySound")
		if BHConfig.OnlyBountyhunterSound then
			for k, v in pairs(player.GetAll()) do
				if v:IsBountyHunter() then
					net.Send(v)
				end
			end
		else
			net.Broadcast()
		end
	end

	if BHConfig.NotifyHunted then
		TBFY_Notify(Player, 1, 4, "A bounty has been placed on your head.")
	end
end

function PLAYER:ResetBountyStats()
	self.Kills = 0
	self.ExtraBounty = 0
	self.WantedBounty = false

	if self.BountyPosted then
		self:CleanUpPosters()
	end

    local BountyHunter = self.HuntedBy
	if IsValid(BountyHunter) then
	   	BountyHunter.Bounty = false
		BountyHunter:CloseBountyMenu()
	end
end

function PLAYER:BH_ClaimBounty(Player)
	local Bounty = Player:CalculateBounty()
	self:addMoney(Bounty)
	self.Bounty = false
	Player.HuntedBy = false
	self:CloseBountyMenu()

	net.Start("BountyFinished")
		net.WriteString(self:Nick())
		net.WriteString(Player:Nick())
		net.WriteFloat(Bounty)
		net.Broadcast()
	DarkRP.log(self:Nick() .. " claimed a bounty of $" .. Bounty .. " on " .. Player:Nick() .. "'s head!", Color(255, 0, 255))
	hook.Call("bh_claimbounty", GAMEMODE, self, Player, Bounty)

	Player:ResetBountyStats()

	Player.BountyCD = CurTime() + BHConfig.BountyCD
	self.PBountyCD[Player:UniqueID()] = CurTime() + BHConfig.PlayerCD
end

function PLAYER:PlaceBountyP(Player, Amount)
	Player.MBountyCD = CurTime() + BHConfig.ManualBountyCD

	self.ExtraBounty = self.ExtraBounty+Amount

	local Bounty = self:CalculateBounty()
	local CurrentBH = self.HuntedBy
	if CurrentBH then
		CurrentBH:UpdateBounty()
	elseif !CurrentBH and self.BountyPosted then
		for k,v in pairs(ents.FindByClass("bountyboard")) do
		    local PosterEnt = v.Posters[self:UniqueID()]
			if IsValid(PosterEnt) then
			    PosterEnt:UpdateReward(Bounty)
			end
        end
	else
		self.BountyPosted = true
		for k,v in pairs(ents.FindByClass("bountyboard")) do
			v:AddBounty(self, self:Nick(), Bounty, Player)
		end
	end

	if BHConfig.NotifyHunted then
		TBFY_Notify(self, 1, 4, "A player has placed a bounty on your head.")
	end
	TBFY_Notify(Player, 1, 4, "You successfully placed a bounty on: " .. self:Nick() .. "s head!")
end

function PLAYER:UpdateBounty()
    local PersonB = self.Bounty
	local Bounty = PersonB:CalculateBounty()

	net.Start("UpdateBountyMenu")
		net.WriteFloat(PersonB.Kills)
		net.WriteFloat(Bounty)
	net.Send(self)
end

function PLAYER:CloseBountyMenu()
    net.Start("RemoveBountyMenu")
	net.Send(self)
end

function PLAYER:CalculateBounty()
    local TotalBounty = self.Kills*BHConfig.RewardForEachKill
	TotalBounty = math.Clamp(TotalBounty,0,BHConfig.MaxBounty)
	if BHConfig.WantedBounty and self.WantedBounty then
		TotalBounty = TotalBounty + BHConfig.WantedBountyAmount
	end
	TotalBounty = TotalBounty+self.ExtraBounty
    return TotalBounty
end

function PLAYER:CleanUpPosters()
	for k,v in pairs(ents.FindByClass("bountyboard")) do
		local Poster = v.Posters[self:UniqueID()]
		if IsValid(Poster) then
		    table.RemoveByValue(v.PosterPoses.Taken[Poster.IDs[1]], Poster.IDs[2])
			Poster:Remove()
		end
	end
	self.BountyPosted = false
end

net.Receive("place_bounty_player", function(len, Player)
	if BHConfig.DisableManualBounty then return end
	if Player.MBountyCD > CurTime() then
		local Diff = math.Round(Player.MBountyCD-CurTime())
		TBFY_Notify(Player, 1, 4, "You can't place another bounty for another: " .. Diff .. " seconds.")
		return false
	end

	local PHit, Amount = net.ReadEntity(), net.ReadFloat()
	if TBFY_BHConfig.ManualMinimumBounty > Amount || Amount > TBFY_BHConfig.ManualMaximumBounty then return end

	if Player:CanPlaceBounty() and IsValid(PHit) and PHit != Player and !PHit:IsBountyHunter() and PHit:CanReceiveBounty() then
		if Player:canAfford(Amount) then
			Player:addMoney(-Amount)
			PHit:PlaceBountyP(Player, Amount)
		end
	end
end)

hook.Add("PlayerDeath", "BountyHunterSystemDeath", function(Player, Inflictor, Attacker)
    if (!Player:IsPlayer() or !Attacker:IsPlayer() or Player == Attacker or BHConfig.PlayersRequired > #player.GetAll()) then return end

	if BHConfig.RemoveBountyOnDeath and Player.Bounty and Player != Attacker then
		Player:ResetBountyStats()

	    if !Attacker:IsBountyHunter() and Attacker.BountyCD < CurTime() and Attacker:CanReceiveBounty() then
	    	Attacker.Kills = Attacker.Kills + 1
        end
		return
	end

	if Attacker:CanBountyHunt() and Attacker.Bounty == Player then
		Attacker:BH_ClaimBounty(Player)
        return
	end

	local CurrentBH = Attacker.HuntedBy
	if BHConfig.RemoveBountyOnBHDeath and CurrentBH == Player then
		Player:ResetBountyStats()
	elseif CurrentBH and CurrentBH.Bounty == Attacker then
	    Attacker.Kills = Attacker.Kills + 1
		CurrentBH:UpdateBounty()
		return
	elseif !CurrentBH and Attacker.BountyPosted then
        Attacker.Kills = Attacker.Kills + 1
		local Bounty = Attacker:CalculateBounty()
		for k,v in pairs(ents.FindByClass("bountyboard")) do
		    local PosterEnt = v.Posters[Attacker:UniqueID()]
			if IsValid(PosterEnt) then
			    PosterEnt:UpdateReward(Bounty)
			end
        end
        return
	end

	if !Attacker:IsBountyHunter() and Attacker.BountyCD < CurTime() and Attacker:CanReceiveBounty() then
		if (BHConfig.JobBH and 1 > BH_GetBountyHunterAmount()) then return end
	    Attacker.Kills = Attacker.Kills + 1
	   	if Attacker.Kills >= BHConfig.KillsRequired and !Attacker.BountyPosted then
			BH_AnnounceBounty(Attacker)

			Attacker.BountyPosted = true

			local Bounty = Attacker:CalculateBounty()
			for k,v in pairs(ents.FindByClass("bountyboard")) do
			    v:AddBounty(Attacker, Attacker:Nick(), Bounty)
			end
		end
	end

	if !BHConfig.ResetKillsBHOnly then
		Player:ResetBountyStats()
	end
end)

hook.Add("PlayerDisconnected", "BountyDC", function(Player)
	Player:ResetBountyStats()
end)

hook.Add("playerArrested", "BountyHunterSystemArrest", function(Player, time, Arrester)
	if IsValid(Arrester) then
		if Arrester:CanBountyHunt() and Arrester.Bounty == Player then
			Arrester:BH_ClaimBounty(Player)
		elseif BHConfig.ResetKillsOnArrest and !Player:IsBountyHunter() then
			Player:ResetBountyStats()
		end
	end
end)

hook.Add("PlayerInitialSpawn", "BountyHunterSystemSpawn", function(Player)
	Player.Kills = 0
	Player.Bounty = false
	Player.HuntedBy = false
	Player.BountyPosted = false
	Player.BountyCD = 0
	Player.PBountyCD = {}
	Player.ExtraBounty = 0
	Player.MBountyCD = 0

	//Sync posters
	timer.Simple(10, function()
			for k,v in pairs(ents.FindByClass("bountyposter")) do
			    net.Start("AddNewBountyPoster")
					net.WriteEntity(v)
					local Name = ""
					if IsValid(v.Player) then
						Name = v.Player:Nick()
					end
					net.WriteString(Name)
					net.WriteFloat(v.Bounty)
				net.Send(Player)
			end
	end)
end)

hook.Add("OnPlayerChangedTeam", "BountyHunterSwitchTeam", function(Player, OldTeam, NewTeam)
	if TBFY_BHConfig.BountyJobs[OldTeam] then
	    local BountyP = Player.Bounty
		if BountyP then
		    BountyP.HuntedBy = false
		end
		Player.Bounty = false
		Player:CloseBountyMenu()
	end
end)

local TGBlacklist = {"bountyboard", "bountyposter"}
hook.Add("CanTool", "DisableRemovingBHEntsTool", function(Player, trace, tool)
    local ent = trace.Entity

	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:IsAdmin() then
			return false
		end
	end
end)

hook.Add("CanProperty", "DisableRemovingBHEntsProperty", function(Player, stringproperty, ent)
	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:IsAdmin() then
			return false
		end
	end
end)

hook.Add("playerWanted", "PostBountyonWated", function(Wanted, WantedBy, Reason)
    if BHConfig.WantedBounty and Wanted:CanReceiveBounty() then
	    if Wanted.BountyPosted then
			Wanted.WantedBounty = true
			local Bounty = Wanted:CalculateBounty()
			for k,v in pairs(ents.FindByClass("bountyboard")) do
				local PosterEnt = v.Posters[Wanted:UniqueID()]
				if IsValid(PosterEnt) then
					PosterEnt:UpdateReward(Bounty)
				end
			end
			return
		end

		BH_AnnounceBounty(Wanted)

		Wanted.BountyPosted = true
		Wanted.WantedBounty = true

		local Bounty = Wanted:CalculateBounty()
		for k,v in pairs(ents.FindByClass("bountyboard")) do
			v:AddBounty(Wanted, Wanted:Nick(), Bounty)
		end
	end
end)

hook.Add("PreCleanupMap", "RespawnBountyBoardAfterCleanup", function()
	BountyBoardInfoSave = {}
	for k,v in pairs(ents.FindByClass("bountyposter")) do
		BountyBoardInfoSave[k] = {v.Player, v.Bounty}
	end
end)

hook.Add("PostCleanupMap", "RespawnBountyBoardAfterCleanup", function()
	SpawnBountyBoards()

	for k,v in pairs(ents.FindByClass("bountyboard")) do
		for i, poster in pairs(BountyBoardInfoSave) do
			local Player = poster[1]
			if IsValid(Player) then
				v:AddBounty(Player, Player:Nick(), poster[2])
			end
		end
	end
	BountyBoardInfoSave = {}
end)
