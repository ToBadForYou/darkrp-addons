local MODULE = GAS.Logging:MODULE()

MODULE.Category = "ToBadForYou"
MODULE.Name     = "Firearms License System"
MODULE.Colour   = Color(125,35,35)

MODULE:Hook("FA_ToggleInstructor","fa_toggleinstructor",function(Player, MPlayer)
	local LogText = "granted"
	if !MPlayer:FA_IsInstructor() then
		LogText = "revoked"
	end
	MODULE:Log(GAS.Logging:FormatPlayer(Player) .. " " .. LogText .. " " .. GAS.Logging:FormatPlayer(MPlayer) .. " instructor status.")
end)

MODULE:Hook("FA_ToggleLicense","fa_togglelicense",function(Player, MPlayer, LID, Bool, Type)
	local LogText = "granted"
	if !Bool then
		LogText = "revoked"
	end
	local LicenseName = FALICENSE_DATABASE[LID].Name
	MODULE:Log(GAS.Logging:FormatPlayer(Player) .. " " .. LogText .. " " .. GAS.Logging:FormatPlayer(MPlayer) .. " " .. LicenseName .. " " .. Type .. ".")
end)

MODULE:Hook("FA_ToggleTheory","fa_ToggleTheory",function(Player, MPlayer, LID, Granted)
	local LogText = "granted"
	if !Granted then
		LogText = "revoked"
	end
	local LicenseName = FALICENSE_DATABASE[LID].Name
	MODULE:Log(GAS.Logging:FormatPlayer(Player) .. " " .. LogText .. " " .. GAS.Logging:FormatPlayer(MPlayer) .. " " .. LicenseName .. " theory test.")
end)

MODULE:Hook("FA_Application","fa_applicaton",function(Player, LID, Carry, Sell)
	local Text = ""
	if Carry then
		Text = "carry license"
	end
	if Sell then
		if Text == "" then
			Text = "sell license"
		else
			Text = Text .. " and sell license"
		end
	end
	local LicenseName = FALICENSE_DATABASE[LID].Name
	MODULE:Log(GAS.Logging:FormatPlayer(Player) .. " submitted an application for " .. LicenseName .. " " .. Text .. ".")
end)

MODULE:Hook("FA_Application_Action","fa_applicaton_action",function(Player, MPlayer, LID, Approved)
	local LogText = "approved"
	if !Approved then
		LogText = "disapproved"
	end
	local LicenseName = FALICENSE_DATABASE[LID].Name
	MODULE:Log(GAS.Logging:FormatPlayer(Player) .. " " .. LogText .. " " .. GAS.Logging:FormatPlayer(MPlayer) .. " " .. LicenseName .. " application.")
end)

GAS.Logging:AddModule(MODULE)
