
net.Receive("tbfy_update_theory", function()
	local SID, Full, String = net.ReadString(), net.ReadBool(), net.ReadString()
	TBFY_SH.TheoryTestPlayers[SID] = TBFY_SH.TheoryTestPlayers[SID] or {}
	if Full then
		TBFY_SH:ToggleCompileTheory(String, false, SID)
	else
		local ID, Value = net.ReadFloat(), net.ReadBool()
		TBFY_SH.TheoryTestPlayers[SID][String] = TBFY_SH.TheoryTestPlayers[SID][String] or {}
		TBFY_SH.TheoryTestPlayers[SID][String][ID] = Value
	end
end)

local Derma = TBFY_SH.Config.Derma
local TWidth, THeight = 800, 450
local HasLMat = Material("tobadforyou/tbfy_theory_tick.png")
local NoLMat = Material("tobadforyou/tbfy_theory_notick.png")
local SelectOption = Material("tobadforyou/tbfy_theory_select.png")

local function TimeToString(Time)
	local s = Time % 60
	Time = math.floor( Time / 60 )
	local m = Time % 60
	Time = math.floor( Time / 60 )

	return string.format("%02i:%02i", m, s)
end

net.Receive("tbfy_theory_open", function()
	local SoftID, TestID, RQuestString, Deadline, QAmount, QReq = net.ReadString(), net.ReadString(), net.ReadString(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat()
	local Data = {TestID = TestID, QuestionString = RQuestString, Deadline = Deadline, QuestionA = QAmount, QuestionR = QReq}
	TBFY_LastPCUI:UpdateSoftware(SoftID, Data)
end)

local PANEL = {}

function PANEL:Init()
	self.ButtonText = ""
	self.BColor = ButtonColor
	self:SetText("")
	self.Font = "tbfy_buttontext"

	self.QuestionID = 1
	self.Num = 0
	self.SelectedAnswer = nil
	self.Correct = nil
end

function PANEL:SetQuestion(Number, ID)
	self.Num = Number
	self:SetBText(Number)
	self.QuestionID = ID
end

function PANEL:Paint(W,H)
	local C = self.BColor
	if self.Correct then
		C = Color(0,150,0,255)
	elseif self.Correct == false then
		C = Color(150,0,0,255)
	elseif self.SelectedAnswer then
		C = Color(0,150,0,255)
	end

	draw.RoundedBox(4, 0, 0, W, H, C)
	draw.SimpleText(self.ButtonText, self.Font, W/2, H/2, self.TColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
vgui.Register("tbfy_questionbox", PANEL, "tbfy_button")

local PANEL = {}

local OptionSize = 15
function PANEL:Paint(W,H)
	surface.SetDrawColor(255,255,255, 255)
	surface.SetMaterial(SelectOption)
	surface.DrawTexturedRect(0,0,OptionSize,OptionSize)
	if self.Selected then
		if self.WrongAnswer then
			surface.SetDrawColor(175,0,0, 255)
		else
			surface.SetDrawColor(0,175,0, 255)
		end
		surface.SetMaterial(SelectOption)
		surface.DrawTexturedRect(2,2,OptionSize-4,OptionSize-4)
	end

	local TStart = W/2-10
	local dw, dh = surface.GetTextSize("tbfy_theory_answer")
	local splitResults = TBFY_cutLength(self.Option, W-20, "tbfy_theory_answer")
	for k, txt in pairs(splitResults) do
		draw.SimpleText(txt, "tbfy_theory_answer", 20, OptionSize/2-0.5+(dh*(k-1)), Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	self.OLines = table.Count(splitResults)
end

function PANEL:DoClick()
	local Parent = self:GetParent()
	if !Parent.DisableAnswerButtons then
		for k,v in pairs(Parent.ButtonOptions) do
			v.Selected = false
		end
		self.Selected = true
		Parent.CQBox.SelectedAnswer = self.ID
	end
end
vgui.Register("tbfy_theory_answer_option", PANEL, "tbfy_button")

local PANEL = {}

function PANEL:Init()
	self.ButtonOptions = {}
	self.CQBox = nil
	self.QID = nil
	self.Question = ""
	self.QLines = 0

	self.Pic = vgui.Create("tbfy_imgur", self)
end

function PANEL:SetQuestion(TID, QBox)
	for k,v in pairs(self.ButtonOptions) do
		v:Remove()
		self.ButtonOptions[k] = nil
	end

	self.CQBox = QBox
	self.QID = QBox.QuestionID
	self.QuestionTbl = TBFY_SH.TheoryTests[TID][self.QID]
	self.Question = self.QuestionTbl.Question

	self.Pic:SetImgurID(self.QuestionTbl.Imgur)
	for k,v in pairs(self.QuestionTbl.Options) do
		local OptionButton = vgui.Create("tbfy_theory_answer_option", self)
		OptionButton.Option = v
		OptionButton.ID = k
		if QBox.SelectedAnswer == k then
			OptionButton.Selected = true
		else
			OptionButton.Selected = false
		end
		self.ButtonOptions[k] = OptionButton
	end
end

function PANEL:PerformLayout(W,H)
	local PicW = W*0.45

	self.Pic:SetPos(15,15)
	self.Pic:SetSize(PicW,H-55)

	surface.SetFont("tbfy_theory_answer")
	local TW, TH = surface.GetTextSize("A")
	local BH = 25+(25*self.QLines)
	for k,v in pairs(self.ButtonOptions) do
		v:SetSize(W-PicW-45,45)
		v:SetPos(PicW + 40, BH)
		BH = BH + TH+25
	end
end

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.TabListColors)

	local TStart = W/2-10
	local dw, dh = surface.GetTextSize("tbfy_theory_question")
	local splitResults = TBFY_cutLength(self.Question, W/2+10, "tbfy_theory_question")
	for k, txt in pairs(splitResults) do
		draw.SimpleText(txt, "tbfy_theory_question", TStart, 20+(dh+3)*(k-1), Color(0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
	self.QLines = table.Count(splitResults)
end
vgui.Register("tbfy_questiontab", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self.AnswersCorrect = 0
	self.TotalQuestions = 0

	self.TopFrame = vgui.Create("tbfy_comp_dpanel", self)
	self.TopFrame:SetTitle(TBFY_GetLang("TheoryTextResults"), false)
end

function PANEL:SetAnswersCorrect(Answers, ID, QAmount, QReq)
	self.AnswersCorrect = Answers
	self.TotalQuestions = QAmount
	self.QuestionsReq = QReq
end

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, Derma.WindowBorder)
	draw.RoundedBox(4, 2, 2, W-4, H-4, Derma.CProgramBG)

	draw.SimpleText(TBFY_GetLang("TheoryResultsMenu"), "tbfy_computer_programtitle", W/2, (Derma.HeaderH+5)/2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local MiddleW = W/2
	local MiddleH = (H+Derma.HeaderH/2)/2

	surface.SetFont("tbfy_theory_question")
	local TW, TH = surface.GetTextSize(TBFY_GetLang("TheoryTextYou") .. " ")

	local Result = TBFY_GetLang("TheoryFailed")
	local TC = Color(175,0,0,255)
	local ReqText = string.format(TBFY_GetLang("TheoryRequirement"), self.QuestionsReq)

	if self.AnswersCorrect >= self.QuestionsReq then
		Result = TBFY_GetLang("TheoryPassed")
		TC = Color(0,175,0,255)
	end

	local RTW, RTH = surface.GetTextSize(Result)
	local ETW, ETH = surface.GetTextSize(Result)

	local CenterT = (TW+RTW+ETW)/2

	draw.SimpleText(TBFY_GetLang("TheoryTextYou"), "tbfy_theory_question", MiddleW-CenterT, MiddleH-TH, Color(0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText(Result, "tbfy_theory_question", MiddleW-CenterT+TW, MiddleH-TH, TC, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText(TBFY_GetLang("TheoryTextTest"), "tbfy_theory_question", MiddleW-CenterT+TW+RTW, MiddleH-TH, Color(0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText(TBFY_GetLang("TheoryTextResults") .. ": " .. self.AnswersCorrect .. "/" .. self.TotalQuestions, "tbfy_theory_question", MiddleW, MiddleH, Color(0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText(ReqText, "tbfy_theory_question", MiddleW, MiddleH+TH, Color(0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

local Width, Height = 200, 100
function PANEL:PerformLayout(W,H)
	local Parent = self:GetParent()
	self:SetPos(Parent:GetWide()/2-Width/2, Parent:GetTall()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopFrame:SetSize(W-4,Derma.HeaderH)
	self.TopFrame:SetPos(2,2)
end
vgui.Register("tbfy_theory_results", PANEL)

local PANEL = {}

function PANEL:GetAnswers()
	local Answers = ""

	for k,v in pairs(self.QBoxes) do
		local Ans = v.SelectedAnswer
		if !Ans then Ans = 0 end
		Answers = Answers .. v.QuestionID .. ":" .. Ans .. ";"
	end

	return Answers
end

function PANEL:CorrectTest(ID, QReq)
	LocalPlayer().TBFY_TheoryDeadline = nil

	self.FinishTest:SetEnabled(false)
	self.QuestionList.DisableAnswerButtons = true
	local TestTbl = TBFY_SH.TheoryTests[ID]

	local AnswersCorrect = 0
	for k,v in pairs(self.QBoxes) do
		local RightAnswer = TestTbl[v.QuestionID].CorrectAnswer
		if v.SelectedAnswer == RightAnswer then
			AnswersCorrect = AnswersCorrect + 1
			v.Correct = true
		else
			v.Correct = false
		end
	end

	local Results = vgui.Create("tbfy_theory_results", self)
	Results:SetAnswersCorrect(AnswersCorrect, ID, self.QAmount, QReq)
end

function PANEL:Init()
	self.TheoryID = 1
	self.ViewingQuestion = nil
	self.Questions = {}

	self.OverviewList = vgui.Create("DPanel", self)
	self.OverviewList.Paint = function(selfp, W, H)
		draw.RoundedBox(4, 0, 0, W, H, Derma.TabListColors)
	end

	self.QuestionList = vgui.Create("tbfy_questiontab", self)
	self.QuestionList:SetVisible(false)

	self.PrevQuest = vgui.Create("tbfy_button", self)
	self.PrevQuest:SetBText("<")
	self.PrevQuest:SetBFont("tbfy_theory_paneltext")
	self.PrevQuest.DoClick = function()
		if self.ViewingQuestion then
			local PrevQuest = self.ViewingQuestion-1
			if PrevQuest > 0 then
				self.QuestionList:SetQuestion(self.TheoryID, self.QBoxes[PrevQuest])
				self.ViewingQuestion = PrevQuest
			end
		end
	end

	self.OverviewQuest = vgui.Create("tbfy_button", self)
	self.OverviewQuest:SetBText(TBFY_GetLang("TheoryOverview"))
	self.OverviewQuest:SetBFont("tbfy_theory_paneltext")
	self.OverviewQuest.DoClick = function()
		self:HideQuestion()
	end

	self.NextQuest = vgui.Create("tbfy_button", self)
	self.NextQuest:SetBText(">")
	self.NextQuest:SetBFont("tbfy_theory_paneltext")
	self.NextQuest.DoClick = function()
		if self.ViewingQuestion then
			local NextQuest = self.ViewingQuestion+1
			if NextQuest <= self.QAmount then
				self.QuestionList:SetQuestion(self.TheoryID, self.QBoxes[NextQuest])
				self.ViewingQuestion = NextQuest
			end
		end
	end

	self.FinishTest = vgui.Create("tbfy_button", self)
	self.FinishTest:SetBText(TBFY_GetLang("TheoryTextFinishTest"))
	self.FinishTest:SetBFont("tbfy_theory_paneltext")
	self.FinishTest.DoClick = function()
		local Answers = self:GetAnswers()
		net.Start("tbfy_computer_run")
			net.WriteString(self:GetParent().SoftID)
			net.WriteString("TheoryAnswers")
			net.WriteString(Answers)
		net.SendToServer()
		self:CorrectTest(self.TheoryID, self.QReq)
	end
end

local BoxS = 40
function PANEL:SetupTheoryTest(TheoryID, QString, QAmount, QReq)
	self.TheoryID = TheoryID
	self.QAmount = QAmount
	self.QReq = QReq

	local Wide = self:GetWide() - 10
	local Questions = string.Explode(":", QString)
	local QPerRow = 10
	local Num = 0
	local HNum = 0
	self.QBoxes = {}
	local BoxPad = BoxS+Derma.Padding
	for k,v in pairs(Questions) do
		if v != "" then
			if Num >= QPerRow then
				Num = 0
				HNum = HNum + 1
			end
			local QBox = vgui.Create("tbfy_questionbox", self.OverviewList)
			QBox:SetQuestion(k, tonumber(v))
			QBox:SetSize(BoxS,BoxS)
			QBox:SetPos(Wide/2 - (BoxPad*QPerRow)/2 + BoxPad*Num,Derma.Padding + BoxPad*HNum)
			QBox.DoClick = function() self:ViewQuestion(QBox) end
			self.QBoxes[k] = QBox
			Num = Num + 1
		end
	end
end

function PANEL:ViewQuestion(QBox)
	self.ViewingQuestion = QBox.Num
	self.OverviewList:SetVisible(false)
	self.QuestionList:SetQuestion(self.TheoryID, QBox)
	self.QuestionList:SetVisible(true)
end

function PANEL:HideQuestion()
	self.ViewingQuestion = nil
	self.OverviewList:SetVisible(true)
	self.QuestionList:SetVisible(false)
end

function PANEL:PerformLayout(W,H)
	self:SetSize(W, H)

	local HStart = 0
	self.OverviewList:SetPos(5,HStart)
	self.OverviewList:SetSize(W-10, H-5)

	self.QuestionList:SetPos(5,HStart)
	self.QuestionList:SetSize(W-10, H-5)

	local Ow = W/2-50
	self.PrevQuest:SetSize(45, 25)
	self.PrevQuest:SetPos(Ow-50, H-35)

	self.OverviewQuest:SetSize(100, 25)
	self.OverviewQuest:SetPos(Ow, H-35)

	self.NextQuest:SetSize(45, 25)
	self.NextQuest:SetPos(Ow+105, H-35)

	self.FinishTest:SetSize(110, 25)
	self.FinishTest:SetPos(W-110-Derma.Padding*2, H-25-Derma.Padding*2)
end
vgui.Register("tbfy_comp_theorytest_menu", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Name = ""
	self.ID = 1
	self.Desc = ""
	self.Price = 0

	self.TButton = vgui.Create("tbfy_button", self)
	self.TButton.Paint = function(selfp, W,H)
		if TBFY_SH:PlayerHasTheory(TBFY_SH:SID(LocalPlayer()), self.TheoryTest, self.ID) then
			surface.SetDrawColor(200,200,200, 255)
			surface.SetMaterial(HasLMat)
			surface.DrawTexturedRect(0,0,15,15)
		else
			draw.RoundedBox(4, 0, 0, W, H, selfp.BColor)
			draw.SimpleText(selfp.ButtonText, self.Font, W/2, H/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
end

function PANEL:SetOptionInfo(v, TestID)
	self.Name = v.Name
	self.Image = Material(v.Image)
	self.Desc = v.Desc
	self.Price = v.Cost
	self.TheoryTest = TestID
	self.ID = v.ID

	if TBFY_SH:PlayerHasTheory(TBFY_SH:SID(LocalPlayer()), TestID, v.ID) then
		self.TButton:SetEnabled(false)
	else
		self.TButton:SetBText("$" .. self.Price)
		self.TButton.DoClick = function()
				if !LocalPlayer():canAfford(self.Price) then
					Msg = vgui.Create("tbfy_comp_reqdata")
					Msg:Setup("ERROR", "CAN'T AFFORD THIS", "OK")
					return
			end
			net.Start("tbfy_computer_run")
				net.WriteString(self.MParent.SoftID)
				net.WriteString("StartTheory")
				net.WriteString(TestID)
				net.WriteFloat(v.ID)
			net.SendToServer()
		end
	end
end

function PANEL:Paint(W,H)
	draw.SimpleText(self.Name, "tbfy_theory_text", 5, H/2, Color(0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText(self.Desc, "tbfy_theory_choose_text", H*2+35, H/2, Color(0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.SetDrawColor(255,255,255, 255)
	surface.SetMaterial(self.Image)
	surface.DrawTexturedRect(25, 0, H*2, H)
end

function PANEL:PerformLayout(W,H)
	local ButtonW,ButtonH = 55,H/2
	self.TButton:SetSize(50,ButtonH)
	if TBFY_SH:PlayerHasTheory(TBFY_SH:SID(LocalPlayer()), self.TheoryTest, self.ID) then
		self.TButton:SetPos(W-(ButtonW/2)-22.5,ButtonH/2)
	else
		self.TButton:SetPos(W-ButtonW-15,ButtonH/2)
	end
end
vgui.Register("tbfy_comp_theory_option", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Options = {}

	self.List = vgui.Create("DScrollPanel", self)
	self.List.Licenses = {}
	self.List.VBar.Paint = function() end
	self.List.VBar.btnUp.Paint = function() end
  self.List.VBar.btnDown.Paint = function() end
	self.List.VBar.btnGrip.Paint = function() end
end

function PANEL:SetupList(ID, SoftID)
	for k,v in pairs(TBFY_SH.TheoryTestItems[ID]) do
		local Option = vgui.Create("tbfy_comp_theory_option", self.List)
		Option.MParent = self.MParent
		Option:SetOptionInfo(v, ID)
		self.Options[k] = Option
	end
end

function PANEL:Paint(W,H)

end

function PANEL:PerformLayout(Width, Height)
	self.List:SetSize(Width+5, Height-10)
	self.List:SetPos(5, 5)

	local HStart = 0
	for k,v in pairs(self.Options) do
		v:SetPos(0,HStart)
		v:SetSize(Width+5, 35)

		HStart = HStart + 40
	end
end
vgui.Register("tbfy_comp_theory_list", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Sheet = vgui.Create("DPropertySheet", self)
	self.Sheet:SetPadding(1)
	--self.Sheet.OColor = CProgramBG

	for k,v in pairs(TBFY_SH.TheoryTests) do
		local Sheet = vgui.Create("tbfy_comp_theory_list", self.Sheet)
		Sheet.MParent = self
		Sheet:SetupList(k)

		self.Sheet:AddSheet(v.Name, Sheet)
	end
	if table.Count(TBFY_SH.TheoryTests) < 1 then
		local Sheet = vgui.Create("DPanel", self.Sheet)

		self.Sheet:AddSheet("None Available", Sheet)
	end
end

function PANEL:UpdateData(Data)
		local Program = self:GetParent()
		Program:SetProgram("", "tbfy_comp_theorytest_menu", TWidth, THeight)
		Program.PaintOver = function(selfp, W,H)

		draw.SimpleText(TBFY_GetLang("TheoryTestMenu"), "tbfy_computer_programtitle", W/2, (Derma.HeaderH+5)/2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		local DLine = LocalPlayer().TBFY_TheoryDeadline
		if DLine then
			local TimeLeft = TimeToString(math.Round(DLine - CurTime()))
			draw.SimpleText(TBFY_GetLang("TheoryTimeLeft") .. ": " .. TimeLeft, "tbfy_computer_programtitle", 5, (Derma.HeaderH+5)/2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local Text = TBFY_GetLang("TheoryOverview")
		if Program.Software.ViewingQuestion then
			Text = TBFY_GetLang("TheoryQuestion") .. " " .. Program.Software.ViewingQuestion .. "/" .. Program.Software.QAmount
		end
		draw.SimpleText(Text, "tbfy_computer_programtitle", W-95, (Derma.HeaderH+5)/2, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	LocalPlayer().TBFY_TheoryDeadline = Data.Deadline
	Program.Software:SetupTheoryTest(Data.TestID, Data.QuestionString, Data.QuestionA, Data.QuestionR)
end

function PANEL:PerformLayout(W, H)
	self.Sheet:SetSize(W,H)
end

function PANEL:Paint(W, H)

end
vgui.Register("tbfy_comp_theorytest", PANEL)
