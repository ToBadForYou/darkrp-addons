
local boneManipulation = {
	["HandsUp"] = {
		["ValveBiped.Bip01_R_UpperArm"] = Angle(73,35,128),
		["ValveBiped.Bip01_L_Hand"] = Angle(-12,12,90),
		["ValveBiped.Bip01_L_Forearm"] = Angle(-28,-29,44),
		["ValveBiped.Bip01_R_Forearm"] = Angle(-22,1,15),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(-77,-46,4),
		["ValveBiped.Bip01_R_Hand"] = Angle(33,39,-21),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,30,0),
		["ValveBiped.Bip01_L_Finger1"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger11"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger2"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger3"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger31"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,30,0),
		["ValveBiped.Bip01_R_Finger2"] = Angle(20,25,0),
		["ValveBiped.Bip01_R_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger3"] = Angle(20,35,0),
		["ValveBiped.Bip01_R_Finger31"] = Angle(0,45,0)
	}
}

net.Receive("tbfy_bonemanipulate", function()
	local ply, boneType, reset = net.ReadEntity(), net.ReadString(), net.ReadBool()

	if IsValid(ply) then
		for k,v in pairs(boneManipulation[boneType]) do
			local bone = ply:LookupBone(k)
			if bone then
				if reset then
					ply:ManipulateBoneAngles(bone, Angle(0,0,0))
				else
					ply:ManipulateBoneAngles(bone, v)
				end
			end
		end
		if TBFYSurrenderConfig.DisablePlayerShadow then
			ply:DrawShadow(false)
		end
	end
end)

surface.CreateFont("tbfy_surrender", {
	size = 23,
	weight = 400,
	antialias = true,
	shadow = false,
	font = "Coolvetica"
})

net.Receive("tbfy_surrender", function(Player, len)
	local surrenderTime = net.ReadUInt(26)
	if surrenderTime == 0 then
		LocalPlayer().Surrendering = false
	else
		LocalPlayer().Surrendering = surrenderTime
	end
end)

hook.Add("HUDPaint", "tbfy_surrender_hudpaint", function()
	local surrenderTime = LocalPlayer().Surrendering
	if surrenderTime then
		local TimeLeft = math.Round(surrenderTime - CurTime(), 1)
		if TimeLeft > 0 then
			draw.SimpleTextOutlined("Surrendering - " .. TimeLeft,"tbfy_surrender", ScrW()/2, ScrH()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
		end
	end
end)