
resource.AddWorkshop("892601987")

util.AddNetworkString("fa_send_licenses")
util.AddNetworkString("fa_update_practical_license")
util.AddNetworkString("fa_update_carry_license")
util.AddNetworkString("fa_update_sell_license")
util.AddNetworkString("fa_open_amanagement")
util.AddNetworkString("fa_toggle_theory")
util.AddNetworkString("fa_toggle_practical")
util.AddNetworkString("fa_toggle_carry")
util.AddNetworkString("fa_toggle_sell")
util.AddNetworkString("fa_practical_test_menu")
util.AddNetworkString("fa_start_practical_test")
util.AddNetworkString("fa_update_practical_test")
util.AddNetworkString("fa_application_request_menu")
util.AddNetworkString("fa_application_request_send")
util.AddNetworkString("fa_application_examine_menu")
util.AddNetworkString("fa_application_request_examine_info")
util.AddNetworkString("fa_application_send_examine_info")
util.AddNetworkString("fa_application_action")
util.AddNetworkString("fa_update_instructor")
util.AddNetworkString("fa_toggle_instructor")
util.AddNetworkString("fa_open_insmanagement")

local PLAYER = FindMetaTable("Player")
local FA_Config = TBFY_FAConfig

hook.Add("Initialize", "CreateFALicenseTbls", function()
	file.CreateDir("firearmssystem")
	file.CreateDir("firearmssystem/practicaltests")

	if !sql.TableExists("tbfy_fa") then
		sql.Query("CREATE TABLE tbfy_fa (steamid varchar(255), license varchar(255), instructor int)")
	end
end)

hook.Add("bLogs_FullyLoaded","DI_bLogsInit",function()
	if ((not GAS or not GAS.Logging) and bLogs) then
		local MODULE = bLogs:Module()

		MODULE.Category = "ToBadForYou"
		MODULE.Name     = "Firearms License System"
		MODULE.Colour   = Color(125,35,35)

		MODULE:Hook("FA_ToggleInstructor","fa_toggleinstructor",function(Player, MPlayer)
			local LogText = "granted"
			if !MPlayer:FA_IsInstructor() then
				LogText = "revoked"
			end
			MODULE:Log(bLogs:FormatPlayer(Player) .. " " .. LogText .. " " .. bLogs:FormatPlayer(MPlayer) .. " instructor status.")
		end)

		MODULE:Hook("FA_ToggleLicense","fa_togglelicense",function(Player, MPlayer, LID, Bool, Type)
			local LogText = "granted"
			if !Bool then
				LogText = "revoked"
			end
			local LicenseName = FALICENSE_DATABASE[LID].Name
			MODULE:Log(bLogs:FormatPlayer(Player) .. " " .. LogText .. " " .. bLogs:FormatPlayer(MPlayer) .. " " .. LicenseName .. " " .. Type .. ".")
		end)

		MODULE:Hook("FA_ToggleTheory","fa_ToggleTheory",function(Player, MPlayer, LID, Granted)
			local LogText = "granted"
			if !Granted then
				LogText = "revoked"
			end
			local LicenseName = FALICENSE_DATABASE[LID].Name
			MODULE:Log(bLogs:FormatPlayer(Player) .. " " .. LogText .. " " .. bLogs:FormatPlayer(MPlayer) .. " " .. LicenseName .. " theory test.")
		end)

		MODULE:Hook("FA_Application","fa_applicaton",function(Player, LID, Carry, Sell)
			local Text = ""
			if Carry then
				Text = "carry license"
			end
			if Sell then
				if Text == "" then
					Text = "sell license"
				else
					Text = Text .. " and sell license"
				end
			end
			local LicenseName = FALICENSE_DATABASE[LID].Name
			MODULE:Log(bLogs:FormatPlayer(Player) .. " submitted an application for " .. LicenseName .. " " .. Text .. ".")
		end)

		MODULE:Hook("FA_Application_Action","fa_applicaton_action",function(Player, MPlayer, LID, Approved)
			local LogText = "approved"
			if !Approved then
				LogText = "disapproved"
			end
			local LicenseName = FALICENSE_DATABASE[LID].Name
			MODULE:Log(bLogs:FormatPlayer(Player) .. " " .. LogText .. " " .. bLogs:FormatPlayer(MPlayer) .. " " .. LicenseName .. " application.")
		end)

		bLogs:AddModule(MODULE)
	end
end)

