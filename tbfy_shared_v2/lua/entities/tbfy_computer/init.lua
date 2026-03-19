AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props/de_inferno/tableantique.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)

	local Phys = self:GetPhysicsObject()
	if Phys then
		Phys:EnableMotion(false)
	end

	local ChairDB = list.Get("Vehicles")["Chair_Plastic"];

	local Chair = ents.Create("prop_vehicle_prisoner_pod")
	Chair:SetPos(self:GetPos()+self:GetForward()*35)
	local Angles = self:GetAngles()
	Angles:RotateAroundAxis(self:GetUp(), 90)
	Chair:SetAngles(Angles)
	Chair:SetParent(self)
	Chair:SetModel(ChairDB.Model)
	Chair:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt");
	Chair:Spawn()
	Chair.PCChair = true
	self.Chair = Chair
	Chair:setKeysNonOwnable(true)

	if ChairDB.Members then table.Merge(Chair, ChairDB.Members); end
	if ChairDB.KeyValues then
		for k, v in pairs(ChairDB.KeyValues) do
			Chair:SetKeyValue(k, v);
		end
	end

	local Phys = Chair:GetPhysicsObject()
	if Phys then
		Phys:EnableMotion(false)
	end

	self:SetPCType(3)
	self:SetupPCData()
	self.LoggedIn = nil
	self:SetScreenStatus(1)
	self.TimeType = 1

	self.AccountNID = 1
	self.UsedAccounts = {}
	self.TBFY_Childs = self.TBFY_Childs or {}

	local Owner = self.dt.owning_ent
	if IsValid(Owner) then
		self:CPPISetOwner(self.dt.owning_ent)
	end
end

function ENT:InitPCType(PCType)
	if PCType then
		self:SetPCType(PCType)
		if PCType == 1 then
			self:SetScreenStatus(2)
			self.Logo = "nWhMT1O"
			self:SetAvatarID("nWhMT1O")
			self.Wallpaper = "BoJTOEI"
			self:SetWallpaperID("BoJTOEI")
		elseif PCType == 2 then
			self:SetScreenStatus(3)
			self.Logo = "ou7nSPE"
			self.Wallpaper = "Lkky8Pb"
			self:SetWallpaperID("Lkky8Pb")
		else
			self:SetScreenStatus(1)
		end
		self.LoggedIn = nil
	end
end

function ENT:InitPSpawn(Player)
	self:SetEOwner(Player)

	self.Softwares = {}
	self.JobsAllowed = {}
end

function ENT:SetupPCData()
	self:SetFirewall(true)
	self:ResetIP()
	self:ResetPassword()
end

function ENT:ResetIP()
	local IP = "192.168.0." .. math.random(1,9) .. math.random(1,9)
	self.IP = IP
	self:SetIP(IP)
end

local Chars = {}
local Amount = 0
for Loop = 48, 57 do
   Chars[Amount] = string.char(Loop)
   Amount = Amount+1
end
for Loop = 98, 122 do
   Chars[Amount] = string.char(Loop)
   Amount = Amount+1
end
local function TBFY_GeneratePassword(Length)
	local PW = ""
	for i = 0, Length do
		local RNum = math.random(0,Amount-1)
		PW = PW .. Chars[RNum]
	end
	return PW
end

function ENT:ResetPassword()
	self.password = TBFY_GeneratePassword(8)
end

function ENT:ToggleFirewall()
	self:SetFirewall(!self:GetFirewall())
end

function ENT:Use(activator, caller)
	if self.Tapped and self.Tapped > CurTime() then return false; end
	self.Tapped = CurTime() + 1;

	local InUse = self.Chair:GetDriver()
	if !InUse:IsPlayer() then
		activator.CanEChairPC = true
		activator:EnterVehicle(self.Chair)
		self.CPlayer = activator
		activator.CanEChairPC = false

		TBFY_SH:UsePC(activator, self)
	end
end

function ENT:Touch(TouchEnt)
end

function ENT:InitSettings(Logo, Wallpaper, TimeType)
	if Logo and Logo != "" then
		self.Logo = Logo
		self:SetAvatarID(Logo)
	end

	if Wallpaper and Wallpaper != "" then
		self.Wallpaper = Wallpaper
		self:SetWallpaperID(Wallpaper)
	end
	if TimeType != 0 then
		self.TimeType = TimeType
	end
end

hook.Add("SetupPlayerVisibility", "tbfy_spv_computer", function(Player)
	local PC = Player.TBFY_UsedPC
	if IsValid(PCPC) then
		local CPlayer = PC.CPlayer

		if PC.CPlayer == Player and Player:GetPos():Distance(PC:GetPos()) < 150 then
			if PC.TBFY_Childs and PC.TBFY_Childs.CCTV then
				for k,v in pairs(PC.TBFY_Childs.CCTV) do
					if IsValid(v) then
						AddOriginToPVS(v:GetPos())
					end
				end
			end
		end
	end
end)
