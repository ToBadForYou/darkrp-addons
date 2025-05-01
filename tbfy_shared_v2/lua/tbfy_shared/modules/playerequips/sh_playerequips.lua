TBFY_SH.PEquips = TBFY_SH.PEquips or {}
TBFY_SH.PEquipsDB = TBFY_SH.PEquipsDB or {}

function TBFY_SH:RegisterEquip(Data)
	if Data.ForPurchase then
		DarkRP.createEntity(Data.Name, {
			ent = Data.Ent,
			model = Data.Model,
			price = Data.Price,
			max = Data.MaxBuy,
			cmd = "buy_tbfy_" .. Data.Name,
			allowed = Data.PurchaseJobs,
			EID = Data.EID
		})
	end
	TBFY_SH.PEquipsDB[Data.EID] = {Name = Data.Name, Model = Data.Model, MScale = Data.MScale, MSkin = Data.MSkin, MColor = Data.MColor, Bone = Data.Bone, Pos = Data.AdjPos, Ang = Data.AdjAng, CustomPos = Data.CustomPos}
end