FA_Instructors = FA_Instructors or {}
function PLAYER:LoadFALInformation()
  local SID = TBFY_SH:SID(self)
	local FALCompiledS = sql.Query("SELECT license, instructor FROM tbfy_fa WHERE steamid = ".. sql.SQLStr(SID) .."")

	if FALCompiledS then
		local Instructor = tonumber(FALCompiledS[1].instructor)

		if Instructor == 1 then
			FA_Instructors[SID] = Instructor
			net.Start("fa_update_instructor")
				net.WriteString(SID)
				net.WriteBool(true)
			net.Broadcast()
		end

		local Licenses = FALCompiledS[1].license
		DecompileFALicenses(Licenses, SID)
		net.Start("fa_send_licenses")
			net.WriteString(Licenses)
			net.WriteString(SID)
		net.Broadcast()
		self.FA_LicensesString = Licenses
	else
		sql.Query("INSERT INTO tbfy_fa (`steamid`, `instructor`)VALUES ('"..SID.."', '0')" )
		FALICENSE_PLAYERDB[SID] = {}

		net.Start("fa_send_licenses")
			net.WriteString("")
			net.WriteString(SID)
		net.Broadcast()
		self.FA_LicensesString  = ""
	end
	self.FA_Loaded = true
end

hook.Add("PlayerInitialSpawn", "LoadFALicensesInit", function(Player)
	Player:LoadFALInformation()

	timer.Simple(3, function()
		for k,v in pairs(player.GetAll()) do
      local SID = TBFY_SH:SID(v)
			if v:FA_IsInstructor() then
				net.Start("fa_update_instructor")
					net.WriteString(SID)
					net.WriteBool(true)
				net.Send(Player)
			end

			if v.FA_Loaded then
				net.Start("fa_send_licenses")
					net.WriteString(v.FA_LicensesString)
					net.WriteString(SID)
				net.Send(Player)
			end
		end
	end)
end)

function PLAYER:CompileFALicenses()
	local SaveString = ""
	for k,v in pairs(FALICENSE_PLAYERDB[TBFY_SH:SID(self)]) do
		SaveString = SaveString .. k .. ":" .. v.Practical .. ":" .. v.Carry .. ":" .. v.Sell .. ";"
	end
	self.FA_LicensesString = SaveString
	return SaveString
end

function PLAYER:SaveFALicenses()
	local ValueToSave = self:CompileFALicenses()
	sql.Query("UPDATE tbfy_fa SET license='"..ValueToSave.."' WHERE steamid='"..TBFY_SH:SID(self).."'")
end

function PLAYER:FA_SaveInstructor()
  local SID = TBFY_SH:SID(self)
	local Value = 0
	if FA_Instructors[SID] then
		Value = 1
	end
	sql.Query("UPDATE tbfy_fa SET instructor='" .. Value .. "' WHERE steamid='"..SID.."'")
end

function PLAYER:ToggleFALicensePractical(LID, OverrideRevoke)
	local SteamID = TBFY_SH:SID(self)
	FALICENSE_PLAYERDB[SteamID][LID] = FALICENSE_PLAYERDB[SteamID][LID] or {}

	local Bool = true
	if (OverrideRevoke == nil or OverrideRevoke == true) and self:FAPassedPractical(LID) then
		FALICENSE_PLAYERDB[SteamID][LID] = {Practical = 0, Carry = FALICENSE_PLAYERDB[SteamID][LID].Carry or 0, Sell = FALICENSE_PLAYERDB[SteamID][LID].Sell or 0}

		net.Start("fa_update_practical_license")
			net.WriteString(SteamID)
			net.WriteFloat(LID)
			net.WriteFloat(0)
		net.Broadcast()
	else
		FALICENSE_PLAYERDB[SteamID][LID] = {Practical = 1, Carry = FALICENSE_PLAYERDB[SteamID][LID].Carry or 0, Sell = FALICENSE_PLAYERDB[SteamID][LID].Sell or 0}

		net.Start("fa_update_practical_license")
			net.WriteString(SteamID)
			net.WriteFloat(LID)
			net.WriteFloat(1)
		net.Broadcast()
		Bool = false
	end
	self:SaveFALicenses()
