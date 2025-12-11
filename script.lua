-- Advanced Universal Hub v5.2
-- Menu key L, Panic RightControl by default.

-- Services
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

-- Themes
local themes = {
    Midnight = {bg=Color3.fromRGB(14,16,22), panel=Color3.fromRGB(22,28,40), accent=Color3.fromRGB(0,145,255), accent2=Color3.fromRGB(0,110,200), text=Color3.fromRGB(230,238,255), subtle=Color3.fromRGB(110,130,160), success=Color3.fromRGB(70,210,140), warn=Color3.fromRGB(255,195,90), danger=Color3.fromRGB(255,80,90)},
    NeoGreen = {bg=Color3.fromRGB(12,16,12), panel=Color3.fromRGB(24,32,28), accent=Color3.fromRGB(0,200,140), accent2=Color3.fromRGB(0,150,100), text=Color3.fromRGB(220,245,230), subtle=Color3.fromRGB(90,130,110), success=Color3.fromRGB(60,220,140), warn=Color3.fromRGB(240,190,80), danger=Color3.fromRGB(255,80,80)},
    Amber    = {bg=Color3.fromRGB(24,18,12), panel=Color3.fromRGB(34,26,18), accent=Color3.fromRGB(255,170,80), accent2=Color3.fromRGB(220,135,60), text=Color3.fromRGB(255,240,220), subtle=Color3.fromRGB(150,110,80), success=Color3.fromRGB(60,220,140), warn=Color3.fromRGB(255,200,120), danger=Color3.fromRGB(255,90,90)},
    Purple   = {bg=Color3.fromRGB(18,12,26), panel=Color3.fromRGB(30,20,44), accent=Color3.fromRGB(170,110,255), accent2=Color3.fromRGB(130,80,210), text=Color3.fromRGB(235,225,255), subtle=Color3.fromRGB(140,110,170), success=Color3.fromRGB(90,220,160), warn=Color3.fromRGB(250,190,120), danger=Color3.fromRGB(255,90,130)},
    Christmas = {bg=Color3.fromRGB(14,18,16), panel=Color3.fromRGB(22,28,24), accent=Color3.fromRGB(200,30,30), accent2=Color3.fromRGB(30,160,60), text=Color3.fromRGB(240,235,220), subtle=Color3.fromRGB(140,170,150), success=Color3.fromRGB(60,200,110), warn=Color3.fromRGB(255,210,110), danger=Color3.fromRGB(255,80,90)},
}
local colors = themes.Christmas

-- Config
local config = {
    version = "5.2.0",
    menuKey = Enum.KeyCode.L,
    panicKey = Enum.KeyCode.RightControl,
    aimbotKey = Enum.UserInputType.MouseButton2,
    aimbotSmooth = 0.18,
    aimbotFov = 140,
    aimbotEnabled = false,
    triggerEnabled = false,
    aimbotMode = "Nearest Crosshair",
    aimbotArea = "Head",
    silentAim = false,
    esp = {
        enabled=false, names=true, distance=true, arrows=true, healthbar=true, boxes=true, tracers=true, items=false, teamColors=true,
        colors = {accent=Color3.fromRGB(0,145,255), outline=Color3.fromRGB(0,110,200), box=Color3.fromRGB(0,145,255), tracer=Color3.fromRGB(0,145,255), preset="Blue"},
        worldTags={"Chest","Coin","Key"},
        opacity = 0.6,
        thicknessBox = 2,
        thicknessTracer = 2,
        nameFilter = "",
    },
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
    theme = "Christmas",
    keybinds = {toggleUI=Enum.KeyCode.L, panic=Enum.KeyCode.RightControl, toggleAimbot=Enum.KeyCode.F1, toggleESP=Enum.KeyCode.F2, toggleFly=Enum.KeyCode.F3, toggleNoclip=Enum.KeyCode.F4},
    presets = {
        legit   = {ws=24, jp=70, fov=75, aimbot=false, esp=true},
        rage    = {ws=60, jp=120, fov=100, aimbot=true, esp=true},
        visuals = {fov=80, aimbot=false, esp=true},
    },
    autoDisableOnTP = false,
    stopOnPanic = true,
    uiBlur = false,
    blurSize = 8,
    uiOpacity = 1,
    menuW = 640,
    menuH = 480,
    compact = false,
    lastConfig = "",
    disableInVIP = false,
    aimbotSkipFriends = true,
    aimbotLegitDecay = false,
    overlayToggleKey = Enum.KeyCode.F6,
    solidTheme = false,
    snow = false,
    showQuickbar = true,
    lastPreset = "",
    friendWhitelist = {},
    autoExec = {},
    autoExecEnabled = false,
    avoidLowHealth = false,
    stickTarget = false,
    rankedStop = false,
    defaultFov = 70,
    autoInteractFilter = "",
    gamePreset = "",
}
local hidden = false

-- State
local wsDefault = Hum.WalkSpeed
local jpDefault = Hum.JumpPower
local gravityDefault = workspace.Gravity
local connections = {}
local highlightObjects, nametagObjects, arrowObjects, tracerObjects = {}, {}, {}, {}
local worldHighlights = {}
local blurEffect
local flyEnabled, flyBV = false, nil
local noclipEnabled = false
local autoClickEnabled = false
local autoInteractEnabled = false
local sprinting = false
local infiniteJump = false
local safeWalkEnabled = false
local currentGameId = game.PlaceId
local offscreenGui = Instance.new("ScreenGui")
offscreenGui.Name = "OffscreenGui"
offscreenGui.ResetOnSpawn = false
offscreenGui.Parent = game:GetService("CoreGui")

