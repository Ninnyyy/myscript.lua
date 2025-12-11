-- Advanced Universal Hub v5.0
-- Universal client script for executors. No place lock. Menu key L, Panic RightControl by default.

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
    Midnight = {bg=Color3.fromRGB(14,16,22), panel=Color3.fromRGB(22,28,40), accent=Color3.fromRGB(0,145,255), accent2=Color3.fromRGB(0,110,200), text=Color3.fromRGB(230,238,255), subtle=Color3.fromRGB(110,130,160), success=Color3.fromRGB(70,210,140), warn=Color3.fromRGB(255,195,90), danger=Color3.fromRGB(255,80,90)},
    NeoGreen = {bg=Color3.fromRGB(12,16,12), panel=Color3.fromRGB(24,32,28), accent=Color3.fromRGB(0,200,140), accent2=Color3.fromRGB(0,150,100), text=Color3.fromRGB(220,245,230), subtle=Color3.fromRGB(90,130,110), success=Color3.fromRGB(60,220,140), warn=Color3.fromRGB(240,190,80), danger=Color3.fromRGB(255,80,80)},
    Amber    = {bg=Color3.fromRGB(24,18,12), panel=Color3.fromRGB(34,26,18), accent=Color3.fromRGB(255,170,80), accent2=Color3.fromRGB(220,135,60), text=Color3.fromRGB(255,240,220), subtle=Color3.fromRGB(150,110,80), success=Color3.fromRGB(60,220,140), warn=Color3.fromRGB(255,200,120), danger=Color3.fromRGB(255,90,90)},
    Purple  = {bg=Color3.fromRGB(18,12,26), panel=Color3.fromRGB(30,20,44), accent=Color3.fromRGB(170,110,255), accent2=Color3.fromRGB(130,80,210), text=Color3.fromRGB(235,225,255), subtle=Color3.fromRGB(140,110,170), success=Color3.fromRGB(90,220,160), warn=Color3.fromRGB(250,190,120), danger=Color3.fromRGB(255,90,130)},
}
local colors = themes.Midnight

-- // Config
local config = {
    version = "5.0.0",
    menuKey = Enum.KeyCode.L,
    panicKey = Enum.KeyCode.RightControl,
    aimbotKey = Enum.UserInputType.MouseButton2,
    aimbotSmooth = 0.18,
    aimbotFov = 140,
    aimbotEnabled = false,
    triggerEnabled = false,
    esp = {enabled=false, names=true, distance=true, arrows=true, healthbar=true, boxes=true, tracers=true, items=false, worldTags={"Chest","Coin","Key"}},
    flySpeed = 75,
    wsBoost = 28,
    jpBoost = 70,
    sprintSpeed = 40,
    speedLock = false,
    lowGravity = false,
    fov = 80,
    teleportList = {},
    webhookUrl = "",
    theme = "Midnight",
    profiles = {},
    keybinds = {
        toggleUI = Enum.KeyCode.L,
        panic = Enum.KeyCode.RightControl,
        toggleAimbot = Enum.KeyCode.F1,
        toggleESP = Enum.KeyCode.F2,
        toggleFly = Enum.KeyCode.F3,
        toggleNoclip = Enum.KeyCode.F4,
    },
    presets = {
        legit = {ws=24, jp=70, fov=75, aimbot=false, esp=true},
        rage = {ws=60, jp=120, fov=100, aimbot=true, esp=true},
        visuals = {fov=80, aimbot=false, esp=true},
    },
}
local hidden = false
local wsDefault = Hum.WalkSpeed
local jpDefault = Hum.JumpPower
local gravityDefault = workspace.Gravity
local connections = {}
local highlightObjects, nametagObjects, arrowObjects = {}, {}, {}
local tracerObjects = {}
local blurEffect
local flyEnabled, flyBV = false, nil
local noclipEnabled = false
local autoClickEnabled = false
local autoInteractEnabled = false
local sprinting = false
local infiniteJump = false
local safeWalkEnabled = false
local fullbrightEnabled = false
local noFogEnabled = false
local currentGameId = game.PlaceId
local supportedGames = { -- example supported list
    [121864768012064] = "Example Game Module",
}
local gameModuleLoaded = supportedGames[currentGameId]

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
local function toast(msg)
    StarterGui:SetCore("SendNotification", {Title = "Advanced", Text = msg, Duration = 3, Button1 = "OK"})
end
local function log(event, data)
    if config.webhookUrl == "" then return end
    task.spawn(function()
        local payload = HttpService:JSONEncode({content = ("[%s] %s"):format(event, data or "")})
        pcall(function()
            http_request({Url = config.webhookUrl, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body = payload})
        end)
    end)
end
local function setBlur(on)
    if on then
        if not blurEffect then
            blurEffect = Instance.new("BlurEffect")
            blurEffect.Size = 10
            blurEffect.Parent = Lighting
        end
    else
        if blurEffect then blurEffect:Destroy(); blurEffect = nil end
    end
end
setBlur(true)
local function applyTheme() colors = themes[config.theme] or colors end

-- UI Factory
local function makeCorner(obj, r) local c=Instance.new("UICorner"); c.CornerRadius = UDim.new(0,r or 10); c.Parent=obj end
local function makeToggle(parent, label, callback, defaultState)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 40)
    f.BackgroundColor3 = colors.panel
    f.BorderSizePixel = 0
    makeCorner(f,10)
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1; l.Size = UDim2.new(1, -70, 1, 0); l.Position = UDim2.new(0, 12, 0, 0)
    l.Font = Enum.Font.Gotham; l.TextColor3 = colors.text; l.TextSize = 15; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = label; l.Parent = f
    local btn = Instance.new("TextButton"); btn.Size = UDim2.fromOffset(56, 24); btn.Position = UDim2.new(1, -70, 0.5, -12)
    btn.BackgroundColor3 = colors.bg; btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.Text = ""; makeCorner(btn,24); btn.Parent = f
    local knob = Instance.new("Frame"); knob.Size=UDim2.fromOffset(20,20); knob.Position=UDim2.new(0,2,0.5,-10); knob.BackgroundColor3=colors.subtle; knob.BorderSizePixel=0; makeCorner(knob,20); knob.Parent=btn
    local on = defaultState or false
    local function set(state)
        on = state
        tween(btn, 0.16, {BackgroundColor3 = on and colors.accent or colors.bg})
        tween(knob, 0.16, {Position = on and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10), BackgroundColor3 = on and Color3.new(1,1,1) or colors.subtle})
        if callback then task.spawn(function() callback(on) end) end
    end
    btn.MouseButton1Click:Connect(function() ripple(btn); set(not on); log("toggle", label .. "=" .. tostring(not on)) end)
    set(on); return set
