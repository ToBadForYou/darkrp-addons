
util.AddNetworkString("tbfy_notify")
util.AddNetworkString("tbfy_sendmsg")

local PLAYER = FindMetaTable("Player")

function TBFY_Notify(Player, msgtype, len, msg)
    net.Start("tbfy_notify")
        net.WriteString(msg)
        net.WriteFloat(msgtype)
        net.WriteFloat(len)
    net.Send(Player)
end

function TBFY_SH:SendMessage(Player, msgType, msg)
  if IsValid(Player) then
    net.Start("tbfy_sendmsg")
      net.WriteString(msgType)
      net.WriteString(msg)
    net.Send(Player)
  end
end

local function clearFunctions(table)
  local newTable = {}
	for k, v in pairs(table) do
		if !isfunction(v) then
			newTable[k] = v
		elseif istable(v) then
			newTable[k] = clearFunctions(v)
		end
	end
	return newTable or {}
end

function TBFY_SH:CopyEntityTable(entity, includeFunctions)
  local entTable = entity:GetTable() or {}
  if includeFunctions then
    return entTable
  else
    return clearFunctions(entTable)
  end
end

function TBFY_SH:ApplyEntityTable(entity, table)
  for key,value in pairs(table) do
    entity[key] = value
  end
end

function TBFY_SH:CopyNetworkVars(entity)
  local networkVars = entity:GetNetworkVars()
  local table = {}
  if networkVars then
    for key, val in pairs(networkVars) do
      table["Set" .. key] = val
    end
  end
  return table
end

function TBFY_SH:ApplyNetworkVar(entity, table)
  for key,value in pairs(table) do
    entity[key](entity, value)
  end
end

function TBFY_SH:SaveSQLite(SID, Table, Index, Value)
  local String = ""
  for k,v in pairs(Index) do
    if String == "" then
      String = Index[k] .. "='" .. Value[k] .. "'"
    else
      String = String .. "," .. Index[k] .. "='" .. Value[k] .. "'"
    end
  end
	sql.Query("UPDATE '" .. Table .. "' SET " .. String .. " WHERE steamid='"..SID.."'")
end

function TBFY_SH:CheckExpiredDays(Time, Days)
	local CTime = os.time()
	local CDays = math.floor(CTime/(60*60*24))
	local ODays = math.floor(Time/(60*60*24))

	local Dif = CDays-ODays
	if Dif >= Days then
		return false
	else
		return true
	end
end

//Since some addons don't allow nil values as actor
function PLAYER:DKRP_wanted(actor, reason, time, suppressMsg)
    self:setDarkRPVar("wanted", true)
    self:setDarkRPVar("wantedReason", reason)

    timer.Create(self:SteamID64() .. " wantedtimer", time or GAMEMODE.Config.wantedtime, 1, function()
        if not IsValid(self) then return end
        self:unWanted()
    end)

    if suppressMsg then return end

    local actorNick = IsValid(actor) and actor:Nick() or DarkRP.getPhrase("disconnected_player")
    local centerMessage = DarkRP.getPhrase("wanted_by_police", self:Nick(), reason, actorNick)
    local printMessage = DarkRP.getPhrase("wanted_by_police_print", actorNick, self:Nick(), reason)

    for _, ply in pairs(player.GetAll()) do
        ply:PrintMessage(HUD_PRINTCENTER, centerMessage)
        ply:PrintMessage(HUD_PRINTCONSOLE, printMessage)
    end

    DarkRP.log(string.Replace(printMessage, "\n", " "), Color(0, 150, 255))
end

concommand.Add("tbfy_materials", function(Player, CMD, Args)
  if !Player:TBFY_AdminAccess() then return end

  local ModelPath = Args[1]
  local OldModel = Player:GetModel()
  Player:SetModel(ModelPath)
  PrintTable(Player:GetMaterials())
  Player:SetModel(OldModel)
end)

concommand.Add("tbfy_bones", function(Player, CMD, Args)
  if !Player:TBFY_AdminAccess() then return end

  local ModelPath = Args[1]
  local OldModel = Player:GetModel()
  Player:SetModel(ModelPath)
  for i = 1, Player:GetBoneCount() do
    print(i .. " = " .. Player:GetBoneName(i))
  end
  Player:SetModel(OldModel)
end)
