print("/////////////////////////////////////////////////")
print("//                                             //")
print("//              TBFY_Shared Loaded             //")
print("//  www.gmodstore.com/users/76561197989708503  //")
print("//                                             //")
print("/////////////////////////////////////////////////")
if SERVER then
	include("tbfy_shared/sh_config.lua")
	include("tbfy_shared/sh_init.lua")

	AddCSLuaFile("tbfy_shared/sh_config.lua")
	AddCSLuaFile("tbfy_shared/skins/falkos.lua")
	AddCSLuaFile("tbfy_shared/sh_init.lua")
elseif CLIENT then
	include("tbfy_shared/sh_config.lua")
	include("tbfy_shared/skins/falkos.lua")
	include("tbfy_shared/sh_init.lua")
end
