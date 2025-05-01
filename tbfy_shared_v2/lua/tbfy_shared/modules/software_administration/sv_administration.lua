
local lastLockdown = 0
function TBFY_SH:DKRP_Lockdown(Player)
	local Lockdown = GetGlobalBool("DarkRP_LockDown")
	if Lockdown then
		TBFY_SH:SendMessage(Player, "",  "Successfully ended lockdown.")
		DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_ended"))
		DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_ended"))
		SetGlobalBool("DarkRP_LockDown", false)
		return ""
	else
		if lastLockdown > CurTime() - GAMEMODE.Config.lockdowndelay then
				--show(DarkRP.getPhrase("wait_with_that"))
				TBFY_SH:SendMessage(Player, "",  "A lockdown can be initiated again in: " .. math.Round(lastLockdown - CurTime() + GAMEMODE.Config.lockdowndelay) .. " seconds.")
				return ""
		end

		for _, v in pairs(player.GetAll()) do
        v:ConCommand("play " .. GAMEMODE.Config.lockdownsound .. "\n")
    end

    DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_started"))
    SetGlobalBool("DarkRP_LockDown", true)
    DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_started"))
	end
	lastLockdown = CurTime()
	TBFY_SH:SendMessage(Player, "",  "Successfully initiated lockdown.")
end

local LotteryPeople = {}
local LotteryAmount = 0
local function EnterLottery(answer, ent, initiator, target, TimeIsUp)
    if tobool(answer) and not table.HasValue(LotteryPeople, target) then
        if not target:canAfford(LotteryAmount) then
            DarkRP.notify(target, 1,4, DarkRP.getPhrase("cant_afford", "lottery"))

            return
        end
        table.insert(LotteryPeople, target)
        target:addMoney(-LotteryAmount)
        DarkRP.notify(target, 0,4, DarkRP.getPhrase("lottery_entered", DarkRP.formatMoney(LotteryAmount)))
        hook.Run("playerEnteredLottery", target)
    elseif IsValid(target) and answer ~= nil and not table.HasValue(LotteryPeople, target) then
        DarkRP.notify(target, 1,4, DarkRP.getPhrase("lottery_not_entered", "You"))
    end

    if TimeIsUp then
        for i = #LotteryPeople, 1, -1 do
            if not IsValid(LotteryPeople[i]) then table.remove(LotteryPeople, i) end
        end

        if table.Count(LotteryPeople) == 0 then
            DarkRP.notifyAll(1, 4, DarkRP.getPhrase("lottery_noone_entered"))
            hook.Run("lotteryEnded", LotteryPeople, nil)
            return
        end
        local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
        hook.Run("lotteryEnded", LotteryPeople, chosen, #LotteryPeople * LotteryAmount)
        chosen:addMoney(#LotteryPeople * LotteryAmount)
        DarkRP.notifyAll(0, 10, DarkRP.getPhrase("lottery_won", chosen:Nick(), DarkRP.formatMoney(#LotteryPeople * LotteryAmount)))
    end
end

function TBFY_SH:DKRP_Lottery(Player)
	local amount = net.ReadFloat()
	if not GAMEMODE.Config.lottery then
			DarkRP.notify(Player, 1, 4, DarkRP.getPhrase("disabled", "/lottery", ""))
			return ""
	end

	if #player.GetAll() <= 2 or TBFY_SH.LotteryON then
			DarkRP.notify(Player, 1, 6, DarkRP.getPhrase("unable", "/lottery", ""))
			return ""
	end

	if (TBFY_SH.LastLottery or 0) > CurTime() then
			DarkRP.notify(Player, 1, 5, DarkRP.getPhrase("have_to_wait", tostring(TBFY_SH.LastLottery - CurTime()), "/lottery"))
			return ""
	end

	amount = tonumber(amount)
	if not amount then
			DarkRP.notify(Player, 1, 5, string.format("Please specify an entry cost ($%i-%i)", GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost))
			return ""
	end

	LotteryAmount = math.Clamp(math.floor(amount), GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost)

	hook.Run("lotteryStarted", Player, LotteryAmount)

	LotteryPeople = {}
	for k,v in pairs(player.GetAll()) do
			if v ~= Player then
					DarkRP.createQuestion(DarkRP.getPhrase("lottery_has_started", DarkRP.formatMoney(LotteryAmount)), "lottery" .. tostring(k), v, 30, EnterLottery, Player, v)
			end
	end
	timer.Create("Lottery", 30, 1, function() EnterLottery(nil, nil, nil, nil, true) end)
end

function TBFY_SH:DKRP_Warrant(Player)
	local WPlayer, Reason = net.ReadEntity(), net.ReadString()
	if IsValid(WPlayer) then
		local IsWarranted = WPlayer.warranted
		if IsWarranted then
			WPlayer:unWarrant(Player)
		else
			WPlayer:warrant(Player, Reason)
		end
	end
end

function TBFY_SH:DKRP_Wanted(Player)
	local WPlayer, Reason = net.ReadEntity(), net.ReadString()
	if IsValid(WPlayer) then
		local IsWanted = WPlayer:isWanted()
		if IsWanted then
			WPlayer:unWanted(Player)
		else
			WPlayer:wanted(Player, Reason)
		end
	end
end

function TBFY_SH:DKRP_Gunlicense(Player)
	local WPlayer = net.ReadEntity()
	if IsValid(WPlayer) then
		local HasLicense = WPlayer:getDarkRPVar("HasGunlicense")
		if HasLicense then
			TBFY_Notify(WPlayer, 0, 4, "Your gun license was revoked.")
			WPlayer:setDarkRPVar("HasGunlicense", nil)
		else
			TBFY_Notify(WPlayer, 0, 4, "You were granted a gun license.")
			WPlayer:setDarkRPVar("HasGunlicense", true)
		end
	end
end

function TBFY_SH:AdminSoftware(Player, SoftID)
	local Type = net.ReadString()
	if Type == "Action" then
		local ID = net.ReadFloat()
		local Func = TBFY_SH.CompAdmin.Actions[ID].Func
		TBFY_SH[Func](self, Player, SoftID)
	else
		local Idf = net.ReadString()
		local Func = TBFY_SH.CompAdmin.Functions[Idf].Func
		TBFY_SH[Func](self, Player, SoftID)
	end
end
