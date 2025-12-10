-- Advanced Control Panel v4.1 for game 121864768012064
-- Drop into an executor; runs as LocalScript on the client.

if game.PlaceId ~= 121864768012064 then
    warn("Wrong game! This script is for game 121864768012064")
    return
end

-- // Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local HRP = Char:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- // Themes
local themes = {
    Blue = {bg = Color3.fromRGB(16, 18, 26), panel = Color3.fromRGB(28, 34, 48), accent = Color3.fromRGB(0, 132, 255), accent2 = Color3.fromRGB(0, 92, 180), text = Color3.fromRGB(225, 235, 248), subtle = Color3.fromRGB(90, 110, 140), success = Color3.fromRGB(50, 200, 120), warn = Color3.fromRGB(255, 170, 60), danger = Color3.fromRGB(255, 70, 70)},
    NeoGreen = {bg = Color3.fromRGB(12, 16, 12), panel = Color3.fromRGB(24, 32, 28), accent = Color3.fromRGB(0, 200, 140), accent2 = Color3.fromRGB(0, 150, 100), text = Color3.fromRGB(220, 245, 230), subtle = Color3.fromRGB(90, 130, 110), success = Color3.fromRGB(60, 220, 140), warn = Color3.fromRGB(240, 190, 80), danger = Color3.fromRGB(255, 80, 80)},
    Amber = {bg = Color3.fromRGB(22, 18, 12), panel = Color3.fromRGB(34, 26, 18), accent = Color3.fromRGB(255, 160, 60), accent2 = Color3.fromRGB(220, 120, 40), text = Color3.fromRGB(255, 240, 220), subtle = Color3.fromRGB(150, 110, 80), success = Color3.fromRGB(60, 220, 140), warn = Color3.fromRGB(255, 200, 120), danger = Color3.fromRGB(255, 80, 80)},
    Purple = {bg = Color3.fromRGB(16, 12, 24), panel = Color3.fromRGB(28, 20, 40), accent = Color3.fromRGB(170, 110, 255), accent2 = Color3.fromRGB(120, 70, 200), text = Color3.fromRGB(235, 225, 255), subtle = Color3.fromRGB(130, 100, 160), success = Color3.fromRGB(80, 210, 140), warn = Color3.fromRGB(250, 190, 110), danger = Color3.fromRGB(255, 90, 120)},
}
local colors = themes.Blue

-- // Config
local config = {
    version = "4.1.0",
    menuKey = Enum.KeyCode.L,
    panicKey = Enum.KeyCode.RightControl,
    aimbotKey = Enum.UserInputType.MouseButton2,
    aimbotSmooth = 0.18,
    aimbotFov = 140,
    aimbotEnabled = false,
    triggerEnabled = false,
    esp = {enabled = false, names = true, distance = true, arrows = true, healthbar = true},
    flySpeed = 60,
    wsBoost = 28,
    jpBoost = 70,
    fov = 80,
    teleportList = {
        {name = "Spawn", pos = Vector3.new(0, 5, 0)},
        {name = "High Point", pos = Vector3.new(0, 50, 0)},
    },
    webhookUrl = "",
    theme = "Blue",
}
local hidden = false

-- // State
local wsDefault = Hum.WalkSpeed
local jpDefault = Hum.JumpPower
local connections = {}
local highlightObjects, nametagObjects, arrowObjects = {}, {}, {}
local blurEffect
local flyEnabled, flyBV = false, nil
local noclipEnabled = false
local autoClickEnabled = false
local autoInteractEnabled = false
local offscreenGui = Instance.new("ScreenGui")
offscreenGui.Name = "OffscreenGui"
offscreenGui.ResetOnSpawn = false
offscreenGui.Parent = game:GetService("CoreGui")

-- // Helpers
local function tween(obj, time, props, style, dir)
    return TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
end

local function ripple(button)
    local r = Instance.new("Frame")
    r.BackgroundColor3 = colors.accent
    r.BackgroundTransparency = 0.4
    r.Size = UDim2.fromOffset(0, 0)
    r.AnchorPoint = Vector2.new(0.5, 0.5)
    r.Position = UDim2.new(0.5, 0, 0.5, 0)
    r.BorderSizePixel = 0
    r.ZIndex = 5
    r.Parent = button
    tween(r, 0.35, {Size = UDim2.fromScale(2.4, 2.4), BackgroundTransparency = 1}).Completed:Connect(function() r:Destroy() end)
