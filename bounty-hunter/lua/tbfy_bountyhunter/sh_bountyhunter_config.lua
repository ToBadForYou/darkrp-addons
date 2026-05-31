
--[[
You can now set a maximum price for bounties
Moved close button X to buttom left on place bounty UI
Place bounty menu can be closed by pressing Q

Config changes:
Added .ManualMaximumBounty
]]
TBFY_BHConfig = TBFY_BHConfig or {}

//How much for each player the person has killed
TBFY_BHConfig.RewardForEachKill = 500
//Maximum reward the bounty can reach (excluded player amount placed)
TBFY_BHConfig.MaxBounty = 3000
//How many kills a person has to kill before he becomes hunted
TBFY_BHConfig.KillsRequired = 3
//Cooldown between bounties on players (Player can't get a bounty on his head until X seconds has passed)
TBFY_BHConfig.BountyCD = 300
//Cooldown for bounties on unique players
//For example, if I kill Player1 I can't start a bounty on Player1s head until after this cooldown is over
TBFY_BHConfig.PlayerCD = 3000
//How many players has to be on before system is activated?
TBFY_BHConfig.PlayersRequired = 0
//Should the bounty be canceled if the player is killed?
TBFY_BHConfig.RemoveBountyOnDeath = true
//Should the bounty be canceled if the bounty hunter is killed by the hunted?
TBFY_BHConfig.RemoveBountyOnBHDeath = false
//Should kills only reset if killed by a bounty hunter?
TBFY_BHConfig.ResetKillsBHOnly = false
//Reset players kills if arrested?
TBFY_BHConfig.ResetKillsOnArrest = false
//Should the player be notified when a bounty is placed on his head?
TBFY_BHConfig.NotifyHunted = true
//Should the sound play?
TBFY_BHConfig.PlayBountySound = true
//Play the sound for only bounty hunter job?
TBFY_BHConfig.OnlyBountyhunterSound = false
//If this is set to false anyone that isn't in the blacklist config can start a bounty
TBFY_BHConfig.JobBH = true
//If set to true, bounties will be posted on players who get wanted
TBFY_BHConfig.WantedBounty = true
//Bounty start amount if posted from wanted
TBFY_BHConfig.WantedBountyAmount = 500
//Should players be allowed to place bounties? true = Disable, false = allow
TBFY_BHConfig.DisableManualBounty = false
//Cooldown between manual placed bounties
TBFY_BHConfig.ManualBountyCD = 600
//The minimum amount you can place on bounties
TBFY_BHConfig.ManualMinimumBounty = 300
//The maximum amount you can place on bounties
TBFY_BHConfig.ManualMaximumBounty = 3000

local function BH_InitJobs()
	--[[
		CanPlaceBounty = If this job can place bounties
		CanReceiveBounty = If this job can have a bounty placed on their head
		CanBountyHunt = If this job can accept bounties
	]]
	TBFY_BHConfig.JobBlackList = {
		[TEAM_POLICE] = {CanPlaceBounty = false, CanReceiveBounty = false, CanBountyHunt = false},
	}
	//Which teams should be bounty hunters?
	TBFY_BHConfig.BountyJobs = {
		[TEAM_BH] = true,
	}
end

hook.Add("DarkRPFinishedLoading", "BH_InitJobs", function()
    if DCONFIG then
		hook.Add("DConfigDataLoaded", "BH_InitJobs", BH_InitJobs)
	elseif ezJobs then
        hook.Add("ezJobsLoaded", "BH_InitJobs", BH_InitJobs)
    else
        hook.Add("loadCustomDarkRPItems", "BH_InitJobs", BH_InitJobs)
    end
end)