end

function PLAYER:ToggleFALicenseCanCarry(LID)
	local SteamID = TBFY_SH:SID(self)
	FALICENSE_PLAYERDB[SteamID][LID] = FALICENSE_PLAYERDB[SteamID][LID] or {}

	Bool = true
	if self:FACanCarry(LID) then
		FALICENSE_PLAYERDB[SteamID][LID] = {Practical = FALICENSE_PLAYERDB[SteamID][LID].Practical or 0, Carry = 0, Sell = FALICENSE_PLAYERDB[SteamID][LID].Sell or 0}

		net.Start("fa_update_carry_license")
			net.WriteString(SteamID)
			net.WriteFloat(LID)
			net.WriteFloat(0)
		net.Broadcast()
	else
		FALICENSE_PLAYERDB[SteamID][LID] = {Practical = FALICENSE_PLAYERDB[SteamID][LID].Practical or 0, Carry = 1, Sell = FALICENSE_PLAYERDB[SteamID][LID].Sell or 0}

		net.Start("fa_update_carry_license")
			net.WriteString(SteamID)
			net.WriteFloat(LID)
			net.WriteFloat(1)
		net.Broadcast()
		Bool = false
	end
	self:SaveFALicenses()

	return Bool
end

function PLAYER:ToggleFALicenseCanSell(LID)
	local SteamID = TBFY_SH:SID(self)
	FALICENSE_PLAYERDB[SteamID][LID] = FALICENSE_PLAYERDB[SteamID][LID] or {}

	Bool = true
	if self:FACanSell(LID) then
		FALICENSE_PLAYERDB[SteamID][LID] = {Practical = FALICENSE_PLAYERDB[SteamID][LID].Practical or 0, Carry = FALICENSE_PLAYERDB[SteamID][LID].Carry or 0, Sell = 0}

		net.Start("fa_update_sell_license")
			net.WriteString(SteamID)
			net.WriteFloat(LID)
			net.WriteFloat(0)
		net.Broadcast()
	else
		FALICENSE_PLAYERDB[SteamID][LID] = {Practical = FALICENSE_PLAYERDB[SteamID][LID].Practical or 0, Carry = FALICENSE_PLAYERDB[SteamID][LID].Carry or 0, Sell = 1}

		net.Start("fa_update_sell_license")
			net.WriteString(SteamID)
			net.WriteFloat(LID)
			net.WriteFloat(1)
		net.Broadcast()
		Bool = false
	end
	self:SaveFALicenses()
	return Bool
end

function FA_LoadAddonInfo()
	local CurrentMap = string.lower(game.GetMap())

	if !FA_Practical_Targets then
		FA_Practical_Targets = {}
		if file.Exists( "firearmssystem/practicaltests/" .. CurrentMap .. ".txt" ,"DATA") then
			FA_Practical_Targets = util.JSONToTable(file.Read( "firearmssystem/practicaltests/" .. CurrentMap .. ".txt" ))
		end
	end
end
hook.Add("InitPostEntity", "fa_LoadAddonStuff", FA_LoadAddonInfo)

