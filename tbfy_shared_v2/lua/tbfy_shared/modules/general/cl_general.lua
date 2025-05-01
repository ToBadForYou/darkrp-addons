file.CreateDir("tbfy_shared")
file.CreateDir("tbfy_shared/imgur")

TBFY_SH.CachedImages = TBFY_SH.CachedImages or {}

function TBFY_SH.GetImgurImage(ImgurID)
	if TBFY_SH.CachedImages[ImgurID] then
		return TBFY_SH.CachedImages[ImgurID]
	elseif file.Exists("tbfy_shared/imgur/"..ImgurID..".png", "DATA") then
		TBFY_SH.CachedImages[ImgurID] = Material("data/tbfy_shared/imgur/"..ImgurID..".png", "noclamp smooth")
	else
		http.Fetch("https://i.imgur.com/"..ImgurID..".png",function(Body, Len, Headers)
			file.Write("tbfy_shared/imgur/"..ImgurID..".png", Body)
			TBFY_SH.CachedImages[ImgurID] = Material("data/tbfy_shared/imgur/"..ImgurID..".png", "noclamp smooth")
		end)
	end

	return TBFY_SH.CachedImages[ImgurID]
end

//Credits to Bobblehead for creating ScissorCircle function
//Modified by ToBadForYou
function render.SetScissorCirclePercent(x,y,radius, Percent, CachedVal)
	if x then
		render.ClearStencil()
		render.SetStencilTestMask(255)
		render.SetStencilWriteMask(255)
		render.SetStencilEnable(true)
		render.SetStencilReferenceValue(1)

		render.SetStencilCompareFunction(STENCIL_NEVER)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_REPLACE)
		render.SetStencilZFailOperation(STENCIL_REPLACE)

		draw.NoTexture()
		surface.SetDrawColor(color_white)

		local poly = {}
		if CachedVal then
			poly = CachedVal
		else
			local v = 360
			poly[1] = {x = x, y = y}
			for i = 0, v*Percent do
				poly[i+2] = {x = math.sin(-math.rad(i/v*360)) * (-radius) + x, y = math.cos(-math.rad(i/v*360)) * (-radius) + y}
			end
		end

		surface.DrawPoly(poly)

		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		return poly
	else
		render.SetStencilEnable(false)
	end
end

//END

function surface.DrawCornerRect(x, y, w, h, length, size)
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(255, 255, 255, 255)

	//top left
	surface.DrawRect(x, y, length, size)
	surface.DrawRect(x, y, size, length)

	//top right
	surface.DrawRect(x + w - length, y, length, size)
	surface.DrawRect(x + w - size, y, size, length)

	//bot left
  surface.DrawRect(x, y + h - size, length, size)
  surface.DrawRect(x, y + h - length, size, length)

	//bot right
  surface.DrawRect(x + w - length, y + h - size, length, size)
  surface.DrawRect(x + w - size, y + h - length, size, length)
end

function TBFY_cutLength(str, pW, font)
	surface.SetFont(font);

	local sW = pW - 40;

	for i = 1, string.len(str) do
		local sStr = string.sub(str, 1, i);
		local w, h = surface.GetTextSize(sStr);

		if (w > pW || (w > sW && string.sub(str, i, i) == " ")) then
			local cutRet = TBFY_cutLength(string.sub(str, i + 1), pW, font);

			local returnTable = {sStr};

			for k, v in pairs(cutRet) do
				table.insert(returnTable, v);
			end

			return returnTable;
		end
	end

	return {str};
end

net.Receive("tbfy_notify", function()
    local txt = net.ReadString()
    GAMEMODE:AddNotify(txt, net.ReadFloat(), net.ReadFloat())
    surface.PlaySound("buttons/lightswitch2.wav")

    MsgC(Color(255, 20, 20, 255), "[TBFY] ", Color(200, 200, 200, 255), txt, "\n")
end)

net.Receive("tbfy_sendmsg", function()
	local Type, MsgT = net.ReadString(), net.ReadString()
	TBFY_SH:SendMessage(Type, MsgT)
end)

function TBFY_SH:SendMessage(Type, MsgT)
	local Msg = vgui.Create("tbfy_comp_reqdata")
	Msg:Setup(Type, MsgT, "OK")
