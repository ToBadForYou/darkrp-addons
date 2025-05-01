util.AddNetworkString("tbfy_comp_loginscreen")
util.AddNetworkString("tbfy_comp_login")
util.AddNetworkString("tbfy_computer_cmd")
util.AddNetworkString("tbfy_manage_accountinfo")
util.AddNetworkString("tbfy_logout")
util.AddNetworkString("tbfy_computer_run")
util.AddNetworkString("tbfy_toggle_software")
util.AddNetworkString("tbfy_computer_updateentities")

TBFY_SH.ComputerAccounts = TBFY_SH.ComputerAccounts or {}

function TBFY_SH:LoadCAccount(Player)
	local SID = TBFY_SH:SID(Player)
	local CData = sql.Query("SELECT username, password, programs, data FROM tbfy_computer WHERE steamid = '".. SID .."'")
	if CData and CData[1] then
		TBFY_SH:LoadCAccountData(SID, CData[1])
	else
		sql.Query("INSERT INTO tbfy_computer (`steamid`, `username`, `password`) VALUES('"..SID.."', 'Default', '123')")
		TBFY_SH.ComputerAccounts[SID] = {Username = "Default", Password = "123", Avatar = "", Wallpaper = "", Programs = {}}
	end
end

function TBFY_SH:LoadCAccountData(SID, CData)
	local UN, PW, Programs, Data = CData.username, CData.password, CData.programs, CData.data

	local DataExplode = {}
	if Data and Data != "NULL" then
		DataExplode = string.Explode(";", Data)
	end
	local AV, WP, TT = DataExplode[1] or "", DataExplode[2] or "", tonumber(DataExplode[3]) or 1

	local ProgramsExplode = {}
	if Programs and Programs != "NULL" then
		ProgramsExplode = string.Explode(";", Programs)
	end

	InstalledP = {}
	for k,v in pairs(ProgramsExplode) do
		if v != "" then
			InstalledP[v] = true
		end
	end

	TBFY_SH.ComputerAccounts[SID] = {Username = UN, Password = PW, Avatar = AV, Wallpaper = WP, TimeType = TT, Programs = InstalledP}
end

function TBFY_SH:UpdateCAccountData(SID, Type)
	local SQLString = ""
	for k,v in pairs(Type) do
		safe_v = v
		if isstring(v) then
			safe_v = sql.SQLStr(v)
			SQLString = SQLString .. k .. "=" .. safe_v .. ","
		else
			SQLString = SQLString .. k .. "='" .. safe_v .. "',"
		end
	end

	local Len = string.len(SQLString)
	local FSQLString = string.sub(SQLString, 1, Len-1)
	sql.Query("UPDATE tbfy_computer SET " .. FSQLString .. " WHERE steamid='" .. SID .. "'")
end

function TBFY_SH:CompileCAccountPrograms(SID)
	local Programs = TBFY_SH.ComputerAccounts[SID].Programs
	local CString = ""
	for k,v in pairs(Programs) do
		CString = CString .. k .. ";"
	end
	return CString
end

function TBFY_SH:CompileCAccountData(SID)
	local Account = TBFY_SH.ComputerAccounts[SID]
	local CString = Account.Avatar .. ";" .. Account.Wallpaper .. ";" .. Account.TimeType
	return CString
end

function TBFY_SH:ExitPC(Player, PCChair)
	local PC = Player.TBFY_UsedPC
	if IsValid(PC) then
		if PC:GetPCType() == 1 then
			PC.LoggedIn = nil
		end
		PC.CPlayer = nil
		Player.TBFY_UsedPC = nil
	end
end

