
print("////////////////////////////////////////////")
print("//                                        //")
print("//    Loading Stock Market System Files   //")
print("//   www.gmodstore.com/scripts/view/4058  //")
print("//         Created by ToBadForYou         //")
print("//                                        //")
print("////////////////////////////////////////////")

if SERVER then
	include("tbfy_stockmarket/sh_stockmarket_config.lua")
	include("tbfy_stockmarket/sv_stockmarket.lua")
	include("tbfy_stockmarket/sh_stockmarket.lua")

	AddCSLuaFile("tbfy_stockmarket/sh_stockmarket_config.lua")
	AddCSLuaFile("tbfy_stockmarket/sh_stockmarket.lua")
	AddCSLuaFile("tbfy_stockmarket/cl_stockmarket.lua")
elseif CLIENT then
	include("tbfy_stockmarket/sh_stockmarket_config.lua")
	include("tbfy_stockmarket/sh_stockmarket.lua")
  include("tbfy_stockmarket/cl_stockmarket.lua")
end
