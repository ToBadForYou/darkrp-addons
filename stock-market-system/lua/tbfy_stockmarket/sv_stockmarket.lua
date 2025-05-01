
util.AddNetworkString("stockm_send_stocks")
util.AddNetworkString("stockm_open_market")
util.AddNetworkString("stockm_request_stockhistory")
util.AddNetworkString("stockm_send_stockhistory")
util.AddNetworkString("stockm_send_compiledstocks")
util.AddNetworkString("stockm_buy")
util.AddNetworkString("stockm_sell")
util.AddNetworkString("stockm_update_playerstocks")
util.AddNetworkString("stockm_update_status")
util.AddNetworkString("stockm_update_stock")
util.AddNetworkString("stockm_update_monitors")

resource.AddSingleFile("tobadforyou/stockm_comp_stockmarket.png")

//To allow queries for stocks if no players
if TBFY_STOCKMConfig.AlwaysUpdate then
	RunConsoleCommand("sv_hibernate_think", 1)
end

TBFY_STOCKS = TBFY_STOCKS or {}
TBFY_STOCKSHISTORY = TBFY_STOCKSHISTORY or {}

local PLAYER = FindMetaTable("Player")
local StockM_Open = false

local Time = os.date("!*t") --The ! forces it to check UTC timezone instead of local timezone
local CurH, CurM = Time.hour, Time.min
local BaseH = BaseH or CurH
local BaseM = BaseM or math.ceil(CurM/10)*10

function StockM_FetchStock(Stock, First, RealStock, StartVal, LastVal)
	if RealStock then
		local QueryStock = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22" .. Stock .. "%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
		http.Fetch(QueryStock,
			function( body, len, headers, code )
				local StockData = util.JSONToTable(body)
				if StockData and StockData.query and StockData.query.results then
					local Results = StockData.query.results.quote
					local PercentChange = Results.ChangeinPercent
					if PercentChange then
						PercentChange = string.Replace(PercentChange, "%", "" )
						local Change, LastTradePriceOnly = Results.Change, Results.LastTradePriceOnly

						if Change and LastTradePriceOnly and PercentChange then
							local Data = {
								AmountChanged = tonumber(Results.Change),
								PercentChanged = tonumber(PercentChange),
								Value = math.Round(tonumber(Results.LastTradePriceOnly),2),
								--DateChecked = Results.LastTradeDate,
							}

							StockM_SaveStockData(Stock, Data, First)
							StockM_LoadStockData(Stock)
						else
							print("Failed to get values for stock: " .. Stock)
						end
					else
						print("Failed to get values for stock: " .. Stock)
					end
				else
					print("Failed to get values for stock: " .. Stock)
				end
			end
		)
	else
		local NewValue = 0
		local AmountChanged = 0
		local PercentChanged = 0

		if First then
			NewValue = StartVal
		else
			local LastValue = LastVal
			local RNumber = math.random(0, 1000)

			if RNumber > 990 then
				PercentChanged = math.Rand(-30, 30)
			elseif RNumber > 970 then
				PercentChanged = math.Rand(-20, 20)
			elseif RNumber > 930 then
				PercentChanged = math.Rand(-10, 10)
			elseif RNumber > 850 then
				PercentChanged = math.Rand(-4, 4)
			else
				PercentChanged = math.Rand(-1, 1)
			end

			PercentChanged = math.Round(PercentChanged, 2)
			NewValue = math.Round(LastValue * (1 + PercentChanged/100),2)
			AmountChanged = math.Round(NewValue-LastValue, 2)
		end

		local Data = {
			AmountChanged = math.Round(AmountChanged,2),
			PercentChanged = math.Round(PercentChanged,2),
			Value = math.Round(NewValue,2),
		}
		StockM_SaveStockData(Stock, Data, First)
		StockM_LoadStockData(Stock)
	end
end