function FA_SavePracticeTargets(TargetsTbl, LID, StartPos, FinishPos)
	local TargetsToSave = TargetsTbl[LID]

	local ValuesToSave = {}
	for k,v in pairs(TargetsToSave) do
		local Index = 1
		ValuesToSave[k] = {}
		for m,n in pairs(v) do
			ValuesToSave[k][Index] = {Pos = n.FA_Pos, Ang = n.FA_Ang, VeliVec = n.VeliVector, STime = n.SwitchTime}
			Index = Index + 1
		end
	end
	ValuesToSave["Init"] = StartPos
	ValuesToSave["FinishPos"] = FinishPos

	local CurrentMap = string.lower(game.GetMap())
	local OldTaTbl = {}
	if file.Exists( "firearmssystem/practicaltests/" .. CurrentMap .. ".txt" ,"DATA") then
		OldTaTbl = util.JSONToTable(file.Read( "firearmssystem/practicaltests/" .. CurrentMap .. ".txt" ))
	end
	OldTaTbl[LID] = ValuesToSave

	FA_Practical_Targets = OldTaTbl

	file.Write("firearmssystem/practicaltests/" .. CurrentMap .. ".txt", util.TableToJSON(OldTaTbl))
end

net.Receive("fa_toggle_instructor", function(len, Player)
	if !Player:FA_AdminAccess() then return end
	local MPlayer = net.ReadEntity()
	if !IsValid(MPlayer) or !MPlayer:IsPlayer() then return end

	local SID = TBFY_SH:SID(MPlayer)
	if MPlayer:FA_IsInstructor() then
		FA_Instructors[SID] = nil
		MPlayer:FA_SaveInstructor()

		net.Start("fa_update_instructor")
			net.WriteString(SID)
			net.WriteBool(false)
		net.Broadcast()

		TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("InstructorRevoker"), MPlayer:Nick()))
		TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("InstructorRevoked"), Player:Nick()))
	else
		FA_Instructors[SID] = true
		MPlayer:FA_SaveInstructor()

		net.Start("fa_update_instructor")
			net.WriteString(SID)
			net.WriteBool(true)
		net.Broadcast()

		TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("InstructorGranter"), MPlayer:Nick()))
		TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("InstructorGranted"), Player:Nick()))
	end

	hook.Call("FA_ToggleInstructor", GAMEMODE, Player, MPlayer)
end)

net.Receive("fa_toggle_theory", function(len, Player)
	if Player:FA_AdminAccess() or (Player:FA_InstructorAccess() and FA_CheckInsAccess("Theory")) then
		local MPlayer, LicenseID = net.ReadEntity(), net.ReadFloat()
		if !IsValid(MPlayer) or !MPlayer:IsPlayer() then return end

    local SID = TBFY_SH:SID(MPlayer)
  	local LicenseTbl = FALICENSE_DATABASE[LicenseID]
  	local TestID = LicenseTbl.TheoryTest
  	local LicenseName = LicenseTbl.Name
  	local Granted = false

		if TBFY_SH:PlayerHasTheory(SID, TestID, LicenseID) then
      TBFY_SH:ToggleTheory(SID, TestID, LicenseID, nil)
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("TheoryTestRevoker"), MPlayer:Nick(), LicenseName))
			TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("TheoryTestRevoked"), Player:Nick(), LicenseName))
		else
      Granted = true
      TBFY_SH:ToggleTheory(SID, TestID, LicenseID, true)
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("TheoryTestGranter"), MPlayer:Nick(), LicenseName))
			TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("TheoryTestGranted"), Player:Nick(), LicenseName))
		end
    hook.Call("FA_ToggleTheory", GAMEMODE, Player, MPlayer, LicenseID, Granted)
	end
end)

