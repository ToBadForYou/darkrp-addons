
local CatName = "TBFY Shared"
local MFolder = "tbfy_shared"

hook.Add("DarkRPFinishedLoading", "tbfy_dkrp_finish", function()
	DarkRP.registerDarkRPVar("warrant", net.WriteBit, fc{tobool, net.ReadBit})
end)

local ESaveInfo = {
["tbfy_remover"] = {Class = "tbfy_remover", NameS = "TBFY Remover", NoGEnt = true, NoSave = true, ModelS = "models/props/cs_assault/washer_box2.mdl"},
["computer"] = {Class = "tbfy_computer", Folder = "computer", Cond = function(Ent) return true end, NameS = "Computer", ModelS = "models/props/cs_office/computer.mdl", SaveS =  "Save Computers + Ents", SavedS = "Successfully saved %s computer systems.",
LoadFunc = function(Data)
	local Computer = ents.Create("tbfy_computer")
	Computer:SetPos(Data.Pos)
	Computer:SetAngles(Data.Angles)
	Computer:SetEName(Data.Name)
	Computer:Spawn()
	Computer.Softwares = Data.Softwares
	Computer.JobsAllowed = Data.JobsAllowed
	Computer:InitPCType(Data.PCType)
	Computer:InitSettings(Data.Logo, Data.Wallpaper, Data.TimeType)

	local Childs = Data.Childs
	for k,v in pairs(Childs) do
		Computer.TBFY_Childs[k] = Computer.TBFY_Childs[k] or {}
		for n, SEntD in pairs(v) do
			local SEnt = ents.Create(SEntD.Class)
			if IsValid(SEnt) then
				SEnt:SetPos(SEntD.Pos)
				SEnt:SetAngles(SEntD.Angles)
				if SEnt.SetEName and SEntD.Name then
					SEnt:SetEName(SEntD.Name)
				end
				SEnt.EParent = Computer
				SEnt:Spawn()
				if k == "CCTV" then
					local Screen = ents.Create("tbfy_screen")
					Screen:SetPos(SEntD.ScreenPos)
					Screen:SetAngles(SEntD.ScreenAng)

					Screen.Camera = SEnt
					SEnt.Screen = Screen
					SEnt:SetScreen(Screen)
					Screen:SetCamera(SEnt)

					Screen:Spawn()
					Screen:SetModel(SEntD.ScreenModel)

					local c = SEntD.Color
					SEnt:UpdateSettings(SEntD.ManiBone.y, SEntD.ManiBone.z, tobool(SEntD.Pan),SEntD.PanType,c.r,c.g,c.b)
				elseif k == "SecurityDoor" then
					SEnt:InitDoor(SEntD.DoorID, SEntD.DSkin, SEntD.Explosives, SEntD.Drill, SEntD.UseEDoor, SEntD.DMount)

					for k,v in pairs(SEntD.Scanners) do
						local Scanner = ents.Create("tbfy_pdr_keycardscanner")
						Scanner:SetPos(v.Pos)
						Scanner:SetAngles(v.Ang)
						Scanner:SetDoor(SEnt)
						Scanner:Spawn()
					end
				end
				table.insert(Computer.TBFY_Childs[k], SEnt)
			end
		end
	end
end,

SaveFunc = function(Ent, Tbl)
	local NTbl = {}
	NTbl.Pos = Ent:GetPos()
	NTbl.Angles = Ent:GetAngles()
	NTbl.Name = Ent:GetEName()
	NTbl.Softwares = Ent.Softwares
	NTbl.JobsAllowed = Ent.JobsAllowed
	NTbl.PCType = Ent:GetPCType()
	NTbl.Logo = Ent.Logo
	NTbl.Wallpaper = Ent.Wallpaper
	NTbl.TimeType = Ent.TimeType

	local Childs = Ent.TBFY_Childs
	local ChildT = {}
	if Childs then
		for k,v in pairs(Childs) do
			local Cat = k
			ChildT[k] = {}
			for n, SEnt in pairs(v) do
				if IsValid(SEnt) then
					local EIns = {}
					EIns.Class = SEnt:GetClass()
					EIns.Pos = SEnt:GetPos()
					EIns.Angles = SEnt:GetAngles()
					EIns.Name = SEnt.GetEName and SEnt:GetEName() or ""
					if k == "CCTV" then
						EIns.ManiBone = SEnt.ManiBone
						if SEnt.Pan then
							EIns.Pan = 1
						else
							EIns.Pan = 0
						end
						EIns.PanType = SEnt.PanType
						EIns.Color = SEnt:GetColor()
						EIns.ScreenPos = SEnt.Screen:GetPos()
						EIns.ScreenAng = SEnt.Screen:GetAngles()
						EIns.ScreenModel = SEnt.Screen:GetModel()
					elseif k == "SecurityDoor" then
						EIns.DSkin = SEnt.DSkin
						EIns.DoorID = SEnt.DoorID
						EIns.Explosives = SEnt.Explosives
						EIns.Drill = SEnt.Drill
						EIns.UseEDoor = SEnt.UseEDoor
						EIns.DMount = SEnt.DMount

						local Scanners = {}
						for k,v in pairs(SEnt.Scanners) do
							Scanners[k] = {Pos = v:GetPos(), Ang = v:GetAngles()}
						end
						EIns.Scanners = Scanners
					end
					table.insert(ChildT[k], EIns)
				end
			end
		end
	end
	NTbl.Childs = ChildT
	return NTbl
end},
}