function StockM_SaveStockData(Stock, data, First)
	TBFY_STOCKS[Stock] = data
	file.Write("stockmarket/stocksvalue/" .. Stock .. ".txt", util.TableToJSON(TBFY_STOCKS[Stock]))

	if !First then
		local Time = os.date("!*t")
		local TimeString = Time.month .. "/" .. Time.day .. "/" .. Time.year

		TBFY_STOCKSHISTORY[Stock][TimeString] = TBFY_STOCKSHISTORY[Stock][TimeString] or {}
		TBFY_STOCKSHISTORY[Stock][TimeString][BaseH] = TBFY_STOCKSHISTORY[Stock][TimeString][BaseH] or {}
		TBFY_STOCKSHISTORY[Stock][TimeString][BaseH][BaseM] = data

		StockM_CalculateAverage(Stock, TimeString)

		file.Write("stockmarket/stockshistory/" .. Stock .. ".txt", util.TableToJSON(TBFY_STOCKSHISTORY[Stock]))
	end
end

function StockM_LoadStockData(Stock)
	TBFY_STOCKS[Stock] = util.JSONToTable(file.Read( "stockmarket/stocksvalue/" .. Stock .. ".txt" ))

	local StockData = TBFY_STOCKS[Stock]
	net.Start("stockm_update_stock")
		net.WriteString(Stock)
		net.WriteFloat(StockData.AmountChanged)
		net.WriteFloat(StockData.PercentChanged)
		net.WriteFloat(StockData.Value)
	net.Broadcast()
end

function StockM_LoadStockHistoryData(Stock)
	local LoadFile = file.Read( "stockmarket/stockshistory/" .. Stock .. ".txt")
	if LoadFile then
		TBFY_STOCKSHISTORY[Stock] = util.JSONToTable(LoadFile)
	end
end

function StockM_CalculateAverage(Stock, TimeString)
	local TotalVal = 0
	local Amount = 0
	for k,v in pairs(TBFY_STOCKSHISTORY[Stock][TimeString][BaseH]) do
		if istable(v) then
			TotalVal = TotalVal + v.Value
			Amount = Amount + 1
		end
	end
	TBFY_STOCKSHISTORY[Stock][TimeString][BaseH].AvgVal = math.Round(TotalVal/Amount,2)

	TotalVal = 0
	Amount = 0
	for k,v in pairs(TBFY_STOCKSHISTORY[Stock][TimeString]) do
		if istable(v) then
			TotalVal = TotalVal + v.AvgVal
			Amount = Amount + 1
		end
	end
	TBFY_STOCKSHISTORY[Stock][TimeString].AvgVal = math.Round(TotalVal/Amount,2)
end

function PLAYER:StockM_Save()
    local CompiledString = ""

	for k,v in pairs(self.TBFY_Stocks) do
	    CompiledString = CompiledString .. k .. "," .. v .. ";"
	end

	sql.Query("UPDATE tbfy_stockm SET stocks='"..CompiledString.."' WHERE steamid='"..self:SteamID().."'")
end

function PLAYER:StockM_TradeStocks(StockID, Amount)
	self.TBFY_Stocks[StockID] = (self.TBFY_Stocks[StockID] or 0) + Amount

	net.Start("stockm_update_playerstocks")
		net.WriteFloat(StockID)
		net.WriteFloat(self.TBFY_Stocks[StockID])
	net.Send(self)

	self:StockM_Save()
end

function PLAYER:StockM_GiveMoney(Amount)
	return self:addMoney(Amount)
end

hook.Add("Initialize", "stockm_init", function()
	file.CreateDir("stockmarket")
	file.CreateDir("stockmarket/stocksvalue")
	file.CreateDir("stockmarket/stockshistory")
	file.CreateDir("stockmarket/entities")

	if !sql.TableExists("tbfy_stockm") then
		sql.Query("CREATE TABLE tbfy_stockm (steamid varchar(255), stocks varchar(255))")
	end

	for k,v in ipairs(TBFY_STOCKMConfig.Stocks) do
		TBFY_STOCKS[v.Stock] = TBFY_STOCKS[v.Stock] or {}
		TBFY_STOCKSHISTORY[v.Stock] = TBFY_STOCKSHISTORY[v.Stock] or {}

		if file.Exists("stockmarket/stocksvalue/" .. v.Stock .. ".txt" ,"DATA") then
			StockM_LoadStockData(v.Stock)
			StockM_LoadStockHistoryData(v.Stock)
		else
			timer.Simple(k*0.1, function()
				StockM_FetchStock(v.Stock, true, v.RealStock, v.StartValue)
			end)
		end
	end
end)