end

local Derma = TBFY_SH.Config.Derma
local NoPic = Material("vgui/avatar_default")

local function DrawCircle(x, y, radius, seg)
	local cir = {}
	table.insert(cir, {x = x, y = y})
	for i = 0, seg do
		local a = math.rad( (i / seg) * -360)
		table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius})
	end
	local a = math.rad(0)
	table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius})
	surface.DrawPoly(cir)
end

local PANEL = {}

function PANEL:Init()
	self.Avatar = vgui.Create("tbfy_imgur", self)
	self.Avatar:SetPaintedManually(true)
	self.Avatar:SetZPos(-1)
end

function PANEL:PerformLayout(W, H)
	self.Avatar:SetSize(W,H)
end

function PANEL:SetImgurID(ImgurID)
	self.Avatar:SetImgurID(ImgurID)
end

function PANEL:Paint(w, h)
	local SizeW,SizeH = w,h
	surface.SetDrawColor(Color(0, 0, 0, 255))
	DrawCircle(w/2, h/2, SizeH/2, math.max(SizeW,SizeH)/2)

	render.ClearStencil()
	render.SetStencilEnable( true )

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_ZERO)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(1)

	draw.NoTexture()
	surface.SetDrawColor(Color(0, 0, 0, 255))
	DrawCircle(w/2, h/2, SizeH/2-1, math.max(SizeW,SizeH)/2)

	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(1)

	self.Avatar:PaintManual()

	render.SetStencilEnable(false)
	render.ClearStencil()
end
vgui.Register("tbfy_CircularAvatar", PANEL)

local PANEL = {}

function PANEL:Init()
	self.ButtonText = ""
	self.ButtonTextColor = Color(255,255,255,255)
	self.BColor = Derma.ButtonColor
	self:SetText("")
	self.Font = "tbfy_buttontext"
	self.DButtonC = Derma.ButtonColor
	self.DHoverC = Derma.ButtonColorHovering
	self.DClickC = Derma.ButtonColorPressed
	self.Picture = nil
	self.PicPadding = 0
	self.DrawText = true
	self.DrawBox = true
	self.AdjustTextColor = false
end

function PANEL:UpdateColours()
	if self:IsDown() or self.m_bSelected then self.BColor = self.DClickC return end
	if self.Hovered and !self:GetDisabled() then self.BColor = self.DHoverC return end

	self.BColor = self.DButtonC
	return
end

function PANEL:SetBText(Text)
	self.ButtonText = Text
end

function PANEL:SetBoxColor(BC, BHC, BPC)
	self.DButtonC = BC
	self.DHoverC = BHC
	self.DClickC = BPC
end

function PANEL:SetBTextColor(Color)
	self.ButtonTextColor = Color
end

function PANEL:SetTextColorAdjust()
	self.AdjustTextColor = true
	self.DrawBox = false
end

function PANEL:SetBFont(Font)
	self.Font = Font
end

function PANEL:SetPicture(Mat, DrawText, DrawBox, Padding)
	self.Picture = Mat
	self.DrawText = DrawText
	self.DrawBox = DrawBox
	self.PicPadding = Padding
end

function PANEL:SetBColors(Press,Hover,Normal)
	self.DClickC = Press
	self.DHoverC = Hover
	self.DButtonC = Normal
end

function PANEL:SetCIcon()
	self.CIcon = true
end

