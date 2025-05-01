
--[[
I recommend you fully reinstall the addon for this update

Made the configs into one global table
Moved the lua files into its own folder
Containers will now autorespawn upon cleanup
]]

TBFY_CollectConfig = TBFY_CollectConfig or {} 

//Cooldown for dropping items
TBFY_CollectConfig.DropItemCD = 1
//Players required for spawning to be enabled
TBFY_CollectConfig.PlayersReq = 1
//Should items spawn in random locations?
TBFY_CollectConfig.ItemSpawning = true
//How often should items spawn?
TBFY_CollectConfig.SpawnTimer = 120
//Should items spawn in random containers?
TBFY_CollectConfig.ItemSpawningContainers = true
//How often should items spawn in containers
TBFY_CollectConfig.SpawnTimerContainer = 120
//How many items can a container max stack up to?
TBFY_CollectConfig.ContainerMaxItems = 5
//How many items can currently exist? (Also counts player dropped items)
TBFY_CollectConfig.ItemSpawnLimit = 25
//Should collection reset after reward is claimed?
TBFY_CollectConfig.ResetOnClaimed = false
//How much faster should items spawn depending on players? This % is for each extra player
TBFY_CollectConfig.PlayerAdjustTimer = .01
//For container spawning
TBFY_CollectConfig.PlayerAdjustTimerContainer = .01
//WARNING THINK ABOUT IT BEFORE LOWERING THE TIMER TOO MUCH AS IT CAN CAUSE A LOT OF LAG
//Max % reduction for timer
TBFY_CollectConfig.MaxTimerReduction = .50
 
//Sounds
TBFY_CollectConfig.DropItemSound = Sound("items/ammocrate_close.wav")
TBFY_CollectConfig.PickupItemSound = Sound("items/ammocrate_open.wav")
 
