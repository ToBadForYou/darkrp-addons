local MODULE = GAS.Logging:MODULE()

MODULE.Category = "ToBadForYou"
MODULE.Name     = "Bounty Hunter"
MODULE.Colour   = Color(100,40,45)

MODULE:Hook("BH_Claimbounty","bh_claimbounty",function(BH, Player, BountyA)
	MODULE:Log(GAS.Logging:FormatPlayer(BH) .. " claimed a bounty of $" .. BountyA .. " on " .. GAS.Logging:FormatPlayer(Player) .. "'s head!")
end)

MODULE:Hook("BH_Startbounty","bh_startbounty",function(BH, Player)
	MODULE:Log(GAS.Logging:FormatPlayer(BH) .. " started a bounty hunt on " .. GAS.Logging:FormatPlayer(Player) .. "'s head!")
end)

GAS.Logging:AddModule(MODULE)