end

local function toast(msg, color)
    StarterGui:SetCore("SendNotification", {Title = "Advanced", Text = msg, Duration = 3, Button1 = "OK"})
end

local function setBlur(on)
    if on then
        if not blurEffect then
            blurEffect = Instance.new("BlurEffect")
            blurEffect.Size = 8
            blurEffect.Parent = Lighting
        end
    else
        if blurEffect then blurEffect:Destroy() blurEffect = nil end
    end
end
setBlur(true)

local function applyTheme()
    local function recolor(guiObj)
        if guiObj:IsA("Frame") or guiObj:IsA("TextButton") or guiObj:IsA("TextLabel") then
            if guiObj:GetAttribute("Accent") then
                guiObj.BackgroundColor3 = colors.accent
            elseif guiObj:GetAttribute("Panel") then
                guiObj.BackgroundColor3 = colors.panel
            elseif guiObj:GetAttribute("BG") then
                guiObj.BackgroundColor3 = colors.bg
            end
            if guiObj:IsA("TextLabel") or guiObj:IsA("TextButton") then
                guiObj.TextColor3 = colors.text
            end
        elseif guiObj:IsA("UIGradient") and guiObj.Parent and guiObj.Parent:GetAttribute("BG") then
            guiObj.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, colors.bg),
                ColorSequenceKeypoint.new(1, colors.accent2)
            })
        end
        for _, child in ipairs(guiObj:GetChildren()) do
            recolor(child)
        end
    end
    recolor(game:GetService("CoreGui"):FindFirstChild("AdvancedMenu") or Instance.new("Folder"))
end

local function setConfigClipboard()
    if setclipboard then
        setclipboard(HttpService:JSONEncode(config))
        toast("Config copied to clipboard", colors.success)
    else
        toast("setclipboard not available", colors.warn)
    end
end

local function loadConfigFromString(str)
    local ok, data = pcall(function() return HttpService:JSONDecode(str) end)
    if ok and type(data) == "table" then
        for k,v in pairs(data) do config[k] = v end
        toast("Config loaded", colors.success)
    else
        toast("Failed to load config", colors.danger)
    end
end

-- // GUI
local gui = Instance.new("ScreenGui")
gui.Name = "idk why advanced menu"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(540, 380)
main.Position = UDim2.new(0.5, -270, 0.5, -190)
main.BackgroundColor3 = colors.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main:SetAttribute("BG", true)
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local gradient = Instance.new("UIGradient", main)
gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, colors.bg), ColorSequenceKeypoint.new(1, colors.accent2)}
gradient.Rotation = 45

-- Quick actions
local quick = Instance.new("Frame")
quick.Size = UDim2.new(0, 540, 0, 32)
quick.Position = UDim2.new(0, 0, 0, -36)
quick.BackgroundTransparency = 1
quick.Parent = main
local qaList = Instance.new("UIListLayout", quick)
qaList.Padding = UDim.new(0, 8)
qaList.FillDirection = Enum.FillDirection.Horizontal
qaList.HorizontalAlignment = Enum.HorizontalAlignment.Right
qaList.VerticalAlignment = Enum.VerticalAlignment.Center

local function pill(label, color, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(120, 28)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 13
    b.Font = Enum.Font.GothamSemibold
    b.Text = label
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 14)
    b.Parent = quick
    b.MouseButton1Click:Connect(function() ripple(b); if cb then cb() end end)
end

pill("Panic", colors.danger, function()
    gui:Destroy()
    offscreenGui:Destroy()
    setBlur(false)
    Hum.WalkSpeed = wsDefault
    Hum.JumpPower = jpDefault
end)
pill("Hide UI", colors.accent2, function()
    hidden = not hidden
    main.Visible = not hidden
    offscreenGui.Enabled = not hidden
end)
pill("Rejoin", colors.accent, function()
    TeleportService:Teleport(game.PlaceId, LP)
end)

