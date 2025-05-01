print("////////////////////////////////////////////")
print("//                                        //")
print("// Loading Realistic Election System Files//")
print("//   www.gmodstore.com/scripts/view/5794  //")
print("//         Created by ToBadForYou         //")
print("//                                        //")
print("////////////////////////////////////////////")

if SERVER then
	include("tbfy_relections/sh_relections_config.lua")
	include("tbfy_relections/sv_relections.lua")
	include("tbfy_relections/sh_relections.lua")

	AddCSLuaFile("tbfy_relections/sh_relections_config.lua")
	AddCSLuaFile("tbfy_relections/sh_relections.lua")
	AddCSLuaFile("tbfy_relections/cl_relections.lua")
elseif CLIENT then
	include("tbfy_relections/sh_relections_config.lua")
	include("tbfy_relections/sh_relections.lua")
    include("tbfy_relections/cl_relections.lua")
end
