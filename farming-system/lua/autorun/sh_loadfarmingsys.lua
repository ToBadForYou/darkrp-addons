print("////////////////////////////////////////////")
print("//      Loading Farming System Files      //")
print("//   www.gmodstore.com/scripts/view/2784  //")
print("//         Created by ToBadForYou         //")
print("////////////////////////////////////////////")
if SERVER then
	include("tbfy_farm/sh_farming_config.lua")
	include("tbfy_farm/sv_farming.lua")
	include("tbfy_farm/sh_farming.lua")

	AddCSLuaFile("tbfy_farm/sh_farming_config.lua")
	AddCSLuaFile("tbfy_farm/sh_farming.lua")
	AddCSLuaFile("tbfy_farm/cl_farming.lua")
	AddCSLuaFile("tbfy_farm/cl_plantsetup.lua")
elseif CLIENT then
	include("tbfy_farm/sh_farming_config.lua")
	include("tbfy_farm/sh_farming.lua")
    include("tbfy_farm/cl_farming.lua")
	include("tbfy_farm/cl_plantsetup.lua")
end
