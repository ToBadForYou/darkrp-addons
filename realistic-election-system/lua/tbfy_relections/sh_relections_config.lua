RES_Config = RES_Config or {}
RES_Phase = RES_Phase or 0

--[[
Should now properly remove posters
Fixed (possibly) error in regards to voting display
Added italian langauge (Thanks to Blaster Alpha: https://steamcommunity.com/profiles/76561198141142594)
Added turkish language (Thanks to Wolflix https://steamcommunity.com/id/Wolflix/)
]]

--IF YOU WANNA REMOVE THE DEFAULT JOB, REMOVE THIS FOLDER: addons\realisticelectionsystem\lua\darkrp_modules
--IF YOU WANNA REMOVE THE COMPUTER FROM BEING PURCHASEABLE REMOVE THIS FOLDER: addons\tbfy_shared_v2\lua\darkrp_modules

--Contact me on gmodstore if you want to help with translations
--Languages available:
--[[
english
french
italian
turkish
]]
RES_Config.LanguageToUse = "english"

//Who can access admin commands etc
RES_Config.AdminAccessCustomCheck = function(Player) return Player:IsSuperAdmin() end
//NOTE: These uses DarkRPs chatcommand system, which means it will always use / before the command so by default it would be -> /removecandidate NICK
//Chatcommand to remove a candidate from the election
RES_Config.RemoveFromElectionChatCommands = {"removecandidate", "kickcandidate"}

RES_Config.NPCData = {
["res_application_npc"] = {Text = "Political Applications", Model = "models/alyx.mdl", TextFont = "res_npc_text", TextRotationSpeed = 80, TextColor = Color(255,255,255,255), TextBackgroundColor = Color(0,0,0,255)},
}

//Max posters allowed to place
RES_Config.MaxCampaignPosters = 5

RES_Config.PodiumDecals = {
[1] = {Name = "Anarchy", Mat = Material("tbfy/podium/pod_anarchy.png")},
[2] = {Name = "Arrows", Mat = Material("tbfy/podium/pod_arrow.png")},
[3] = {Name = "Christian", Mat = Material("tbfy/podium/pod_christ.png")},
[4] = {Name = "Hammer and Sickle", Mat = Material("tbfy/podium/pod_cum.png")},
[5] = {Name = "Enviromental", Mat = Material("tbfy/podium/pod_env.png")},
[6] = {Name = "Fist", Mat = Material("tbfy/podium/pod_fist.png")},
[7] = {Name = "Islam", Mat = Material("tbfy/podium/pod_islam.png")},
[8] = {Name = "Peace", Mat = Material("tbfy/podium/pod_peace.png")},
[9] = {Name = "Hippie", Mat = Material("tbfy/podium/pod_piss.png")},
[10] = {Name = "Inverted Pentagram", Mat = Material("tbfy/podium/pod_satan.png")},
[11] = {Name = "Stars", Mat = Material("tbfy/podium/pod_star.png")},
}

RES_Config.PosterDecals = {
[1] = {Name = "Anarchy", Mat = Material("tbfy/posters/post_anarchy.png")},
[2] = {Name = "Arrows", Mat = Material("tbfy/posters/post_arrow.png")},
[3] = {Name = "Christian", Mat = Material("tbfy/posters/post_christ.png")},
[4] = {Name = "Hammer and Sickle", Mat = Material("tbfy/posters/post_cum.png")},
[5] = {Name = "Enviromental", Mat = Material("tbfy/posters/post_env.png")},
[6] = {Name = "Fist", Mat = Material("tbfy/posters/post_fist.png")},
[7] = {Name = "Islam", Mat = Material("tbfy/posters/post_islam.png")},
[8] = {Name = "Peace", Mat = Material("tbfy/posters/post_peace.png")},
[9] = {Name = "Hippie", Mat = Material("tbfy/posters/post_piss.png")},
[10] = {Name = "Inverted Pentagram", Mat = Material("tbfy/posters/post_satan.png")},
[11] = {Name = "Stars", Mat = Material("tbfy/posters/post_star.png")},
}

local function RES_InitJobs()
timer.Simple(3, function()
DarkRP.createEntity("Podium", {
    ent = "res_podium",
    model = "models/alec/atom_smasher/alec_trump_podium_01b.mdl",
    price = 300,
    max = 2,
    cmd = "buypodium",
	allowed = {RES_GetConf("JOBS_CandidateJob")},
})
DarkRP.createEntity("Poster Table", {
    ent = "res_campaign_poster_table",
    model = "models/props/CS_militia/table_shed.mdl",
    price = 500,
    max = 1,
    cmd = "buypostertable",
	allowed = {RES_GetConf("JOBS_CandidateJob")},
})
DarkRP.createEntity("Poster Printer", {
    ent = "res_printer",
    model = "models/pcmod/kopierer.mdl",
    price = 500,
    max = 1,
    cmd = "buyresprinter",
	allowed = {RES_GetConf("JOBS_CandidateJob")},
})

//For those who are too lazy to restrict their jobs
RPExtraTeams[RES_GetConf("JOBS_ElectionJob")].customCheck = function(Player) return false end
end)
end

hook.Add("DarkRPFinishedLoading", "RES_InitJobs", function()
    if DCONFIG then
		hook.Add("DConfigDataLoaded", "RES_InitJobs", RES_InitJobs)
	elseif ezJobs then
        hook.Add("ezJobsLoaded", "RES_InitJobs", RES_InitJobs)
    else
        hook.Add("loadCustomDarkRPItems", "RES_InitJobs", RES_InitJobs)
    end
end)