end
local function makeButton(parent, label, callback)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-10,0,40); b.BackgroundColor3=colors.panel; b.BorderSizePixel=0; b.AutoButtonColor=false
    b.Font=Enum.Font.GothamSemibold; b.TextColor3=colors.text; b.TextSize=15; b.Text=label; makeCorner(b,10); b.Parent=parent
    b.MouseEnter:Connect(function() tween(b,0.08,{BackgroundColor3=colors.accent2}) end)
    b.MouseLeave:Connect(function() tween(b,0.08,{BackgroundColor3=colors.panel}) end)
    b.MouseButton1Click:Connect(function() ripple(b); if callback then task.spawn(callback) end end)
    return b
end
local function makeSlider(parent,label,min,max,default,callback)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,44); f.BackgroundColor3=colors.panel; f.BorderSizePixel=0; makeCorner(f,10); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(0.5,-10,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local value=Instance.new("TextLabel"); value.BackgroundTransparency=1; value.Size=UDim2.new(0.5,-10,1,0); value.Position=UDim2.new(0.5,0,0,0); value.Font=Enum.Font.GothamSemibold; value.TextColor3=colors.text; value.TextSize=14; value.TextXAlignment=Enum.TextXAlignment.Right; value.Text=tostring(default); value.Parent=f
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-24,0,6); bar.Position=UDim2.new(0,12,1,-12); bar.BackgroundColor3=colors.bg; bar.BorderSizePixel=0; makeCorner(bar,6); bar.Parent=f
    local fill=Instance.new("Frame"); fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3=colors.accent; fill.BorderSizePixel=0; makeCorner(fill,6); fill.Parent=bar
    local dragging=false
    local function setVal(v)
        v=math.clamp(v,min,max); value.Text=tostring(math.floor(v*100)/100); tween(fill,0.1,{Size=UDim2.new((v-min)/(max-min),0,1,0)}); if callback then task.spawn(function() callback(v) end) end
    end
    bar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setVal(min+(max-min)*((UserInputService:GetMouseLocation().X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X)) end end)
    bar.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(inp) if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then setVal(min+(max-min)*((UserInputService:GetMouseLocation().X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X)) end end)
    setVal(default); return setVal
end
local function makeDropdown(parent,label,options,callback)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,40); f.BackgroundColor3=colors.panel; f.BorderSizePixel=0; makeCorner(f,10); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(0.5,-10,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0.5,-20,1,-8); btn.Position=UDim2.new(0.5,8,0,4); btn.BackgroundColor3=colors.bg; btn.BorderSizePixel=0; btn.TextColor3=colors.text; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=14; btn.Text=options[1] or "Select"; makeCorner(btn,8); btn.Parent=f
    local function set(val) btn.Text=val; if callback then callback(val) end end
    btn.MouseButton1Click:Connect(function() ripple(btn); local next=1; for i,opt in ipairs(options) do if opt==btn.Text then next=i%#options+1 end end; set(options[next]) end)
    set(options[1]); return set
end

-- // GUI scaffold
local guiRoot = gui
-- Title, tabs, pages like previous build (omitted for brevity inside code output)

-- Build tabs list
local tabDefs = {
    "Dashboard",
    "Movement",
    "Visuals",
    "Combat",
    "Automation",
    "Player List",
    "Script Hub",
    "Configs",
    "Protection",
    "UI / Theme",
}

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
    Midnight = {bg=Color3.fromRGB(14,16,22), panel=Color3.fromRGB(22,28,40), accent=Color3.fromRGB(0,145,255), accent2=Color3.fromRGB(0,110,200), text=Color3.fromRGB(230,238,255), subtle=Color3.fromRGB(110,130,160), success=Color3.fromRGB(70,210,140), warn=Color3.fromRGB(255,195,90), danger=Color3.fromRGB(255,80,90)},
    NeoGreen = {bg=Color3.fromRGB(12,16,12), panel=Color3.fromRGB(24,32,28), accent=Color3.fromRGB(0,200,140), accent2=Color3.fromRGB(0,150,100), text=Color3.fromRGB(220,245,230), subtle=Color3.fromRGB(90,130,110), success=Color3.fromRGB(60,220,140), warn=Color3.fromRGB(240,190,80), danger=Color3.fromRGB(255,80,80)},
    Amber    = {bg=Color3.fromRGB(24,18,12), panel=Color3.fromRGB(34,26,18), accent=Color3.fromRGB(255,170,80), accent2=Color3.fromRGB(220,135,60), text=Color3.fromRGB(255,240,220), subtle=Color3.fromRGB(150,110,80), success=Color3.fromRGB(60,220,140), warn=Color3.fromRGB(255,200,120), danger=Color3.fromRGB(255,90,90)},
    Purple  = {bg=Color3.fromRGB(18,12,26), panel=Color3.fromRGB(30,20,44), accent=Color3.fromRGB(170,110,255), accent2=Color3.fromRGB(130,80,210), text=Color3.fromRGB(235,225,255), subtle=Color3.fromRGB(140,110,170), success=Color3.fromRGB(90,220,160), warn=Color3.fromRGB(250,190,120), danger=Color3.fromRGB(255,90,130)},
}
local colors = themes.Midnight