-- Title bar
local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 44)
title.BackgroundColor3 = colors.panel
title.BorderSizePixel = 0
title:SetAttribute("Panel", true)
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -170, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.Text = "Advanced Control Panel v4.1"
titleLabel.TextColor3 = colors.text
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = title

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 140, 1, 0)
versionLabel.Position = UDim2.new(1, -150, 0, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Font = Enum.Font.Gotham
versionLabel.Text = "v" .. config.version
versionLabel.TextColor3 = colors.subtle
versionLabel.TextSize = 14
versionLabel.TextXAlignment = Enum.TextXAlignment.Right
versionLabel.Parent = title

-- Tabs with icons
local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(0, 160, 1, -44)
tabs.Position = UDim2.new(0, 0, 0, 44)
tabs.BackgroundColor3 = colors.panel
tabs.BorderSizePixel = 0
tabs:SetAttribute("Panel", true)
tabs.Parent = main
Instance.new("UICorner", tabs).CornerRadius = UDim.new(0, 12)
local tabList = Instance.new("UIListLayout", tabs)
tabList.VerticalAlignment = Enum.VerticalAlignment.Top
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabList.Padding = UDim.new(0, 8)

local tabMeta = {
    {"Movement", "rbxassetid://3926305904", Vector2.new(204, 284)},
    {"Visuals", "rbxassetid://3926305904", Vector2.new(924, 244)},
    {"Combat", "rbxassetid://3926305904", Vector2.new(644, 364)},
    {"Utility", "rbxassetid://3926305904", Vector2.new(44, 764)},
    {"Config", "rbxassetid://3926305904", Vector2.new(84, 284)},
    {"Status", "rbxassetid://3926305904", Vector2.new(644, 124)},
}
local pages = {}
local selectedTab
local pageHolder = Instance.new("Frame")
pageHolder.Size = UDim2.new(1, -160, 1, -44)
pageHolder.Position = UDim2.new(0, 160, 0, 44)
pageHolder.BackgroundTransparency = 1
pageHolder.Parent = main

for _, meta in ipairs(tabMeta) do
    local name = meta[1]
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -24, 1, -24)
    page.Position = UDim2.new(0, 12, 0, 12)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = pageHolder
    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 10)
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Left
    list.VerticalAlignment = Enum.VerticalAlignment.Top
    pages[name] = page
end

local tabButtons = {}
local tabIndicator = Instance.new("Frame")
tabIndicator.Size = UDim2.new(0, 6, 0, 36)
tabIndicator.BackgroundColor3 = colors.accent
tabIndicator.BorderSizePixel = 0
tabIndicator.Visible = false
tabIndicator.Parent = tabs
Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(0, 3)

local function switchTab(name)
    for tabName, page in pairs(pages) do
        page.Visible = (tabName == name)
    end
    selectedTab = name
end

local function createTabButton(meta)
    local name, icon, offset = meta[1], meta[2], meta[3]
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -24, 0, 38)
    b.BackgroundColor3 = colors.bg
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = colors.text
    b.TextSize = 15
    b.Text = "   " .. name
    b:SetAttribute("BG", true)
    local ic = Instance.new("ImageLabel")
    ic.Size = UDim2.fromOffset(18, 18)
    ic.Position = UDim2.new(0, 10, 0.5, -9)
    ic.BackgroundTransparency = 1
    ic.Image = icon
    ic.ImageRectSize = Vector2.new(36, 36)
    ic.ImageRectOffset = offset
    ic.ImageColor3 = colors.text
    ic.Parent = b
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.Parent = tabs
    b.MouseEnter:Connect(function() tween(b, 0.12, {BackgroundColor3 = colors.panel}) end)
    b.MouseLeave:Connect(function()
        if selectedTab ~= name then tween(b, 0.12, {BackgroundColor3 = colors.bg}) end
    end)
    b.MouseButton1Click:Connect(function()
        ripple(b)
        switchTab(name)
        for other, btn in pairs(tabButtons) do
            tween(btn, 0.2, {BackgroundColor3 = (other == name) and colors.accent or colors.bg})
        end
        tabIndicator.Visible = true
        tween(tabIndicator, 0.2, {Position = UDim2.new(0, 4, 0, b.Position.Y.Offset), BackgroundColor3 = colors.accent})
    end)
    return b
end

