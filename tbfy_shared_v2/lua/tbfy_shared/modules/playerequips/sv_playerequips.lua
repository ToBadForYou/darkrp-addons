util.AddNetworkString("tbfy_TogglePEquip")
util.AddNetworkString("tbfy_ClearPEquip")

function TBFY_SH:TogglePEquip(Player, EID, Equip)
	local SID = TBFY_SH:SID(Player)
	net.Start("tbfy_TogglePEquip")
		net.WriteString(EID)
		net.WriteBool(Equip)
		net.WriteString(SID)
	net.Broadcast()

	TBFY_SH.PEquips[SID] = TBFY_SH.PEquips[SID] or {}
	TBFY_SH.PEquips[SID][EID] = Equip
end