hook.Add("tbfy_InitSetup", "tbfy_shared", function()
	local Software = {
		ID = "Falkwall",
		Name = "Falkwall",
		Desc = "Protection for dummies.",
		Default = true,
		PCType = {
			[1] = true,
			[3] = true,
		},
		Downloadable = false,
		UI = "tbfy_comp_firewall",
		Icon = Material("tobadforyou/tbfy_computer_firewall.png"),
		W = 400,
		H = 176,
		Children = nil,
		AEnts = nil
	}
	TBFY_SH:RegisterCSoftware(Software)

	local Software = {
		ID = "Falkstore",
		Name = "Falkstore",
		Desc = "Used for downloading software.",
		Default = true,
		PCType = {
			[3] = true,
		},
		Downloadable = false,
		UI = "tbfy_comp_falkstore",
		Icon = Material("tobadforyou/tbfy_comp_falkstore.png"),
		W = 450,
		H = 500,
		Children = nil,
		AEnts = nil
	}
	TBFY_SH:RegisterCSoftware(Software)

	local Software = {
		ID = "GovArchives",
		Name = "Archives",
		Desc = "Government database.",
		Func = "ArchiveSoftware",
		Default = false,
		PCType = {
			[1] = true,
		},
		Downloadable = false,
		UI = "tbfy_comp_archive",
		Icon = Material("tobadforyou/tbfy_computer_archive.png"),
		W = 750,
		H = 500,
		Children = nil,
		AEnts = nil
	}
	TBFY_SH:RegisterCSoftware(Software)

	local Software = {
		ID = "Administration",
		Name = "Administration",
		Desc = "Administration software.",
		Func = "AdminSoftware",
		Default = false,
		PCType = {
			[1] = true,
		},
		Downloadable = false,
		UI = "tbfy_comp_administration",
		Icon = Material("tobadforyou/tbfy_comp_administration.png"),
		W = 700,
		H = 500,
		Children = nil,
		AEnts = nil
	}
	TBFY_SH:RegisterCSoftware(Software)

	local Software = {
		ID = "TheoryTest",
		Name = "Theory Test",
		Desc = "Used for various theory tests.",
		Func = "TheorySoftware",
		Default = false,
		PCType = {
			[2] = true,
			[3] = true,
		},
		Downloadable = true,
		UI = "tbfy_comp_theorytest",
		Icon = Material("tobadforyou/tbfy_comp_theorytest.png"),
		W = 400,
		H = 500,
		Children = nil,
		AEnts = nil
	}
	TBFY_SH:RegisterCSoftware(Software)

	//Not fully funcitonal yet
	local Software = {
		ID = "cmd",
		Name = "CMD",
		Desc = "FalkOS command, used to run commands directly.",
		Func = "CMD",
		Default = true,
		PCType = {
			[3] = true,
		},
		Downloadable = false,
		UI = "tbfy_comp_cmd",
		Icon = Material("tobadforyou/tbfy_comp_cmd.png"),
		W = 700,
		H = 500,
		Children = nil,
		AEnts = nil
	}
	//TBFY_SH:RegisterCSoftware(Software)

	//Archive data
	local GArchive = {
		ID = 1,
		Name = "Wanted"
	}
	TBFY_SH:RegisterGArchive(GArchive)

	local GArchive = {
		ID = 2,
		Name = "Warrant"
	}
	TBFY_SH:RegisterGArchive(GArchive)

	local GArchive = {
		ID = 3,
		Name = "Arrest"
	}
	TBFY_SH:RegisterGArchive(GArchive)

	//Computer Administrator Actions
	local ACompAction = {
		Name = "Toggle Lockdown",
		Func = "DKRP_Lockdown",
	}
	TBFY_SH:RegisterCompAdminAction(ACompAction)

	local ACompAction = {
		Name = "Start Lottery",
		ReqData = {Title = "Start Lottery", Text = "Enter Amount", Type = "Numeric", But1 = "OK", But2 = "Cancel"},
		Func = "DKRP_Lottery",
	}
	TBFY_SH:RegisterCompAdminAction(ACompAction)

	//Computer Administrator Categories
	local ACompCategory = {
		Name = "Overview",
		Child = "tbfy_administration_overview"
	}
	TBFY_SH:RegisterCompAdminCategory(ACompCategory)

	local ACompCategory = {
		Name = "Actions",
		Child = "tbfy_administration_actions"
	}
	TBFY_SH:RegisterCompAdminCategory(ACompCategory)
/*
	local ACompCategory = {
		Name = "Employees",
		Child = "tbfy_administration_employees"
	}
	TBFY_SH:RegisterCompAdminCategory(ACompCategory)
*/
	//Computer Administrator Functions
	local ACompFunc = {
		Idf = "Warrant",
		Func = "DKRP_Warrant"
	}
	TBFY_SH:RegisterCompAdminFunction(ACompFunc)
	local ACompFunc = {
		Idf = "Wanted",
		Func = "DKRP_Wanted"
	}
	TBFY_SH:RegisterCompAdminFunction(ACompFunc)
	local ACompFunc = {
		Idf = "Gunlicense",
		Func = "DKRP_Gunlicense"
	}
	TBFY_SH:RegisterCompAdminFunction(ACompFunc)

	if SERVER then
		TBFY_SH:SetupAddonInfo(MFolder, TBFY_SH.Config.AdminAccessCustomCheck, ESaveInfo)
	else
		TBFY_SH:SetupCategory(CatName)

		for k,v in pairs(ESaveInfo) do
			TBFY_SH:SetupEntity(CatName, v.NameS, v.Class, v.ModelS, v.OffSet, v.SEnts, v.NoGEnt)
			if !v.NoSave then
				TBFY_SH:SetupCMDButton(CatName, v.SaveS, "save_tbfy_ent " .. MFolder .. " " .. k)
			end
		end

		TBFY_SH:SetupCustomFunctionL(CatName, "tbfy_remover", function(SWEP)
			local EntTrace = LocalPlayer():GetEyeTrace()
			local Ent = EntTrace.Entity
			if IsValid(Ent) then
				net.Start("tbfy_remove_ent")
					net.WriteEntity(Ent)
				net.SendToServer()
			end
		end)

		TBFY_SH:SetupCustomFunctionL(CatName, "tbfy_computer", function(SWEP)
			local LP = LocalPlayer()
			if IsValid(SWEP.GhostEnt) and LP.TBFY_EData then
				local SoftS = ""
				if LP.TBFY_EData.SoftID then
					for k,v in pairs(LP.TBFY_EData.SoftID) do
						SoftS = SoftS .. k .. ":"
					end
				end
				local JobIDS = ""
				if LP.TBFY_EData.JobID then
					for k,v in pairs(LP.TBFY_EData.JobID) do
						JobIDS = JobIDS .. k .. ":"
					end
				end

				net.Start("tbfy_spawn_computer")
					net.WriteVector(SWEP.GhostEnt:GetPos())
					net.WriteAngle(SWEP.GhostEnt:GetAngles())
					net.WriteString(LP.TBFY_EData.EName or "")
					net.WriteFloat(LP.TBFY_EData.PCType or 1)
					net.WriteString(SoftS)
					net.WriteString(JobIDS)
				net.SendToServer()
			end
		end)

		TBFY_SH:SetupCustomFunctionR(CatName, "tbfy_computer", function(SWEP)
			if IsValid(SWEP.GhostEnt) then
				vgui.Create("tbfy_setup_computer")
			end
		end)
		TBFY_SH:SetupCustomFunctionDraw(CatName, "tbfy_computer", function(SWEP)
			draw.SimpleTextOutlined("Press Right-click to setup computer configs","Trebuchet24",ScrW()/2,5,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
		end)
	end
end)

//Make sure all addons have time to setup all hooks
timer.Simple(2, function()
	if !TBFY_SH.Inited then
		hook.Call("tbfy_InitSetup")
		TBFY_SH.Inited = true
	end
end)