for _, meta in ipairs(tabMeta) do
    tabButtons[meta[1]] = createTabButton(meta)
end
switchTab("Movement")
tween(tabButtons["Movement"], 0.01, {BackgroundColor3 = colors.accent})
tabIndicator.Position = UDim2.new(0, 4, 0, tabButtons["Movement"].Position.Y.Offset)
tabIndicator.Visible = true

-- // Control builders
local function makeToggle(parent, label, callback, defaultState)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 40)
    f.BackgroundColor3 = colors.panel
    f.BorderSizePixel = 0
    f:SetAttribute("Panel", true)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -70, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Font = Enum.Font.Gotham
    l.TextColor3 = colors.text
    l.TextSize = 15
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = label
    l.Parent = f
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(56, 24)
    btn.Position = UDim2.new(1, -70, 0.5, -12)
    btn.BackgroundColor3 = colors.bg
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn:SetAttribute("BG", true)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.Parent = f
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(20, 20)
    knob.Position = UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = colors.subtle
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.Parent = btn
    local on = defaultState or false
    local function set(state)
        on = state
        tween(btn, 0.16, {BackgroundColor3 = on and colors.accent or colors.bg})
        tween(knob, 0.16, {Position = on and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10), BackgroundColor3 = on and Color3.new(1, 1, 1) or colors.subtle})
        if callback then task.spawn(function() callback(on) end) end
    end
    btn.MouseButton1Click:Connect(function() ripple(btn); set(not on) end)
    set(on)
    return set
end

local function makeButton(parent, label, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 40)
    b.BackgroundColor3 = colors.panel
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = colors.text
    b.TextSize = 15
    b.Text = label
    b:SetAttribute("Panel", true)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.Parent = parent
    b.MouseEnter:Connect(function() tween(b, 0.08, {BackgroundColor3 = colors.accent2}) end)
    b.MouseLeave:Connect(function() tween(b, 0.08, {BackgroundColor3 = colors.panel}) end)
    b.MouseButton1Click:Connect(function() ripple(b); if callback then task.spawn(callback) end end)
    return b
end

local function makeSlider(parent, label, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 44)
    f.BackgroundColor3 = colors.panel
    f.BorderSizePixel = 0
    f:SetAttribute("Panel", true)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(0.5, -10, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Font = Enum.Font.Gotham
    l.TextColor3 = colors.text
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = label
    l.Parent = f
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0.5, -10, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextColor3 = colors.text
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Text = tostring(default)
    valueLabel.Parent = f
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 1, -12)
    bar.BackgroundColor3 = colors.bg
    bar.BorderSizePixel = 0
    bar:SetAttribute("BG", true)
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = colors.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local function setValue(v)
        v = math.clamp(v, min, max)
        valueLabel.Text = tostring(math.floor(v * 100) / 100)
        tween(fill, 0.1, {Size = UDim2.new((v - min) / (max - min), 0, 1, 0)})
        if callback then task.spawn(function() callback(v) end) end
    end
    local function input(posX)
        local rel = (posX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
        setValue(min + (max - min) * rel)
    end
    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            input(UserInputService:GetMouseLocation().X)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            input(UserInputService:GetMouseLocation().X)
        end
    end)
    setValue(default)
    return setValue
end

-- // ESP & Offscreen
local function clearESP()
    for _, obj in ipairs(highlightObjects) do obj:Destroy() end
    for _, obj in ipairs(nametagObjects) do obj:Destroy() end
    for _, obj in ipairs(arrowObjects) do obj:Destroy() end
    highlightObjects, nametagObjects, arrowObjects = {}, {}, {}
end