timer.Create("stockm_monitormarket", 30, 0, function()
	//We check UTC and stock market is open: 13:30 - 20:00
	local Time = os.date("!*t") --The ! forces it to check UTC timezone instead of local timezone
	local CurH, CurM = Time.hour, Time.min
	if (CurH > 13 or (CurH == 13 and CurM >= 30)) and CurH < 20 then
		StockM_Open = true
	else
		StockM_Open = false
	end

	if CurM >= BaseM and CurH >= BaseH then
		local StocksTbl = TBFY_STOCKMConfig.Stocks
		for k,v in pairs(StocksTbl) do
			if (StockM_Open and v.RealStock) or (StockM_Open and !v.RealStock and v.RealOpenTimes) or (!v.RealStock and !v.RealOpenTimes) then
				timer.Simple(k*0.1, function()
					StockM_FetchStock(v.Stock, false, v.RealStock, nil, TBFY_STOCKS[v.Stock].Value)
				end)
			end
		end
		timer.Simple(table.Count(StocksTbl)*0.15, function()
			net.Start("stockm_update_monitors")
			net.Broadcast()
		end)

		BaseM = BaseM + 5
		if BaseM >= 60 then
			BaseH = BaseH + 1
			BaseM = 0
		end
	end

	net.Start("stockm_update_status")
		net.WriteBool(StockM_Open)
	net.Broadcast()
end)

hook.Add("PlayerInitialSpawn", "stockm_send_stocks", function(Player)
  	timer.Simple(3, function()
		if IsValid(Player) then
			for k,v in pairs(TBFY_STOCKMConfig.Stocks) do
				local StockData = TBFY_STOCKS[v.Stock]
				net.Start("stockm_update_stock")
					net.WriteString(v.Stock)
					net.WriteFloat(StockData.AmountChanged)
					net.WriteFloat(StockData.PercentChanged)
					net.WriteFloat(StockData.Value)
				net.Send(Player)
			end

			Player.TBFY_Stocks = {}
			local CompiledString = sql.Query( "SELECT stocks FROM tbfy_stockm WHERE steamid = ".. sql.SQLStr(Player:SteamID()) .."")

			if CompiledString then
				StockM_DecompileStocks(CompiledString[1].stocks, Player)

				net.Start("stockm_send_compiledstocks")
					net.WriteString(CompiledString[1].stocks)
				net.Send(Player)
			else
				sql.Query("INSERT INTO tbfy_stockm (`steamid`)VALUES ('"..Player:SteamID().."')")
				net.Start("stockm_send_compiledstocks")
					net.WriteString("")
				net.Send(Player)
			end
		end
	end)
end)