function TBFY_SH:LoginPC(Player, SID, AllowLogin)
	local PC = Player.TBFY_UsedPC
	local SoftDB = TBFY_SH.CSoftwares
	local PCType = PC:GetPCType()

	local SInstalled = {}
	for k,v in pairs(SoftDB) do
		if ((v.PCType and v.PCType[PCType]) or !v.PCType) and v.Default then
			SInstalled[k] = true
		end
	end

	if !SID then
		SID = PC.LoggedIn
	end

	local Account, Avatar, Wallpaper, TimeType, UserN = nil, "", "", 1, ""
	if PCType == 1 or PCType == 2 then
		Avatar = PC.Logo
		Wallpaper = PC.Wallpaper
		if PC.TimeType then
			TimeType = PC.TimeType
		end
		for k,v in pairs(PC.Softwares) do
			if SoftDB[k] and ((SoftDB[k].PCType and SoftDB[k].PCType[PCType]) or !SoftDB[k].PCType) then
				SInstalled[k] = true
			end
		end
	else
		Account = TBFY_SH.ComputerAccounts[SID]
		Avatar, Wallpaper, TimeType, UserN = Account.Avatar, Account.Wallpaper, Account.TimeType, Account.Username
		for k,v in pairs(Account.Programs) do
			SInstalled[k] = true
		end
	end

	PC:SetWallpaperID(Wallpaper)

	net.Start("tbfy_comp_login")
		net.WriteString(SID)
		net.WriteEntity(PC)
		net.WriteBool(AllowLogin)
		net.WriteString(Avatar)
		net.WriteString(Wallpaper)
		net.WriteFloat(TimeType)
		net.WriteString(UserN)
		net.WriteFloat(table.Count(SInstalled))
		for k,v in pairs(SInstalled) do
			net.WriteString(k)
		end
	net.Send(Player)
end

function TBFY_SH:CanUsePC(Player, PC, DontCheckPW)
	if !TBFY_SH:NearEntity(Player, PC) then return false end
	local AllowedUse = false
	if PC.JobsAllowed[Player:Team()] or PC:GetEOwner() == Player then
		AllowedUse = true
	end
	if !DontCheckPW and !AllowedUse and Player.TBFY_CompPW and Player.TBFY_CompPW == PC.password then
		AllowedUse = true
	end
	return AllowedUse
end

function TBFY_SH:UsePC(Player, PC)
	Player.TBFY_UsedPC = PC
	local PCType = PC:GetPCType()
	if PCType == 3 and PC.LoggedIn then
		TBFY_SH:LoginPC(Player, PC.LoggedIn, true)
	elseif PCType == 2 then
		TBFY_SH:LoginPC(Player, "", true)
	else
		local Accounts = PC.UsedAccounts
		local AccAmount = table.Count(Accounts)
		net.Start("tbfy_comp_loginscreen")
			net.WriteFloat(PCType)
			if PCType != 3 then
				net.WriteString(PC.Logo)
			else
				net.WriteFloat(AccAmount)
				for k,v in pairs(Accounts) do
					local AccountInfo = TBFY_SH.ComputerAccounts[k]
					if AccountInfo then
						net.WriteString(k)
						net.WriteString(AccountInfo.Username)
						net.WriteString(AccountInfo.Avatar)
					end
				end
			end
		net.Send(Player)
	end
end