-- // Config
local config = {
    version = "5.1.0",
    menuKey = Enum.KeyCode.L,
    panicKey = Enum.KeyCode.RightControl,
    aimbotKey = Enum.UserInputType.MouseButton2,
    aimbotSmooth = 0.18,
    aimbotFov = 140,
    aimbotEnabled = false,
    triggerEnabled = false,
    aimbotMode = "Nearest Crosshair",
    aimbotArea = "Head",
    esp = {enabled=false, names=true, distance=true, arrows=true, healthbar=true, boxes=true, tracers=true, items=false, worldTags={"Chest","Coin","Key"}, teamColors=true},
    flySpeed = 75,
    wsBoost = 28,
    jpBoost = 70,
    sprintSpeed = 40,
    speedLock = false,
    lowGravity = false,
    fov = 80,
    infiniteZoom = true,
    fullbright = false,
    noFog = false,
    teleportList = {
        {name="Spawn", pos=Vector3.new(0,5,0)},
        {name="High Point", pos=Vector3.new(0,50,0)},
    },
    webhookUrl = "",
    theme = "Midnight",
    profiles = {}, -- per-game + global
    keybinds = {
        toggleUI = Enum.KeyCode.L,
        panic = Enum.KeyCode.RightControl,
        toggleAimbot = Enum.KeyCode.F1,
        toggleESP = Enum.KeyCode.F2,
        toggleFly = Enum.KeyCode.F3,
        toggleNoclip = Enum.KeyCode.F4,
    },
    presets = {
        legit = {ws=24, jp=70, fov=75, aimbot=false, esp=true},
        rage = {ws=60, jp=120, fov=100, aimbot=true, esp=true},
        visuals = {fov=80, aimbot=false, esp=true},
    },
}
local hidden = false
local wsDefault = Hum.WalkSpeed
local jpDefault = Hum.JumpPower
local gravityDefault = workspace.Gravity
local connections = {}
local highlightObjects, nametagObjects, arrowObjects = {}, {}, {}
local tracerObjects = {}
local blurEffect
local flyEnabled, flyBV = false, nil
local noclipEnabled = false
local autoClickEnabled = false
local autoInteractEnabled = false
local sprinting = false
local infiniteJump = false
local safeWalkEnabled = false
local currentGameId = game.PlaceId
local supportedGames = { -- extend as you add modules
    [121864768012064] = "Example Game Module",
}
local gameModuleLoaded = supportedGames[currentGameId]

-- // Helpers
local function makeCorner(obj,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 10); c.Parent=obj end
local function tween(obj,time,props,style,dir) return TweenService:Create(obj,TweenInfo.new(time,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props) end
local function ripple(button)
    local r=Instance.new("Frame"); r.BackgroundColor3=colors.accent; r.BackgroundTransparency=0.4; r.Size=UDim2.fromOffset(0,0)
    r.AnchorPoint=Vector2.new(0.5,0.5); r.Position=UDim2.new(0.5,0,0.5,0); r.BorderSizePixel=0; r.ZIndex=5; r.Parent=button
    tween(r,0.35,{Size=UDim2.fromScale(2.4,2.4),BackgroundTransparency=1}).Completed:Connect(function() r:Destroy() end)
end
local function toast(msg) StarterGui:SetCore("SendNotification",{Title="Advanced",Text=msg,Duration=3,Button1="OK"}) end
local function log(event,data)
    if config.webhookUrl=="" then return end
    task.spawn(function()
        local payload=HttpService:JSONEncode({content=("["..event.."] "..(data or ""))})
        pcall(function() http_request({Url=config.webhookUrl,Method="POST",Headers={["Content-Type"]="application/json"},Body=payload}) end)
    end)
end
local function setBlur(on)
    if on then if not blurEffect then blurEffect=Instance.new("BlurEffect"); blurEffect.Size=10; blurEffect.Parent=Lighting end
    else if blurEffect then blurEffect:Destroy(); blurEffect=nil end end
end
setBlur(true)
local function applyTheme() colors = themes[config.theme] or colors end

-- // UI building blocks
local function makeToggle(parent,label,cb,defaultState)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,40); f.BackgroundColor3=colors.panel; f.BorderSizePixel=0; makeCorner(f,10); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(1,-70,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local btn=Instance.new("TextButton"); btn.Size=UDim2.fromOffset(56,24); btn.Position=UDim2.new(1,-70,0.5,-12); btn.BackgroundColor3=colors.bg; btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.Text=""; makeCorner(btn,24); btn.Parent=f
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(20,20); knob.Position=UDim2.new(0,2,0.5,-10); knob.BackgroundColor3=colors.subtle; knob.BorderSizePixel=0; makeCorner(knob,20); knob.Parent=btn
    local on=defaultState or false
    local function set(state)
        on=state
        tween(btn,0.16,{BackgroundColor3=on and colors.accent or colors.bg})
        tween(knob,0.16,{Position=on and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), BackgroundColor3=on and Color3.new(1,1,1) or colors.subtle})
        if cb then task.spawn(function() cb(on) end) end
    end
    btn.MouseButton1Click:Connect(function() ripple(btn); set(not on); log("toggle",label.."="..tostring(not on)) end)
    set(on); return set
end

local function makeButton(parent,label,cb)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-10,0,40); b.BackgroundColor3=colors.panel; b.BorderSizePixel=0; b.AutoButtonColor=false
    b.Font=Enum.Font.GothamSemibold; b.TextColor3=colors.text; b.TextSize=15; b.Text=label; makeCorner(b,10); b.Parent=parent
    b.MouseEnter:Connect(function() tween(b,0.08,{BackgroundColor3=colors.accent2}) end)
    b.MouseLeave:Connect(function() tween(b,0.08,{BackgroundColor3=colors.panel}) end)
    b.MouseButton1Click:Connect(function() ripple(b); if cb then task.spawn(cb) end end)
    return b
end

local function makeSlider(parent,label,min,max,default,cb)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,44); f.BackgroundColor3=colors.panel; f.BorderSizePixel=0; makeCorner(f,10); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(0.5,-10,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local value=Instance.new("TextLabel"); value.BackgroundTransparency=1; value.Size=UDim2.new(0.5,-10,1,0); value.Position=UDim2.new(0.5,0,0,0); value.Font=Enum.Font.GothamSemibold; value.TextColor3=colors.text; value.TextSize=14; value.TextXAlignment=Enum.TextXAlignment.Right; value.Text=tostring(default); value.Parent=f
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-24,0,6); bar.Position=UDim2.new(0,12,1,-12); bar.BackgroundColor3=colors.bg; bar.BorderSizePixel=0; makeCorner(bar,6); bar.Parent=f
    local fill=Instance.new("Frame"); fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3=colors.accent; fill.BorderSizePixel=0; makeCorner(fill,6); fill.Parent=bar
    local dragging=false
    local function setVal(v)
        v=math.clamp(v,min,max); value.Text=tostring(math.floor(v*100)/100); tween(fill,0.1,{Size=UDim2.new((v-min)/(max-min),0,1,0)}); if cb then task.spawn(function() cb(v) end) end
    end
    bar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setVal(min+(max-min)*((UserInputService:GetMouseLocation().X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X)) end end)
    bar.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(inp) if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then setVal(min+(max-min)*((UserInputService:GetMouseLocation().X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X)) end end)
    setVal(default); return setVal