local function addESP(plr)
    if plr == LP or not config.esp.enabled then return end
    local char = plr.Character
    if not char then return end
    local h = Instance.new("Highlight")
    h.FillColor = colors.accent
    h.OutlineColor = colors.accent2
    h.Adornee = char
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
    table.insert(highlightObjects, h)

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if config.esp.names and hrp then
        local bill = Instance.new("BillboardGui")
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0, 200, 0, 40)
        bill.Adornee = hrp
        bill.Parent = char
        local txt = Instance.new("TextLabel")
        txt.BackgroundTransparency = 1
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.Font = Enum.Font.GothamSemibold
        txt.TextColor3 = colors.text
        txt.TextStrokeTransparency = 0.4
        txt.TextStrokeColor3 = colors.bg
        txt.TextSize = 14
        txt.Text = plr.Name
        txt.Parent = bill

        if config.esp.healthbar then
            local barFrame = Instance.new("Frame")
            barFrame.Size = UDim2.new(0.4, 0, 0, 6)
            barFrame.Position = UDim2.new(0.3, 0, 1, -4)
            barFrame.BackgroundColor3 = colors.bg
            barFrame.BorderSizePixel = 0
            barFrame.Parent = bill
            Instance.new("UICorner", barFrame).CornerRadius = UDim.new(1, 0)
            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = colors.success
            fill.Size = UDim2.new(1, 0, 1, 0)
            fill.BorderSizePixel = 0
            fill.Parent = barFrame
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            RunService.RenderStepped:Connect(function()
                if hum then
                    fill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
                end
            end)
        end

        if config.esp.distance then
            RunService.RenderStepped:Connect(function()
                if bill.Parent and hrp then
                    local mag = (hrp.Position - HRP.Position).Magnitude
                    txt.Text = ("%s | %dm"):format(plr.Name, math.floor(mag))
                end
            end)
        end
        table.insert(nametagObjects, bill)
    end

    if config.esp.arrows then
        local arrow = Instance.new("Frame")
        arrow.Size = UDim2.fromOffset(18, 18)
        arrow.BackgroundColor3 = colors.accent
        arrow.BorderSizePixel = 0
        arrow.AnchorPoint = Vector2.new(0.5, 0.5)
        arrow.Position = UDim2.new(0.5, 0, 0.5, 0)
        arrow.Parent = offscreenGui
        Instance.new("UICorner", arrow).CornerRadius = UDim.new(1, 0)
        table.insert(arrowObjects, arrow)
        RunService.RenderStepped:Connect(function()
            if not hrp or not HRP then return end
            local pos, onscreen = camera:WorldToViewportPoint(hrp.Position)
            if onscreen then
                arrow.Visible = false
            else
                arrow.Visible = true
                local viewport = camera.ViewportSize
                local dir = (Vector2.new(pos.X, pos.Y) - viewport/2).Unit
                local clamped = (viewport/2) + dir * math.min(viewport.X, viewport.Y) * 0.45
                arrow.Position = UDim2.fromOffset(clamped.X, clamped.Y)
                local angle = math.deg(math.atan2(dir.Y, dir.X))
                arrow.Rotation = angle
            end
        end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if config.esp.enabled then addESP(p) end
    end)
end)

-- // Aimbot helpers
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.Size = UDim2.fromOffset(config.aimbotFov, config.aimbotFov)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 0.9
fovCircle.BackgroundColor3 = colors.accent
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.ZIndex = 9
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
fovCircle.Parent = gui

local function pulseFov()
    tween(fovCircle, 0.15, {BackgroundTransparency = 0.6, Size = fovCircle.Size + UDim2.fromOffset(12,12)}).Completed:Connect(function()
        tween(fovCircle, 0.15, {BackgroundTransparency = 0.9, Size = UDim2.fromOffset(config.aimbotFov, config.aimbotFov)})
    end)
end

local function getClosestTarget()
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if d < dist and d <= config.aimbotFov then
                    closest = plr
                    dist = d
                end
            end
        end
    end
    return closest
end

-- // Teleports builder
local function buildTeleportButtons(container)
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("TextButton") and child.Text:find("TP:") then child:Destroy() end
    end
    for _, item in ipairs(config.teleportList) do
        makeButton(container, "TP: " .. item.name, function()
            if HRP then HRP.CFrame = CFrame.new(item.pos) end
        end)
    end
end