COLLECTION_COLLCETIONSDB = {
{"Metal Collection",{1,2,3,4,5,6,7,8},8,"£10000", function(Player) Player:addMoney(10000) end},
{"Wood Collection",{9,10,11,12,13,14,15,16},8,"£10000", function(Player) Player:addMoney(10000) end},
{"Bone Collection",{17,18,19,20},4,"£8000", function(Player) Player:addMoney(8000) end},
{"Fruit Collection",{21,22,23,24,25},5,"£9000", function(Player) Player:addMoney(9000) end},
{"Child Collection",{26,27,28,29},4,"£8000", function(Player) Player:addMoney(8000) end},
{"Sign Collection",{30,31,32,33,34,35,36},7,"£9000", function(Player) Player:addMoney(9000) end},
{"Bottle Collection",{37,38,39,40,41,42,43,44,45,46},10,"£13000", function(Player) Player:addMoney(13000) end},
{"Book Collection",{47,48,49,50},4,"£8000", function(Player) Player:addMoney(8000) end},
}
--COLLECTION_ITEMSDB[ID] = {"Modelpath", SpawnChance (Number between 1-100)}
COLLECTION_ITEMSDB = {}
COLLECTION_ITEMSDB[1] = {"models/gibs/metal_gib1.mdl", 100}
COLLECTION_ITEMSDB[2] = {"models/gibs/metal_gib2.mdl", 100}
COLLECTION_ITEMSDB[3] = {"models/gibs/metal_gib3.mdl", 100}
COLLECTION_ITEMSDB[4] = {"models/gibs/metal_gib4.mdl", 100}
COLLECTION_ITEMSDB[5] = {"models/gibs/metal_gib5.mdl",100}
COLLECTION_ITEMSDB[6] = {"models/props_c17/tools_wrench01a.mdl",100}
COLLECTION_ITEMSDB[7] = {"models/props_c17/TrapPropeller_Lever.mdl",100}
COLLECTION_ITEMSDB[8] = {"models/props_canal/mattpipe.mdl",100}
COLLECTION_ITEMSDB[9] = {"models/props_debris/wood_board06a.mdl",100}
COLLECTION_ITEMSDB[10] = {"models/props_junk/wood_pallet001a_chunka1.mdl",100}
COLLECTION_ITEMSDB[11] = {"models/props_junk/wood_crate001a_chunk03.mdl",100}
COLLECTION_ITEMSDB[12] = {"models/props_wasteland/cafeteria_table001a_chunk01.mdl",100}
COLLECTION_ITEMSDB[13] = {"models/props_wasteland/barricade002a_chunk06.mdl",100}
COLLECTION_ITEMSDB[14] = {"models/props_wasteland/cafeteria_bench001a_chunk03.mdl",100}
COLLECTION_ITEMSDB[15] = {"models/Gibs/wood_gib01d.mdl",100}
COLLECTION_ITEMSDB[16] = {"models/props_c17/FurnitureDrawer001a_Shard01.mdl",100}
COLLECTION_ITEMSDB[17] = {"models/Gibs/HGIBS.mdl",100}
COLLECTION_ITEMSDB[18] = {"models/Gibs/HGIBS_rib.mdl",100}
COLLECTION_ITEMSDB[19] = {"models/Gibs/HGIBS_scapula.mdl",100}
COLLECTION_ITEMSDB[20] = {"models/Gibs/HGIBS_spine.mdl",100}
COLLECTION_ITEMSDB[21] = {"models/props_junk/watermelon01.mdl",100}
COLLECTION_ITEMSDB[22] = {"models/props/de_inferno/crate_fruit_break_gib2.mdl",100}
COLLECTION_ITEMSDB[23] = {"models/props/cs_italy/bananna_bunch.mdl",100}
COLLECTION_ITEMSDB[24] = {"models/props/cs_italy/bananna.mdl",100}
COLLECTION_ITEMSDB[25] = {"models/props/cs_italy/orange.mdl",100}
COLLECTION_ITEMSDB[26] = {"models/props_c17/doll01.mdl",100}
COLLECTION_ITEMSDB[27] = {"models/props_lab/huladoll.mdl",100}
COLLECTION_ITEMSDB[28] = {"models/props/de_tides/vending_turtle.mdl",100}
COLLECTION_ITEMSDB[29] = {"models/props/cs_office/snowman_face.mdl",100}
COLLECTION_ITEMSDB[30] = {"models/props_c17/streetsign001c.mdl",100}
COLLECTION_ITEMSDB[31] = {"models/props_c17/streetsign002b.mdl",100}
COLLECTION_ITEMSDB[32] = {"models/props_c17/streetsign003b.mdl",100}
COLLECTION_ITEMSDB[33] = {"models/props_c17/streetsign004e.mdl",100}
COLLECTION_ITEMSDB[34] = {"models/props_c17/streetsign004f.mdl",100}
COLLECTION_ITEMSDB[35] = {"models/props_c17/streetsign005c.mdl",100}
COLLECTION_ITEMSDB[36] = {"models/props_c17/streetsign005d.mdl",100}
COLLECTION_ITEMSDB[37] = {"models/props_junk/garbage_glassbottle001a.mdl",100}
COLLECTION_ITEMSDB[38] = {"models/props_junk/garbage_glassbottle002a.mdl",100}
COLLECTION_ITEMSDB[39] = {"models/props_junk/garbage_glassbottle003a.mdl",100}
COLLECTION_ITEMSDB[40] = {"models/props_junk/garbage_plasticbottle001a.mdl",100}
COLLECTION_ITEMSDB[41] = {"models/props_junk/garbage_plasticbottle002a.mdl",100}
COLLECTION_ITEMSDB[42] = {"models/props_junk/garbage_plasticbottle003a.mdl",100}
COLLECTION_ITEMSDB[43] = {"models/props_junk/GlassBottle01a.mdl",100}
COLLECTION_ITEMSDB[44] = {"models/props_junk/glassjug01.mdl",100}
COLLECTION_ITEMSDB[45] = {"models/props/cs_militia/bottle01.mdl",100}
COLLECTION_ITEMSDB[46] = {"models/props/cs_office/water_bottle.mdl",100}
COLLECTION_ITEMSDB[47] = {"models/props_lab/binderbluelabel.mdl",100}
COLLECTION_ITEMSDB[48] = {"models/props_lab/binderredlabel.mdl",100}
COLLECTION_ITEMSDB[49] = {"models/props_lab/bindergraylabel01a.mdl",100}
COLLECTION_ITEMSDB[50] = {"models/props_lab/bindergreenlabel.mdl",100}