end

local function makeDropdown(parent,label,options,cb)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,40); f.BackgroundColor3=colors.panel; f.BorderSizePixel=0; makeCorner(f,10); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(0.5,-10,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0.5,-20,1,-8); btn.Position=UDim2.new(0.5,8,0,4); btn.BackgroundColor3=colors.bg; btn.BorderSizePixel=0; btn.TextColor3=colors.text; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=14; btn.Text=options[1] or "Select"; makeCorner(btn,8); btn.Parent=f
    local function set(val) btn.Text=val; if cb then cb(val) end end
    btn.MouseButton1Click:Connect(function() ripple(btn); local next=1; for i,opt in ipairs(options) do if opt==btn.Text then next=i%#options+1 end end; set(options[next]) end)
    set(options[1]); return set
end

-- // Root UI
local gui = Instance.new("ScreenGui"); gui.Name="AdvancedMenu"; gui.ResetOnSpawn=false; gui.Parent=game:GetService("CoreGui")
local main = Instance.new("Frame"); main.Size=UDim2.fromOffset(600, 420); main.Position=UDim2.new(0.5,-300,0.5,-210); main.BackgroundColor3=colors.bg; main.BorderSizePixel=0; main.Active=false; main.Draggable=false; main.Parent=gui; makeCorner(main,12)
local grad=Instance.new("UIGradient",main); grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,colors.bg),ColorSequenceKeypoint.new(1,colors.accent2)}; grad.Rotation=60

-- Drag only by title
local dragging=false; local dragStart; local startPos
local function beginDrag(input) dragging=true; dragStart=input.Position; startPos=main.Position; input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end) end
local function updateDrag(input) if not dragging then return end; local delta=input.Position-dragStart; main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end

-- Title
local title=Instance.new("Frame"); title.Size=UDim2.new(1,0,0,46); title.BackgroundColor3=colors.panel; title.BorderSizePixel=0; title.Parent=main; makeCorner(title,12)
title.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then beginDrag(i) end end)
title.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then updateDrag(i) end end)

local titleLabel=Instance.new("TextLabel"); titleLabel.Size=UDim2.new(1,-170,1,0); titleLabel.Position=UDim2.new(0,16,0,0); titleLabel.BackgroundTransparency=1; titleLabel.Font=Enum.Font.GothamBold; titleLabel.Text="Advanced Universal Hub v5.1"; titleLabel.TextColor3=colors.text; titleLabel.TextSize=18; titleLabel.TextXAlignment=Enum.TextXAlignment.Left; titleLabel.Parent=title
local versionLabel=Instance.new("TextLabel"); versionLabel.Size=UDim2.new(0,140,1,0); versionLabel.Position=UDim2.new(1,-150,0,0); versionLabel.BackgroundTransparency=1; versionLabel.Font=Enum.Font.Gotham; versionLabel.Text="v"..config.version; versionLabel.TextColor3=colors.subtle; versionLabel.TextSize=14; versionLabel.TextXAlignment=Enum.TextXAlignment.Right; versionLabel.Parent=title

-- Quick pills
local quick=Instance.new("Frame"); quick.Size=UDim2.new(0,600,0,32); quick.Position=UDim2.new(0,0,0,-36); quick.BackgroundTransparency=1; quick.Parent=main
local qaList=Instance.new("UIListLayout",quick); qaList.Padding=UDim.new(0,8); qaList.FillDirection=Enum.FillDirection.Horizontal; qaList.HorizontalAlignment=Enum.HorizontalAlignment.Right; qaList.VerticalAlignment=Enum.VerticalAlignment.Center
local function pill(label,color,cb) local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(120,28); b.BackgroundColor3=color; b.BorderSizePixel=0; b.TextColor3=Color3.new(1,1,1); b.TextSize=13; b.Font=Enum.Font.GothamSemibold; b.Text=label; b.AutoButtonColor=false; makeCorner(b,14); b.Parent=quick; b.MouseButton1Click:Connect(function() ripple(b); if cb then cb() end end) end
pill("Panic",colors.danger,function() gui:Destroy(); if offscreenGui then offscreenGui:Destroy() end; setBlur(false); Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault; workspace.Gravity=gravityDefault end)
pill("Hide UI",colors.accent2,function() hidden=not hidden; main.Visible=not hidden; if offscreenGui then offscreenGui.Enabled=not hidden end end)
pill("Rejoin",colors.accent,function() TeleportService:Teleport(game.PlaceId,LP) end)

-- Tabs/panels
local tabs=Instance.new("Frame"); tabs.Size=UDim2.new(0,170,1,-46); tabs.Position=UDim2.new(0,0,0,46); tabs.BackgroundColor3=colors.panel; tabs.BorderSizePixel=0; tabs.Parent=main; makeCorner(tabs,12)
local tabList=Instance.new("UIListLayout",tabs); tabList.VerticalAlignment=Enum.VerticalAlignment.Top; tabList.HorizontalAlignment=Enum.HorizontalAlignment.Center; tabList.Padding=UDim.new(0,8)
local tabNames={"Dashboard","Movement","Visuals","Combat","Automation","Player List","Script Hub","Configs","Protection","UI / Theme"}
local pages={}
local selectedTab
local pageHolder=Instance.new("Frame"); pageHolder.Size=UDim2.new(1,-170,1,-46); pageHolder.Position=UDim2.new(0,170,0,46); pageHolder.BackgroundTransparency=1; pageHolder.Parent=main
for _,name in ipairs(tabNames) do
    local page=Instance.new("Frame"); page.Size=UDim2.new(1,-24,1,-24); page.Position=UDim2.new(0,12,0,12); page.BackgroundTransparency=1; page.Visible=false; page.Parent=pageHolder
    local list=Instance.new("UIListLayout",page); list.Padding=UDim.new(0,10); list.FillDirection=Enum.FillDirection.Vertical; list.HorizontalAlignment=Enum.HorizontalAlignment.Left; list.VerticalAlignment=Enum.VerticalAlignment.Top
    pages[name]=page
