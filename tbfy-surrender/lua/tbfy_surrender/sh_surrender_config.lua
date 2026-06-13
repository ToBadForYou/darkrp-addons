
TBFYSurrenderConfig = TBFYSurrenderConfig or {}

//Setting this to true will cause the system to bonemanipulate clientside, might cause sync issues but won't require you to install all playermodels on the server
TBFYSurrenderConfig.BoneManipulateClientside = false
TBFYSurrenderConfig.SurrenderEnabled = true
//All keys can be found here -> https://wiki.garrysmod.com/page/Enums/KEY
//Key for surrendering
TBFYSurrenderConfig.SurrenderKey = KEY_T
//You can't surrender while holding these weapons
TBFYSurrenderConfig.SurrenderWeaponWhitelist = {
    ["weapon_arc_phone"] = true,
}
//Disables drawing player shadow
//Only use this if the shadows are causing issues
TBFYSurrenderConfig.DisablePlayerShadow = false