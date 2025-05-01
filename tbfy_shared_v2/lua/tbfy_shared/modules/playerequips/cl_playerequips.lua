
function TBFY_SH.DrawPlayerEquips(self, Player)
	local SID = TBFY_SH:SID(Player)
	local PEquips = TBFY_SH.PEquips[SID]

	if PEquips then
		local EqpDB = TBFY_SH.PEquipsDB
		for k,v in pairs(PEquips) do
			local EData = EqpDB[v.EID]
			if EData then
				local CEnt = v.CEnt
				if !IsValid(CEnt) then
					CEnt = ClientsideModel(EData.Model, RENDERGROUP_OPAQUE)
					CEnt:SetModelScale(EData.MScale)
					if EData.MSkin then
						CEnt:SetSkin(EData.MSkin)
					end
					if EData.MColor then
						CEnt:SetColor(EData.MColor)
					end

					CEnt:SetParent(Player)

					TBFY_SH.PEquips[SID][v.EID].CEnt = CEnt
				else
					local Bone = Player:LookupBone(EData.Bone)
					if Bone then
						local Pos, Ang = Player:GetBonePosition(Bone)

						local DAng = EData.Ang
						Ang:RotateAroundAxis(Ang:Up(), DAng.p)
						Ang:RotateAroundAxis(Ang:Right(), DAng.y)
						Ang:RotateAroundAxis(Ang:Forward(), DAng.r)

						local DPos = EData.Pos
						if EData.CustomPos then
							local CustomPos = EData.CustomPos[Player:GetModel()]
							if CustomPos then
								DPos = Vector(CustomPos[1], CustomPos[2], CustomPos[3])
								CEnt:SetModelScale(CustomPos[4])
							end
						end
						local FPos = Pos + Ang:Forward() * DPos.x + Ang:Right() * DPos.y + Ang:Up() * DPos.z

						CEnt:SetPos(FPos)
						CEnt:SetAngles(Ang)
						CEnt:DrawModel()
					end
				end
			end
		end
	end
end

net.Receive("tbfy_TogglePEquip", function()
	local EID, Equip, SID = net.ReadString(), net.ReadBool(), net.ReadString()

	TBFY_SH.PEquips[SID] = TBFY_SH.PEquips[SID] or {}
	if TBFY_SH.PEquips[SID][EID] then
		local OCent = TBFY_SH.PEquips[SID][EID].CEnt
		if IsValid(OCent) then
			OCent:Remove()
		end
		TBFY_SH.PEquips[SID][EID] = nil
	end
		
	if Equip then
		TBFY_SH.PEquips[SID][EID] = {CEnt = nil, EID = EID}
	end
end)

net.Receive("tbfy_ClearPEquip", function()
	local SID = net.ReadString()
	if TBFY_SH.PEquips[SID] then
		for k,v in pairs(TBFY_SH.PEquips[SID]) do
			local OCent = v.CEnt
			if IsValid(OCent) then
				OCent:Remove()
			end
			TBFY_SH.PEquips[SID][k] = nil
		end
	end
end)