end
local tabButtons={}
local tabIndicator=Instance.new("Frame"); tabIndicator.Size=UDim2.new(0,6,0,36); tabIndicator.BackgroundColor3=colors.accent; tabIndicator.BorderSizePixel=0; tabIndicator.Visible=false; tabIndicator.Parent=tabs; makeCorner(tabIndicator,3)
local function switchTab(name)
    for tabName,page in pairs(pages) do page.Visible=(tabName==name) end
    selectedTab=name
end
local function createTabButton(name)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-24,0,38); b.BackgroundColor3=colors.bg; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Font=Enum.Font.GothamSemibold; b.TextColor3=colors.text; b.TextSize=15; b.Text="   "..name; b:SetAttribute("BG",true); makeCorner(b,10); b.Parent=tabs
    b.MouseEnter:Connect(function() tween(b,0.12,{BackgroundColor3=colors.panel}) end)
    b.MouseLeave:Connect(function() if selectedTab~=name then tween(b,0.12,{BackgroundColor3=colors.bg}) end end)
    b.MouseButton1Click:Connect(function()
        ripple(b); switchTab(name)
        for other,btn in pairs(tabButtons) do tween(btn,0.2,{BackgroundColor3=(other==name) and colors.accent or colors.bg}) end
        tabIndicator.Visible=true; tween(tabIndicator,0.2,{Position=UDim2.new(0,4,0,b.Position.Y.Offset),BackgroundColor3=colors.accent})
    end)
    return b
end
for _,n in ipairs(tabNames) do tabButtons[n]=createTabButton(n) end
switchTab("Dashboard"); tween(tabButtons["Dashboard"],0.01,{BackgroundColor3=colors.accent}); tabIndicator.Position=UDim2.new(0,4,0,tabButtons["Dashboard"].Position.Y.Offset); tabIndicator.Visible=true

-- // Dashboard
do
    local p=pages["Dashboard"]
    local info=Instance.new("TextLabel"); info.BackgroundTransparency=1; info.Size=UDim2.new(1,-10,0,20); info.Font=Enum.Font.GothamSemibold; info.TextColor3=colors.text; info.TextSize=15; info.TextXAlignment=Enum.TextXAlignment.Left
    info.Text=("Game: %s | PlaceId: %s"):format(game.Name or "Unknown", tostring(currentGameId)); info.Parent=p
    local status=Instance.new("TextLabel"); status.BackgroundTransparency=1; status.Size=UDim2.new(1,-10,0,20); status.Font=Enum.Font.Gotham; status.TextColor3=colors.subtle; status.TextSize=14; status.TextXAlignment=Enum.TextXAlignment.Left
    status.Text=gameModuleLoaded and ("Supported Game: "..gameModuleLoaded) or "Supported Game: No (Universal Mode)"; status.Parent=p
    local server=Instance.new("TextLabel"); server.BackgroundTransparency=1; server.Size=UDim2.new(1,-10,0,20); server.Font=Enum.Font.Gotham; server.TextColor3=colors.subtle; server.TextSize=14; server.TextXAlignment=Enum.TextXAlignment.Left
    server.Text=("Region/Locale: %s | Players: %d"):format(game:GetService("LocalizationService").SystemLocaleId or "Unknown", #Players:GetPlayers()); server.Parent=p
    makeButton(p,"Universal Features",function() switchTab("Movement"); ripple(tabButtons["Movement"]); tween(tabButtons["Movement"],0.2,{BackgroundColor3=colors.accent}) end)
    makeButton(p,"Game-Specific Features",function() if gameModuleLoaded then switchTab("Script Hub") else toast("No module for this game") end end)
    makeButton(p,"Configs",function() switchTab("Configs"); ripple(tabButtons["Configs"]); tween(tabButtons["Configs"],0.2,{BackgroundColor3=colors.accent}) end)
    makeButton(p,"Script Hub",function() switchTab("Script Hub"); ripple(tabButtons["Script Hub"]); tween(tabButtons["Script Hub"],0.2,{BackgroundColor3=colors.accent}) end)
end

-- // Movement
do
    local p=pages["Movement"]
    makeSlider(p,"WalkSpeed",8,160,config.wsBoost,function(v) config.wsBoost=v; if Hum.WalkSpeed~=wsDefault then Hum.WalkSpeed=v end end)
    makeSlider(p,"JumpPower",20,150,config.jpBoost,function(v) config.jpBoost=v; if Hum.JumpPower~=jpDefault then Hum.JumpPower=v end end)
    makeToggle(p,"Speed Boost",function(on) Hum.WalkSpeed = on and config.wsBoost or wsDefault end)
    makeToggle(p,"High Jump",function(on) Hum.JumpPower = on and config.jpBoost or jpDefault end)
    makeToggle(p,"Fly",function(on)
        flyEnabled=on
        if on then
            if not flyBV then flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e6,1e6,1e6); flyBV.Velocity=Vector3.new(); flyBV.Parent=HRP end
        else if flyBV then flyBV:Destroy(); flyBV=nil end end
    end)
    makeSlider(p,"Fly Speed",10,250,config.flySpeed,function(v) config.flySpeed=v end)
    makeToggle(p,"Sprint (hold Shift)",function(on) sprinting=on end)
    makeSlider(p,"Sprint Speed",20,200,config.sprintSpeed,function(v) config.sprintSpeed=v end)
    makeToggle(p,"Speed Lock",function(on) config.speedLock=on end, config.speedLock)
    makeToggle(p,"Noclip",function(on) noclipEnabled=on end)
    makeToggle(p,"Infinite Jump",function(on) infiniteJump=on end)
    makeToggle(p,"Safe-Walk",function(on) safeWalkEnabled=on end)
    makeToggle(p,"Low Gravity",function(on) config.lowGravity=on; workspace.Gravity = on and (gravityDefault*0.3) or gravityDefault end)
    makeButton(p,"Reset Movement Values",function() Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault; workspace.Gravity=gravityDefault end)
    makeButton(p,"Hard Reset Character",function() LP:LoadCharacter() end)
