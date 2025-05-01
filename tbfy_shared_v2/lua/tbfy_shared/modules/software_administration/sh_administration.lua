TBFY_SH.CompAdmin = TBFY_SH.CompAdmin or {Actions = {}, Category = {}, Functions = {}}

function TBFY_SH:RegisterCompAdminAction(Table)
	local ID = table.Count(TBFY_SH.CompAdmin.Actions)+1
	TBFY_SH.CompAdmin.Actions[ID] = Table
end

function TBFY_SH:RegisterCompAdminCategory(Table)
	local ID = table.Count(TBFY_SH.CompAdmin.Category)+1
	TBFY_SH.CompAdmin.Category[ID] = Table
end

function TBFY_SH:RegisterCompAdminFunction(Table)
	TBFY_SH.CompAdmin.Functions[Table.Idf] = Table
end