net.Receive("fa_toggle_practical", function(len, Player)
	if Player:FA_AdminAccess() or (Player:FA_InstructorAccess() and FA_CheckInsAccess("Practical")) then
		local MPlayer, LicenseID = net.ReadEntity(), net.ReadFloat()
		if !IsValid(MPlayer) or !MPlayer:IsPlayer() then return end

		local LicenseName = FALICENSE_DATABASE[LicenseID].Name
		if MPlayer:FAPassedPractical(LicenseID) then
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("PracticalTestRevoker"), MPlayer:Nick(), LicenseName))
			TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("PracticalTestRevoked"), Player:Nick(), LicenseName))
		else
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("PracticalTestGranter"), MPlayer:Nick(), LicenseName))
			TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("PracticalTestGranted"), Player:Nick(), LicenseName))
		end
		local Bool = MPlayer:ToggleFALicensePractical(LicenseID)
		hook.Call("FA_ToggleLicense", GAMEMODE, Player, MPlayer, LicenseID, Bool, "license")
	end
end)

net.Receive("fa_toggle_carry", function(len, Player)
	if Player:FA_AdminAccess() or (Player:FA_InstructorAccess() and FA_CheckInsAccess("Carry")) then
		local MPlayer, LicenseID = net.ReadEntity(), net.ReadFloat()
		if !IsValid(MPlayer) or !MPlayer:IsPlayer() then return end

    local LicenseTbl = FALICENSE_DATABASE[LicenseID]
		local LicenseName = LicenseTbl.Name

		if !TBFY_SH:PlayerHasTheory(TBFY_SH:SID(MPlayer), LicenseTbl.TheoryTest, LicenseID) then
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("NoTheory"), MPlayer:Nick(), LicenseName))
			return false
		end
		if !MPlayer:FAPassedPractical(LicenseID) then
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("NoPractical"), MPlayer:Nick(), LicenseName))
			return false
		end

		if MPlayer:FACanCarry(LicenseID) then
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("CarryLicenseRevoker"), MPlayer:Nick(), LicenseName))
			TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("CarryLicenseRevoked"), Player:Nick(), LicenseName))
		else
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("CarryLicenseGranter"), MPlayer:Nick(), LicenseName))
			TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("CarryLicenseGranted"), Player:Nick(), LicenseName))
		end
		local Bool = MPlayer:ToggleFALicenseCanCarry(LicenseID)
		hook.Call("FA_ToggleLicense", GAMEMODE, Player, MPlayer, LicenseID, Bool, "carry license")
	end
end)

net.Receive("fa_toggle_sell", function(len, Player)
	if Player:FA_AdminAccess() or (Player:FA_InstructorAccess() and FA_CheckInsAccess("Sell")) then
		local MPlayer, LicenseID = net.ReadEntity(), net.ReadFloat()
		if !IsValid(MPlayer) or !MPlayer:IsPlayer() then return end
    local LicenseTbl = FALICENSE_DATABASE[LicenseID]
		local LicenseName = LicenseTbl.Name

		if !TBFY_SH:PlayerHasTheory(TBFY_SH:SID(MPlayer), LicenseTbl.TheoryTest, LicenseID) then
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("NoTheory"), MPlayer:Nick(), LicenseName))
			return false
		end
		if !MPlayer:FAPassedPractical(LicenseID) then
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("NoPractical"), MPlayer:Nick(), LicenseName))
			return false
		end

		if MPlayer:FACanSell(LicenseID) then
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("SellLicenseRevoker"), MPlayer:Nick(), LicenseName))
			TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("SellLicenseRevoked"), Player:Nick(), LicenseName))
		else
			TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("SellLicenseGranter"), MPlayer:Nick(), LicenseName))
			TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("SellLicenseGranted"), Player:Nick(), LicenseName))
		end
		local Bool = MPlayer:ToggleFALicenseCanSell(LicenseID)
		hook.Call("FA_ToggleLicense", GAMEMODE, Player, MPlayer, LicenseID, Bool, "sell license")
	end
end)