end

-- // Visuals
local function clearESP()
    for _,o in ipairs(highlightObjects) do o:Destroy() end
    for _,o in ipairs(nametagObjects) do o:Destroy() end
    for _,o in ipairs(arrowObjects) do o:Destroy() end
    for _,o in ipairs(tracerObjects) do if o.Remove then o:Remove() end end
    highlightObjects,nametagObjects,arrowObjects,tracerObjects={}, {}, {}, {}
end
local function addESP(plr)
    if plr==LP or not config.esp.enabled then return end
    local char=plr.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
    local h=Instance.new("Highlight"); h.FillColor=config.esp.teamColors and plr.TeamColor.Color or colors.accent; h.OutlineColor=colors.accent2; h.Adornee=char; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=char; table.insert(highlightObjects,h)
    if config.esp.names and hrp then
        local bill=Instance.new("BillboardGui"); bill.AlwaysOnTop=true; bill.Size=UDim2.new(0,200,0,40); bill.Adornee=hrp; bill.Parent=char
        local txt=Instance.new("TextLabel"); txt.BackgroundTransparency=1; txt.Size=UDim2.new(1,0,1,0); txt.Font=Enum.Font.GothamSemibold; txt.TextColor3=colors.text; txt.TextStrokeTransparency=0.4; txt.TextStrokeColor3=colors.bg; txt.TextSize=14; txt.Text=plr.Name; txt.Parent=bill
        if config.esp.healthbar and hum then
            local barFrame=Instance.new("Frame"); barFrame.Size=UDim2.new(0.4,0,0,6); barFrame.Position=UDim2.new(0.3,0,1,-4); barFrame.BackgroundColor3=colors.bg; barFrame.BorderSizePixel=0; barFrame.Parent=bill; makeCorner(barFrame,6)
            local fill=Instance.new("Frame"); fill.BackgroundColor3=colors.success; fill.Size=UDim2.new(1,0,1,0); fill.BorderSizePixel=0; fill.Parent=barFrame; makeCorner(fill,6)
            RunService.RenderStepped:Connect(function() if hum then fill.Size=UDim2.new(math.clamp(hum.Health/hum.MaxHealth,0,1),0,1,0) end end)
        end
        if config.esp.distance then RunService.RenderStepped:Connect(function() if bill.Parent and hrp then local mag=(hrp.Position-HRP.Position).Magnitude; txt.Text=("%s | %dm"):format(plr.Name, math.floor(mag)) end end) end
        table.insert(nametagObjects,bill)
    end
    if config.esp.arrows then
        local arrow=Instance.new("Frame"); arrow.Size=UDim2.fromOffset(18,18); arrow.BackgroundColor3=colors.accent; arrow.BorderSizePixel=0; arrow.AnchorPoint=Vector2.new(0.5,0.5); arrow.Position=UDim2.new(0.5,0,0.5,0); arrow.Parent=offscreenGui; makeCorner(arrow,9); table.insert(arrowObjects,arrow)
        RunService.RenderStepped:Connect(function()
            if not hrp or not HRP then return end
            local pos,on=camera:WorldToViewportPoint(hrp.Position)
            if on then arrow.Visible=false else
                arrow.Visible=true
                local viewport=camera.ViewportSize; local dir=(Vector2.new(pos.X,pos.Y)-viewport/2).Unit
                local clamped=(viewport/2)+dir*math.min(viewport.X,viewport.Y)*0.45
                arrow.Position=UDim2.fromOffset(clamped.X,clamped.Y); arrow.Rotation=math.deg(math.atan2(dir.Y,dir.X))
            end
        end)
    end
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() if config.esp.enabled then addESP(p) end end) end)

do -- Visuals tab
    local p=pages["Visuals"]
    makeToggle(p,"ESP (players)",function(on) config.esp.enabled=on; clearESP(); if on then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeToggle(p,"Box ESP",function(on) config.esp.boxes=on end,config.esp.boxes)
    makeToggle(p,"ESP Names",function(on) config.esp.names=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.names)
    makeToggle(p,"ESP Distance",function(on) config.esp.distance=on end,config.esp.distance)
    makeToggle(p,"ESP Arrows",function(on) config.esp.arrows=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.arrows)
    makeToggle(p,"ESP Healthbar",function(on) config.esp.healthbar=on end,config.esp.healthbar)
    makeToggle(p,"ESP Team Colors",function(on) config.esp.teamColors=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.teamColors)
    makeSlider(p,"Camera FOV",40,120,config.fov,function(v) config.fov=v; camera.FieldOfView=v end)
    makeToggle(p,"Fullbright",function(on) fullbrightEnabled=on; if on then Lighting.Brightness=2; Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1) else Lighting.Brightness=1; Lighting.Ambient=Color3.new(0,0,0); Lighting.OutdoorAmbient=Color3.new(0,0,0) end end, false)
    makeToggle(p,"No Fog",function(on) noFogEnabled=on; if on then Lighting.FogEnd=1e9 else Lighting.FogEnd=1000 end end,false)
    makeToggle(p,"Infinite Zoom",function(on) config.infiniteZoom=on; if on then LP.CameraMaxZoomDistance=1e9 else LP.CameraMaxZoomDistance=128 end end,config.infiniteZoom)
end

-- // Combat
local fovCircle=Instance.new("Frame"); fovCircle.Name="FOVCircle"; fovCircle.Size=UDim2.fromOffset(config.aimbotFov,config.aimbotFov); fovCircle.Position=UDim2.fromScale(0.5,0.5); fovCircle.AnchorPoint=Vector2.new(0.5,0.5); fovCircle.BackgroundTransparency=0.9; fovCircle.BackgroundColor3=colors.accent; fovCircle.BorderSizePixel=0; fovCircle.Visible=false; fovCircle.ZIndex=9; makeCorner(fovCircle,100); fovCircle.Parent=gui
local function pulseFov() tween(fovCircle,0.15,{BackgroundTransparency=0.6,Size=fovCircle.Size+UDim2.fromOffset(12,12)}).Completed:Connect(function() tween(fovCircle,0.15,{BackgroundTransparency=0.9,Size=UDim2.fromOffset(config.aimbotFov,config.aimbotFov)}) end) end
local function getClosestTarget()
    local closest, dist=nil, math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid").Health>0 then
            local pos,on=camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if on then
                local mouse=UserInputService:GetMouseLocation()
                local d=(Vector2.new(pos.X,pos.Y)-mouse).Magnitude
                if d<dist and d<=config.aimbotFov then closest=plr; dist=d end
            end
        end
    end
    return closest