-- // Movement tab (with fly + speed sliders)
local movePage = pages["Movement"]
makeToggle(movePage, "Speed Boost", function(on) Hum.WalkSpeed = on and config.wsBoost or wsDefault end)
makeToggle(movePage, "High Jump", function(on) Hum.JumpPower = on and config.jpBoost or jpDefault end)
makeSlider(movePage, "WalkSpeed", 8, 120, config.wsBoost, function(v) config.wsBoost = v; if Hum.WalkSpeed ~= wsDefault then Hum.WalkSpeed = v end end)
makeSlider(movePage, "JumpPower", 20, 150, config.jpBoost, function(v) config.jpBoost = v; if Hum.JumpPower ~= jpDefault then Hum.JumpPower = v end end)
makeToggle(movePage, "Fly", function(on)
    flyEnabled = on
    if on then
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e4, 1e4, 1e4)
            flyBV.Velocity = Vector3.new()
            flyBV.Parent = HRP
        end
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
    end
end)
makeSlider(movePage, "Fly Speed", 10, 200, config.flySpeed, function(v) config.flySpeed = v end)
makeToggle(movePage, "Noclip", function(on) noclipEnabled = on end)
makeButton(movePage, "Preset: Parkour (WS 36 JP 90)", function()
    config.wsBoost = 36; config.jpBoost = 90; flyEnabled = false
    Hum.WalkSpeed = config.wsBoost; Hum.JumpPower = config.jpBoost
    toast("Applied Parkour preset", colors.success)
end)
makeButton(movePage, "Preset: Combat (WS 30 JP 80 FOV 90)", function()
    config.wsBoost = 30; config.jpBoost = 80; camera.FieldOfView = 90
    Hum.WalkSpeed = config.wsBoost; Hum.JumpPower = config.jpBoost
    toast("Applied Combat preset", colors.success)
end)

-- // Visuals tab
local visPage = pages["Visuals"]
makeToggle(visPage, "ESP (players)", function(on)
    config.esp.enabled = on
    clearESP()
    if on then for _, plr in ipairs(Players:GetPlayers()) do addESP(plr) end end
end)
makeToggle(visPage, "ESP Names", function(on)
    config.esp.names = on
    clearESP(); if config.esp.enabled then for _, plr in ipairs(Players:GetPlayers()) do addESP(plr) end end
end, config.esp.names)
makeToggle(visPage, "ESP Distance", function(on)
    config.esp.distance = on
    clearESP(); if config.esp.enabled then for _, plr in ipairs(Players:GetPlayers()) do addESP(plr) end end
end, config.esp.distance)
makeToggle(visPage, "ESP Arrows", function(on)
    config.esp.arrows = on
    clearESP(); if config.esp.enabled then for _, plr in ipairs(Players:GetPlayers()) do addESP(plr) end end
end, config.esp.arrows)
makeToggle(visPage, "ESP Healthbar", function(on)
    config.esp.healthbar = on
    clearESP(); if config.esp.enabled then for _, plr in ipairs(Players:GetPlayers()) do addESP(plr) end end
end, config.esp.healthbar)
makeSlider(visPage, "Camera FOV", 40, 120, config.fov, function(v) config.fov = v; camera.FieldOfView = v end)
makeToggle(visPage, "Background Blur", function(on) setBlur(on) end, true)

-- // Combat tab
local combatPage = pages["Combat"]
makeToggle(combatPage, "Aimbot (hold RMB)", function(on)
    config.aimbotEnabled = on
    fovCircle.Visible = on and not hidden
end)
makeSlider(combatPage, "Aimbot FOV", 40, 240, config.aimbotFov, function(v)
    config.aimbotFov = v
    fovCircle.Size = UDim2.fromOffset(v, v)
end)
makeSlider(combatPage, "Aimbot Smooth", 0.01, 0.5, config.aimbotSmooth, function(v) config.aimbotSmooth = v end)
makeToggle(combatPage, "Triggerbot", function(on) config.triggerEnabled = on end)
makeButton(combatPage, "Reset Camera FOV", function() camera.FieldOfView = 70 end)

