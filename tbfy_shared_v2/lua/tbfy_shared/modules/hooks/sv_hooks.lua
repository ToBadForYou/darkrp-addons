
hook.Add("Initialize", "tbfysh_init", function()
	file.CreateDir("tbfy_configs")

	if !sql.TableExists("tbfy_computer") then
		sql.Query("CREATE TABLE tbfy_computer (steamid varchar(255), username varchar(255), password varchar(255), programs varchar(255), data varchar(255))")
	end
	if !sql.TableExists("tbfy_archives") then
		sql.Query("CREATE TABLE tbfy_archives (steamid varchar(255), type int, actor varchar(255), reason varchar(255), time bigint)")
	end
	if !sql.TableExists("tbfy_theory") then
		sql.Query("CREATE TABLE tbfy_theory (steamid varchar(255), theory varchar(255))")
	end
end)

hook.Add("PlayerInitialSpawn", "tbfy_initalspawn", function(Player)
	if TBFY_SH.Outdated then
		if Player:IsAdmin() then
			TBFY_SH:SendMessage(Player, "", TBFY_GetLang("OutdatedTBFY"))
		end
	end
	Player.TBFY_UsedPCs = {}

	TBFY_SH:LoadCAccount(Player)
	TBFY_SH:LoadGArchives(Player)
	TBFY_SH:LoadTheory(Player)
end)

hook.Add("PlayerDisconnected", "tbfy_playerdisconnect", function(Player)
	local SID = TBFY_SH:SID(Player)
	for k,v in pairs(Player.TBFY_UsedPCs) do
		if IsValid(v) then
			v.UsedAccounts[SID] = nil
			if v.LoggedIn == SID and v.CPlayer != Player then
				TBFY_SH:FalkOS_Logout(v)
				TBFY_SH:SendMessage(v.CPlayer, TBFY_GetLang("UserDisconnectedLogout"), "LOGGED OUT")
			end
		end
	end

	net.Start("tbfy_ClearPEquip")
		net.WriteString(SID)
	net.Broadcast()
end)

hook.Add("playerWanted", "tbfy_garchive_wanted", function(Player, Actor, Reason)
	local WNick = "None"
	if IsValid(Actor) then
		WNick = Actor:Nick()
	end
	TBFY_SH:AddToGArchive(1, TBFY_SH:SID(Player), WNick, Reason, Time)
end)

hook.Add("playerWarranted", "tbfy_garchive_warrant", function(Player, Actor, Reason)
	local WNick = "None"
	if IsValid(Actor) then
		WNick = Actor:Nick()
	end
	TBFY_SH:AddToGArchive(2, TBFY_SH:SID(Player), WNick, Reason, Time)
end)

hook.Add("playerArrested", "tbfy_garchive_arrested", function(Player, Time, Actor)
	if !RHandcuffsConfig then
		local ANick = "None"
		if IsValid(Actor) then
			ANick = Actor:Nick()
		end
		TBFY_SH:AddToGArchive(3, TBFY_SH:SID(Player), ANick, "", Time)
	end
end)

hook.Add("RHC_jailed", "tbfy_garchive_rhcjailed", function(Player, Actor, ATime, Reason)
	local ANick = "None"
	if IsValid(Actor) then
		ANick = Actor:Nick()
	end
	TBFY_SH:AddToGArchive(3, TBFY_SH:SID(Player), ANick, Reason, Time)
end)

hook.Add("PostCleanupMap", "tbfy_respawnents", function()
	for k,v in pairs(TBFY_SH.AInfo) do
		TBFY_SH:RespawnAddonEntities(k)
	end
end)

hook.Add("playerBoughtCustomEntity", "tbfy_BuyCEnt", function(Player, EntTbl, Ent)
	if Ent:GetClass() == "tbfy_computer" then
		Ent:InitPSpawn(Player)
	end
end)

hook.Add("CanPlayerEnterVehicle", "tbfy_CanEnterV", function(Player, Vehicle)
	if Vehicle.PCChair then
		if !Player.CanEChairPC then
			return false
		end
	end
end)

hook.Add("PlayerLeaveVehicle", "tbfy_ExitV", function(Player, Vehicle)
	if Vehicle.PCChair then
		TBFY_SH:ExitPC(Player, Vehicle)
	end
end)

hook.Add("lotteryStarted", "tbfy_lotterystarted", function()
	TBFY_SH.LotteryON = true
end)

hook.Add("lotteryEnded", "tbfy_lotteryended", function()
	TBFY_SH.LotteryON = false
	TBFY_SH.LastLottery = CurTime() + 60
end)

hook.Add("playerWarranted", "tbfy_warranted", function(Player)
	Player:setDarkRPVar("warrant", true)
end)

hook.Add("playerUnWarranted", "tbfy_unwarranted", function(Player)
	Player:setDarkRPVar("warrant", nil)
end)