-- Utility
local function makeCorner(obj,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 10); c.Parent=obj end
local function tween(obj,time,props,style,dir) return TweenService:Create(obj,TweenInfo.new(time,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props) end
local function ripple(button)
    local r=Instance.new("Frame"); r.BackgroundColor3=colors.accent; r.BackgroundTransparency=0.4; r.Size=UDim2.fromOffset(0,0)
    r.AnchorPoint=Vector2.new(0.5,0.5); r.Position=UDim2.new(0.5,0,0.5,0); r.BorderSizePixel=0; r.ZIndex=5; r.Parent=button
    tween(r,0.35,{Size=UDim2.fromScale(2.4,2.4),BackgroundTransparency=1}).Completed:Connect(function() r:Destroy() end)
end
local function toast(msg) StarterGui:SetCore("SendNotification",{Title="Advanced Hub",Text=msg,Duration=3,Button1="OK"}) end
local function log(event,data)
    if config.webhookUrl=="" then return end
    task.spawn(function()
        local payload=HttpService:JSONEncode({content=("["..event.."] "..(data or ""))})
        pcall(function() http_request({Url=config.webhookUrl,Method="POST",Headers={["Content-Type"]="application/json"},Body=payload}) end)
    end)
end
local function setBlur(on, size)
    if on then
        if not blurEffect then blurEffect=Instance.new("BlurEffect"); blurEffect.Parent=Lighting end
        blurEffect.Size = size or config.blurSize or 8
    else
        if blurEffect then blurEffect:Destroy(); blurEffect=nil end
    end
end
local function applyTheme() colors = themes[config.theme] or colors end
local function applyOpacity(guiObj)
    for _,obj in ipairs(guiObj:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") then
            obj.BackgroundTransparency = 1 - config.uiOpacity
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then obj.TextTransparency = 1 - config.uiOpacity end
        end
    end
end

-- Config IO
local function loadConfigFromString(str)
    local ok,data=pcall(function() return HttpService:JSONDecode(str) end)
    if ok and type(data)=="table" then for k,v in pairs(data) do config[k]=v end; toast("Config loaded"); return true end
    toast("Failed to load config"); return false
end
local function ensureDir() pcall(function() if not isfolder("ADVHub") then makefolder("ADVHub") end end) end
local function saveConfigToFile(name)
    ensureDir()
    local path="ADVHub/"..name..".json"
    local ok,err=pcall(function() writefile(path, HttpService:JSONEncode(config)) end)
    toast(ok and ("Saved "..path) or ("Save failed: "..tostring(err)))
end
local function loadConfigFromFile(name)
    local path="ADVHub/"..name..".json"
    local ok,content=pcall(function() return readfile(path) end)
    if ok then loadConfigFromString(content); toast("Loaded "..path) else toast("Load failed") end
end
local function autoLoadConfig()
    ensureDir()
    local perGame="ADVHub/AutoLoad_"..tostring(currentGameId)..".json"
    local global="ADVHub/AutoLoad_Global.json"
    local target=nil
    if isfile and isfile(perGame) then target=perGame elseif isfile and isfile(global) then target=global end
    if target then
        local ok,content=pcall(function() return readfile(target) end)
        if ok then loadConfigFromString(content); toast("Auto-loaded "..target) end
    end
end

local function listConfigs()
    local files = {}
    if listfiles and isfolder and isfolder("ADVHub") then
        for _,f in ipairs(listfiles("ADVHub")) do
            local name = f:match("ADVHub[/\\](.+)%.json$")
            if name then table.insert(files, name) end
        end
    end
    table.sort(files)
    if #files==0 then table.insert(files,"None") end
    return files
end

-- UI builders
local function makeToggle(parent,label,cb,defaultState)
    local h = config.compact and 34 or 40
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,h); f.BackgroundColor3=colors.panel; f.BorderSizePixel=0; makeCorner(f,10); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(1,-90,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local btn=Instance.new("TextButton"); btn.Size=UDim2.fromOffset(70,config.compact and 22 or 24); btn.Position=UDim2.new(1,-80,0.5,-(config.compact and 11 or 12)); btn.BackgroundColor3=colors.bg; btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.Text="Off"; btn.TextColor3=colors.text; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=13; makeCorner(btn,12); btn.Parent=f
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(20,20); knob.Position=UDim2.new(0,2,0.5,-10); knob.BackgroundColor3=colors.subtle; knob.BorderSizePixel=0; makeCorner(knob,20); knob.Parent=btn
    local on=defaultState or false
    local function set(state)
        on=state
        btn.Text = on and "On" or "Off"
        tween(btn,0.16,{BackgroundColor3=on and colors.accent or colors.bg})
        tween(knob,0.16,{Position=on and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), BackgroundColor3=on and Color3.new(1,1,1) or colors.subtle})
        pushLog(string.format("%s: %s", label, on and "On" or "Off"))
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
    local h = config.compact and 38 or 44
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,h); f.BackgroundColor3=colors.panel; f.BorderSizePixel=0; makeCorner(f,10); f.Parent=parent
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

-- ESP helpers
local function clearESP()
    for _,o in ipairs(highlightObjects) do o:Destroy() end
    for _,o in ipairs(nametagObjects) do o:Destroy() end
    for _,o in ipairs(arrowObjects) do o:Destroy() end
    highlightObjects,nametagObjects,arrowObjects,tracerObjects = {},{},{},{}
end

local function clearWorldESP()
    for _,o in ipairs(worldHighlights) do o:Destroy() end
    worldHighlights = {}
end

local function applyEspPreset(name)
    local presets = {
        Blue   = {accent=Color3.fromRGB(0,145,255), outline=Color3.fromRGB(0,110,200), box=Color3.fromRGB(0,145,255), tracer=Color3.fromRGB(0,145,255)},
        Red    = {accent=Color3.fromRGB(255,90,90), outline=Color3.fromRGB(200,50,50), box=Color3.fromRGB(255,90,90), tracer=Color3.fromRGB(255,90,90)},
        Green  = {accent=Color3.fromRGB(70,210,140), outline=Color3.fromRGB(40,160,100), box=Color3.fromRGB(70,210,140), tracer=Color3.fromRGB(70,210,140)},
        Purple = {accent=Color3.fromRGB(170,110,255), outline=Color3.fromRGB(130,80,210), box=Color3.fromRGB(170,110,255), tracer=Color3.fromRGB(170,110,255)},
        Gold   = {accent=Color3.fromRGB(255,200,90), outline=Color3.fromRGB(220,160,60), box=Color3.fromRGB(255,200,90), tracer=Color3.fromRGB(255,200,90)},
    }
    local p = presets[name]
    if p then config.esp.colors = p; config.esp.colors.preset = name; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do task.spawn(function() addESP(pl) end) end end end
end

