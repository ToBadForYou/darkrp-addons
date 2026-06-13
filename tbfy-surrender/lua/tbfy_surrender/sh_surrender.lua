
local PLAYER = FindMetaTable("Player")

function PLAYER:TBFY_CanSurrender()
	if !self:Alive() or self:InVehicle() or self.Restrained or self.RKRestrained then return false end

	local weapon = self:GetActiveWeapon()
	if !IsValid(weapon) or TBFYSurrenderConfig.SurrenderWeaponWhitelist[weapon:GetClass()] then
		return false
	else
		return true
	end
end