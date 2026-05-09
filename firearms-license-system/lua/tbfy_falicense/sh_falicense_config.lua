

--[[
You can now setup a finish position for practical tests
Practical test should no longer require a restart to update new set ones
Added turkish language (Thanks to Wolflix https://steamcommunity.com/id/Wolflix/)
Fixed issue with hooks

Config changes:
]]

--IF YOU WANNA REMOVE THE DEFAULT JOB, REMOVE THIS FOLDER: addons\firearmslicensesystem\lua\darkrp_modules
--IF YOU WANNA REMOVE THE COMPUTER FROM BEING PURCHASEABLE REMOVE THIS FOLDER: addons\tbfy_shared_v2\lua\darkrp_modules

TBFY_FAConfig = TBFY_FAConfig or {}
FALICENSE_PLAYERDB = FALICENSE_PLAYERDB or {}
FALICENSE_DATABASE = FALICENSE_DATABASE or {}

--Contact me on SF for help to translate
--Languages available:
--[[
english
french
slovak
turkish
]]
TBFY_FAConfig.LanguageToUse = "english"
//Who can access admin commands,menus etc
TBFY_FAConfig.AdminAccessCustomCheck = function(Player) return Player:IsAdmin() end
//Should SteamID be displayed on license?
TBFY_FAConfig.DisplaySteamID = true
//Should job be displayed on license?
TBFY_FAConfig.DisplayJob = true

TBFY_FAConfig.NPCData = {
["fa_application_npc"] = {Text = "Firearms License Applications", Model = "models/alyx.mdl", TextFont = "fa_npc_text", TextRotationSpeed = 80, TextColor = Color(255,255,255,255), TextBackgroundColor = Color(0,0,0,255)},
["fa_practicaltest_npc"] = {Text = "Practical Firearms Test", Model = "models/alyx.mdl", TextFont = "fa_npc_text", TextRotationSpeed = 80, TextColor = Color(255,255,255,255), TextBackgroundColor = Color(0,0,0,255)},
}

TBFY_FAConfig.AdminChatCommands = {"!famanage", "!famenu"}
//Chat commands to open the application examine menu
TBFY_FAConfig.ApplicationExamineChatCommands = {"!licenseapps", "!examinefa", "!gunlicenses"}
TBFY_FAConfig.InstructorChatCommands = {"!fains", "!fainsmenu"}
//What types instructors are allowed to grant/revoke
TBFY_FAConfig.InstructorPermission = {
["Theory"] = false,
["Practical"] = true,
["Carry"] = true,
["Sell"] = false,
}
//Set this to false if you only want license restrictions on those you add in the WeaponDB config
TBFY_FAConfig.ShouldRestrictDefault = false
//The default license you require for every weapon unless specified different in the WeaponDB config
TBFY_FAConfig.DefaultRestrictLicense = 1
--[[
1 = No Restrictions
2 = Notifies that you require license to wield it
3 = Can't pickup weapon
]]
TBFY_FAConfig.WeaponRestrictionType = 3
//Insert weapons here to set specific licenses required
//[WEAPON CLASS] = LicenseID Required,
TBFY_FAConfig.WeaponDB = {
["weapon_deagle2"] = 1,
["weapon_glock2"] = 1,
["weapon_pumpshotgun2"] = 2,
["weapon_ak472"] = 4,
["weapon_m42"] = 4,
}

hook.Add("tbfy_InitSetup", "FA_RegisterLicenses", function()
timer.Simple(1, function()
	local License = {
		Name = "A", -- Name
		Desc = "License for Pistols and revolvers.", -- Description
		Image = "fa_pistol.png", -- Image path
		TheoryTest = "fa_theory", --You can customize the test or add new ones in the language file
		TheoryCost = 500, -- Theory cost
		TheoryTime = 600, -- Time to do theory
		TheoryQuestionAmount = 10, --How many questions? (It will not allow more than the total amount available)
		TheoryCorrectRequired = 0, --How many is required to correctly answer to pass?
		PracticalCost = 500, -- Cost for practical test
		PracticalTime = 60, -- Time for practical test
		PracticalWeapon = "weapon_deagle2", -- Weapon granted during test
		PracticalAmmoAmount = 15, -- Ammo granted for the test
	}
	FA_RegisterLicense(License)

	local License = {
		Name = "B",
		Desc = "License for shotguns.",
		Image = "fa_shotgun.png",
		TheoryTest = "fa_theory",
		TheoryCost = 500,
		TheoryTime = 600,
		TheoryQuestionAmount = 10,
		TheoryCorrectRequired = 8,
		PracticalCost = 500,
		PracticalTime = 60,
		PracticalWeapon = "weapon_pumpshotgun2",
		PracticalAmmoAmount = 10,
	}
	FA_RegisterLicense(License)

	local License = {
		Name = "C",
		Desc = "License for SMGs.",
		Image = "fa_smg.png",
		TheoryTest = "fa_theory",
		TheoryCost = 500,
		TheoryTime = 600,
		TheoryQuestionAmount = 10,
		TheoryCorrectRequired = 8,
		PracticalCost = 500,
		PracticalTime = 60,
		PracticalWeapon = "weapon_mp52",
		PracticalAmmoAmount = 60,
	}
	FA_RegisterLicense(License)

	local License = {
		Name = "D",
		Desc = "License for assault rifles.",
		Image = "fa_assault_rifle.png",
		TheoryTest = "fa_theory",
		TheoryCost = 500,
		TheoryTime = 600,
		TheoryQuestionAmount = 10,
		TheoryCorrectRequired = 8,
		PracticalCost = 500,
		PracticalTime = 90,
		PracticalWeapon = "weapon_ak472",
		PracticalAmmoAmount = 120,
	}
	FA_RegisterLicense(License)

	local License = {
		Name = "E",
		Desc = "License for sniper rifles.",
		Image = "fa_sniper.png",
		TheoryTest = "fa_theory",
		TheoryCost = 500,
		TheoryTime = 600,
		TheoryQuestionAmount = 10,
		TheoryCorrectRequired = 8,
		PracticalCost = 500,
		PracticalTime = 60,
		PracticalWeapon = "ls_sniper",
		PracticalAmmoAmount = 10,
	}
	FA_RegisterLicense(License)
end)
end)

local function FA_InitJobConfigs()
//Make sure teams are created before creating config
timer.Simple(3, function()
//Weapons that doesn't require licenses for certain jobs/all jobs
//Useful to allow weapons on certain jobs without licenses
TBFY_FAConfig.WeaponWhitelist = {
["firearms_license"] = true, --Allows all jobs to use it
["gmod_tool"] = true,
["keys"] = true,
["pocket"] = true,
["driving_license"] = true,
["weapon_physcannon"] = true,
["gmod_camera"] = true,
["weapon_physgun"] = true,
["collections_bag"] = true,
["driving_license_checker"] = true,
["fine_list"] = true,
["weapon_r_handcuffs"] = true,
["door_ram"] = true,
["med_kit"] = true,
["stunstick"] = true,
["arrest_stick"] = true,
["unarrest_stick"] = true,
["weapon_r_restrained"] = true,
["tbfy_surrendered"] = true,
["weapon_r_cuffed"] = true,
["weaponchecker"] = true,
["weapon_keypadchecker"] = true,

["weapon_glock2"] = { --If it's for specific jobs it has to be a table
[TEAM_POLICE] = true, -- Allows Police officers to wear glock without license
[TEAM_GUN] = true, -- Allows Gun dealers to wear glock without license
},
["weapon_deagle2"] = { --If it's for specific jobs it has to be a table
[TEAM_CHIEF] = true, -- Allows Chief of police to wear deagle without license
},

}
end)
end

hook.Add("DarkRPFinishedLoading", "FA_InitJobConfigs", function()
    if DCONFIG then
        hook.Add("DConfigDataLoaded", "FA_InitJobConfigs", FA_InitJobConfigs)
    elseif ezJobs then
        hook.Add("ezJobsLoaded", "FA_InitJobConfigs", FA_InitJobConfigs)
    else
        hook.Add("loadCustomDarkRPItems", "FA_InitJobConfigs", FA_InitJobConfigs)
    end
end)