net.Receive("stockm_request_stockhistory", function(len, Player)
	local Stock, When = net.ReadString(), net.ReadString()
	local Time = os.date("!*t")
	local TimeString = Time.month .. "/" .. Time.day .. "/" .. Time.year
	local StockHis = TBFY_STOCKSHISTORY[Stock]

	if StockHis and StockHis[TimeString] then
		local Hour = BaseH
		if Hour < 10 then
			Hour = "0" .. Hour
		end
		net.Start("stockm_send_stockhistory")
			if When == "hourly" then
				local HourTbl = StockHis[TimeString][BaseH]
				local Amount = table.Count(HourTbl)-1 or 0
				local Adjust = 12-Amount
				local AdjustH = BaseH-1
				local PastHourTbl = StockHis[TimeString][AdjustH] or {}
				Amount = Amount + math.Clamp(Adjust,0, table.Count(PastHourTbl)-1)

				net.WriteFloat(Amount)
				net.WriteString(BaseH)
				for k,v in pairs(HourTbl) do
					if istable(v) then
						local Min = tonumber(k)
						local Sorter = BaseH .. Min

						if Min < 10 then
							Min = "0" .. k
						end
						local Date = TimeString .. " - " .. Hour .. ":" .. Min
						net.WriteFloat(v.Value)
						net.WriteString(Date)
						net.WriteFloat(Sorter)
					end
				end
				local Check = 60 - Adjust*5
				for k,v in pairs(PastHourTbl) do
					local Min = tonumber(k)
					if istable(v) and tonumber(k) >= Check then
						if Min < 10 then
							Min = "0" .. k
						end
						local Date = TimeString .. " - " .. AdjustH .. ":" .. Min
						net.WriteFloat(v.Value)
						net.WriteString(Date)
						net.WriteFloat(Min)
					end
				end
			elseif When == "daily" then
				local DailyTbl = StockHis[TimeString]
				net.WriteFloat(table.Count(DailyTbl)-1)
				net.WriteString(TimeString)
				for k,v in pairs(DailyTbl) do
					if istable(v) then
						local Date = TimeString .. " - " .. k .. ":00"
						net.WriteFloat(v.AvgVal)
						net.WriteString(Date)
						net.WriteFloat(k)
					end
				end
			end
		net.Send(Player)
	end
end)

net.Receive("stockm_buy", function(len, Player)
	local StockID, Amount = net.ReadFloat(), net.ReadFloat()
	Amount = math.floor(Amount)
	local OwnedAmount = Player.TBFY_Stocks[StockID] or 0
	if OwnedAmount then
		local TotalCanBuy = StockM_GetConf("STOCK_MaxStocks")-OwnedAmount
		if TotalCanBuy <= 0 then TBFY_SH:SendMessage(Player, "ERROR", StockM_GetLang("MaxBought")) return end
		Amount = math.Clamp(Amount,1,TotalCanBuy)

		local StockTbl = TBFY_STOCKMConfig.Stocks[StockID]
		if StockTbl then
			local Value = TBFY_STOCKS[StockTbl.Stock].Value
			local Totalcost = math.ceil(Value*Amount)

			if Player:StockM_CanAfford(Totalcost) then
				Player:StockM_TradeStocks(StockID, Amount)
				Player:StockM_GiveMoney(-Totalcost)
				TBFY_SH:SendMessage(Player,"SUCCESS", string.format(StockM_GetLang("StockBought"), Amount, Totalcost))
			else
				TBFY_SH:SendMessage(Player,"ERROR", StockM_GetLang("CantAfford"))
			end
		end
	end
end)

net.Receive("stockm_sell", function(len, Player)
	if !Player:StockM_CanTrade() then 
		TBFY_SH:SendMessage(Player, "ERROR", StockM_GetLang("IncorrectJob"))
		return
	end

	local StockID, Amount = net.ReadFloat(), net.ReadFloat()
	Amount = math.floor(Amount)
	Amount = math.Clamp(Amount,1,Amount)

	local StockTbl = TBFY_STOCKMConfig.Stocks[StockID]
	if StockTbl then
		local Value = TBFY_STOCKS[StockTbl.Stock].Value
		local TotalAmount = math.floor(Value*Amount)
		local OwnedAmount = Player.TBFY_Stocks[StockID]

		if OwnedAmount >= Amount then
			Player:StockM_TradeStocks(StockID, -Amount)
			Player:StockM_GiveMoney(TotalAmount)
			TBFY_SH:SendMessage(Player,"SUCCESS", string.format(StockM_GetLang("StockSold"), Amount, TotalAmount), Player)
		else
			TBFY_SH:SendMessage(Player, "ERROR", StockM_GetLang("NotEnoughStocks"))
		end
	end
end)
