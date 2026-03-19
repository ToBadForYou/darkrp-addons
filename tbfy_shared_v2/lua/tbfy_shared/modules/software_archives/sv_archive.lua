util.AddNetworkString("tbfy_archive_senddata")

TBFY_SH.GArchives = TBFY_SH.GArchives or {}
TBFY_SH.GArchives_Updated = TBFY_SH.GArchives_Updated or {}

function TBFY_SH:AddToGArchive(Type, SID, Actor, Reason)
	local Time = os.time()
	Type = tonumber(Type)
	Reason = sql.SQLStr(Reason)
	sql.Query("INSERT INTO tbfy_archives (`steamid`, `type`, `actor`, `reason`, `time`) VALUES('"..SID.."', '"..Type.."', '"..Actor.."', "..Reason..", '"..Time.."')")
	TBFY_SH.GArchives[SID][Type] = TBFY_SH.GArchives[SID][Type] or {}
	table.insert(TBFY_SH.GArchives[SID][Type], {actor = Actor, reason = Reason, time = Time})

	if TBFY_SH.GArchives_Updated[SID][ID] then
		TBFY_SH.GArchives_Updated[SID][ID] = nil
	end
end

function TBFY_SH:LoadGArchives(Player)
	local SID = TBFY_SH:SID(Player)
	TBFY_SH.GArchives[SID] = {}
	TBFY_SH.GArchives_Updated[SID] = {}

	local CData = sql.Query("SELECT type, actor, reason, time FROM tbfy_archives WHERE steamid = '".. SID .."'")
	if CData then
		for k,v in pairs(CData) do
			local CheckOld = TBFY_SH:CheckExpiredDays(v.time, TBFY_SH.Config.ArchiveDaysExpire)
			if CheckOld then
				v.type = tonumber(v.type)
				TBFY_SH.GArchives[SID][v.type] = TBFY_SH.GArchives[SID][v.type] or {}
				table.insert(TBFY_SH.GArchives[SID][v.type], {actor = v.actor, reason = v.reason, time = v.time})
			else
				sql.Query("DELETE FROM tbfy_archives WHERE steamid = '".. SID .."' AND time = '" .. v.time .. "'")
			end
		end
	end
end

function TBFY_SH:ArchiveSoftware(Player, SoftID)
	local SID = net.ReadString()
	local PlayersSID = TBFY_SH:SID(Player)
	local Data = TBFY_SH.GArchives[SID]
	if Data then
		net.Start("tbfy_archive_senddata")
			net.WriteString(SoftID)
			net.WriteString(SID)
			net.WriteUInt(table.Count(Data), 4)
			for ID,Tbl in pairs(Data) do
				net.WriteUInt(ID, 4)

				local ShouldUpdate = true
				if TBFY_SH.GArchives_Updated[SID][ID] and TBFY_SH.GArchives_Updated[SID][ID][PlayersSID] then
					ShouldUpdate = false
				end
				net.WriteBool(ShouldUpdate)

				if ShouldUpdate then
					TBFY_SH.GArchives_Updated[SID][ID] = TBFY_SH.GArchives_Updated[SID][ID] or {}
					TBFY_SH.GArchives_Updated[SID][ID][PlayersSID] = true
					net.WriteUInt(table.Count(Tbl), 32)
					for k,v in pairs(Tbl) do
						net.WriteString(v.actor)
						net.WriteString(v.reason)
						net.WriteUInt(v.time, 32)
					end
				end
			end
		net.Send(Player)
	end

	for k,v in pairs(TBFY_SH.GArchiveTypes) do
		local Func = v.DataFunc
		if Func then
			TBFY_SH[Func](self, Player, SoftID, v.ID, SID)
		end
	end
end