-- // Utility tab
local utilPage = pages["Utility"]
makeButton(utilPage, "Teleport: Safe Spot", function() if HRP then HRP.CFrame = CFrame.new(0, 50, 0) end end)
makeButton(utilPage, "Rejoin Game", function() TeleportService:Teleport(game.PlaceId, LP) end)
makeToggle(utilPage, "Auto Clicker", function(on) autoClickEnabled = on end)
makeToggle(utilPage, "Auto Interact (ProximityPrompts)", function(on) autoInteractEnabled = on end)
makeButton(utilPage, "Add Current Position to Teleports", function()
    if HRP then
        table.insert(config.teleportList, {name = "Pos" .. #config.teleportList + 1, pos = HRP.Position})
        buildTeleportButtons(utilPage)
        toast("Saved teleport #" .. #config.teleportList, colors.success)
    end
end)
buildTeleportButtons(utilPage)
makeButton(utilPage, "Server Hop (lowest ping)", function()
    toast("Scanning servers...", colors.subtle)
    task.spawn(function()
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=25"):format(game.PlaceId)
        local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if ok and res and res.data then
            table.sort(res.data, function(a,b) return (a.ping or 1e9) < (b.ping or 1e9) end)
            local target = res.data[1]
            if target then
                toast("Hopping...", colors.success)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LP)
            else
                toast("No servers found", colors.warn)
            end
        else
            toast("Server fetch failed", colors.danger)
        end
    end)
end)

-- // Config tab (import/export modal)
local configPage = pages["Config"]
makeButton(configPage, "Copy Config to Clipboard", function() setConfigClipboard() end)
makeButton(configPage, "Open Import Modal", function()
    local modal = Instance.new("Frame")
    modal.Size = UDim2.new(0, 360, 0, 200)
    modal.Position = UDim2.new(0.5, -180, 0.5, -100)
    modal.BackgroundColor3 = colors.panel
    modal.BorderSizePixel = 0
    modal.Parent = gui
    Instance.new("UICorner", modal).CornerRadius = UDim.new(0, 12)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 120)
    box.Position = UDim2.new(0, 10, 0, 10)
    box.Text = "Paste JSON here"
    box.ClearTextOnFocus = false
    box.TextWrapped = true
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.TextColor3 = colors.text
    box.BackgroundColor3 = colors.bg
    box.Parent = modal
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    local importBtn = makeButton(modal, "Import", function()
        loadConfigFromString(box.Text)
        modal:Destroy()
    end)
    importBtn.Position = UDim2.new(0, 10, 0, 140)
    importBtn.Size = UDim2.new(0.5, -15, 0, 40)
    local cancelBtn = makeButton(modal, "Cancel", function() modal:Destroy() end)
    cancelBtn.Position = UDim2.new(0.5, 5, 0, 140)
    cancelBtn.Size = UDim2.new(0.5, -15, 0, 40)
end)
makeDropdown(configPage, "Theme", {"Blue", "NeoGreen", "Amber", "Purple"}, function(val)
    config.theme = val
    colors = themes[val] or colors
    applyTheme()
end)
makeButton(configPage, "Check for Update", function()
    toast("Attempting update fetch...", colors.subtle)
    task.spawn(function()
        local ok = pcall(function() game:HttpGet("https://raw.githubusercontent.com/Ninnyyy/myscript.lua/main/script.lua") end)
        toast(ok and "Fetched latest script (replace manually)" or "Update fetch failed", ok and colors.success or colors.danger)
    end)
end)
makeButton(configPage, "Test Webhook", function()
    if config.webhookUrl == "" then toast("Webhook URL empty", colors.warn) return end
    task.spawn(function()
        local payload = HttpService:JSONEncode({content = "Test ping from script v" .. config.version})
        pcall(function()
            http_request({Url = config.webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
        end)
        toast("Webhook sent (if allowed)", colors.success)
    end)
end)

-- Keybind editor
makeButton(configPage, "Change Menu Key (click then press)", function()
    toast("Press a key for Menu", colors.warn)
    local conn; conn = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        config.menuKey = inp.KeyCode
        toast("Menu key set to " .. tostring(inp.KeyCode), colors.success)
        conn:Disconnect()
    end)
end)
makeButton(configPage, "Change Panic Key (click then press)", function()
    toast("Press a key for Panic", colors.warn)
    local conn; conn = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        config.panicKey = inp.KeyCode
        toast("Panic key set to " .. tostring(inp.KeyCode), colors.success)
        conn:Disconnect()
    end)
end)

-- // Status tab
local statusPage = pages["Status"]
local fpsLabel = Instance.new("TextLabel")
fpsLabel.BackgroundTransparency = 1
fpsLabel.Size = UDim2.new(1, -10, 0, 24)
fpsLabel.Position = UDim2.new(0, 12, 0, 0)
fpsLabel.Font = Enum.Font.GothamSemibold
fpsLabel.TextColor3 = colors.text
fpsLabel.TextSize = 15
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Text = "FPS: --"
fpsLabel.Parent = statusPage
local pingLabel = fpsLabel:Clone()
pingLabel.Position = UDim2.new(0, 12, 0, 26)
pingLabel.Text = "Ping: --"
pingLabel.Parent = statusPage
local playerCount = fpsLabel:Clone()
playerCount.Position = UDim2.new(0, 12, 0, 52)
playerCount.Text = "Players: --"
playerCount.Parent = statusPage

local perf = Instance.new("TextLabel")
perf.BackgroundTransparency = 0.2
perf.BackgroundColor3 = colors.panel
perf.Size = UDim2.new(0, 140, 0, 38)
perf.Position = UDim2.new(1, -150, 0, 10)
perf.Font = Enum.Font.GothamSemibold
perf.TextColor3 = colors.text
perf.TextSize = 13
perf.TextXAlignment = Enum.TextXAlignment.Center
perf.TextYAlignment = Enum.TextYAlignment.Center
perf.Text = "FPS: -- | Ping: --"
perf.Parent = gui
Instance.new("UICorner", perf).CornerRadius = UDim.new(0, 8)

-- // Keybind toggle & panic
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == config.menuKey then
        hidden = not hidden
        tween(main, 0.25, {Position = hidden and UDim2.new(0.5, -270, 1.1, 0) or UDim2.new(0.5, -270, 0.5, -190)})
        main.Active = not hidden
        gui.Enabled = not hidden
        fovCircle.Visible = config.aimbotEnabled and not hidden
    elseif input.KeyCode == config.panicKey then
        clearESP(); gui:Destroy(); offscreenGui:Destroy(); setBlur(false)
        Hum.WalkSpeed = wsDefault; Hum.JumpPower = jpDefault
    end
end)

