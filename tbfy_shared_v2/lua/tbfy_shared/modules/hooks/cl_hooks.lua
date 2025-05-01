
hook.Add("PostPlayerDraw", "TBFY_PostPlayerDraw", function(Player)
	if LocalPlayer() != Player then
		TBFY_SH:DrawPlayerEquips(Player)
	end
end)
