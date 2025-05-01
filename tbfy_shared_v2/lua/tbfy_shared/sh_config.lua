
--[[
You can now set computers to be: Government, Private or Public
You can now select time format for the PC in the settings menu (when logged in)
You can now remove entities related to my addons with remover in Setup SWEP -> TBFY_SHARED -> Remover
FalkOS now will properly organize softwares so it stays on the screen
Hovering on text in archives will now display the whole text as a "popup"
Text no longer write over eachother in archives
You can now setup text input related configs ingame (For example model paths)
You can now setup text options related configs ingame (For example if a config has different "modes", 0 = Nothing, 1 = Wanted, 2 = Warranted)
Optimized archives, will now send a lot less data (only sends if server data is changed) and caches the data on the client
Disconnected players are now logged out of computers
Now properly removes player equipment models on disconnection
Now checks github for lastest version (hopefully less will have issues with this)
Added chinese and french language
Fixed Msg error

Configs added:
]]

TBFY_SH = TBFY_SH or {}
TBFY_SH.Config = TBFY_SH.Config or {}

//Admincheck for TBFY_Shared admin stuff
TBFY_SH.Config.AdminAccessCustomCheck = function(Player) return Player:IsAdmin() end
--PARTLY IMPLEMENTED
--[[
english
french
chinese
]]
TBFY_SH.Config.LanguageToUse = "english"
//How many days before archive data expires and is deleted
TBFY_SH.Config.ArchiveDaysExpire = 7
//Client stuff
if CLIENT then
//Derma configs
TBFY_SH.Config.Derma = {
  MainPanelColor = Color(255,255,255,200),
  SecondPanelColor = Color(215,215,220,255),
  HeaderColor = Color(50,50,50,255),
  TabListColors = Color(215,215,220,255),
  ArchiveColor = Color(200,200,210,255),
  ArchiveColor2 = Color(210,210,220,255),
  ButtonColor = Color(50,50,50,255),
  ButtonColorHovering = Color(75,75,75,200),
  ButtonColorPressed = Color(150,150,150,200),
  ButtonOutline = Color(0,0,0,200),
  CB = Color(255,255,255,0),
  CBHover = Color(175,175,225,50),
  CBPress = Color(175,175,225,100),
  WindowBorder = Color(0,0,0,100),
  SoftwareBorderColor = Color(255,255,255,200),
  TopFrame = Color(255,255,255,180),
  CProgramBG = Color(215,215,215,225),
  WColor = Color(255,255,255,225),
  GBGColor = Color(50,175,50,225),
  RBGColor = Color(200,50,50,255),
  Padding = 5,
  HeaderH = 25,
}
surface.CreateFont("tbfy_theory_paneltext", {
	font = "Verdana",
	size = 17,
	weight = 1000,
	antialias = true,
})
surface.CreateFont("tbfy_theory_question", {
	font = "Verdana",
	size = 14,
	weight = 1000,
	antialias = true,
})
surface.CreateFont("tbfy_theory_answer", {
	font = "Verdana",
	size = 12,
	weight = 500,
	antialias = true,
})
surface.CreateFont("tbfy_theory_choose_text", {
	font = "Verdana",
	size = 13,
	weight = 500,
	antialias = true,
})
surface.CreateFont("tbfy_theory_text", {
	font = "Verdana",
	size = 25,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_header", {
	font = "Arial",
	size = 20,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_entname", {
	font = "Verdana",
	size = 12,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_buttontext", {
	font = "Verdana",
	size = 11,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_archives_button", {
	font = "Verdana",
	size = 12,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_archives_header", {
	font = "Verdana",
	size = 18,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_archives_subheader", {
	font = "Verdana",
	size = 13,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_archives_text", {
	font = "Verdana",
	size = 12,
	weight = 500,
	antialias = true,
})

surface.CreateFont("tbfy_computer_programtitle", {
	font = "Verdana",
	size = 17,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_computer_font_login", {
	font = "Arial",
	size = 22,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_computer_window_letters", {
	font = "Arial",
	size = 19,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_computer_font_login_text", {
	font = "Arial",
	size = 14,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_computer_cmdtitle", {
	font = "Consolas",
	size = 22,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_computer_amanager_text", {
	font = "Consolas",
	size = 16,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_computer_cmd", {
	font = "Consolas",
	size = 14,
	weight = 0,
	antialias = true,
})

surface.CreateFont("tbfy_computer_icon", {
	font = "Verdana",
	size = 11,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_country", {
	font = "Verdana",
	size = 14,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_config_name", {
	font = "Arial",
	size = 16,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_config_desc", {
	font = "Arial",
	size = 14,
	weight = 0,
	antialias = true,
})

surface.CreateFont("tbfy_computer_firewall_title", {
	font = "Arial",
	size = 20,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_computer_firewall", {
	font = "Arial",
	size = 16,
	weight = 0,
	antialias = true,
})

surface.CreateFont("tbfy_falkstore_title", {
	font = "Arial",
	size = 16,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_falkstore_desc", {
	font = "Arial",
	size = 14,
	weight = 0,
	antialias = true,
})

surface.CreateFont("tbfy_comp_admin_pinfo", {
	font = "Arial",
	size = 18,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_comp_overview_infotext", {
	font = "Arial",
	size = 14,
	weight = 1000,
	antialias = true,
})
surface.CreateFont("tbfy_comp_overview_infoval", {
	font = "Arial",
	size = 14,
	weight = 0,
	antialias = true,
})
end
