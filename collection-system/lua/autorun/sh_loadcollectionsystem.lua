print("////////////////////////////////////////////")
print("//     Loading Collection System Files    //")
print("//   www.gmodstore.com/scripts/view/3028  //")
print("//         Created by ToBadForYou         //")
print("////////////////////////////////////////////")
if SERVER then
	include("tbfy_collections/sh_collections_config.lua")
	include("tbfy_collections/sh_collections.lua")	
	include("tbfy_collections/sv_collections.lua")

	AddCSLuaFile("tbfy_collections/sh_collections_config.lua")	
	AddCSLuaFile("tbfy_collections/sh_collections.lua")	
	AddCSLuaFile("tbfy_collections/cl_collections.lua")
elseif CLIENT then
	include("tbfy_collections/sh_collections_config.lua")
	include("tbfy_collections/sh_collections.lua")	
    include("tbfy_collections/cl_collections.lua")	
end