FA_DoingPractical = FA_DoingPractical or {}
net.Receive("fa_start_practical_test", function(len, Player)
	local TestID = net.ReadFloat()
	if IsValid(FA_DoingPractical[TestID]) then TBFY_Notify(Player, 1, 4, FA_GetLang("SomeoneDoingPracticalTest")) return end

	if Player:FAPassedPractical(TestID) then return end
	if !FA_Practical_Targets[TestID] then return end

	local TargetsTbl = FA_Practical_Targets[TestID]
	if !TargetsTbl then return end

	local LicenseTbl = FALICENSE_DATABASE[TestID]
	local Cost = LicenseTbl.PracticalCost
	if !Player:canAfford(Cost) then return end
	Player:addMoney(-Cost)

	FA_DoingPractical[TestID] = Player
	Player.FA_DoingPractical = TestID
	Player.FA_TargetScore = 0

	Player.FA_StageScoreReq = #TargetsTbl[1]
	Player.FA_CurStage = 1
	Player.FA_FinishPos = TargetsTbl["FinishPos"]

	local Wep = Player:Give(LicenseTbl.PracticalWeapon)
	timer.Simple(.1, function()
		if IsValid(Wep) then
			Wep:SetClip1(LicenseTbl.PracticalAmmoAmount)
			Player:SelectWeapon(LicenseTbl.PracticalWeapon)
		end
	end)
	Player:SetPos(TargetsTbl["Init"])

	for k,v in pairs(TargetsTbl[1]) do
		local Target = ents.Create("fa_target")
		Target:SetPos(v.Pos)
		Target:SetAngles(v.Ang)
		Target:Spawn()
		Target.Owner = Player

		Target.VeliVector = v.VeliVec
		Target.SwitchTime = v.STime
		Target.LID = TestID
		Target:FA_Enable()
	end

	local UniqueTimer = "tbfy_fa_" .. Player:UniqueID()
	if timer.Exists(UniqueTimer) then
		timer.Remove(UniqueTimer)
	end
	timer.Create(UniqueTimer, LicenseTbl.PracticalTime, 1, function()
		Player:FA_FailPractical()
	end)

	net.Start("fa_start_practical_test")
		net.WriteFloat(TestID)
		net.WriteFloat(Player.FA_StageScoreReq)
		net.WriteFloat(#TargetsTbl)
	net.Send(Player)
end)

hook.Add("PlayerSwitchWeapon", "fa_restrict_weaponswitch", function(Player, WeaponOld, WeaponNew)
	if Player.FA_DoingPractical and WeaponNew:GetClass() != FALICENSE_DATABASE[Player.FA_DoingPractical].PracticalWeapon then
		return true
	end
end)

function PLAYER:FA_PracticalUpdate()
	local UpdateClient = true
	self.FA_TargetScore = self.FA_TargetScore + 1
	if self.FA_TargetScore >= self.FA_StageScoreReq then
		self.FA_TargetScore = 0
		self.FA_CurStage = self.FA_CurStage + 1
		local TargetTbl = FA_Practical_Targets[self.FA_DoingPractical]
		if TargetTbl[self.FA_CurStage] then
			self.FA_StageScoreReq = #TargetTbl[self.FA_CurStage]
			for k,v in pairs(TargetTbl[self.FA_CurStage]) do
				local Target = ents.Create("fa_target")
				Target:SetPos(v.Pos)
				Target:SetAngles(v.Ang)
				Target:Spawn()

				Target.Owner = self
				Target.VeliVector = v.VeliVec
				Target.SwitchTime = v.STime
				Target.LID = self.FA_DoingPractical
				Target:FA_Enable()
			end
		else
			UpdateClient = false
			self:FA_FinishPractical()
		end
	end
	if UpdateClient then
		net.Start("fa_update_practical_test")
			net.WriteBool(false)
			net.WriteFloat(self.FA_TargetScore)
			net.WriteFloat(self.FA_CurStage)
			net.WriteFloat(self.FA_StageScoreReq)
		net.Send(self)
	end
end

function PLAYER:FA_CleanUpPractical()
	local LID = self.FA_DoingPractical
	FA_DoingPractical[LID] = nil
	self.FA_DoingPractical = nil
	self.FA_TargetScore = nil
	self.FA_StageScoreReq = nil
	self.FA_CurStage = nil
	self:StripWeapon(FALICENSE_DATABASE[LID].PracticalWeapon)

	for k,v in pairs(ents.FindByClass("fa_target")) do
		if v.Owner == self then
			v:Remove()
		end
	end

	local UniqueTimer = "tbfy_fa_" .. self:UniqueID()
	if timer.Exists(UniqueTimer) then
		timer.Remove(UniqueTimer)
	end

	net.Start("fa_update_practical_test")
		net.WriteBool(true)
		net.WriteFloat(0)
		net.WriteFloat(0)
	net.Send(self)
end

function PLAYER:FA_FinishPractical()
	if self.FA_FinishPos then
		self:SetPos(self.FA_FinishPos)
	end
	local LID = self.FA_DoingPractical
	self:FA_CleanUpPractical()

	local LicenseName = FALICENSE_DATABASE[LID].Name
	self:ToggleFALicensePractical(LID)

	TBFY_Notify(self, 1, 4, FA_GetLang("PracticalTestFinish") .. LicenseName)
end

function PLAYER:FA_FailPractical()
	if self.FA_FinishPos then
		self:SetPos(self.FA_FinishPos)
	end
	local LID = self.FA_DoingPractical
	self:FA_CleanUpPractical()

	local LicenseName = FALICENSE_DATABASE[LID].Name

	TBFY_Notify(self, 1, 4, FA_GetLang("PracticalTestFail") .. LicenseName)
end

FA_Application_Requests = FA_Application_Requests or {}
net.Receive("fa_application_request_send", function(len, Player)
	local LID, Carry, Sell = net.ReadFloat(), net.ReadBool(), net.ReadBool()

	FA_Application_Requests[Player:SteamID()] = {Player = Player, Nick = Player:Nick(), LID = LID, Carry = Carry, Sell = Sell}
	TBFY_Notify(Player, 1, 4, FA_GetLang("ApplicationRequestSent"))

	for k,v in pairs(player.GetAll()) do
		if v:FA_ExamineMenuAccess() then
			TBFY_Notify(v, 1, 4, FA_GetLang("ApplicationRequestArrived"))
		end
	end

	hook.Call("FA_Application", GAMEMODE, Player, LID, Carry, Sell)
end)

net.Receive("fa_application_request_examine_info", function(len, Player)
	local PSteamID = net.ReadString()
	local AppTbl = FA_Application_Requests[PSteamID]

	if AppTbl then
		net.Start("fa_application_send_examine_info")
			net.WriteTable(AppTbl)
		net.Send(Player)
	end
end)

net.Receive("fa_application_action", function(len, Player)
	local SteamID, Approved = net.ReadString(), net.ReadBool()
	local AppTbl = FA_Application_Requests[SteamID]
	if !AppTbl then return end

	local MPlayer = AppTbl.Player
	if !IsValid(MPlayer) or !Player:FA_ExamineMenuAccess() or Player == MPlayer then return end

	local LicenseName = FALICENSE_DATABASE[AppTbl.LID].Name
	if Approved then
		if AppTbl.Carry then
			MPlayer:ToggleFALicenseCanCarry(AppTbl.LID)
		end

		if AppTbl.Sell then
			MPlayer:ToggleFALicenseCanSell(AppTbl.LID)
		end

		TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("AppApprover"), MPlayer:Nick(), LicenseName))
		TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("AppApproved"), Player:Nick(), LicenseName))
	else
		TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("AppDisapprover"), MPlayer:Nick(), LicenseName))
		TBFY_Notify(MPlayer, 1, 4, string.format(FA_GetLang("AppDisapproved"), Player:Nick(), LicenseName))
	end

	hook.Call("FA_Application_Action", GAMEMODE, Player, MPlayer, AppTbl.LID, Approved)
	FA_Application_Requests[SteamID] = nil
