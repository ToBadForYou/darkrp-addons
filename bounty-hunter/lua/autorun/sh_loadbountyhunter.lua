
print("////////////////////////////////////////////")
print("//   Loading Bounty Hunter System Files   //")
print("//  www.gmodstore.com/scripts/view/2915   //")
print("//         Created by ToBadForYou         //")
print("////////////////////////////////////////////")

if SERVER then
	include("tbfy_bountyhunter/sh_bountyhunter_config.lua")
	AddCSLuaFile("tbfy_bountyhunter/sh_bountyhunter_config.lua")
	
	include("tbfy_bountyhunter/sv_bountyhunter.lua")
	include("tbfy_bountyhunter/sh_bountyhunter.lua")
	
	AddCSLuaFile("tbfy_bountyhunter/sh_bountyhunter.lua")
	AddCSLuaFile("tbfy_bountyhunter/cl_bountyhunter.lua")
elseif CLIENT then
	include("tbfy_bountyhunter/sh_bountyhunter_config.lua")
	include("tbfy_bountyhunter/sh_bountyhunter.lua")
    include("tbfy_bountyhunter/cl_bountyhunter.lua")	
end