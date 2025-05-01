TBFY_SH.GArchiveTypes = TBFY_SH.GArchiveTypes or {}

function TBFY_SH:RegisterGArchive(Table)
	TBFY_SH.GArchiveTypes[Table.ID] = Table
end