function TBFY_SH:PC_Function(Player, SID)
	local PC = Player.TBFY_UsedPC
	local PCType = PC:GetPCType()
	local Action = net.ReadString()
	if Action == "ToggleSoftware" and SID != "" then
		local Toggle, SoftID = net.ReadBool(), net.ReadString()
		local SoftStatus = TBFY_SH:SoftwareInstalled(SID, SoftID)
		if SoftStatus != Toggle then
			net.Start("tbfy_toggle_software")
				net.WriteString("Falkstore")
				net.WriteString(SoftID)
				net.WriteBool(Toggle)
			net.Send(Player)

			if !Toggle then
				TBFY_SH.ComputerAccounts[SID].Programs[SoftID] = nil
			else
				TBFY_SH.ComputerAccounts[SID].Programs[SoftID] = true
			end
			TBFY_SH:UpdateCAccountData(SID, {["programs"] = TBFY_SH:CompileCAccountPrograms(SID)})
		end
	elseif Action == "AccountDetails" then
		local Wallpaper, Avatar, TimeType, UN = net.ReadString(), net.ReadString(), net.ReadFloat(), net.ReadString()
		if PCType != 3 and Player:TBFY_AdminAccess() then
			PC:InitSettings(Avatar, Wallpaper, TimeType)
		elseif SID != "" then
			if Avatar != "" then
				TBFY_SH.ComputerAccounts[SID].Avatar = Avatar
			end
			if Wallpaper != "" then
				TBFY_SH.ComputerAccounts[SID].Wallpaper = Wallpaper
			end
			if TimeType != 0 then
				TBFY_SH.ComputerAccounts[SID].TimeType = TimeType
			end
			if UN != "" then
				TBFY_SH.ComputerAccounts[SID].Username = UN
				TBFY_SH:UpdateCAccountData(SID, {["username"] = UN})
			end
			TBFY_SH:UpdateCAccountData(SID, {["data"] = TBFY_SH:CompileCAccountData(SID)})
		end
	elseif Action == "ToggleFalkwall" then
		if PCType == 1 or !PC:GetFirewall() then
			PC:ToggleFirewall()
			if PCType == 3 then
				PC.UsedAccounts[SID].Falkwall = PC:GetFirewall()
			end
		end
	elseif Action == "ResetIP" and PCType == 1 then
		PC:ResetIP()
		TBFY_SH:SendMessage(Player, "", TBFY_GetLang("IPReset"))
	elseif Action == "ResetPassword" and PCType == 1 then
		PC:ResetPassword()
		TBFY_SH:SendMessage(Player, "",  TBFY_GetLang("PasswordReset"))
	elseif Action == "ToggleEntButton" then
		local Ent, SoftID, EType = net.ReadEntity(), net.ReadString(), net.ReadString()
		local EClass, SoftTbl = Ent:GetClass(), TBFY_SH.CSoftwares[SoftID]
		if SoftTbl.AEnts and SoftTbl.AEnts[EClass] then
			local Childs = PC.TBFY_Childs[EType]
			if Childs then
				for k,v in pairs(Childs) do
					if v == Ent then
						Ent:ToggleButton()
						break
					end
				end
			end
		end
	elseif Action == "RequestEntities" then
		local SoftID = net.ReadString()
		local SoftTbl = TBFY_SH.CSoftwares[SoftID]
		if SoftTbl then
			local Ents = SoftTbl.Children
			if Ents then
				local DataToSend = {}
				for k,v in pairs(Ents) do
					DataToSend[v] = PC.TBFY_Childs[v]
				end

				local CAmount = table.Count(DataToSend)
				if CAmount > 0 then
					net.Start("tbfy_computer_updateentities")
						net.WriteString(SoftID)
						net.WriteFloat(CAmount)
						for k,v in pairs(DataToSend) do
							net.WriteString(k)
							net.WriteFloat(table.Count(v))
							for index,Ent in pairs(v) do
								net.WriteEntity(Ent)
							end
						end
					net.Send(Player)
				end
			end
		end
	end
end

net.Receive("tbfy_computer_run", function(len, Player)
	if Player.NextTBFYAction and Player.NextTBFYAction > CurTime() then return end
	Player.NextTBFYAction = CurTime() + .05

	if !Player:Alive() or !Player:InVehicle() then return end

	local PC = Player.TBFY_UsedPC
	if !IsValid(PC) then return end

	local PCType = PC:GetPCType()
	local Loggedin = PC.LoggedIn
	if PCType != 2 and !Loggedin then return end

	if PCType == 3 and !PC.UsedAccounts[Loggedin] then return end
	local SoftID = net.ReadString()
	if SoftID and SoftID != "" then
		local ToCheck = Loggedin
		if PCType != 3 then
			ToCheck = PC
		end
		if !TBFY_SH:SoftwareInstalled(ToCheck, SoftID) then return end

		local SoftTbl = TBFY_SH.CSoftwares[SoftID]
		if SoftTbl then
			if TBFY_SH[SoftTbl.Func] then
				TBFY_SH[SoftTbl.Func](self, Player, SoftID, Loggedin)
			end
		end
	else
		TBFY_SH:PC_Function(Player, Loggedin)
	end
end)

