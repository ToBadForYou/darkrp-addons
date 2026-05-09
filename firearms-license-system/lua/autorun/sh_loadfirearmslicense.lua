
print("////////////////////////////////////////////")
print("//                                        //")
print("//  Loading Firearm License System Files  //")
print("// www.scriptfodder.com/scripts/view/3841 //")
print("//         Created by ToBadForYou         //")
print("//                                        //")
print("////////////////////////////////////////////")

if SERVER then
	include("tbfy_falicense/sh_falicense_config.lua")
	include("tbfy_falicense/sh_falicense.lua")
	include("tbfy_falicense/sv_falicense.lua")

	AddCSLuaFile("tbfy_falicense/sh_falicense_config.lua")
	AddCSLuaFile("tbfy_falicense/sh_falicense.lua")
	AddCSLuaFile("tbfy_falicense/cl_falicense.lua")
elseif CLIENT then
	include("tbfy_falicense/sh_falicense_config.lua")
	include("tbfy_falicense/sh_falicense.lua")
  include("tbfy_falicense/cl_falicense.lua")
end