function addESP(plr)
    if plr==LP or not config.esp.enabled then return end
    local char=plr.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local c = config.esp.colors
    local fillColor = config.esp.teamColors and plr.TeamColor and plr.TeamColor.Color or c.accent
    local opacity = config.esp.opacity or 0.6
    local h=Instance.new("Highlight"); h.FillColor=fillColor; h.OutlineColor=c.outline; h.FillTransparency=1-opacity; h.OutlineTransparency=1-opacity; h.Adornee=char; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=char; table.insert(highlightObjects,h)
    if config.esp.names then
        local bill=Instance.new("BillboardGui"); bill.AlwaysOnTop=true; bill.Size=UDim2.new(0,200,0,40); bill.Adornee=hrp; bill.Parent=char
        local txt=Instance.new("TextLabel"); txt.BackgroundTransparency=1; txt.Size=UDim2.new(1,0,1,0); txt.Font=Enum.Font.GothamSemibold; txt.TextColor3=colors.text; txt.TextStrokeTransparency=0.4; txt.TextStrokeColor3=colors.bg; txt.TextSize=14; txt.Text=plr.Name; txt.Parent=bill
        if config.esp.healthbar and hum then
            local barFrame=Instance.new("Frame"); barFrame.Size=UDim2.new(0.4,0,0,6); barFrame.Position=UDim2.new(0.3,0,1,-4); barFrame.BackgroundColor3=colors.bg; barFrame.BorderSizePixel=0; makeCorner(barFrame,6); barFrame.Parent=bill
            local fill=Instance.new("Frame"); fill.BackgroundColor3=colors.success; fill.Size=UDim2.new(1,0,1,0); fill.BorderSizePixel=0; makeCorner(fill,6); fill.Parent=barFrame
            RunService.RenderStepped:Connect(function() if hum then fill.Size=UDim2.new(math.clamp(hum.Health/hum.MaxHealth,0,1),0,1,0) end end)
        end
        if config.esp.distance then
            RunService.RenderStepped:Connect(function() if bill.Parent and hrp then local mag=(hrp.Position-HRP.Position).Magnitude; txt.Text=("%s | %dm"):format(plr.Name, math.floor(mag)) end end)
        end
        table.insert(nametagObjects,bill)
    end
    if config.esp.arrows then
        local th = config.esp.thicknessTracer or 2
        local arrow=Instance.new("Frame"); arrow.Size=UDim2.fromOffset(12+th*3,12+th*3); arrow.BackgroundColor3=c.tracer; arrow.BackgroundTransparency=1-opacity; arrow.BorderSizePixel=0; arrow.AnchorPoint=Vector2.new(0.5,0.5); arrow.Position=UDim2.new(0.5,0,0.5,0); arrow.Parent=offscreenGui; makeCorner(arrow,9); table.insert(arrowObjects,arrow)
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

-- GUI root
local gui = Instance.new("ScreenGui"); gui.Name="AdvancedMenu"; gui.ResetOnSpawn=false; gui.Parent=game:GetService("CoreGui")
local mainWidth, mainHeight = config.menuW or 640, config.menuH or 480
local main = Instance.new("Frame"); main.Size=UDim2.fromOffset(mainWidth, mainHeight); main.Position=UDim2.new(0.5,-mainWidth/2,0.5,-mainHeight/2); main.BackgroundColor3=colors.bg; main.BorderSizePixel=0; main.Active=true; main.Draggable=true; main.Parent=gui; makeCorner(main,12)
local function setMainSize(w,h)
    mainWidth, mainHeight = w,h
    config.menuW, config.menuH = w,h
    main.Size = UDim2.fromOffset(w,h)
    main.Position = UDim2.new(0.5,-w/2,0.5,-h/2)
end
local grad=Instance.new("UIGradient",main); grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,colors.bg),ColorSequenceKeypoint.new(1,colors.accent2)}; grad.Rotation=60
local grip = Instance.new("Frame"); grip.Size=UDim2.fromOffset(14,14); grip.Position=UDim2.new(1,-18,1,-18); grip.BackgroundColor3=colors.panel; grip.BorderSizePixel=0; makeCorner(grip,4); grip.Parent=main
makeDraggable(grip, function(delta)
    setMainSize(math.clamp(mainWidth + delta.X, 520, 900), math.clamp(mainHeight + delta.Y, 360, 720))
end)

-- Title
local title=Instance.new("Frame"); title.Size=UDim2.new(1,0,0,46); title.BackgroundColor3=colors.panel; title.BorderSizePixel=0; title.Parent=main; makeCorner(title,12)
local titleLabel=Instance.new("TextLabel"); titleLabel.Size=UDim2.new(1,-170,1,0); titleLabel.Position=UDim2.new(0,18,0,6); titleLabel.BackgroundTransparency=1; titleLabel.Font=Enum.Font.GothamBold; titleLabel.Text="Ninnydll"; titleLabel.TextColor3=Color3.fromRGB(255,215,120); titleLabel.TextSize=18; titleLabel.TextXAlignment=Enum.TextXAlignment.Left; titleLabel.Parent=title
task.spawn(function()
    local gold1 = Color3.fromRGB(255,215,120)
    local gold2 = Color3.fromRGB(255,235,170)
    while titleLabel.Parent do
        tween(titleLabel,0.8,{TextColor3=gold2}):Play()
        task.wait(0.8)
        tween(titleLabel,0.8,{TextColor3=gold1}):Play()
        task.wait(0.8)
    end
end)
local versionLabel=Instance.new("TextLabel"); versionLabel.Size=UDim2.new(0,70,1,0); versionLabel.Position=UDim2.new(1,-88,0,6); versionLabel.BackgroundTransparency=1; versionLabel.Font=Enum.Font.Gotham; versionLabel.Text="v"..config.version; versionLabel.TextColor3=colors.subtle; versionLabel.TextSize=13; versionLabel.TextXAlignment=Enum.TextXAlignment.Right; versionLabel.Parent=title
local logLabel=Instance.new("TextLabel"); logLabel.Size=UDim2.new(0,180,1,0); logLabel.Position=UDim2.new(1,-270,0,6); logLabel.BackgroundTransparency=1; logLabel.Font=Enum.Font.GothamSemibold; logLabel.Text="Logs ready"; logLabel.TextColor3=colors.warn; logLabel.TextSize=13; logLabel.TextXAlignment=Enum.TextXAlignment.Right; logLabel.Parent=title
local function pushLog(msg)
    if logLabel then logLabel.Text = msg end
end

-- Status bar
local statusLabel=Instance.new("TextLabel"); statusLabel.BackgroundTransparency=1; statusLabel.Size=UDim2.new(0, 220, 0, 20); statusLabel.Position=UDim2.new(1,-230,0,48); statusLabel.Font=Enum.Font.Gotham; statusLabel.TextColor3=colors.subtle; statusLabel.TextSize=13; statusLabel.TextXAlignment=Enum.TextXAlignment.Right; statusLabel.Parent=main

-- Quick pills
local quick=Instance.new("Frame"); quick.Size=UDim2.new(0, mainWidth, 0, 32); quick.Position=UDim2.new(0,0,0,-40); quick.BackgroundTransparency=1; quick.Parent=main
local qaList=Instance.new("UIListLayout",quick); qaList.Padding=UDim.new(0,8); qaList.FillDirection=Enum.FillDirection.Horizontal; qaList.HorizontalAlignment=Enum.HorizontalAlignment.Center; qaList.VerticalAlignment=Enum.VerticalAlignment.Center
local quickPad=Instance.new("UIPadding", quick); quickPad.PaddingLeft=UDim.new(0,12); quickPad.PaddingRight=UDim.new(0,12)
local function pill(label,color,cb) local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(120,28); b.BackgroundColor3=color; b.BorderSizePixel=0; b.TextColor3=Color3.new(1,1,1); b.TextSize=13; b.Font=Enum.Font.GothamSemibold; b.Text=label; b.AutoButtonColor=false; makeCorner(b,14); b.Parent=quick; b.MouseButton1Click:Connect(function() ripple(b); if cb then cb() end end) end
pill("Panic",colors.danger,function() clearESP(); gui:Destroy(); offscreenGui:Destroy(); setBlur(false); Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault; workspace.Gravity=gravityDefault end)
pill("Hide UI",colors.accent2,function() hidden=not hidden; main.Visible=not hidden; offscreenGui.Enabled=not hidden end)
pill("Rejoin",colors.accent,function() TeleportService:Teleport(game.PlaceId,LP) end)

