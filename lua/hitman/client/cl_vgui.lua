local PNL = FindMetaTable("Panel")

local function GetTextHeight(font, text)
    surface.SetFont(font)
    local w, h = surface.GetTextSize(text)
    return h
end

local function GetTextWide(font, text)
    surface.SetFont(font)
    local w, h = surface.GetTextSize(text)
    return w
end

local function Ease(t, b, c, d)
	t = t / d
	local ts = t * t
	local tc = ts * t


	return b + c * (-2 * tc + 3 * ts)
end

local function LerpColor(fract, from, to)
	return Color(Lerp(fract, from.r, to.r), Lerp(fract, from.g, to.g), Lerp(fract, from.b, to.b), Lerp(fract, from.a or 255, to.a or 255))
end

function PNL:LerpColor(var, to, duration, callback)
    if not duration then
        duration = 0.5
    end

    local color = self[var]
    local anim = self:NewAnimation(duration)
    anim.Color = to

    anim.Think = function(anim, pnl, fract)
        local newFract = Ease(fract, 0, 1, 1)

        if not anim.StartColor then
            anim.StartColor = color
        end

        local newColor = LerpColor(newFract, anim.StartColor, anim.Color)
        self[var] = newColor
    end

    anim.OnEnd = function()
        if callback then
            callback(self)
        end
    end
end

function PNL:SetMyScroll()
    self.sBar = self:GetVBar()
    self.sBar:SetWide(5)
    self.sBar:SetHideButtons(true)

    function self.sBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end

    function self.sBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
    end

    self.sBar.toscroll = 0

    function self.sBar:OnMouseWheeled(dlta)
        if not self:IsVisible() then return false end
        self.toscroll = self.toscroll + dlta * -100

        return true
    end

    function self.sBar:OnMousePressed()
        local x, y = self:CursorPos()
        local PageSize = self.BarSize

        if y > self.btnGrip.y then
            self.toscroll = self:GetScroll() + PageSize
        else
            self.toscroll = self:GetScroll() - PageSize
        end
    end

    function self.sBar:Think()
        if self.Dragging then
            self.toscroll = self:GetScroll()

            return
        end

        local oldScroll = self:GetScroll()
        self:SetScroll(Lerp(FrameTime() * 10, oldScroll, self.toscroll))

        if oldScroll == self:GetScroll() then
            self.toscroll = oldScroll
        end
    end
end

local PANEL = {}
AccessorFunc(PANEL, "backgroundAlpha", "BackgroundAlpha")
AccessorFunc(PANEL, "cornerRadius", "CornerRadius")

function PANEL:Init()
    self:SetFont("htRoboto25")
    self:SetTextColor(color_white)
    self:SetPaintBackground(false)

    self.padding = {5, 10, 5, 10}

    self.backgroundColor = Color(0, 0, 0, 77)
    self:SetTextColor(Color(255, 255, 255))
    self.backgroundColor2 = self.backgroundColor
    self.disabledColor = Color(225, 112, 85, 80)
    self.backgroundAlpha = 128
    self.currentBackgroundAlpha = 0
    self.cornerRadius = 5
    self:SizeToContents()
end

function PANEL:GetPadding()
    return self.padding
end

function PANEL:SetPadding(left, top, right, bottom)
    self.padding = {left or self.padding[1], top or self.padding[2], right or self.padding[3], bottom or self.padding[4]}
end

function PANEL:SizeToContents()
    local width, height = self:GetSize()
    self:SetSize(width + self.padding[1] + self.padding[3], height + self.padding[2] + self.padding[4])
end

function PANEL:SetBackgroundColor(color)
    self.backgroundColor = Color(color.r, color.g, color.b, self.backgroundAlpha)
    self.backgroundColor2 = Color(color.r, color.g, color.b, self.backgroundAlpha)
end

function PANEL:Paint(width, height)
    if self.disabled then
        draw.RoundedBox(self.cornerRadius, 0, 0, width, height, Color(self.disabledColor.r, self.disabledColor.g, self.disabledColor.b, self.disabledColor.a))

        return
    end

    if self.selected then
        draw.RoundedBox(self.cornerRadius, 0, 0, width, height, Color(self.backgroundColor.r + 25, self.backgroundColor.g + 25, self.backgroundColor.b + 25, self.backgroundColor.a + 60))

        return
    end

    draw.RoundedBox(self.cornerRadius, 0, 0, width, height, Color(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, self.backgroundColor.a))
end

function PANEL:SetTextColorInternal(color)
    baseclass.Get("DButton").SetTextColor(self, color)
    self:SetFGColor(color)
end

function PANEL:SetTextColor(color)
    self:SetTextColorInternal(color)
    self.color = color
end

function PANEL:SetDisabled(bValue)
    self.disabled = bValue
end

