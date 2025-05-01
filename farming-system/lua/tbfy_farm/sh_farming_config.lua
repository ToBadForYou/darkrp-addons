
--[[
You can now eat fruits that are stored in boxes
Added support for Vrondakis level system
Added support for DarkRP Essentials level system
Moved addons main files into its own folder

Configs added:
FarmingSellPercentageXP
]]


hook.Add("loadCustomDarkRPItems", "farming_sys_init", function()
//How long before it removes a plant after it dies
FarmingDeathTimer = 40
//NPC Model
FarmingBuyerModel = "models/player/Group01/Female_01.mdl"
FarmingBuyerText = "Farmer Merchant"
//How close storages must be to the NPC
FarmingBuyerRange = 250
//Chatcommand for manager menu use /COMMAND -> /managefareas
FarmingManagerChatCommand = {"!managefareas", "!farmingareas"}
//How many plants can a person have growing at the same time?
FarmingMaxPlants = 4
//Should you only be able to plant within the farming locations you setup?
FarmingRestrictToAreas = true
//Percentage of amount earnt from selling fruits given as XP
FarmingSellPercentageXP = 10

FarmingDatabase = {}

FarmingDatabase["Apple"] = {}
//Plantable in the ground?
FarmingDatabase["Apple"].Plot = true
//Plant grow time
FarmingDatabase["Apple"].GrowPTime = 70
//Fruits grow time
FarmingDatabase["Apple"].GrowFTime = 40
//How $ for each
FarmingDatabase["Apple"].SellPrice = 15
//How much hunger it restores
FarmingDatabase["Apple"].Hunger = 5
//% chance for the plant to die after harvested
FarmingDatabase["Apple"].DeathChance = 50
//Minimum fruits spawned
FarmingDatabase["Apple"].MinFruits = 8
//Maximum fruits spawned (Dont put higher than the amount of positions)
FarmingDatabase["Apple"].MaxFruits = 15
//Fruit model
FarmingDatabase["Apple"].ProduceModel = "models/props/de_inferno/crate_fruit_break_gib2.mdl"
//Plant Model
FarmingDatabase["Apple"].PlantModel = "models/props/de_inferno/tree_small.mdl"
//Plant pos
FarmingDatabase["Apple"].PlantPos = Vector(0,0,0)
//Fruit poses
FarmingDatabase["Apple"].FruitPos = {Vector(-17.26,7.196,84.78),Vector(34.53,4.31,84.78),Vector(5.75,4.31,127.15),Vector(34.53,-40.28,104.85),Vector(-5.75,-44.6,91.47),Vector(-24.46,10.0,104.85),Vector(30.21,50.35,141),Vector(50.359710693359,-18.703,107), Vector(-25.89,-56.11510848999,120),Vector(-44.604309082031,-40.287769317627,123),Vector(0,-54.676258087158,145),Vector(-4.3165588378906,-54,189.60430908203),Vector(-7.1942443847656,17,166),Vector(5,-13,178),Vector(-8.63,-8.63,140.53)}
//Plant size {1, Vector(1,1,1)} is standard size of the model
FarmingDatabase["Apple"].PlantSize = {0.5,Vector(1,1,1)}
//Fruit size
FarmingDatabase["Apple"].FruitSize = {1,Vector(1,1,1)}
//Plantable in a pot?
FarmingDatabase["Apple"].Pot = true
//Plants grow time in pot
FarmingDatabase["Apple"].PotGrowPTime = 90
//Fruits grow time in pot
FarmingDatabase["Apple"].PotGrowFTime = 60
//Pots plant pos
FarmingDatabase["Apple"].PotPlantPos = Vector(0,0,6)
//Pot fruit pos
FarmingDatabase["Apple"].PotFruitPos = {Vector(11,4,27),Vector(0,-11,28),Vector(13,-12,31),Vector(-8,2.5,31),Vector(1.5,-14,41),Vector(5,10,40),Vector(2.5,-2,50),Vector(-2.8000030517578,4.5,47),Vector(-1,-11.5,50),Vector(-4,1,25),Vector(2.8777008056641,-1.4388427734375,30),Vector(-5,-13,34),Vector(0,6,38),Vector(8,-7,32),Vector(-5,-2.877685546875,38)}
//Pot plant size
FarmingDatabase["Apple"].PotPlantSize = {0.12,Vector(1,1,1)}
//Pot Fruit size
FarmingDatabase["Apple"].PotFruitSize = {0.2,Vector(1,1,1)}

FarmingDatabase["Melon"] = {}
FarmingDatabase["Melon"].Plot = true
FarmingDatabase["Melon"].GrowPTime = 50
FarmingDatabase["Melon"].GrowFTime = 70
FarmingDatabase["Melon"].SellPrice = 45
FarmingDatabase["Melon"].Hunger = 15
FarmingDatabase["Melon"].DeathChance = 50
FarmingDatabase["Melon"].MinFruits = 2
FarmingDatabase["Melon"].MaxFruits = 5
FarmingDatabase["Melon"].ProduceModel = "models/props_junk/watermelon01.mdl"
FarmingDatabase["Melon"].PlantModel = "models/props/pi_fern.mdl"
FarmingDatabase["Melon"].PlantPos = Vector(0,0,0)
FarmingDatabase["Melon"].FruitPos = {Vector(-1.438850402832,14.388488769531,9),Vector(-14,3.5,8.5),Vector(-6.5,-14,10.5),Vector(12.949638366699,-8.6330871582031,7.1999969482422),Vector(12.949638366699,10.07194519043,9)}
FarmingDatabase["Melon"].PlantSize = {0.8,Vector(1,1,1)}
FarmingDatabase["Melon"].FruitSize = {0.85,Vector(1,1,1)}
FarmingDatabase["Melon"].Pot = true
FarmingDatabase["Melon"].PotGrowPTime = 70
FarmingDatabase["Melon"].PotGrowFTime = 90
FarmingDatabase["Melon"].PotPlantPos = Vector(0,0,4)
FarmingDatabase["Melon"].PotFruitPos = {Vector(6,5,9.8000030517578),Vector(6,-4,9),Vector(-3.5,-7.5,9.6999969482422),Vector(-7,2,9),Vector(-1.5,9,9)}
FarmingDatabase["Melon"].PotPlantSize = {0.4,Vector(1,1,1)}
FarmingDatabase["Melon"].PotFruitSize = {0.35,Vector(1,1,1)}

FarmingDatabase["Banana"] = {}
FarmingDatabase["Banana"].Plot = true
FarmingDatabase["Banana"].GrowPTime = 80
FarmingDatabase["Banana"].GrowFTime = 30
FarmingDatabase["Banana"].SellPrice = 30
FarmingDatabase["Banana"].Hunger = 8
FarmingDatabase["Banana"].DeathChance = 50
FarmingDatabase["Banana"].MinFruits = 3
FarmingDatabase["Banana"].MaxFruits = 8
FarmingDatabase["Banana"].ProduceModel = "models/props/cs_italy/bananna_bunch.mdl"
FarmingDatabase["Banana"].PlantModel = "models/props/de_dust/du_palm_tree01_skybx.mdl"
FarmingDatabase["Banana"].PlantPos = Vector(0,0,0)
FarmingDatabase["Banana"].FruitPos = {Vector(-5.7554016113281,11.510787963867,113.77697753906),Vector(12.949645996094,17.266189575195,129.38848876953),Vector(17.266189575195,-14.38850402832,129.38848876953),Vector(25.899276733398,12.949645996094,120.467628479),Vector(-2.8777008056641,-21.582717895508,138.30935668945),Vector(-24.460433959961,1.4388427734375,120.467628479),Vector(-27.338134765625,-25.899276733398,120.467628479),Vector(-4.3165435791016,18.705032348633,133.84892272949)}
FarmingDatabase["Banana"].PlantSize = {1.2,Vector(1,1,1)}
FarmingDatabase["Banana"].FruitSize = {1,Vector(1,1,1)}
//Model issue
FarmingDatabase["Banana"].Pot = false
FarmingDatabase["Banana"].PotGrowPTime = 100
FarmingDatabase["Banana"].PotGrowFTime = 40
FarmingDatabase["Banana"].PotPlantPos = Vector(0,0,15)
FarmingDatabase["Banana"].PotFruitPos = {Vector(0,5,38),Vector(3,-4,43),Vector(4.3165473937988,1.4388427734375,44),Vector(-5,-4,43),Vector(-5,0,46),Vector(-5,-2,38),Vector(6,5,42),Vector(0,0,42)}
FarmingDatabase["Banana"].PotPlantSize = {0.25,Vector(1,1,1)}
FarmingDatabase["Banana"].PotFruitSize = {0.25,Vector(1,1,1)}

FarmingDatabase["Orange"] = {}
FarmingDatabase["Orange"].Plot = true
FarmingDatabase["Orange"].GrowPTime = 40
FarmingDatabase["Orange"].GrowFTime = 30
FarmingDatabase["Orange"].SellPrice = 25
FarmingDatabase["Orange"].Hunger = 6
FarmingDatabase["Orange"].DeathChance = 50
FarmingDatabase["Orange"].MinFruits = 5
FarmingDatabase["Orange"].MaxFruits = 8
FarmingDatabase["Orange"].ProduceModel = "models/props/cs_italy/orange.mdl"
FarmingDatabase["Orange"].PlantModel = "models/props_foliage/shrub_01a.mdl"
FarmingDatabase["Orange"].PlantPos = Vector(0,0,0)
FarmingDatabase["Orange"].FruitPos = {Vector(0,-10.07194519043,20.10791015625),Vector(8.6331176757813,10.07194519043,35.719421386719),Vector(-17.266174316406,5.7553939819336,22.33812713623),Vector(-1.4388427734375,-8.6330871582031,33.489212036133),Vector(-8.6331176757813,-11.510787963867,8.9568328857422),Vector(-7.1942138671875,-7.1942443847656,40.17985534668),Vector(5.75537109375,4.3165435791016,20.10791015625),Vector(-15.827331542969,12.949638366699,26.798561096191)}
FarmingDatabase["Orange"].PlantSize = {0.8,Vector(1,1,1)}
FarmingDatabase["Orange"].FruitSize = {1,Vector(1,1,1)}
FarmingDatabase["Orange"].Pot = true
FarmingDatabase["Orange"].PotGrowPTime = 60
FarmingDatabase["Orange"].PotGrowFTime = 40
FarmingDatabase["Orange"].PotPlantPos = Vector(0,0,6)
FarmingDatabase["Orange"].PotFruitPos = {Vector(0,5,15.647476196289),Vector(5,4,23),Vector(-2,0,15),Vector(5,-4,16),Vector(0,-5,20.10791015625),Vector(-5,-5,18),Vector(-7.1942443847656,2.877685546875,16),Vector(0,0,19)}
FarmingDatabase["Orange"].PotPlantSize = {0.3,Vector(1,1,1)}
FarmingDatabase["Orange"].PotFruitSize = {0.25,Vector(1,1,1)}

if !TEAM_FARMER then
TEAM_FARMER = DarkRP.createJob("Farmer", {
    color = Color(50, 200, 20, 255),
    model = {
        "models/player/Group01/Female_01.mdl",
        "models/player/Group01/Female_02.mdl",
        "models/player/Group01/Female_03.mdl",
        "models/player/Group01/Female_04.mdl",
        "models/player/Group01/Female_06.mdl",
        "models/player/group01/male_01.mdl",
        "models/player/Group01/Male_02.mdl",
        "models/player/Group01/male_03.mdl",
        "models/player/Group01/Male_04.mdl",
        "models/player/Group01/Male_05.mdl",
        "models/player/Group01/Male_06.mdl",
        "models/player/Group01/Male_07.mdl",
        "models/player/Group01/Male_08.mdl",
        "models/player/Group01/Male_09.mdl"
    },
    description = [[Farm for a living, plant seeds and harvest your plants. Sell them at the farmer NPC.]],
    weapons = {"gardening_hoe"},
    command = "farmer",
    max = 2,
    salary = 50,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Citizens",
})

DarkRP.createEntity("Pot", {
    ent = "farming_pot",
    model = "models/stormeffect/drug_plantpot1a.mdl",
    price = 100,
    max = 5,
    cmd = "buyfarmingpot",
    allowed = {TEAM_FARMER},
})
DarkRP.createEntity("Storage", {
    ent = "farming_storage",
    model = "models/Items/item_item_crate.mdl",
    price = 50,
    max = 5,
    cmd = "buyfarmingstorage",
    allowed = {TEAM_FARMER},
})
DarkRP.createEntity("Apple Seed", {
    ent = "farming_seed",
    model = "models/weapons/w_bugbait.mdl",
    price = 50,
    max = 5,
    cmd = "buyappleseed",
	seedid = "Apple",
    allowed = {TEAM_FARMER},
})
DarkRP.createEntity("Melon Seed", {
    ent = "farming_seed",
    model = "models/weapons/w_bugbait.mdl",
    price = 50,
    max = 5,
    cmd = "buymelonseed",
    seedid = "Melon",
	allowed = {TEAM_FARMER},
})
DarkRP.createEntity("Banana Seed", {
    ent = "farming_seed",
    model = "models/weapons/w_bugbait.mdl",
    price = 50,
    max = 5,
    cmd = "buybananaseed",
    seedid = "Banana",
	allowed = {TEAM_FARMER},
})
DarkRP.createEntity("Orange Seed", {
    ent = "farming_seed",
    model = "models/weapons/w_bugbait.mdl",
    price = 50,
    max = 5,
    cmd = "buyorangeseed",
    seedid = "Orange",
	allowed = {TEAM_FARMER},
})
end
end)