end

do -- Combat tab
    local p=pages["Combat"]
    makeToggle(p,"Aimbot (hold RMB)",function(on) config.aimbotEnabled=on; fovCircle.Visible=on and not hidden end)
    makeDropdown(p,"Aim Mode",{"Nearest Crosshair","Nearest Player"},function(v) config.aimbotMode=v end)
    makeDropdown(p,"Target Area",{"Head","Torso","Random"},function(v) config.aimbotArea=v end)
    makeSlider(p,"Aimbot FOV",40,240,config.aimbotFov,function(v) config.aimbotFov=v; fovCircle.Size=UDim2.fromOffset(v,v) end)
    makeSlider(p,"Aimbot Smooth",0.01,0.5,config.aimbotSmooth,function(v) config.aimbotSmooth=v end)
    makeToggle(p,"FOV Circle",function(on) fovCircle.Visible=on end,true)
    makeToggle(p,"Triggerbot",function(on) config.triggerEnabled=on end)
    makeToggle(p,"No Recoil (placeholder)",function() end)
    makeToggle(p,"No Spread (placeholder)",function() end)
    makeToggle(p,"Rapid Fire (placeholder)",function() end)
    makeButton(p,"Reset Camera FOV",function() camera.FieldOfView=70 end)
end

-- // Automation
do
    local p=pages["Automation"]
    makeSlider(p,"Auto Click Rate (s)",0.02,0.3,0.05,function(v) config.autoClickRate=v end)
    makeToggle(p,"Auto Clicker",function(on) autoClickEnabled=on end)
    makeToggle(p,"Auto Interact (Prompts)",function(on) autoInteractEnabled=on end)
    makeToggle(p,"Anti-AFK (tiny movements)",function(on) config.antiAfk=on end)
    makeButton(p,"Start Generic Auto-Collect",function() toast("Generic auto-collect stub active"); config.autoCollect=true end)
    makeButton(p,"Stop Generic Auto-Collect",function() config.autoCollect=false end)
end

-- // Player List
local priorityTarget=nil
do
    local p=pages["Player List"]
    local container=Instance.new("Frame"); container.Size=UDim2.new(1,-10,0,240); container.BackgroundColor3=colors.panel; container.BorderSizePixel=0; makeCorner(container,10); container.Parent=p
    local uiList=Instance.new("UIListLayout",container); uiList.FillDirection=Enum.FillDirection.Vertical; uiList.Padding=UDim.new(0,4); uiList.HorizontalAlignment=Enum.HorizontalAlignment.Left
    local function refresh()
        for _,c in ipairs(container:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _,plr in ipairs(Players:GetPlayers()) do
            local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,-8,0,28); btn.BackgroundColor3=colors.bg; btn.BorderSizePixel=0; btn.TextColor3=colors.text; btn.Font=Enum.Font.Gotham; btn.TextSize=13; btn.TextXAlignment=Enum.TextXAlignment.Left
            local dist=HRP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and math.floor((plr.Character.HumanoidRootPart.Position-HRP.Position).Magnitude) or "--"
            btn.Text=string.format("%s | %sm | %s", plr.Name, dist, plr.Team and plr.Team.Name or "NoTeam")
            makeCorner(btn,8); btn.Parent=container
            btn.MouseButton1Click:Connect(function()
                priorityTarget=plr
                toast("Priority target: "..plr.Name)
            end)
        end
    end
    refresh()
    Players.PlayerAdded:Connect(refresh); Players.PlayerRemoving:Connect(refresh)
    makeButton(p,"Teleport to Priority Target",function()
        if priorityTarget and priorityTarget.Character and priorityTarget.Character:FindFirstChild("HumanoidRootPart") then
            HRP.CFrame=priorityTarget.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
        end
    end)
    makeButton(p,"Spectate Priority Target",function()
        if priorityTarget and priorityTarget.Character and priorityTarget.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject=priorityTarget.Character:FindFirstChild("Humanoid")
        end
    end)
    makeButton(p,"Clear Priority Target",function() priorityTarget=nil end)
end

-- // Script Hub (stub)
do
    local p=pages["Script Hub"]
    local desc=Instance.new("TextLabel"); desc.BackgroundTransparency=1; desc.Size=UDim2.new(1,-10,0,40); desc.Font=Enum.Font.Gotham; desc.TextColor3=colors.text; desc.TextSize=14; desc.TextWrapped=true; desc.Text="Script Hub stub: categorize and execute scripts. Add your URLs/functions to the lists below."; desc.Parent=p
    makeButton(p,"Execute Universal Script (placeholder)",function() toast("Run your universal script here") end)
    makeButton(p,"Load Game Module",function()
        if supportedGames[currentGameId] then
            toast("Loading module for "..tostring(supportedGames[currentGameId]))
            log("module","Loaded "..tostring(supportedGames[currentGameId]))
        else toast("No module for this game") end
    end)
end

-- // Configs
do
    local p=pages["Configs"]
    makeButton(p,"Copy Config to Clipboard",function() if setclipboard then setclipboard(HttpService:JSONEncode(config)); toast("Config copied") else toast("setclipboard not available") end end)
    makeButton(p,"Import Config (prompt)",function()
        local str=input or "" -- placeholder; in-executor you can paste into console: loadConfigFromString([[json]])
        toast("Use console: loadConfigFromString(jsonString)")
    end)
    makeDropdown(p,"Theme",{"Midnight","NeoGreen","Amber","Purple"},function(v) config.theme=v; applyTheme() end)
    makeButton(p,"Apply Preset: Legit",function() local t=config.presets.legit; config.wsBoost=t.ws; config.jpBoost=t.jp; camera.FieldOfView=t.fov; config.aimbotEnabled=t.aimbot; config.esp.enabled=t.esp; toast("Legit preset applied") end)
    makeButton(p,"Apply Preset: Rage",function() local t=config.presets.rage; config.wsBoost=t.ws; config.jpBoost=t.jp; camera.FieldOfView=t.fov; config.aimbotEnabled=t.aimbot; config.esp.enabled=t.esp; toast("Rage preset applied") end)
    makeButton(p,"Apply Preset: Visuals",function() local t=config.presets.visuals; camera.FieldOfView=t.fov; config.aimbotEnabled=t.aimbot; config.esp.enabled=t.esp; toast("Visuals preset applied") end)