function PANEL:OnCursorEntered()
    if self.disabled then return end
    self.backgroundToColor = Color(self.backgroundColor.r + 30, self.backgroundColor.g + 30, self.backgroundColor.b + 30, self.backgroundColor.a + 80)
    self:LerpColor("backgroundColor", self.backgroundToColor, 0.2)
end

function PANEL:OnCursorExited()
    if self.disabled then return end
    self:LerpColor("backgroundColor", self.backgroundColor2, 0.2)
end

function PANEL:OnMousePressed(code)
    if self.disabled then return end

    if self.color then
        self:SetTextColor(self.color)
    end

    if code == MOUSE_LEFT and self.DoClick then
        self:DoClick(self)
    elseif code == MOUSE_RIGHT and self.DoRightClick then
        self:DoRightClick(self)
    end
end

function PANEL:OnMouseReleased(key)
    if self.disabled then return end

    if self.color then
        self:SetTextColor(self.color)
    else
        self:SetTextColor(color_white)
    end
end

vgui.Register("ht.Button", PANEL, "DButton")
PANEL = {}

function PANEL:Init()
    self.title = "SOsi huy i ne psihuy"
    self.bShow = true
    self:AlphaTo(0, 0)
    self:AlphaTo(255, 0.3)
    self.tertiaryColor = HITMAN.config.colors.tertiary
end

function PANEL:InitPanel()
    self.TopPanel = self:Add("DPanel")
    self.TopPanel:SetSize(self:GetWide(), math.Clamp(self:GetTall() * 0.1, 18, 36))
    self.TopPanel:SetPos(0, 0)

    self.TopPanel.Paint = function(this, w, h)
        local hText = GetTextHeight("htRoboto25", self.title)
        surface.SetDrawColor(self.tertiaryColor)
        surface.DrawRect(0, 0, w, h)
        surface.SetFont("htRoboto25")
        surface.SetTextColor(240, 240, 240)
        surface.SetTextPos(5, (h - hText) / 2)
        surface.DrawText(self.title)
    end

    if self.bShow then
        self.exitButton = self.TopPanel:Add("ht.Button")
        self.exitButton:SetSize(math.Clamp(self.TopPanel:GetWide() * 0.15, 36, 48), self.TopPanel:GetTall())
        self.exitButton:SetPos(self.TopPanel:GetWide() - self.exitButton:GetWide(), 0)
        self.exitButton:SetFont("htRoboto25")
        self.exitButton:SetText("✖")
        self.exitButton:SetCornerRadius(0)
        self.exitButton:SetTextColor(HITMAN.config.colors.text)

        self.exitButton.DoClick = function()
            self:OnRemove()
        end
    end
end

function PANEL:OnRemove()
    if IsValid(self) then
        self:AlphaTo(0, 0.3, 0, function()
            self:Remove()
        end)
    end
end

function PANEL:SetTitle(text)
    self.title = text
end

function PANEL:ShowCloseButton(bShow)
    self.bShow = bShow
end

function PANEL:Paint(width, height)
    surface.SetDrawColor(HITMAN.config.colors.primary)
    surface.DrawRect(0, 0, width, height)
end

vgui.Register("ht.Frame", PANEL, "EditablePanel")
PANEL = {}

function PANEL:Init()
    self:SetSize(300, 300)
    self.backgroundColor = HITMAN.config.colors.secondary
end

function PANEL:SetBackgroundColor(color)
    self.backgroundColor = color
end

function PANEL:Paint(width, height)
    surface.SetDrawColor(self.backgroundColor)
    surface.DrawRect(0, 0, width, height)
end

vgui.Register("ht.Panel", PANEL, "EditablePanel")
PANEL = {}

function PANEL:Init()
    self:SetSize(300, 300)
    self:SetMyScroll()
    self.backgroundColor = HITMAN.config.colors.secondary
end

function PANEL:SetBackgroundColor(color)
    self.backgroundColor = color
end

function PANEL:Paint(width, height)
    surface.SetDrawColor(self.backgroundColor)
    surface.DrawRect(0, 0, width, height)
end

vgui.Register("ht.DscrollPanel", PANEL, "DScrollPanel")

DEFINE_BASECLASS("DTextEntry")
PANEL = {}

function PANEL:Init()
    self:SetPaintBackground(false)
end

function PANEL:Paint(width, height)
    -- draw.RoundedBox(0, 0, 0, width, height, )
    surface.SetDrawColor(HITMAN.config.colors.bg)
    surface.DrawRect(0, 0, width, height)

    BaseClass.Paint(self, width, height)
end

vgui.Register("htTextEntry", PANEL, "DTextEntry")