-- Tabs & pages
local tabs=Instance.new("Frame"); tabs.Size=UDim2.new(0,175,1,-52); tabs.Position=UDim2.new(0,0,0,52); tabs.BackgroundColor3=colors.panel; tabs.BorderSizePixel=0; tabs.Parent=main; makeCorner(tabs,12)
local tabsPad = Instance.new("UIPadding", tabs); tabsPad.PaddingLeft = UDim.new(0,8); tabsPad.PaddingRight = UDim.new(0,8); tabsPad.PaddingTop = UDim.new(0,10)
local tabList=Instance.new("UIListLayout",tabs); tabList.VerticalAlignment=Enum.VerticalAlignment.Top; tabList.HorizontalAlignment=Enum.HorizontalAlignment.Center; tabList.Padding=UDim.new(0, config.compact and 6 or 8)
local tabNames={"Dashboard","Movement","Visuals","Combat","Automation","Player List","Script Hub","Configs","Protection","UI / Theme"}
local pages={}
local selectedTab
local pageHolder=Instance.new("Frame"); pageHolder.Size=UDim2.new(1,-185,1,-62); pageHolder.Position=UDim2.new(0,185,0,52); pageHolder.BackgroundTransparency=1; pageHolder.Parent=main
for _,name in ipairs(tabNames) do
    local page=Instance.new("ScrollingFrame"); page.Size=UDim2.new(1,-24,1,-24); page.Position=UDim2.new(0,12,0,12); page.BackgroundTransparency=1; page.Visible=false; page.ScrollBarThickness=6; page.VerticalScrollBarInset=Enum.ScrollBarInset.ScrollBar; page.CanvasSize=UDim2.new(0,0,0,0); page.Parent=pageHolder
    local pad=Instance.new("UIPadding",page); pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10); pad.PaddingTop=UDim.new(0,10); pad.PaddingBottom=UDim.new(0,10)
    local list=Instance.new("UIListLayout",page); list.Padding=UDim.new(0, config.compact and 6 or 10); list.FillDirection=Enum.FillDirection.Vertical; list.HorizontalAlignment=Enum.HorizontalAlignment.Left; list.VerticalAlignment=Enum.VerticalAlignment.Top
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize=UDim2.new(0,0,0,list.AbsoluteContentSize.Y+20) end)
    pages[name]=page
end
local tabButtons={}
local tabColors = {
    ["Dashboard"]=colors.accent,
    ["Movement"]=Color3.fromRGB(30,160,90),
    ["Visuals"]=Color3.fromRGB(60,140,255),
    ["Combat"]=Color3.fromRGB(220,70,70),
    ["Automation"]=Color3.fromRGB(200,140,60),
    ["Player List"]=Color3.fromRGB(120,200,255),
    ["Script Hub"]=Color3.fromRGB(200,140,255),
    ["Configs"]=Color3.fromRGB(120,180,200),
    ["Protection"]=Color3.fromRGB(180,160,80),
    ["UI / Theme"]=Color3.fromRGB(120,180,120),
}
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
        for other,btn in pairs(tabButtons) do tween(btn,0.2,{BackgroundColor3=(other==name) and (tabColors[name] or colors.accent) or colors.bg}) end
        tabIndicator.Visible=true; tween(tabIndicator,0.2,{Position=UDim2.new(0,4,0,b.Position.Y.Offset),BackgroundColor3=tabColors[name] or colors.accent})
    end)
    return b
end
for _,n in ipairs(tabNames) do tabButtons[n]=createTabButton(n) end
switchTab("Dashboard"); tween(tabButtons["Dashboard"],0.01,{BackgroundColor3=colors.accent}); tabIndicator.Position=UDim2.new(0,4,0,tabButtons["Dashboard"].Position.Y.Offset); tabIndicator.Visible=true

-- Dashboard
do
    local p=pages["Dashboard"]
    local info=Instance.new("TextLabel"); info.BackgroundTransparency=1; info.Size=UDim2.new(1,-10,0,20); info.Font=Enum.Font.GothamSemibold; info.TextColor3=colors.text; info.TextSize=15; info.TextXAlignment=Enum.TextXAlignment.Left
    info.Text=("Game: %s | PlaceId: %s"):format(game.Name or "Unknown", tostring(currentGameId)); info.Parent=p
    local status=Instance.new("TextLabel"); status.BackgroundTransparency=1; status.Size=UDim2.new(1,-10,0,20); status.Font=Enum.Font.Gotham; status.TextColor3=colors.subtle; status.TextSize=14; status.TextXAlignment=Enum.TextXAlignment.Left
    status.Text="Mode: Universal (no per-game module)"; status.Parent=p
    makeButton(p,"Universal Features",function() switchTab("Movement"); ripple(tabButtons["Movement"]) end)
    makeButton(p,"Game-Specific Features",function() switchTab("Script Hub"); ripple(tabButtons["Script Hub"]) end)
    makeButton(p,"Configs",function() switchTab("Configs"); ripple(tabButtons["Configs"]) end)
end

-- Movement
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
        else
            if flyBV then flyBV:Destroy(); flyBV=nil end
        end
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