end

-- // Protection
do
    local p=pages["Protection"]
    makeToggle(p,"Auto-disable on teleport",function(on) config.autoDisableOnTP=on end)
    makeToggle(p,"Stop features on panic",function(on) config.stopOnPanic=on end,true)
    makeButton(p,"Status: Universal "..(gameModuleLoaded and ("+ "..gameModuleLoaded) or "(no module)"),function() toast("Status shown") end)
end

-- // UI / Theme
do
    local p=pages["UI / Theme"]
    makeDropdown(p,"Theme",{"Midnight","NeoGreen","Amber","Purple"},function(v) config.theme=v; applyTheme() end)
    makeToggle(p,"UI Animations",function(on) config.animations=on end,true)
    makeToggle(p,"UI Sounds",function(on) config.uiSounds=on end,false)
    makeButton(p,"Compact Layout (placeholder)",function() toast("Compact mode stub") end)
    makeButton(p,"Changelog",function() toast("v5.1: universal hub, dashboard, automation, player list, script hub stub") end)
end

-- // Keybinds & Panic handling
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == config.menuKey then
        hidden = not hidden
        tween(main, 0.22, {Position = hidden and UDim2.new(0.5, -300, 1.1, 0) or UDim2.new(0.5, -300, 0.5, -210)})
        main.Active = not hidden
        gui.Enabled = not hidden
        fovCircle.Visible = config.aimbotEnabled and not hidden
    elseif input.KeyCode == config.panicKey then
        clearESP(); gui:Destroy(); if offscreenGui then offscreenGui:Destroy() end; setBlur(false)
        Hum.WalkSpeed = wsDefault; Hum.JumpPower = jpDefault; workspace.Gravity=gravityDefault
    elseif input.KeyCode == config.keybinds.toggleAimbot then config.aimbotEnabled=not config.aimbotEnabled; fovCircle.Visible=config.aimbotEnabled
    elseif input.KeyCode == config.keybinds.toggleESP then config.esp.enabled=not config.esp.enabled; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end
    elseif input.KeyCode == config.keybinds.toggleFly then flyEnabled=not flyEnabled
    elseif input.KeyCode == config.keybinds.toggleNoclip then noclipEnabled=not noclipEnabled
    elseif input.KeyCode == Enum.KeyCode.Space and infiniteJump then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- // Loops
table.insert(connections, RunService.Stepped:Connect(function()
    if noclipEnabled and Char then for _,part in ipairs(Char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end
    if safeWalkEnabled and HRP then local ray=Ray.new(HRP.Position, Vector3.new(0,-6,0)); local hit=workspace:FindPartOnRay(ray,Char); if not hit then HRP.Velocity=Vector3.new(HRP.Velocity.X,0,HRP.Velocity.Z) end end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if flyEnabled and flyBV and HRP then
        local dir=Vector3.new(); local camCF=camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += camCF.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= camCF.UpVector end
        if dir.Magnitude>0 then dir=dir.Unit*config.flySpeed else dir=Vector3.new() end
        flyBV.Velocity=dir
    end
    if sprinting and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not flyEnabled then Hum.WalkSpeed=config.sprintSpeed
    elseif sprinting and not flyEnabled then Hum.WalkSpeed=config.wsBoost end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if config.aimbotEnabled and UserInputService:IsMouseButtonPressed(config.aimbotKey) then
        local target=getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            pulseFov()
            local targetPos = target.Character.HumanoidRootPart.Position
            if config.aimbotArea=="Head" then local h=target.Character:FindFirstChild("Head"); if h then targetPos=h.Position end
            elseif config.aimbotArea=="Torso" then local t=target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("HumanoidRootPart"); if t then targetPos=t.Position end
            elseif config.aimbotArea=="Random" then local parts={"Head","UpperTorso","HumanoidRootPart","LeftUpperArm","RightUpperArm"}; local choice=target.Character:FindFirstChild(parts[math.random(1,#parts)]); if choice then targetPos=choice.Position end end
            local look=CFrame.new(camera.CFrame.Position,targetPos)
            camera.CFrame=camera.CFrame:Lerp(look,config.aimbotSmooth)
            if config.triggerEnabled then VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0); VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0) end
        end
    end
end))

task.spawn(function()
    while true do
        if autoClickEnabled then
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0)
        end
        task.wait(config.autoClickRate or 0.05)
    end
end)

task.spawn(function()
    while true do
        if autoInteractEnabled then
            for _,prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then pcall(function() fireproximityprompt(prompt) end) end
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if config.antiAfk then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Right, false, nil); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Right, false, nil) end
        task.wait(30)
    end
end)

local last=tick()
table.insert(connections, RunService.RenderStepped:Connect(function()
    local now=tick(); local fps=1/(now-last); last=now
    local ping=math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
    -- status tab labels updated via references (omitted here for brevity)
end))

-- Float anim
task.spawn(function()
    while gui.Parent do
        tween(main,1.6,{Position=UDim2.new(main.Position.X.Scale,main.Position.X.Offset,main.Position.Y.Scale,main.Position.Y.Offset+4)},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        task.wait(1.6)
        tween(main,1.6,{Position=UDim2.new(main.Position.X.Scale,main.Position.X.Offset,main.Position.Y.Scale,main.Position.Y.Offset-4)},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
        task.wait(1.6)
    end
end)

-- Respawn
LP.CharacterAdded:Connect(function(newChar)
    Char=newChar; Hum=Char:WaitForChild("Humanoid"); HRP=Char:WaitForChild("HumanoidRootPart")
    wsDefault=Hum.WalkSpeed; jpDefault=Hum.JumpPower
    if config.esp.enabled then task.delay(1,function() clearESP(); for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end) end
end)

applyTheme()
toast("Loaded Advanced Universal Hub v"..config.version)
