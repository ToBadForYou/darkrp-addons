
--[[
You can now trade stocks through stock market software
Now uses tbfy_shared_v2 to save/load entities
Now uses tbfy_shared_v2 translation system
German language added (https://steamcommunity.com/id/CuzImJordy/ )

Configs added:
]]

TBFY_STOCKMConfig = TBFY_STOCKMConfig or {}

--Contact me on gmodstore for help to translate
--Languages available:
--[[
chinese
english
french
korean
spanish
]]
TBFY_STOCKMConfig.LanguageToUse = "english"

//NOTE: REAL LIFE stocks are not working as Yahoo API shutdown
//If anyone finds a suitable API contact me on gmodstore
//The stocks to track, NOTE: these are REAL LIFE stocks, the stock must be the same as IRL
TBFY_STOCKMConfig.Stocks = {
[1] = {Name = "Yahoo", Stock = "YHOO", RealStock = false, StartValue = 900, RealOpenTimes = false},
[2] = {Name = "Apple", Stock = "AAPL", RealStock = false, StartValue = 3000, RealOpenTimes = false},
[3] = {Name = "Facebook", Stock = "FB", RealStock = false, StartValue = 2500, RealOpenTimes = false},
[4] = {Name = "Microsoft", Stock = "MSFT", RealStock = false, StartValue = 1500, RealOpenTimes = false},
[5] = {Name = "Nintendo", Stock = "NTDOY", RealStock = false, StartValue = 2000, RealOpenTimes = false},
[6] = {Name = "Sony", Stock = "SNE", RealStock = false, StartValue = 600, RealOpenTimes = false},
[7] = {Name = "McDonalds", Stock = "MCD", RealStock = false, StartValue = 400, RealOpenTimes = false},
[8] = {Name = "Nokia", Stock = "NOK", RealStock = false, StartValue = 250, RealOpenTimes = false},
[9] = {Name = "Google", Stock = "GOOGL", RealStock = false, StartValue = 1000, RealOpenTimes = false},
[10] = {Name = "NVIDIA", Stock = "NVDA", RealStock = false, StartValue = 110, RealOpenTimes = false},
[11] = {Name = "eBay", Stock = "EBAY", RealStock = false, StartValue = 600, RealOpenTimes = false},
//Fake ones needs to have a start value - this is only set on first startup after its added, after that it will use the saved data
//If RealOpenTimes is set to true, the stock will change values when the REAL stock market is open, if set to false it will update values every 5 mins
[12] = {Name = "ToBaddie LTD", Stock = "TBFY", RealStock = false, StartValue = 500, RealOpenTimes = false},
[13] = {Name = "Gmodstore", Stock = "GMSTO", RealStock = false, StartValue = 150, RealOpenTimes = true},
}
//Who can access admin commands
TBFY_STOCKMConfig.AdminAccessCustomCheck = function(Player) return Player:IsSuperAdmin() end
//If this is set to true, server will run think hook and timers even though no players are online
//This is required to be set to true if you want stocks to update even though no players are online
//Recommended to have this to true
TBFY_STOCKMConfig.AlwaysUpdate = true