-- // Loops
table.insert(connections, RunService.Stepped:Connect(function()
    if noclipEnabled and Char then
        for _, part in ipairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if flyEnabled and flyBV and HRP then
        local dir = Vector3.new()
        local camCF = camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += camCF.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= camCF.UpVector end
        if dir.Magnitude > 0 then dir = dir.Unit * config.flySpeed else dir = Vector3.new() end
        flyBV.Velocity = dir
    end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if config.aimbotEnabled and UserInputService:IsMouseButtonPressed(config.aimbotKey) then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            pulseFov()
            local targetPos = target.Character.HumanoidRootPart.Position
            local look = CFrame.new(camera.CFrame.Position, targetPos)
            camera.CFrame = camera.CFrame:Lerp(look, config.aimbotSmooth)
            if config.triggerEnabled then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
            end
        end
    end
end))

task.spawn(function()
    while true do
        if autoClickEnabled then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        if autoInteractEnabled then
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end
        end
        task.wait(0.5)
    end
end)

local last = tick()
table.insert(connections, RunService.RenderStepped:Connect(function()
    local now = tick()
    local fps = 1 / (now - last)
    last = now
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
    fpsLabel.Text = ("FPS: %d"):format(math.floor(fps))
    pingLabel.Text = ("Ping: %dms"):format(ping)
    playerCount.Text = ("Players: %d"):format(#Players:GetPlayers())
    perf.Text = ("FPS: %d | Ping: %dms"):format(math.floor(fps), ping)
end))

-- Slight float animation
task.spawn(function()
    while gui.Parent do
        tween(main, 1.6, {Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset + 4)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.6)
        tween(main, 1.6, {Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset - 4)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.6)
    end
end)

-- Respawn handling
LP.CharacterAdded:Connect(function(newChar)
    Char = newChar
    Hum = Char:WaitForChild("Humanoid")
    HRP = Char:WaitForChild("HumanoidRootPart")
    wsDefault = Hum.WalkSpeed
    jpDefault = Hum.JumpPower
    if config.esp.enabled then
        task.delay(1, function()
            clearESP()
            for _, plr in ipairs(Players:GetPlayers()) do addESP(plr) end
        end)
    end
end)

applyTheme()
toast("Loaded Advanced Control Panel v" .. config.version, colors.success)
