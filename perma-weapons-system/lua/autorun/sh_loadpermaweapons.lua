
print("////////////////////////////////////////////")
print("//   Loading Perma Weapons System Files   //")
print("// www.scriptfodder.com/scripts/view/2970 //")
print("//         Created by ToBadForYou         //")
print("////////////////////////////////////////////")

if SERVER then
	include("tbfy_permitems/sh_permaweapons_config.lua")
	AddCSLuaFile("tbfy_permitems/sh_permaweapons_config.lua")
	
	include("tbfy_permitems/sv_permaweapons.lua")
	include("tbfy_permitems/sh_permaweapons.lua")
	
	AddCSLuaFile("tbfy_permitems/sh_permaweapons.lua")
	AddCSLuaFile("tbfy_permitems/cl_permaweapons.lua")
elseif CLIENT then
	include("tbfy_permitems/sh_permaweapons_config.lua")
	include("tbfy_permitems/sh_permaweapons.lua")
    include("tbfy_permitems/cl_permaweapons.lua")	
end