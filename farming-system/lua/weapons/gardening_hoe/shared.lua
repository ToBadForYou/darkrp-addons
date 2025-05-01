if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Garden Hoe"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "ToBadForYou"
SWEP.Instructions = "Left Click: Create a plot."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.HoldType = "melee";
SWEP.ViewModel = "models/weapons/v_crowbar.mdl";
SWEP.WorldModel = "models/weapons/w_crowbar.mdl";

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "melee"
SWEP.Category = "ToBadForYou"
SWEP.UID = {{ user_id }}

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize() self:SetWeaponHoldType("melee") end
function SWEP:CanPrimaryAttack ( ) return true; end

local function TraceUp ( vec )
	local trace = {};
	trace.start = vec;
	trace.endpos = vec + Vector(0, 0, 999999999);
	trace.mask = MASK_SOLID_BRUSHONLY;
	
	return util.TraceLine(trace);
end

function InsidePlantingZone(pPos)
	local PlantingZone = false

	for k, v in pairs(FarmingAreas) do
		local minVec = Vector(math.Min(v[1].x, v[2].x), math.Min(v[1].y, v[2].y), math.Min(v[1].z, v[2].z));
		local maxVec = Vector(math.Max(v[1].x, v[2].x), math.Max(v[1].y, v[2].y), math.Max(v[1].z, v[2].z));
		
		if (pPos.x >= minVec.x && pPos.y >= minVec.y && pPos.x <= maxVec.x && pPos.y <= maxVec.y) then
			PlantingZone = true
			break;
		end
	end

	return PlantingZone
end

function AimDirt(TraceData)
if TraceData.MatType == MAT_DIRT or TraceData.MatType == MAT_GRASS then
    return true
else
    return false	
end
end

function SWEP:PrimaryAttack()
	if SERVER then
		local Trace = self.Owner:GetEyeTrace()
		
		self.Weapon:SetNextPrimaryFire(CurTime() + 5)
		self.Weapon:SetNextSecondaryFire(CurTime() + 5)
				
		if Trace.HitWorld and TraceUp(Trace.HitPos).HitSky and ((AimDirt(Trace) and !FarmingRestrictToAreas) or InsidePlantingZone(Trace.HitPos)) then
			local Nearbyplot = false
			for k, v in pairs(ents.FindInSphere(Trace.HitPos, 50)) do
				if !v:GetClass() then return end
				if v:GetClass() == 'farming_plot' then
					Nearbyplot = true
				end
			end	
			
            if !Nearbyplot and self.Owner:GetPos():Distance(Trace.HitPos) < 250 then		
				self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)			
				local AngleDirt = Trace.HitNormal + Trace.HitNormal:Angle():Up() + Trace.HitNormal:Angle():Forward()*-1
				local Plot = ents.Create('farming_plot')
				Plot:SetPos(Trace.HitPos + Vector(0,0,-1))
				Plot:SetAngles(AngleDirt:Angle())
				Plot.SID = self.Owner.SID
				Plot:Spawn()		
            end			
		end			
    end	
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack();
end