local localplayer = LocalPlayer()
local function OpenMenu()
    if !IsValid(localplayer) then
        localplayer = LocalPlayer()
    end

    local frame = vgui.Create("ht.Frame")
    frame:SetSize(ScrW() * 0.4, ScrH() * 0.5)
    frame:SetPos((ScrW() - frame:GetWide()) / 2, (ScrH() - frame:GetTall()) / 2)
    frame:SetTitle("Заказ на убийство")
    frame:MakePopup()
    frame:InitPanel()

    local panel = vgui.Create("ht.DscrollPanel", frame)
    panel:SetSize(frame:GetWide() * 0.35, frame:GetTall() - frame.TopPanel:GetTall() - 5)
    panel:SetPos(0, frame.TopPanel:GetTall() + 5)
    panel:SetBackgroundColor(HITMAN.config.colors.tertiary)

    local infPanel = vgui.Create("ht.Panel", frame)
    infPanel:SetSize(frame:GetWide() * 0.65 - 5, frame:GetTall() - frame.TopPanel:GetTall() - 5)
    infPanel:SetPos(frame:GetWide() * 0.35 + 5, frame.TopPanel:GetTall() + 5)
    infPanel:SetBackgroundColor(HITMAN.config.colors.tertiary)
    local wide, tall = panel:GetWide(), panel:GetTall() * 0.1
    local aSize = panel:GetWide() * 0.2

    for k, v in ipairs(player.GetAll()) do
        if localplayer == v then continue end
        local item = vgui.Create("ht.Panel", panel)
        item:SetSize(wide, tall)
        item:Dock(TOP)
        item:DockMargin(0, 0, 0, 5)

        item:SetBackgroundColor(HITMAN.config.colors.secondary)
        local Avatar = vgui.Create("AvatarImage", item)
        Avatar:SetSize(aSize - 10, tall - 10)
        Avatar:SetPos(5, 5)
        Avatar:SetPlayer(v, 128)

        local name = item:Add("DLabel")
        name:SetText(v:Name())
        name:SetFont("htRoboto25")
        name:SetTextColor(HITMAN.config.colors.text)
        name:SizeToContents()
        name:SetPos(aSize, tall * .25)

        --[[local job = item:Add( "DLabel" )
        job:SetText(v:getDarkRPVar("job"))
        job:SetFont("htRoboto20")
        job:SetTextColor(HITMAN.config.colors.text)
        job:SizeToContents()
        job:SetPos(aSize, tall * .5)]]

        local button = item:Add("ht.Button")
        button:SetSize(item:GetWide(), item:GetTall())
        button:SetPos(0, 0)
        button:SetText("")
        button:SetCornerRadius(0)
        button:SetTextColor(HITMAN.config.colors.text)

        button.DoClick = function()
            infPanel:Clear()
            local infWide, infTall = infPanel:GetWide(), infPanel:GetTall()
            iconWide = infPanel:GetWide() * 0.6
            local icon = vgui.Create("DModelPanel", infPanel)
            icon:SetSize(iconWide, iconWide)
            icon:SetPos(infWide * 0.2, 0)
            icon:SetModel(v:GetModel())

            local name = infPanel:Add("DLabel")
            name:SetText(v:Name())
            name:SetFont("htRoboto30")
            name:SetTextColor(HITMAN.config.colors.text)
            name:SizeToContents()
            name:SetPos((infWide - name:GetWide()) / 2, infTall * .63)

            local job = infPanel:Add( "DLabel" )
            job:SetText(v:getDarkRPVar("job"))
            job:SetFont("htRoboto25")
            job:SetTextColor(HITMAN.config.colors.text)
            job:SizeToContents()
            job:SetPos((infWide - job:GetWide()) / 2, infTall * .68)

            local TextEntry = infPanel:Add("htTextEntry")
            TextEntry:SetSize(infWide * 0.4, infTall * 0.06)
            TextEntry:SetPos((infWide - TextEntry:GetWide()) / 2, infTall * 0.75)
            TextEntry:SetNumeric(true)
            TextEntry:SetFont("htRoboto30")
            TextEntry:SetTextColor(HITMAN.config.colors.text)
            TextEntry:SetValue(HITMAN.config.price[1])
            TextEntry:SetPaintBackground(false)

            local button = infPanel:Add("ht.Button")
            button:SetSize(infWide * 0.4, infTall * 0.06)
            button:SetPos((infWide - button:GetWide()) / 2, infTall * 0.83)
            button:SetText("Заказать")
            button:SetCornerRadius(0)
            button:SetFont("htRoboto20")
            button:SetTextColor(HITMAN.config.colors.text)
            button:SetBackgroundColor(HITMAN.config.colors.btnColor)

            button.DoClick = function()
                net.Start("hitman.AddOrder")
                    net.WriteEntity(v)
                    net.WriteUInt(TextEntry:GetValue(), 24)
                net.SendToServer()
            end
        end
    end
end

net.Receive("hitman.OpenMenu", OpenMenu)