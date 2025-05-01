
--[[
You can now disable permanent weapons
You can now remove spawned entities with property menu (Hold down C, rightclick entity and then remove)

Config changes:
Added .EnableWeapons
]]

PermItemsConfig = PermItemsConfig or {}

//Chatcommands to open the menu
PermItemsConfig.MenuChatCommands = {"!permweapons","!permentities","!permmenu"}

//Who can access admin commands etc
PermItemsConfig.AdminAccessCustomCheck = function(Player) return Player:IsSuperAdmin() end

--[[

"darkrpwallet" = DarkRP cash
"ps1" = Pointshop 1
"pcurrency" = Inbuilt currency system

]]
PermItemsConfig.Currency = "pcurrency"
PermItemsConfig.CurrencyName = "Cash"
//Used for $,�,� for example
PermItemsConfig.CurrencySymbol = "$"
//NPC model
PermItemsConfig.NPCModel = "models/player/Group01/Female_01.mdl"
//Text above NPC
PermItemsConfig.NPCText = "Permanent Weapons/Entities"

//If chatcommand should be allowed or not
PermItemsConfig.AllowMenuCMD = true

//Allow selling of weapons/Entities
PermItemsConfig.AllowSelling = true
//How much % of the original price should be given when sold?
PermItemsConfig.SellRate = .50

//Disable perm entities
PermItemsConfig.EnableEntities = true
//Disable perm weapons
PermItemsConfig.EnableWeapons = true
//Grants weapons on spawn/change team etc if set to true, set to false if you want spawned only through menu
PermItemsConfig.GrantLoadout = true
//Make it return false for the conditions that shouldnt allow opening it and true for those who should
//For example, this allows only admins to open the menu
--[[
if Player:IsAdmin() then
    return true
else
    return false
end
]]
PermItemsConfig.OpenMenuCheck = function(Player) return true end
//Font for the menus
PermItemsConfig.Font = "Trebuchet18"

//For changing colors on the menus
PermItemsConfig.FrameColor = Color(200,200,200,200)
PermItemsConfig.FrameOutline = Color(0,0,0,255)
PermItemsConfig.HeaderColor = Color(50,50,50,200)
PermItemsConfig.ColorBoxes = Color(150,150,150,200)
PermItemsConfig.ColorBoxesOutlines = Color(50,50,50,200)
PermItemsConfig.ButtonColor = Color(0,0,0,200)
PermItemsConfig.ButtonColorHovering = Color(75,75,75,200)
PermItemsConfig.ButtonColorPressed = Color(125,125,125,200)

--{Category Name, {Ent Class, Description, Cost, Model, Name},}
--NOTE: ONLY ADD MODEL AND NAME if it requires overriding, for example if SWEP uses base name+model
--An example of a weapon that requires the model+name to be overridden
--{"weapon_vape", "A classic vape", 300, "models/swamponions/vape.mdl", "Vape"},
PermItemsConfig.WeaponsList = {
[1] = {"Assault Rifles", {
	[1] = {"weapon_ak472", "A powerful beast.", 300},
	[2] = {"weapon_m42", "A classic weapon within the military.", 250},
	}
},
[2] = {"Submachine Guns", {
	[1] = {"weapon_mp52", "Common within SWAT teams.", 250},
	[2] = {"weapon_mac102", "Used by gangsters.", 200},
	}
},
[3] = {"Sniper Rifles", {
	[1] = {"ls_sniper", "Deadly but silent.", 500}
	}
},
[4] = {"Shotguns", {
	[1] = {"weapon_pumpshotgun2", "A classic shotgun.", 350}
	}
},
[5] = {"Pistols", {
	[1] = {"weapon_deagle2", "One of the most powerful pistols.", 200},
	[2] = {"weapon_p2282", "Aim, point and fire.", 150},
	[3] = {"weapon_fiveseven2", "A quick and deadly sidearm.", 150},
	[4] = {"weapon_glock2", "Kind of weak, but cheap.", 50}
	}
}
}
--{Category Name, {Ent Class, Model Path, Name, Description, Price, Spawnlimit}}
PermItemsConfig.EntitiesList = {
[1] = {"Money Printers", {
    [1] = {"money_printer", "models/props_c17/consolebox01a.mdl", "Money Printer", "A basic money printer", 300,1}
    }
},

[2] = {"General", {
    [1] = {"gunlab", "models/props_c17/TrapPropeller_Engine.mdl", "Gun Lab", "A basic Gun lab.", 200,1},
    [2] = {"drug_lab", "models/props_lab/crematorcase.mdl", "Drug Lab", "A basic drug production.", 250, 1},
    [3] = {"microwave", "models/props/cs_office/microwave.mdl","Microwave", "It produces food.", 150, 1}
    }
}
}