net.Receive("tbfy_manage_accountinfo", function(len, Player)
	local PC = Player.TBFY_UsedPC
	if !IsValid(PC) then return end

	local Username, Password = net.ReadString(), net.ReadString()
	local ULen, PLen = string.len(Username), string.len(Password)
	if ULen < 1 or ULen > 10 or PLen < 1 or PLen > 10 then return false end

	local SID = TBFY_SH:SID(Player)
	if TBFY_SH.ComputerAccounts[SID] then
		TBFY_SH.ComputerAccounts[SID].Username = Username
		TBFY_SH.ComputerAccounts[SID].Password = Password
		TBFY_SH:UpdateCAccountData(SID, {["username"] = Username, ["password"] = Password})
	end
end)

function TBFY_SH:FalkOS_Logout(PC, Player)
	PC.LoggedIn = nil
	local PCType = PC:GetPCType()
	if PCType == 1 then
		PC:SetScreenStatus(2)
	else
		PC:SetScreenStatus(1)
	end

	if IsValid(Player) then
		local Accounts = PC.UsedAccounts
		local AccAmount = table.Count(PC.UsedAccounts)
		net.Start("tbfy_comp_loginscreen")
			net.WriteFloat(PCType)
			if PCType == 1 then
				net.WriteString(PC.Logo)
			else
				net.WriteFloat(AccAmount)
				for k,v in pairs(Accounts) do
					local AccountInfo = TBFY_SH.ComputerAccounts[k]
					if AccountInfo then
						net.WriteString(k)
						net.WriteString(AccountInfo.Username)
						net.WriteString(AccountInfo.Avatar)
					end
				end
			end
		net.Send(Player)
	end
end

net.Receive("tbfy_logout", function(len, Player)
	local PC = Player.TBFY_UsedPC
	if IsValid(PC) and PC.LoggedIn then
		TBFY_SH:FalkOS_Logout(PC, Player)
	end
end)

net.Receive("tbfy_comp_login", function(len, Player)
	local PC = Player.TBFY_UsedPC
	if !IsValid(PC) or !TBFY_SH:NearEntity(Player, PC) then return false end

	local UN, PW, SID = net.ReadString(), net.ReadString(), net.ReadString()
	local JobA = TBFY_SH:CanUsePC(Player, PC, true)
	local PCType = PC:GetPCType()

	local OwnAcc = false
	if SID == "" and PCType == 3 then
		SID = TBFY_SH:SID(Player)
		OwnAcc = true
	end

	local AllowLogin = false
	if PCType == 1 then
		if PW == PC.password or JobA then
			AllowLogin = true
		end
	elseif OwnAcc then
		local Account = TBFY_SH.ComputerAccounts[SID]
		if Account and UN == Account.Username and PW == Account.Password then
			AllowLogin = true
		end
	elseif PC.UsedAccounts[SID] then
		local Account = TBFY_SH.ComputerAccounts[SID]
		if Account and UN == Account.Username and PW == Account.Password then
			AllowLogin = true
		end
	end

	if AllowLogin then
		if PCType == 1 and !JobA then
			Player.TBFY_CompPW = PW
		elseif PCType == 3 then
			if OwnAcc then
				PC.UsedAccounts[SID] = {ID = PC.AccountNID, Falkwall = true}
				PC.AccountNID = PC.AccountNID + 1
				Player.TBFY_UsedPCs[PC:EntIndex()] = PC
			end
			PC.LoggedIn = SID
			PC:SetScreenStatus(3)
		end
	end

	if PCType == 1 then
		PC.LoggedIn = ""
	end

	TBFY_SH:LoginPC(Player, SID, AllowLogin)
end)