-- Visuals
do
    local p=pages["Visuals"]
    makeToggle(p,"ESP (players)",function(on) config.esp.enabled=on; clearESP(); if on then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeToggle(p,"Box ESP",function(on) config.esp.boxes=on end,config.esp.boxes)
    makeToggle(p,"ESP Names",function(on) config.esp.names=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.names)
    makeToggle(p,"ESP Distance",function(on) config.esp.distance=on end,config.esp.distance)
    makeToggle(p,"ESP Arrows",function(on) config.esp.arrows=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.arrows)
    makeToggle(p,"ESP Healthbar",function(on) config.esp.healthbar=on end,config.esp.healthbar)
    makeToggle(p,"ESP Team Colors",function(on) config.esp.teamColors=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.teamColors)
    makeDropdown(p,"ESP Color Preset",{"Blue","Red","Green","Purple","Gold"},applyEspPreset)
    makeSlider(p,"Box Thickness",1,6,config.esp.thicknessBox or 2,function(v) config.esp.thicknessBox=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeSlider(p,"Tracer Thickness",1,6,config.esp.thicknessTracer or 2,function(v) config.esp.thicknessTracer=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeSlider(p,"ESP Opacity",0.2,1,config.esp.opacity or 0.6,function(v) config.esp.opacity=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    local filterBox=Instance.new("TextBox"); filterBox.Size=UDim2.new(1,-10,0,36); filterBox.BackgroundColor3=colors.bg; filterBox.TextColor3=colors.text; filterBox.PlaceholderText="World ESP name filter (comma separated)"; filterBox.Text=config.esp.nameFilter or ""; filterBox.BorderSizePixel=0; filterBox.Font=Enum.Font.Gotham; filterBox.TextSize=14; makeCorner(filterBox,8); filterBox.Parent=p
    filterBox.FocusLost:Connect(function() config.esp.nameFilter=filterBox.Text end)
    makeSlider(p,"Camera FOV",40,120,config.fov,function(v) config.fov=v; camera.FieldOfView=v end)
    makeToggle(p,"Fullbright",function(on) config.fullbright=on; if on then Lighting.Brightness=2; Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1) else Lighting.Brightness=1; Lighting.Ambient=Color3.new(0,0,0); Lighting.OutdoorAmbient=Color3.new(0,0,0) end end,false)
    makeToggle(p,"No Fog",function(on) config.noFog=on; if on then Lighting.FogEnd=1e9 else Lighting.FogEnd=1000 end end,false)
    makeToggle(p,"Infinite Zoom",function(on) config.infiniteZoom=on; if on then LP.CameraMaxZoomDistance=1e9 else LP.CameraMaxZoomDistance=128 end end,config.infiniteZoom)
end

-- Combat helpers
local fovCircle=Instance.new("Frame"); fovCircle.Name="FOVCircle"; fovCircle.Size=UDim2.fromOffset(config.aimbotFov,config.aimbotFov); fovCircle.Position=UDim2.fromScale(0.5,0.5); fovCircle.AnchorPoint=Vector2.new(0.5,0.5); fovCircle.BackgroundTransparency=0.9; fovCircle.BackgroundColor3=colors.accent; fovCircle.BorderSizePixel=0; fovCircle.Visible=false; fovCircle.ZIndex=9; makeCorner(fovCircle,100); fovCircle.Parent=gui
local function pulseFov() tween(fovCircle,0.15,{BackgroundTransparency=0.6,Size=fovCircle.Size+UDim2.fromOffset(12,12)}).Completed:Connect(function() tween(fovCircle,0.15,{BackgroundTransparency=0.9,Size=UDim2.fromOffset(config.aimbotFov,config.aimbotFov)}) end) end
local function getClosestTarget()
    local closest, dist=nil, math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid").Health>0 then
            local skip=false
            if config.aimbotSkipFriends and LP:IsFriendsWith(plr.UserId) then skip=true end
            for _,name in ipairs(config.friendWhitelist) do if plr.Name:lower()==tostring(name):lower() then skip=true end end
            if config.avoidLowHealth and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health < 20 then skip=true end
            if not skip then
                local pos,on=camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if on then
                    local mouse=UserInputService:GetMouseLocation()
                    local d=(Vector2.new(pos.X,pos.Y)-mouse).Magnitude
                    if d<dist and d<=config.aimbotFov then closest=plr; dist=d end
                end
            end
        end
    end
    return closest
end

-- Combat
do
    local p=pages["Combat"]
    makeToggle(p,"Aimbot (hold RMB)",function(on) config.aimbotEnabled=on; fovCircle.Visible=on and not hidden end)
    makeDropdown(p,"Aim Mode",{"Nearest Crosshair","Nearest Player"},function(v) config.aimbotMode=v end)
    makeDropdown(p,"Target Area",{"Head","Torso","Random"},function(v) config.aimbotArea=v end)
    makeSlider(p,"Aimbot FOV",40,240,config.aimbotFov,function(v) config.aimbotFov=v; fovCircle.Size=UDim2.fromOffset(v,v) end)
    makeSlider(p,"Aimbot Smooth",0.01,0.5,config.aimbotSmooth,function(v) config.aimbotSmooth=v end)
    makeToggle(p,"FOV Circle",function(on) fovCircle.Visible=on end,true)
    makeToggle(p,"Triggerbot",function(on) config.triggerEnabled=on end)
    makeToggle(p,"Skip Friends",function(on) config.aimbotSkipFriends=on end,config.aimbotSkipFriends)
    makeToggle(p,"Legit FOV Decay",function(on) config.aimbotLegitDecay=on end,config.aimbotLegitDecay)
    makeToggle(p,"Avoid Low Health Targets",function(on) config.avoidLowHealth=on end, config.avoidLowHealth)
    makeToggle(p,"Stick to Last Target",function(on) config.stickTarget=on end, config.stickTarget)
    makeToggle(p,"Silent Aim",function(on) config.silentAim=on end, config.silentAim)
    makeButton(p,"Reset Camera FOV",function() camera.FieldOfView=70 end)
end

-- Automation
do
    local p=pages["Automation"]
    makeSlider(p,"Auto Click Rate (s)",0.02,0.3,0.05,function(v) config.autoClickRate=v end)
    makeToggle(p,"Auto Clicker",function(on) autoClickEnabled=on end)
    makeToggle(p,"Auto Interact (Prompts)",function(on) autoInteractEnabled=on end)
    makeToggle(p,"Anti-AFK",function(on) config.antiAfk=on end)
    makeButton(p,"Start Generic Auto-Collect",function() toast("Generic auto-collect stub"); config.autoCollect=true end)
    makeButton(p,"Stop Generic Auto-Collect",function() config.autoCollect=false end)
end

-- Player List
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
            btn.MouseButton1Click:Connect(function() priorityTarget=plr; toast("Priority target: "..plr.Name) end)
        end
    end
    refresh()
    Players.PlayerAdded:Connect(refresh); Players.PlayerRemoving:Connect(refresh)
    makeButton(p,"Teleport to Priority Target",function()
        if priorityTarget and priorityTarget.Character and priorityTarget.Character:FindFirstChild("HumanoidRootPart") then HRP.CFrame=priorityTarget.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0) end
    end)
    makeButton(p,"Spectate Priority Target",function()
        if priorityTarget and priorityTarget.Character and priorityTarget.Character:FindFirstChild("Humanoid") then camera.CameraSubject=priorityTarget.Character:FindFirstChild("Humanoid") end
    end)
    makeButton(p,"Clear Priority Target",function() priorityTarget=nil; camera.CameraSubject=LP.Character:FindFirstChild("Humanoid") end)
end

-- Script Hub (stub)
do
    local p=pages["Script Hub"]
    local desc=Instance.new("TextLabel"); desc.BackgroundTransparency=1; desc.Size=UDim2.new(1,-10,0,40); desc.Font=Enum.Font.Gotham; desc.TextColor3=colors.text; desc.TextSize=14; desc.TextWrapped=true; desc.Text="Script Hub: favorites + auto-exec per game."; desc.Parent=p
    local execBox=Instance.new("TextBox"); execBox.Size=UDim2.new(1,-10,0,100); execBox.BackgroundColor3=colors.bg; execBox.TextColor3=colors.text; execBox.PlaceholderText="Paste script URL or code stub"; execBox.Text=""; execBox.ClearTextOnFocus=false; execBox.TextWrapped=true; execBox.TextXAlignment=Enum.TextXAlignment.Left; execBox.TextYAlignment=Enum.TextYAlignment.Top; execBox.BorderSizePixel=0; execBox.Font=Enum.Font.Gotham; execBox.TextSize=14; makeCorner(execBox,8); execBox.Parent=p
    makeButton(p,"Run Script",function() toast("Run your universal script here") end)
    makeToggle(p,"Auto-Exec (all games)",function(on) config.autoExecEnabled=on end, config.autoExecEnabled)
    local autoBox=Instance.new("TextBox"); autoBox.Size=UDim2.new(1,-10,0,80); autoBox.BackgroundColor3=colors.bg; autoBox.TextColor3=colors.text; autoBox.PlaceholderText="Script name for auto-exec"; autoBox.Text=""; autoBox.ClearTextOnFocus=false; autoBox.TextWrapped=true; autoBox.TextXAlignment=Enum.TextXAlignment.Left; autoBox.TextYAlignment=Enum.TextYAlignment.Top; autoBox.BorderSizePixel=0; autoBox.Font=Enum.Font.Gotham; autoBox.TextSize=14; makeCorner(autoBox,8); autoBox.Parent=p
    makeButton(p,"Add Auto-Exec for this game",function()
        if autoBox.Text~="" then
            config.autoExec[tostring(currentGameId)] = autoBox.Text
            pushLog("Auto-exec set for "..currentGameId)
        end
    end)
    local gameNameLower = string.lower(game.Name or "")
    local isFisch = game.PlaceId==16732694052 or gameNameLower:find("fisch")
    local isFishIt = gameNameLower:find("fish it") ~= nil
    local isForge = gameNameLower:find("forge") ~= nil
    -- per-game modules with tag filters
    local function addWorldTagESP(tagList, fill, outline)
        clearWorldESP()
        for _,d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") then
                for _,tag in ipairs(tagList) do
                    if d.Name:lower():find(tag) then
                        local h=Instance.new("Highlight"); h.FillColor=fill; h.OutlineColor=outline; h.Adornee=d; h.Parent=d; table.insert(worldHighlights,h)
                        break
                    end
                end
            end
        end
    end

    if isFisch or isFishIt then
        local fishFilter=Instance.new("TextBox"); fishFilter.Size=UDim2.new(1,-10,0,30); fishFilter.BackgroundColor3=colors.bg; fishFilter.TextColor3=colors.text; fishFilter.Text="fish,hotspot"; fishFilter.PlaceholderText="Tags: fish,hotspot"; fishFilter.BorderSizePixel=0; fishFilter.Font=Enum.Font.Gotham; fishFilter.TextSize=14; makeCorner(fishFilter,8); fishFilter.Parent=p
        makeToggle(p,"Fishing: Auto Interact (reel)",function(on) config.autoInteractFilter="reel"; autoInteractEnabled=on end)
        makeToggle(p,"Fishing: ESP (fish/hotspots)",function(on)
            if on then
                local tags={}
                for t in string.gmatch(string.lower(fishFilter.Text), "([^,]+)") do table.insert(tags, t:match("^%s*(.-)%s*$")) end
                addWorldTagESP(tags, Color3.fromRGB(60,200,255), Color3.fromRGB(10,120,200))
            else
                clearWorldESP()
            end
        end)
    end
    if isForge then
        local forgeFilter=Instance.new("TextBox"); forgeFilter.Size=UDim2.new(1,-10,0,30); forgeFilter.BackgroundColor3=colors.bg; forgeFilter.TextColor3=colors.text; forgeFilter.Text="ore,anvil,forge,smelt"; forgeFilter.PlaceholderText="Tags: ore,anvil,forge"; forgeFilter.BorderSizePixel=0; forgeFilter.Font=Enum.Font.Gotham; forgeFilter.TextSize=14; makeCorner(forgeFilter,8); forgeFilter.Parent=p
        makeToggle(p,"Forge: Ore/Station ESP",function(on)
            if on then
                local tags={}
                for t in string.gmatch(string.lower(forgeFilter.Text), "([^,]+)") do table.insert(tags, t:match("^%s*(.-)%s*$")) end
                addWorldTagESP(tags, Color3.fromRGB(200,140,60), Color3.fromRGB(255,200,120))
            else
                clearWorldESP()
            end
        end)
        makeToggle(p,"Forge: Auto Interact prompts",function(on) config.autoInteractFilter="forge,smelt,anvil"; autoInteractEnabled=on end)
    end
end

-- Configs
do
    local p=pages["Configs"]
    makeButton(p,"Copy Config to Clipboard",function() if setclipboard then setclipboard(HttpService:JSONEncode(config)); toast("Config copied") else toast("setclipboard not available") end end)
    makeButton(p,"Create/Save Config (Desktop/ADVHub)",function()
        local name="Config_"..tostring(os.time())
        saveConfigToFile(name)
        config.lastConfig = name
        pushLog("Saved "..name)
    end)
    local configList = listConfigs()
    local selectedConfig = configList[1]
    makeDropdown(p,"Load Config",configList,function(v) selectedConfig=v end)
    makeButton(p,"Load Selected",function()
        if selectedConfig and selectedConfig ~= "None" then
            loadConfigFromFile(selectedConfig)
            config.lastConfig = selectedConfig
            pushLog("Loaded "..selectedConfig)
        else
            toast("No config selected")
        end
    end)
    makeButton(p,"Delete Selected",function()
        if selectedConfig and selectedConfig ~= "None" and delfile then
            local path="ADVHub/"..selectedConfig..".json"
            pcall(function() delfile(path) end)
            pushLog("Deleted "..selectedConfig)
        else
            toast("No config selected or delfile missing")
        end
    end)
    makeButton(p,"Duplicate Selected",function()
        if selectedConfig and selectedConfig ~= "None" then
            local src="ADVHub/"..selectedConfig..".json"
            local dst="ADVHub/"..selectedConfig.."_copy.json"
            local ok,content=pcall(function() return readfile(src) end)
            if ok then pcall(function() writefile(dst, content) end); pushLog("Duplicated "..selectedConfig) else toast("Copy failed") end
        else
            toast("Select a config first")
        end
    end)
    makeDropdown(p,"Theme",{"Christmas","Midnight","NeoGreen","Amber","Purple"},function(v) config.theme=v; applyTheme() end)
    makeButton(p,"Apply Preset: Legit",function() local t=config.presets.legit; config.wsBoost=t.ws; config.jpBoost=t.jp; camera.FieldOfView=t.fov; config.aimbotEnabled=t.aimbot; config.esp.enabled=t.esp; config.lastPreset="Legit"; toast("Legit preset applied") end)
    makeButton(p,"Apply Preset: Rage",function() local t=config.presets.rage; config.wsBoost=t.ws; config.jpBoost=t.jp; camera.FieldOfView=t.fov; config.aimbotEnabled=t.aimbot; config.esp.enabled=t.esp; config.lastPreset="Rage"; toast("Rage preset applied") end)
    makeButton(p,"Apply Preset: Visuals",function() local t=config.presets.visuals; camera.FieldOfView=t.fov; config.aimbotEnabled=t.aimbot; config.esp.enabled=t.esp; config.lastPreset="Visuals"; toast("Visuals preset applied") end)
    makeButton(p,"Set Auto-Load (Global)",function() saveConfigToFile("AutoLoad_Global") end)
    makeButton(p,"Set Auto-Load (This Game)",function() saveConfigToFile("AutoLoad_"..tostring(currentGameId)) end)
    makeButton(p,"List Saved Configs (console)",function()
        if listfiles and isfolder and isfolder("ADVHub") then
            local files = listfiles("ADVHub")
            for _,f in ipairs(files) do print("ADVHub file:", f) end
            pushLog("Listed configs in console")
        else
            toast("listfiles not available")
        end
    end)
end

-- Protection
do
    local p=pages["Protection"]
    makeToggle(p,"Auto-disable on teleport",function(on) config.autoDisableOnTP=on end,config.autoDisableOnTP)
    makeToggle(p,"Stop features on panic",function(on) config.stopOnPanic=on end,config.stopOnPanic)
    makeToggle(p,"Low Profile Mode (visual only)",function(on) config.lowProfile=on end,false)
    makeToggle(p,"Menu Blur",function(on) config.uiBlur=on; setBlur(on, config.blurSize) end, config.uiBlur)
    makeToggle(p,"Snow Overlay",function(on) config.snow=on; if on then
        if not gui:FindFirstChild("SnowLayer") then
            local snow=Instance.new("ImageLabel"); snow.Name="SnowLayer"; snow.Parent=gui; snow.Size=UDim2.new(1,0,1,0); snow.Position=UDim2.new(0,0,0,0); snow.BackgroundTransparency=1
            snow.Image="rbxassetid://6764432401"; snow.ImageTransparency=0.25; snow.ScaleType=Enum.ScaleType.Tile; snow.TileSize=UDim2.new(0,128,0,128)
            task.spawn(function()
                while snow.Parent do
                    tween(snow,2,{Position=UDim2.new(0,-20,0,-20)}):Play()
                    task.wait(2)
                    snow.Position=UDim2.new(0,0,0,0)
                end
            end)
        end
    else
        local snow=gui:FindFirstChild("SnowLayer"); if snow then snow:Destroy() end
    end end, config.snow)
    makeToggle(p,"Solid Theme (no gradient)",function(on)
        config.solidTheme=on
        local g=main:FindFirstChildOfClass("UIGradient")
        if g then g.Enabled=not on end
    end, config.solidTheme)
    makeToggle(p,"Disable in VIP/Private",function(on) config.disableInVIP=on end, config.disableInVIP)
    local box=Instance.new("TextBox"); box.Size=UDim2.new(1,-10,0,36); box.BackgroundColor3=colors.bg; box.TextColor3=colors.text; box.PlaceholderText="Username to whitelist"; box.Text=""; box.BorderSizePixel=0; box.Font=Enum.Font.Gotham; box.TextSize=14; makeCorner(box,8); box.Parent=p
    makeButton(p,"Add to Whitelist",function()
        if box.Text and box.Text~="" then table.insert(config.friendWhitelist, box.Text); pushLog("Whitelisted "..box.Text); box.Text="" end
    end)
    makeButton(p,"Clear Whitelist",function() config.friendWhitelist={} pushLog("Whitelist cleared") end)
end

-- UI / Theme
do
    local p=pages["UI / Theme"]
    makeDropdown(p,"Theme",{"Christmas","Midnight","NeoGreen","Amber","Purple"},function(v) config.theme=v; applyTheme() end)
    makeSlider(p,"Menu Opacity",0.5,1,config.uiOpacity,function(v) config.uiOpacity=v; applyOpacity(main) end)
    makeSlider(p,"Menu Width",520,820,mainWidth,function(v) setMainSize(v, mainHeight) end)
    makeSlider(p,"Menu Height",360,640,mainHeight,function(v) setMainSize(mainWidth, v) end)
    makeSlider(p,"Blur Strength",0,15,config.blurSize,function(v) config.blurSize=v; if config.uiBlur then setBlur(true, v) end end)
    makeToggle(p,"Compact Layout",function(on) config.compact=on; toast("Reopen UI to apply compact spacing") end, config.compact)
    makeToggle(p,"UI Animations",function(on) config.animations=on end,true)
    makeToggle(p,"UI Sounds",function(on) config.uiSounds=on end,false)
    makeButton(p,"Apply Fisch/Fish It Visuals",function()
        config.gamePreset="FischVisual"
        config.autoInteractFilter="reel"
        config.esp.nameFilter="fish,hotspot"
        toast("Applied Fisch/Fish It visual preset")
    end)
    makeButton(p,"Apply Forge Visuals",function()
        config.gamePreset="ForgeVisual"
        config.autoInteractFilter="forge,smelt,anvil"
        config.esp.nameFilter="ore,anvil,forge,smelt"
        toast("Applied Forge visual preset")
    end)
    makeButton(p,"Changelog",function() toast("v5.2: scrollable UI, ESP colors, status HUD, config save/load, opacity controls") end)
end

-- Overlay HUD + Quick Bar
local function makeDraggable(frame, onDrag)
    local dragging=false; local dragStart; local startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=input.Position; startPos=frame.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=input.Position-dragStart
            if onDrag then
                onDrag(delta)
            else
                frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            end
        end
    end)
end

local overlay = Instance.new("Frame"); overlay.Size=UDim2.new(0,220,0,24); overlay.Position=UDim2.new(0,8,0,8); overlay.BackgroundColor3=Color3.fromRGB(0,0,0); overlay.BackgroundTransparency=0.35; overlay.BorderSizePixel=0; overlay.Parent=gui; makeCorner(overlay,8); makeDraggable(overlay)
local overlayLabel=Instance.new("TextLabel"); overlayLabel.BackgroundTransparency=1; overlayLabel.Size=UDim2.new(1,-10,1,0); overlayLabel.Position=UDim2.new(0,6,0,0); overlayLabel.Font=Enum.Font.GothamSemibold; overlayLabel.TextColor3=Color3.new(1,1,1); overlayLabel.TextSize=13; overlayLabel.TextXAlignment=Enum.TextXAlignment.Left; overlayLabel.Parent=overlay

local quickBar = Instance.new("Frame"); quickBar.Size=UDim2.new(0,260,0,32); quickBar.Position=UDim2.new(1,-280,1,-48); quickBar.BackgroundColor3=Color3.fromRGB(0,0,0); quickBar.BackgroundTransparency=0.35; quickBar.BorderSizePixel=0; quickBar.Parent=gui; makeCorner(quickBar,10); makeDraggable(quickBar); quickBar.Visible=config.showQuickbar
local qList=Instance.new("UIListLayout",quickBar); qList.FillDirection=Enum.FillDirection.Horizontal; qList.Padding=UDim.new(0,6); qList.VerticalAlignment=Enum.VerticalAlignment.Center; qList.HorizontalAlignment=Enum.HorizontalAlignment.Center
local function qToggle(label,getState,toggleFn)
    local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(70,24); b.BackgroundColor3=Color3.fromRGB(30,30,30); b.BorderSizePixel=0; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.Gotham; b.TextSize=12; b.Text=label; makeCorner(b,8); b.Parent=quickBar
    local function update()
        b.BackgroundColor3 = getState() and colors.accent or Color3.fromRGB(30,30,30)
    end
    b.MouseButton1Click:Connect(function() toggleFn(); update() end)
    update()
end
qToggle("ESP", function() return config.esp.enabled end, function() config.esp.enabled=not config.esp.enabled; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
qToggle("Aimbot", function() return config.aimbotEnabled end, function() config.aimbotEnabled=not config.aimbotEnabled end)
qToggle("Fly", function() return flyEnabled end, function() flyEnabled=not flyEnabled end)
qToggle("Panic", function() return false end, function() clearESP(); gui:Destroy(); offscreenGui:Destroy(); setBlur(false); Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault; workspace.Gravity=gravityDefault end)

-- Keybinds & panic
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == config.menuKey then
        hidden = not hidden
        tween(main, 0.22, {Position = hidden and UDim2.new(0.5, -320, 1.1, 0) or UDim2.new(0.5, -320, 0.5, -240)})
        main.Active = not hidden
        gui.Enabled = not hidden
        fovCircle.Visible = config.aimbotEnabled and not hidden
    elseif input.KeyCode == config.panicKey then
        clearESP(); gui:Destroy(); offscreenGui:Destroy(); setBlur(false)
        Hum.WalkSpeed = wsDefault; Hum.JumpPower = jpDefault; workspace.Gravity=gravityDefault
    elseif input.KeyCode == config.keybinds.toggleAimbot then config.aimbotEnabled=not config.aimbotEnabled; fovCircle.Visible=config.aimbotEnabled
    elseif input.KeyCode == config.keybinds.toggleESP then config.esp.enabled=not config.esp.enabled; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end
    elseif input.KeyCode == config.keybinds.toggleFly then flyEnabled=not flyEnabled
    elseif input.KeyCode == config.keybinds.toggleNoclip then noclipEnabled=not noclipEnabled
    elseif input.KeyCode == config.overlayToggleKey then
        overlay.Visible = not overlay.Visible
        quickBar.Visible = not quickBar.Visible
    elseif input.KeyCode == Enum.KeyCode.Space and infiniteJump then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local function autoDisable(reason)
    config.aimbotEnabled=false
    config.esp.enabled=false
    flyEnabled=false
    noclipEnabled=false
    autoClickEnabled=false
    autoInteractEnabled=false
    clearESP()
    Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault; workspace.Gravity=gravityDefault
    pushLog("Disabled ("..reason..")")
end
Hum.Died:Connect(function()
    if config.autoDisableOnTP then autoDisable("death") end
end)
TeleportService.TeleportInitFailed:Connect(function()
    if config.autoDisableOnTP then autoDisable("teleport") end
end)

-- Loops
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
    local target = nil
    if config.stickTarget and _G.__stickyTarget and _G.__stickyTarget.Parent then
        target = _G.__stickyTarget
    else
        target = getClosestTarget()
    end
    if config.aimbotEnabled and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and UserInputService:IsMouseButtonPressed(config.aimbotKey) then
        pulseFov()
        local targetPos = target.Character.HumanoidRootPart.Position
        if config.aimbotArea=="Head" then local h=target.Character:FindFirstChild("Head"); if h then targetPos=h.Position end
        elseif config.aimbotArea=="Torso" then local t=target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("HumanoidRootPart"); if t then targetPos=t.Position end
        elseif config.aimbotArea=="Random" then local parts={"Head","UpperTorso","HumanoidRootPart","LeftUpperArm","RightUpperArm"}; local choice=target.Character:FindFirstChild(parts[math.random(1,#parts)]); if choice then targetPos=choice.Position end end
        if config.silentAim then
            local screenPos = camera:WorldToViewportPoint(targetPos)
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, nil, 0)
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, nil, 0)
        else
            local look=CFrame.new(camera.CFrame.Position,targetPos)
            camera.CFrame=camera.CFrame:Lerp(look,config.aimbotSmooth)
            if config.triggerEnabled then VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0); VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0) end
        end
        _G.__lastTargetName = target.Name
        _G.__lastTargetDist = (targetPos - HRP.Position).Magnitude
        if config.aimbotLegitDecay then config.aimbotFov = math.max(40, config.aimbotFov - 0.2) end
        if config.stickTarget then _G.__stickyTarget = target end
    end
end))