function PANEL:Paint(W,H)
	local TWPos, THPos = W/2, H/2
	local IWPos, IHPos, ISize = W/2, 0, {W,H}
	if self.CIcon then
		local F = self.Font
		surface.SetFont(F)
		local TW, TH = surface.GetTextSize(self.ButtonText)
		THPos = H-TH
		local CSize = W*0.66
		IWPos, IHPos = W/2, H*0.1
		ISize = {CSize, CSize}
	end
	if self.DrawBox then
		draw.RoundedBox(4, 0, 0, W, H, self.BColor)
	end
	if self.DrawText then
		local TextColor = self.ButtonTextColor
		if self.AdjustTextColor then
			TextColor = self.BColor
		end
		draw.SimpleText(self.ButtonText, self.Font, TWPos, THPos, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	if self.Picture then
		local PicPad = self.PicPadding
		surface.SetMaterial(self.Picture)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(IWPos-ISize[1]/2+PicPad,IHPos+PicPad,ISize[1]-PicPad*2,ISize[2]-PicPad*2)
	end
end
vgui.Register("tbfy_button", PANEL, "DButton")

local PANEL = {}

local gradient_down = surface.GetTextureID("vgui/gradient_down")
function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, self.BColor)
	surface.SetTexture(gradient_down)
	surface.SetDrawColor(0, 142, 203, 200)
	surface.DrawTexturedRect(1,1,W-2,H-2)
	local TextColor = self.ButtonTextColor
	if self.AdjustTextColor then
		TextColor = self.BColor
	end
	draw.SimpleText(self.ButtonText, self.Font, W/2, H/2, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
vgui.Register("tbfy_button_starwars", PANEL, "tbfy_button")

local PANEL = {}

function PANEL:Init()
	self:SetText("")
	self.Font = "tbfy_buttontext"
	self.BPos = 0
	self.PTime = 0
	self.CurMode = "OFF"
	self.EType = ""
	self.Toggled = {}
end

function PANEL:SetToggleInfo(OnText, OnTColor, OnBGColor, OffText, OffTColor, OffBGColor, FuncN, StartVal, OnVal)
	self.Toggled["ON"] = {T = OnText, TC = OnTColor, TBG = OnBGColor}
	self.Toggled["OFF"] = {T = OffText, TC = OffTColor, TBG = OffBGColor}
	self.FuncN = FuncN
	self.OnVal = OnVal
	self.LastV = StartVal
	self:SetBMode(StartVal)
end

function PANEL:SetSliderInfo(W, MovingT)
	self.SliderS = W
	self.MovingT = MovingT
end

function PANEL:SetBMode(Val)
	if Val == self.OnVal then
		self.CurMode = "ON"
		self.BPos = self:GetWide()-self.SliderS/2
	else
		self.CurMode = "OFF"
		self.BPos = 0
	end
	self.PTime = 0
end

function PANEL:ToggleB()
	if self.CurMode == "ON" then
		self.CurMode = "OFF"
	elseif self.CurMode == "OFF" then
		self.CurMode = "ON"
	end
	self.PTime = CurTime()
	local Bool = true
	if self.CurMode == "OFF" then
		Bool = false
	end
	if self.OnValueChanged then
		self:OnValueChanged(Bool)
	end
end

function PANEL:SetServerCheck(Ent, SoftID)
	self.ServerCheck = true
	self.Ent = Ent
	self.SoftID = SoftID
end

function PANEL:DoClick()
	if self.ServerCheck then
		net.Start("tbfy_computer_run")
			net.WriteString("")
			net.WriteString("ToggleEntButton")
			net.WriteEntity(self.Ent)
			net.WriteString(self.SoftID)
			net.WriteString(self.EType)
		net.SendToServer()
	else
		self:ToggleB()
	end
end

function PANEL:SetEType(Type)
	self.EType = Type
end

function PANEL:Think()
	if IsValid(self.Ent) then
		local Val = self.Ent[self.FuncN](self.Ent)
		if Val != self.LastV then
			self.LastV = Val
			self:ToggleB()
		end
	end

	if self.PTime then
		local TotT = self.PTime + self.MovingT
		local W = self:GetWide()
		if self.CurMode == "ON" then
			self.BPos = math.Remap(math.Min(CurTime(), TotT), self.PTime, TotT, 0, W - self.SliderS)
		else
			self.BPos = math.Remap(math.Min(CurTime(), TotT), self.PTime, TotT, W - self.SliderS, 0)
		end
	end
end

function PANEL:Paint(W, H)
	draw.RoundedBox(4, 0, 0, W, H, Color(0,0,0,200))

	local Mode = self.CurMode
	local CurI = self.Toggled[Mode]

	draw.RoundedBox(4, 1, 1, W-2, H-2, CurI.TBG)

	draw.RoundedBox(4, self.BPos, 0, self.SliderS, H, Color(0,0,0,200))
	draw.RoundedBox(4, self.BPos + 1, 1, self.SliderS - 2, H-2, Derma.MainPanelColor)

	draw.SimpleText(CurI.T, self.Font, W/2, H/2, CurI.TC, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
vgui.Register("tbfy_button_toggle", PANEL, "DButton")

local PANEL = {}

function PANEL:UpdateImage(ImgurID, OvrMat)
	if OvrMat then
		self.Mat = OvrMat
		self:SetHTML("")
	elseif !ImgurID then
		self.Mat = NoPic
		self:SetHTML("")
	elseif type(ImgurID) == "string" then
		local URL = "https://i.imgur.com/" .. ImgurID .. ".jpg"
		self.Mat = nil
		timer.Simple(.4, function()
			self:SetHTML([[<img src="]] .. URL .. [[" style="width:]] .. self:GetWide()-20 .. [[;height:]] .. self:GetTall()-20 .. [[;">]])
		end)
	end
end

function PANEL:Paint(W,H)
	if self.Mat then
		surface.SetDrawColor(255,255,255, 255)
		surface.SetMaterial(self.Mat)
		surface.DrawTexturedRect(10,10,W-20,H-20)
	end

	if self:IsLoading() then
		return true
	end
end
vgui.Register("tbfy_html_picture", PANEL, "DHTML")

local PANEL = {}

function PANEL:Init()
	self.ImgurID = nil
	self.Mat = nil
end

function PANEL:SetImgurID(ID)
	if !ID or ID == "" then
		self.Mat = NoPic
	elseif type(ID) != "string" then
		self.Mat = ID
	elseif type(ID) == "string" then
		self.ImgurID = ID
		local Mat = TBFY_SH.GetImgurImage(self.ImgurID)
		if Mat then
			self.Loading = false
			self.Mat = Mat
		else
			self.Mat = NoPic
			self.Loading = true
		end
	end
end

function PANEL:Think()
	if self.Loading then
		local Mat = TBFY_SH.GetImgurImage(self.ImgurID)
		if Mat then
			self.Loading = false
			self.Mat = Mat
		end
	end
end

function PANEL:Paint(W,H)
	if self.Mat then
		surface.SetDrawColor(255,255,255, 255)
		surface.SetMaterial(self.Mat)
		surface.DrawTexturedRect(0,0,W,H)
	end
end
vgui.Register("tbfy_imgur", PANEL)

local PANEL = {}

function PANEL:Init()
	self.Text = ""
	self.Font = "default"
	self.AlignX = TEXT_ALIGN_CENTER
	self.AlignY = TEXT_ALIGN_CENTER
	self.DisplayHoverText = false
	self.Hovering = false
end

function PANEL:SetText(text)
	self.Text = text
end

function PANEL:SetAlignX(align)
	self.AlignX = align
end

function PANEL:SetAlignY(align)
	self.AlignY = align
end

function PANEL:SetFont(font)
	self.Font = font
end

function PANEL:SetDisplayHoverText(Boolean)
	self.DisplayHoverText = Boolean
end

function PANEL:OnCursorEntered()
	self.Hovering = true
end

function PANEL:OnCursorExited()
	self.Hovering = false
end

function PANEL:Paint(W,H)
	local X = 0
	if self.AlignX == TEXT_ALIGN_RIGHT then
		X = W
	elseif self.AlignX == TEXT_ALIGN_CENTER then
		X = W/2
	end

	local Y = 0
	if self.AlignY == TEXT_ALIGN_BOTTOM then
		Y = H
	elseif self.AlignY == TEXT_ALIGN_CENTER then
		Y = H/2
	end

	if self.Hovering then
		surface.SetFont(self.Font)
		local TextW, TextH = surface.GetTextSize(self.Text)
		TextW = TextW + 10
		TextH = TextH + 1
		DisableClipping(true)
		draw.RoundedBox(4, W/2-TextW/2, -TextH, TextW, TextH, Color(0,0,0,255))
		draw.SimpleText(self.Text, self.Font, W/2, -1, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		DisableClipping(false)
	end

	draw.SimpleText(self.Text, self.Font, X, Y, Color(0, 0, 0, 255), self.AlignX, self.AlignY)
end
vgui.Register("tbfy_label", PANEL)