end)

hook.Add("PlayerDisconnected", "fa_disconnect_player", function(Player)
	if Player.FA_DoingPractical then
		Player:FA_CleanUpPractical()
	end
end)

hook.Add("PlayerLoadout", "fa_grantlicense", function(Player)
	Player:Give("firearms_license")
end)

hook.Add("PlayerSay", "fa_checkmenuchat", function(Player, Text)
	local FA_Config = TBFY_FAConfig

	if Player:FA_AdminAccess() then
		if table.HasValue(FA_Config.AdminChatCommands, Text) then
			net.Start("fa_open_amanagement")
			net.Send(Player)
			return ""
		end
	end
	if Player:FA_InstructorAccess() then
		if table.HasValue(FA_Config.InstructorChatCommands, Text) then
			net.Start("fa_open_insmanagement")
			net.Send(Player)
			return ""
		end
	end
	if Player:FA_ExamineMenuAccess() then
		if table.HasValue(FA_Config.ApplicationExamineChatCommands, Text) then
			local PlayerNicks = {}
			for k,v in pairs(FA_Application_Requests) do
				PlayerNicks[k] = v.Nick
			end
			net.Start("fa_application_examine_menu")
				net.WriteTable(PlayerNicks)
			net.Send(Player)
			return ""
		end
	end
end)