local function GeneratePuzzle()
	local Type = math.random(1,7)
	local String = nil
	local Solution = nil
	if Type == 1 then
		local R1,R2,R3,R4 = math.random(0,9), math.random(0,9), math.random(0,9), math.random(0,9)
		String = R1 .. R2 .. R3 .. R4 .. " - " .. R2 .. R3 .. R4 .. R1 .. " - " .. R3 .. R4 .. R1 .. R2 .. " - XXXX"
		Solution = R4 .. R1 .. R2 .. R3
	elseif Type == 2 then
		local R1,R2,R3,R4 = math.random(0,9), math.random(0,9), math.random(0,9), math.random(0,9)
		String = R1 .. R2 .. R3 .. R4 .. " - " .. R4 .. R1 .. R2 .. R3 .. " - " .. R3 .. R4 .. R1 .. R2 .. " - XXXX"
		Solution = R2 .. R3 .. R4 .. R1
	elseif Type == 3 then
		local R1 = math.random(2,12)
		local R2 = R1*R1
		local R3 = R2*R2
		local R4 = R3*R3
		local X = ""
		for i = 1, string.len(R2) do
			X = X .. "X"
		end
		String = R1 .. " - " .. X .. " - " .. R3 .. " - " .. R4
		Solution = R2
	elseif Type == 4 then
		local R1 = math.random(10,100)
		local Increase = math.random(1,9)
		local R2, R3, R4 = R1+Increase, R1+Increase*2, R1+Increase*3
		local X = ""
		for i = 1, string.len(R4) do
			X = X .. "X"
		end
		String = R1 .. " - " .. R2 .. " - " .. R3 .. " - " .. X
		Solution = R4
	elseif Type == 5 then
		local R1 = math.random(50,100)
		local Decrease = math.random(1,9)
		local R2, R3, R4 = R1-Decrease, R1-Decrease*2, R1-Decrease*3
		local X = ""
		for i = 1, string.len(R4) do
			X = X .. "X"
		end
		String = R1 .. " - " .. R2 .. " - " .. R3 .. " - " .. X
		Solution = R4
	elseif Type == 6 then
		local RVar = math.random(1,9)
		local RXAmount = math.random(1, 5)
		local TotVal = RVar*RXAmount
		local ToDisplay = RXAmount .. "X"
		if RXAmount == 1 then
			ToDisplay = "X"
		end
		String = ToDisplay .. " - " .. TotVal .. " = 0, X = ?"
		Solution = RVar
	elseif Type == 7 then
		local RVarX,RVarY,RVarZ = math.random(1,9),math.random(1,9), math.random(2,4)
		String = "X = " .. RVarX .. ", Y = X + " .. RVarY .. " Z = X + Y, " .. RVarZ .. "Z = ?"
		Solution = RVarZ*(RVarX*2+RVarY)
	end
	return String, tostring(Solution)
end

