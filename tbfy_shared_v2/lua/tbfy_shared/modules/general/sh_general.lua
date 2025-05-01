
local PLAYER = FindMetaTable("Player")

function PLAYER:TBFY_AdminAccess()
	return TBFY_SH.Config.AdminAccessCustomCheck(self)
end

function PLAYER:DKRP_isWarranted()
    return self:getDarkRPVar("warrant")
end

function TBFY_SH:SID(Player)
	if Player:IsBot() then
		return Player:Nick()
	else
		return Player:SteamID()
	end
end

function TBFY_SH:NearEntity(Player, Ent)
	local PPos, EntPos = Player:GetPos(), Ent:GetPos()
	if PPos:Distance(EntPos) < 150 then
		return true
	else
		return false
	end
end

local DoorsC = {
	["func_door_rotating"] = true,
	["func_door"] = true,
	["prop_door_rotating"] = true,
}
function TBFY_IsDoor(Ent)
	local Class = Ent:GetClass()
	return	DoorsC[Class]
end

function TBFY_TimeToString(Time)
	local s = Time % 60
	Time = math.floor(Time / 60)
	local m = Time % 60
	Time = math.floor(Time / 60)

	return string.format("%02i:%02i", m, s)
end

//Borrowed from DarkRP
function TBFY_isEmpty(vector, ignore, CheckRadie, CheckAll)
    ignore = ignore or {}

    local point = util.PointContents(vector)
    local a = point ~= CONTENTS_SOLID
        and point ~= CONTENTS_MOVEABLE
        and point ~= CONTENTS_LADDER
        and point ~= CONTENTS_PLAYERCLIP
        and point ~= CONTENTS_MONSTERCLIP
    if not a then return false end

    local b = true
	local Radie = CheckRadie or 35
    for k,v in pairs(ents.FindInSphere(vector, Radie)) do
        if (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics" or v.NotEmptyPos or CheckAll) and not table.HasValue(ignore, v) then
            b = false
            break
        end
    end

    return a and b
end

//Borrowed from DarkRP
function TBFY_findEmptyPos(pos, ignore, distance, step, area)
    if TBFY_isEmpty(pos, ignore) and TBFY_isEmpty(pos + area, ignore) then
        return pos
    end

    for j = step, distance, step do
        for i = -1, 1, 2 do -- alternate in direction
            local k = j * i

            -- Look North/South
            if TBFY_isEmpty(pos + Vector(k, 0, 0), ignore) and TBFY_isEmpty(pos + Vector(k, 0, 0) + area, ignore) then
                return pos + Vector(k, 0, 0)
            end

            -- Look East/West
            if TBFY_isEmpty(pos + Vector(0, k, 0), ignore) and TBFY_isEmpty(pos + Vector(0, k, 0) + area, ignore) then
                return pos + Vector(0, k, 0)
            end

            -- Look Up/Down
            if TBFY_isEmpty(pos + Vector(0, 0, k), ignore) and TBFY_isEmpty(pos + Vector(0, 0, k) + area, ignore) then
                return pos + Vector(0, 0, k)
            end
        end
    end

    return pos
end