hook.Add("PlayerCanPickupWeapon", "fa_restrict_weapon_pickup", function(Player, Weapon)
	local PracTest = Player.FA_DoingPractical
	local WepClass = Weapon:GetClass()
	local TestWep = nil
	local FA_Config = TBFY_FAConfig
	local WepWH = FA_Config.WeaponWhitelist
	if WepWH[WepClass] == true or (WepWH[WepClass] and WepWH[WepClass][Player:Team()]) then return end

	if PracTest then
		TestWep = FALICENSE_DATABASE[PracTest].PracticalWeapon
	end

	if !PracTest and WepClass != TestWep then
		local LReq = FA_Config.WeaponDB[WepClass]
		local ResType = FA_Config.WeaponRestrictionType

		if ((LReq and !Player:FACanCarry(LReq)) or (FA_Config.ShouldRestrictDefault and !Player:FACanCarry(FA_Config.DefaultRestrictLicense))) then
			LicenseName = FALICENSE_DATABASE[FA_Config.DefaultRestrictLicense].Name
			if LReq then
				LicenseName = FALICENSE_DATABASE[LReq].Name
			end

			if ResType == 2 then
				TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("ReqLicense"), LicenseName))
			elseif ResType == 3 then
				TBFY_Notify(Player, 1, 4, string.format(FA_GetLang("ReqLicense"), LicenseName))
				return false
			end
		end
	end
end)

hook.Add("PlayerDeath", "fa_dodeath", function(Player)
	if Player.FA_DoingPractical then
		Player:FA_FailPractical()
	end
end)

hook.Add("playerCanChangeTeam", "fa_CantChangeDuringTest", function(Player)
	if Player.FA_DoingPractical then
		return false, FA_GetLang("PracticalCantSwitchJob")
	end
end)

local TGBlacklist = {"fa_target", "fa_practicaltest_npc", "fa_application_npc"}
hook.Add("CanTool", "fa_DisableRemovingEntsTool", function(Player, trace, tool)
	if tool == "fa_targets" and !Player:FA_AdminAccess() then return false end

	local ent = trace.Entity

	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:FA_AdminAccess() then
			return false
		end
	end
end)

hook.Add("CanProperty", "fa_DisableRemovingEntsProperty", function(Player, stringproperty, ent)
	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:FA_AdminAccess() then
			return false
		end
	end
end)

hook.Add("canPocket", "fa_RestrictPocketing", function(Player, Ent)
    if table.HasValue(TGBlacklist, Ent:GetClass()) then
	    return false, "You can't put that in your pocket!"
	end
end)

hook.Add("TBFY_FinishedTheory", "FA_TrackTheory", function(Player, TheoryID, LicenseID)
	if FA_GetConf("LICENSE_GrantLicenseOnTheoryComplete") and FA_TheoryIDs[TheoryID] then
		Player:ToggleFALicensePractical(LicenseID, false)
	end
end)