net.Receive("tbfy_computer_cmd", function (len,Player)
	if Player.NextTBFYAction and Player.NextTBFYAction > CurTime() then return end
	Player.NextTBFYAction = CurTime() + .05

	local PC = Player.TBFY_UsedPC
	if !IsValid(PC) then return end
	local PCType = PC:GetPCType()

	local Exe, Command = net.ReadString(), net.ReadString()
	if Command == "ipconfig" then
		net.Start("tbfy_computer_cmd")
			net.WriteString(Exe)
			net.WriteString(Command)
			net.WriteFloat(1)
			net.WriteString(PC.IP)
		net.Send(Player)
	elseif Command == "connect" then
		local IP, CorrectIP = net.ReadString(), "No"
		if PC.IP == IP then
			CorrectIP = "Yes"
		end
		net.Start("tbfy_computer_cmd")
			net.WriteString(Exe)
			net.WriteString(Command)
			net.WriteFloat(1)
			net.WriteString(CorrectIP)
		net.Send(Player)
	elseif Command == "retrieve" then
		local DType = net.ReadString()
		if DType == "accounts" then
			net.Start("tbfy_computer_cmd")
				net.WriteString(Exe)
				net.WriteString(Command)
				if PCType == 1 then
					net.WriteFloat(4)
					net.WriteString("1")
					net.WriteString("1")
					net.WriteString("Administrator")
					if PC:GetFirewall() then
						net.WriteString(string.rep("*",string.len(PC.password)))
					else
						net.WriteString(PC.password)
					end
				else
					local Accounts = PC.UsedAccounts
					local AccountA = table.Count(Accounts)
					if AccountA > 0 then
						net.WriteFloat(AccountA*3+1)
						net.WriteString(AccountA)
						for k,v in pairs(Accounts) do
							local AccountInfo = TBFY_SH.ComputerAccounts[k]
							if AccountInfo then
								net.WriteString(v.ID)
								net.WriteString(AccountInfo.Username)
								if v.Falkwall then
									net.WriteString(string.rep("*",string.len(AccountInfo.Password)))
								else
									net.WriteString(AccountInfo.Password)
								end
							end
						end
					else
						net.WriteFloat(2)
						net.WriteString("0")
						net.WriteString("No accounts found")
					end
				end
			net.Send(Player)
		elseif DType == "password" then
			local ID = tonumber(net.ReadString())
			local SID, FWall = nil, true

			if PCType == 1 then
				if ID == 1 then
					SID, FWall = "", PC:GetFirewall()
				end
			else
				for k,v in pairs(PC.UsedAccounts) do
					if ID == v.ID then
						SID, FWall = k, v.Falkwall
						break
					end
				end
			end

			net.Start("tbfy_computer_cmd")
				net.WriteString(Exe)
				net.WriteString(Command)
				net.WriteFloat(2)
				net.WriteString("0")
				if !SID then
					net.WriteString("Failed to retrieve data - Account not found")
				elseif FWall then
					net.WriteString("Failed to retrieve data - Falkwall blocking")
				else
					local PW = PC.password
					if PCType == 3 then
						PW = TBFY_SH.ComputerAccounts[SID].Password
					end
					net.WriteString("Retrieved Data - " .. PW)
				end
			net.Send(Player)
		end
	elseif Exe == "hack.exe" then
		local Stage, Puzzle, Solution = net.ReadString(), "", nil
		if Stage == "1" then
			local IP, ID, SID = net.ReadString(), tonumber(net.ReadString()), ""
			local CorrectIP, CorrectID, FWall = false, false, true

			if PCType == 1 then
				if ID == 1 then
					CorrectID = true
					if !PC:GetFirewall() then
						FWall = false
					end
				end
			else
				for k,v in pairs(PC.UsedAccounts) do
					if ID == v.ID then
						SID = k
						CorrectID = true
						if !v.Falkwall then
							FWall = false
						end
						break
					end
				end
			end

			if PC.IP == IP then
				CorrectIP = true
			end

			if CorrectIP and CorrectID and FWall then
				Puzzle, Solution = GeneratePuzzle()
				Player.TBFY_HackData = {PC = PC, SID = SID, HackCompleted = 0, Solution = Solution}
			end

			net.Start("tbfy_computer_cmd")
				net.WriteString(Exe)
				net.WriteString(Command)
				net.WriteFloat(3)
				net.WriteString("1")
				net.WriteString(Puzzle)
				if !CorrectIP then
					net.WriteString("Invalid IP")
				elseif !CorrectID then
					net.WriteString("Invalid Account ID")
				elseif !FWall then
					net.WriteString("Falkwall already offline")
				end
			net.Send(Player)
		elseif Stage == "2" then
			local Answer, HData, Complete = net.ReadString(), Player.TBFY_HackData, "No"
			if PC == HData.PC then
				if HData.Solution == Answer then
					Player.TBFY_HackData.HackCompleted = Player.TBFY_HackData.HackCompleted + 1
					if Player.TBFY_HackData.HackCompleted >= 4 then
						Complete = "Yes"
						if PCType == 1 then
							PC:SetFirewall(false)
						else
							PC.UsedAccounts[HData.SID].Falkwall = false
						end
						Player.TBFY_HackData = nil
					else
						Puzzle, Solution = GeneratePuzzle()
						Player.TBFY_HackData.Solution = Solution
					end
				end
				net.Start("tbfy_computer_cmd")
					net.WriteString(Exe)
					net.WriteString(Command)
					net.WriteFloat(3)
					net.WriteString("2")
					net.WriteString(Puzzle)
					net.WriteString(Complete)
				net.Send(Player)
			end
		end
	end
end)
