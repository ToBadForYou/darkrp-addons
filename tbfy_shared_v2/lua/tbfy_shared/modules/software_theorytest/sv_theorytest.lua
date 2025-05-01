
util.AddNetworkString("tbfy_theory_open")
util.AddNetworkString("tbfy_update_theory")

function TBFY_SH:ToggleTheory(SID, Test, ID, Toggle)
	TBFY_SH.TheoryTestPlayers[SID][Test] = TBFY_SH.TheoryTestPlayers[SID][Test] or {}
	TBFY_SH.TheoryTestPlayers[SID][Test][ID] = Toggle
	TBFY_SH:ToggleCompileTheory(TBFY_SH.TheoryTestPlayers[SID], true, SID)
	TBFY_SH:SaveSQLite(SID, "tbfy_theory", {"theory"}, {TBFY_SH.TheoryTestPlayers[SID].string})

	net.Start("tbfy_update_theory")
		net.WriteString(SID)
		net.WriteBool(false)
		net.WriteString(Test)
		net.WriteFloat(ID)
		net.WriteBool(Toggle)
	net.Broadcast()
end

function TBFY_SH:LoadTheory(Player)
	local SID = TBFY_SH:SID(Player)
	TBFY_SH.TheoryTestPlayers[SID] = {string = ""}

	local Query = sql.Query("SELECT theory FROM tbfy_theory WHERE steamid = '".. SID .."'")
	if Query then
		local TheoryString = Query[1].theory
		TBFY_SH.TheoryTestPlayers[SID].string = TheoryString
		TBFY_SH:ToggleCompileTheory(TheoryString, false, SID)

		net.Start("tbfy_update_theory")
			net.WriteString(SID)
			net.WriteBool(true)
			net.WriteString(TheoryString)
		net.Broadcast()
	else
		sql.Query("INSERT INTO tbfy_theory (`steamid`, `theory`) VALUES ('"..SID.."', '')" )
	end
end

function TBFY_SH:StartTheoryTest(Player, SoftID)
	local ID, ItemID = net.ReadString(), net.ReadFloat()

  local Test = table.Copy(TBFY_SH.TheoryTests[ID])
  local Item = nil
	for k,v in pairs(TBFY_SH.TheoryTestItems[ID]) do
		if v.ID == ItemID then
			Item = v
		end
	end

	if !Test or !Item then return end

	local Cost = Item.Cost
	if !Player:canAfford(Cost) then return end
	Player:addMoney(-Cost)

	local Deadline = CurTime() + Item.Time
	Player.TBFY_Test = {Test = ID, Item = Item, Deadline = Deadline}

	local QAvail, QAmount = table.Count(Test)-1, Item.QAmount
	if !QAmount then
		QAmount = QAvail
	else
		QAmount = math.Clamp(QAmount, 0, QAvail)
	end

	local GenTest = TBFY_SH:GenerateTheoryQuestions(Test, QAmount)
	net.Start("tbfy_theory_open")
		net.WriteString(SoftID)
		net.WriteString(ID)
		net.WriteString(GenTest)
		net.WriteFloat(Deadline)
		net.WriteFloat(QAmount)
		net.WriteFloat(Item.QRequired)
	net.Send(Player)
end

function TBFY_SH:TheoryAnswers(Player)
	local TestInf = Player.TBFY_Test
	if !TestInf or TestInf.Deadline < CurTime() then return end

	local TestTbl = TBFY_SH.TheoryTests[TestInf.Test]
	if !TestTbl then return end
	local Item = TestInf.Item
	if !Item then return end

	local AnswerString = net.ReadString()
	local QuestionAmount = Item.QAmount
	local AnswersTbl = string.Explode(";", AnswerString)
	local AnswersCorrect = 0
	for k,v in pairs(AnswersTbl) do
		if v and v != "" then
			local SplitID = string.Explode(":", v)
			local RightAnswer = TestTbl[tonumber(SplitID[1])].CorrectAnswer
			if tonumber(SplitID[2]) == RightAnswer then
				AnswersCorrect = AnswersCorrect + 1
			end
		end
	end

	local AmountReq = Item.QRequired
	if AnswersCorrect >= AmountReq then
		TBFY_SH:ToggleTheory(TBFY_SH:SID(Player), TestInf.Test, Item.ID, true)
		hook.Run("TBFY_FinishedTheory", Player, TestInf.Test, Item.ID)
	end
	Player.TBFY_Test = nil
end

function TBFY_SH:TheorySoftware(Player, SoftID)
	local Action = net.ReadString()
	if Action == "StartTheory" then
		TBFY_SH:StartTheoryTest(Player, SoftID)
	elseif Action == "TheoryAnswers" then
		TBFY_SH:TheoryAnswers(Player)
	end
end

function TBFY_SH:GenerateTheoryQuestions(Test, Amount)
	Test.Name = nil

	local QString = ""
	for i = 1, Amount do
		local RIndex = math.random(1, Amount-i)
		local RQuest = Test[RIndex]

		if i == 1 then
			QString = RQuest.ID
		else
			QString = QString .. ":" .. RQuest.ID
		end
		local HValue = table.maxn(Test)
		Test[RIndex] = Test[HValue]
		Test[HValue] = nil
		table.SortByMember(Test, Test.ID, true)
	end
	return QString
end
