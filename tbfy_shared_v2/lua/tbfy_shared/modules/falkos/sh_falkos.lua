TBFY_SH.CSoftwares = TBFY_SH.CSoftwares or {}

function TBFY_SH:RegisterCSoftware(Software)
	TBFY_SH.CSoftwares[Software.ID] = Software
end

function TBFY_SH:SoftwareInstalled(Entity, SoftID)
	if SERVER then
		local SID = Entity
		if type(Entity) == "string" then
		elseif Entity:IsPlayer() then
			SID = TBFY_SH:SID(Entity)
		elseif Entity:GetPCType() != 3 then
			return Entity.Softwares[SoftID]
		end
			local Account = TBFY_SH.ComputerAccounts[SID]
			return Account.Programs[SoftID]
	end
end