task.spawn(function()
    while true do
        if autoClickEnabled then VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0); VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0) end
        task.wait(config.autoClickRate or 0.05)
    end
end)

task.spawn(function()
    while true do
        if autoInteractEnabled then
            for _,prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    local allow = true
                    if config.autoInteractFilter and config.autoInteractFilter ~= "" then
                        allow=false
                        local text = string.lower(prompt.Name or "")
                        for tag in string.gmatch(string.lower(config.autoInteractFilter), "([^,]+)") do
                            tag = tag:match("^%s*(.-)%s*$")
                            if tag ~= "" and text:find(tag) then allow=true end
                        end
                    end
                    if allow then pcall(function() fireproximityprompt(prompt) end) end
                end
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
local sessionStart = tick()
table.insert(connections, RunService.RenderStepped:Connect(function()
    local now=tick(); local fps=1/math.max(now-last, 1/60); last=now
    local ping=math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
    local session = math.floor(now - sessionStart)
    statusLabel.Text = string.format("FPS: %d | Ping: %dms | %ds | LastCfg: %s", math.floor(fps), ping, session, config.lastConfig ~= "" and config.lastConfig or "none")
    local targetText = ""
    if _G.__lastTargetName and _G.__lastTargetDist then
        targetText = string.format(" | Target: %s (%dm)", _G.__lastTargetName, math.floor(_G.__lastTargetDist))
    end
    overlayLabel.Text = string.format("FPS: %d | Ping: %dms | Mode: %s%s", math.floor(fps), ping, config.aimbotEnabled and "Aimbot" or "Idle", targetText)
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
setBlur(config.uiBlur)
applyOpacity(main)
autoLoadConfig()
if config.disableInVIP and (game.PrivateServerId and game.PrivateServerId ~= "") then
    autoDisable("VIP/Private")
end
toast("Loaded Advanced Universal Hub v"..config.version)
