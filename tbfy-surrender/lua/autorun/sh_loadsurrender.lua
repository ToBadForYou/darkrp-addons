
print("////////////////////////////////////////////")
print("//                                        //")
print("//     Loading Surrender System Files     //")
print("//         Created by ToBadForYou         //")
print("//                                        //")
print("////////////////////////////////////////////")
if SERVER then
	include("tbfy_surrender/sh_surrender_config.lua")
	include("tbfy_surrender/sh_surrender.lua")
	include("tbfy_surrender/sv_surrender.lua")

	AddCSLuaFile("tbfy_surrender/sh_surrender_config.lua")
	AddCSLuaFile("tbfy_surrender/sh_surrender.lua")
	AddCSLuaFile("tbfy_surrender/cl_surrender.lua")
elseif CLIENT then
	include("tbfy_surrender/sh_surrender_config.lua")
	include("tbfy_surrender/sh_surrender.lua")
	include("tbfy_surrender/cl_surrender.lua")
end
