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
    animations = true,
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
    worldScanInterval = 3,
    overlayDock = "TL",
    recentConfigs = {},
    fisch = {
        autoCastDelay=0.6,
        autoReelDelay=0.4,
        rarityFilter="Common,Uncommon,Rare",
        autoSellThreshold=0,
        autoCast=false,
        autoReel=false,
        autoMiniGame=false,
        perfectOnly=false,
        loopAutoFish=false,
        valueFilter=0,
        ignoreTrash=true,
        whitelist="",
        blacklist="",
        focusMode="Balanced",
        hotspotQuick={"Hotspot 1","Hotspot 2","Hotspot 3"},
        spotTeleport="",
        autoSellOnFull=false,
        sellKeepRarity="Rare",
        sellKeepValue=100,
        autoDiscardTrash=true,
        sortMode="Rarity",
        lockList="",
        autoEquipBest=true,
        autoUpgradeLevel=0,
        autoBait=true,
        loadouts={},
        depthPreference="Any",
        boatAssist=false,
        fishHud=true,
        antiAfk=true,
        eventNotify=true,
    },
    forge = {autoInsert=true, autoCollect=true, anvilTolerance=0.18},
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
local sessionEvents = {}
local updateTimeline
local flyEnabled, flyBV = false, nil
local islandSpots = {}
local noclipEnabled = false
local autoClickEnabled = false
local autoInteractEnabled = false
local worldEspState = {tags=nil,fill=nil,outline=nil}
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
local function tween(obj,time,props,style,dir)
    if config and config.animations==false then
        for k,v in pairs(props) do obj[k]=v end
        local fake={}
        function fake:Play() return self end
        function fake:Destroy() end
        fake.Completed={Connect=function(_,cb) if cb then cb() end return {Disconnect=function() end} end}
        return fake
    end
    return TweenService:Create(obj,TweenInfo.new(time,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props)
end
local function ripple(button)
    local r=Instance.new("Frame"); r.BackgroundColor3=colors.accent; r.BackgroundTransparency=0.4; r.Size=UDim2.fromOffset(0,0)
    r.AnchorPoint=Vector2.new(0.5,0.5); r.Position=UDim2.new(0.5,0,0.5,0); r.BorderSizePixel=0; r.ZIndex=5; r.Parent=button
    tween(r,0.35,{Size=UDim2.fromScale(2.4,2.4),BackgroundTransparency=1}).Completed:Connect(function() r:Destroy() end)
end
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
local function parseColor(text)
    local r,g,b = string.match(text or "", "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    if r and g and b then
        return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
    end
end
local function refreshIslands()
    islandSpots = {}
    local seen = {}
    for _,loc in ipairs(config.teleportList or {}) do
        if loc.name and loc.pos then
            table.insert(islandSpots, {name=loc.name, pos=loc.pos})
            seen[loc.name] = true
        end
    end
    for _,obj in ipairs(workspace:GetDescendants()) do
        local lower = string.lower(obj.Name or "")
        if lower:find("island") then
            local pos
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                if obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                else
                    local cf = obj:GetBoundingBox()
                    pos = cf.Position
                end
            end
            if pos and not seen[obj.Name] then
                table.insert(islandSpots, {name=obj.Name, pos=pos})
                seen[obj.Name] = true
            end
        end
    end
    if #islandSpots==0 and HRP then
        table.insert(islandSpots, {name="Current", pos=HRP.Position})
    end
end
local function softPanic()
    config.aimbotEnabled=false
    config.esp.enabled=false
    flyEnabled=false
    noclipEnabled=false
    autoClickEnabled=false
    autoInteractEnabled=false
    clearESP(); clearWorldESP()
    Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault; workspace.Gravity=gravityDefault
    pushLog("Soft panic: disabled toggles")
    toast("Soft panic: toggles disabled")
end
local function formatColor(c)
    if not c then return "" end
    local r,g,b = math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)
    return string.format("%d, %d, %d", r,g,b)
end
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
    table.insert(config.recentConfigs,1,name)
    while #config.recentConfigs>3 do table.remove(config.recentConfigs) end
    if ok then pushSessionEvent("Saved config "..name) end
end
local function loadConfigFromFile(name)
    local path="ADVHub/"..name..".json"
    local ok,content=pcall(function() return readfile(path) end)
    if ok then
        loadConfigFromString(content)
        toast("Loaded "..path)
        table.insert(config.recentConfigs,1,name)
        while #config.recentConfigs>3 do table.remove(config.recentConfigs) end
        pushSessionEvent("Loaded config "..name)
    else
        toast("Load failed")
    end
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

local function makeDropdown(parent,label,options,cb,defaultVal)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,40); f.BackgroundColor3=colors.panel; f.BorderSizePixel=0; makeCorner(f,10); f.Parent=parent
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(0.5,-10,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0.5,-20,1,-8); btn.Position=UDim2.new(0.5,8,0,4); btn.BackgroundColor3=colors.bg; btn.BorderSizePixel=0; btn.TextColor3=colors.text; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=14; btn.Text=options[1] or "Select"; makeCorner(btn,8); btn.Parent=f
    local function set(val) btn.Text=val; if cb then cb(val) end end
    btn.MouseButton1Click:Connect(function() ripple(btn); local next=1; for i,opt in ipairs(options) do if opt==btn.Text then next=i%#options+1 end end; set(options[next]) end)
    set(defaultVal or options[1]); return set
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

local function addDivider(parent)
    local d=Instance.new("Frame"); d.Size=UDim2.new(1,-10,0,1); d.BackgroundColor3=colors.subtle; d.BackgroundTransparency=0.8; d.BorderSizePixel=0; d.Parent=parent; return d
end
local grad=Instance.new("UIGradient",main); grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,colors.bg),ColorSequenceKeypoint.new(1,colors.accent2)}; grad.Rotation=60
local grip = Instance.new("Frame"); grip.Size=UDim2.fromOffset(14,14); grip.Position=UDim2.new(1,-18,1,-18); grip.BackgroundColor3=colors.panel; grip.BorderSizePixel=0; makeCorner(grip,4); grip.Parent=main
makeDraggable(grip, function(delta)
    setMainSize(math.clamp(mainWidth + delta.X, 520, 900), math.clamp(mainHeight + delta.Y, 360, 720))
end)

-- Title
local titleHeight = 48
local title=Instance.new("Frame"); title.Size=UDim2.new(1,0,0,titleHeight); title.BackgroundColor3=colors.panel:lerp(Color3.new(0,0,0),0.16); title.BorderSizePixel=0; title.Parent=main; makeCorner(title,12)
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
local function pushSessionEvent(msg)
    local stamp = os.date("%H:%M:%S")
    table.insert(sessionEvents, 1, string.format("[%s] %s", stamp, msg))
    while #sessionEvents > 6 do table.remove(sessionEvents) end
    if updateTimeline then updateTimeline() end
end
local underline=Instance.new("Frame"); underline.Size=UDim2.new(1,-16,0,1); underline.Position=UDim2.new(0,8,1,-1); underline.BackgroundColor3=colors.accent; underline.BorderSizePixel=0; underline.Parent=title

-- Status bar
local statusHeight = 26
local statusBar=Instance.new("Frame"); statusBar.Size=UDim2.new(1,-14,0,statusHeight); statusBar.Position=UDim2.new(0,7,0,titleHeight); statusBar.BackgroundColor3=colors.panel:lerp(colors.bg,0.4); statusBar.BorderSizePixel=0; statusBar.Parent=main; makeCorner(statusBar,10)
local statusLabel=Instance.new("TextLabel"); statusLabel.BackgroundTransparency=1; statusLabel.Size=UDim2.new(1,-20,1,0); statusLabel.Position=UDim2.new(0,10,0,0); statusLabel.Font=Enum.Font.GothamSemibold; statusLabel.TextColor3=colors.subtle; statusLabel.TextSize=13; statusLabel.TextXAlignment=Enum.TextXAlignment.Left; statusLabel.Parent=statusBar
local contentTop = titleHeight + statusHeight + 12

-- Quick pills
local quick=Instance.new("Frame"); quick.Size=UDim2.new(0, mainWidth, 0, 32); quick.Position=UDim2.new(0,0,0,-40); quick.BackgroundTransparency=1; quick.Parent=main
local qaList=Instance.new("UIListLayout",quick); qaList.Padding=UDim.new(0,8); qaList.FillDirection=Enum.FillDirection.Horizontal; qaList.HorizontalAlignment=Enum.HorizontalAlignment.Center; qaList.VerticalAlignment=Enum.VerticalAlignment.Center
local quickPad=Instance.new("UIPadding", quick); quickPad.PaddingLeft=UDim.new(0,12); quickPad.PaddingRight=UDim.new(0,12)
local function pill(label,color,cb) local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(120,28); b.BackgroundColor3=color; b.BorderSizePixel=0; b.TextColor3=Color3.new(1,1,1); b.TextSize=13; b.Font=Enum.Font.GothamSemibold; b.Text=label; b.AutoButtonColor=false; makeCorner(b,14); b.Parent=quick; b.MouseButton1Click:Connect(function() ripple(b); if cb then cb() end end) end
pill("Panic",colors.danger,function() clearESP(); gui:Destroy(); offscreenGui:Destroy(); setBlur(false); Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault; workspace.Gravity=gravityDefault end)
pill("Hide UI",colors.accent2,function() hidden=not hidden; main.Visible=not hidden; offscreenGui.Enabled=not hidden end)
pill("Rejoin",colors.accent,function() TeleportService:Teleport(game.PlaceId,LP) end)
pill("Soft Panic",colors.warn,softPanic)

-- Tabs & pages
local tabs=Instance.new("Frame"); tabs.Size=UDim2.new(0,175,1,-contentTop-10); tabs.Position=UDim2.new(0,0,0,contentTop); tabs.BackgroundColor3=colors.panel; tabs.BorderSizePixel=0; tabs.Parent=main; makeCorner(tabs,12)
local tabsPad = Instance.new("UIPadding", tabs); tabsPad.PaddingLeft = UDim.new(0,8); tabsPad.PaddingRight = UDim.new(0,8); tabsPad.PaddingTop = UDim.new(0,10)
local tabList=Instance.new("UIListLayout",tabs); tabList.VerticalAlignment=Enum.VerticalAlignment.Top; tabList.HorizontalAlignment=Enum.HorizontalAlignment.Center; tabList.Padding=UDim.new(0, config.compact and 6 or 8)
local tabNames={"Dashboard","Movement","Visuals","Combat","Automation","Player List","Script Hub","Configs","Protection","UI / Theme"}
local tabIcons={
    Dashboard="🏠", Movement="🏃", Visuals="👁", Combat="🎯", Automation="⚙️", ["Player List"]="🧑", ["Script Hub"]="📜", Configs="💾", Protection="🛡", ["UI / Theme"]="🎨"
}
local pages={}
local selectedTab
local pageHolder=Instance.new("Frame"); pageHolder.Size=UDim2.new(1,-185,1,-contentTop-10); pageHolder.Position=UDim2.new(0,185,0,contentTop); pageHolder.BackgroundColor3=colors.panel:lerp(colors.bg,0.35); pageHolder.BorderSizePixel=0; pageHolder.Parent=main; makeCorner(pageHolder,14)
local pagePadding=Instance.new("UIPadding",pageHolder); pagePadding.PaddingTop=UDim.new(0,8); pagePadding.PaddingBottom=UDim.new(0,8); pagePadding.PaddingLeft=UDim.new(0,10); pagePadding.PaddingRight=UDim.new(0,10)
for _,name in ipairs(tabNames) do
    local page=Instance.new("ScrollingFrame"); page.Size=UDim2.new(1,0,1,0); page.Position=UDim2.new(0,0,0,0); page.BackgroundTransparency=1; page.Visible=false; page.ScrollBarThickness=6; page.VerticalScrollBarInset=Enum.ScrollBarInset.ScrollBar; page.CanvasSize=UDim2.new(0,0,0,0); page.Parent=pageHolder
    local pad=Instance.new("UIPadding",page); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,12)
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
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-24,0,38); b.BackgroundColor3=colors.bg; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Font=Enum.Font.GothamSemibold; b.TextColor3=colors.text; b.TextSize=15; b.Text=((tabIcons[name] or "").."  "..name); b:SetAttribute("BG",true); makeCorner(b,10); b.Parent=tabs
    b.MouseEnter:Connect(function() tween(b,0.12,{BackgroundColor3=colors.panel}) end)
    b.MouseLeave:Connect(function() if selectedTab~=name then tween(b,0.12,{BackgroundColor3=colors.bg}) end end)
    b.MouseButton1Click:Connect(function()
        ripple(b); switchTab(name)
        for other,btn in pairs(tabButtons) do tween(btn,0.2,{BackgroundColor3=(other==name) and (tabColors[name] or colors.accent) or colors.bg}) end
        tabIndicator.Visible=true; tween(tabIndicator,0.2,{Position=UDim2.new(0,4,0,b.Position.Y.Offset),BackgroundColor3=tabColors[name] or colors.accent})
    end)
    return b
end
for i,n in ipairs(tabNames) do
    tabButtons[n]=createTabButton(n)
    if n=="Visuals" or n=="Automation" or n=="Configs" then
        local sep=Instance.new("Frame"); sep.Size=UDim2.new(1,-24,0,1); sep.BackgroundColor3=colors.subtle; sep.BackgroundTransparency=0.8; sep.BorderSizePixel=0; sep.Parent=tabs
    end
end
switchTab("Dashboard"); tween(tabButtons["Dashboard"],0.01,{BackgroundColor3=colors.accent}); tabIndicator.Position=UDim2.new(0,4,0,tabButtons["Dashboard"].Position.Y.Offset); tabIndicator.Visible=true

-- Dashboard
do
    local p=pages["Dashboard"]
    local info=Instance.new("TextLabel"); info.BackgroundTransparency=1; info.Size=UDim2.new(1,-10,0,20); info.Font=Enum.Font.GothamSemibold; info.TextColor3=colors.text; info.TextSize=15; info.TextXAlignment=Enum.TextXAlignment.Left
    info.Text=("Game: %s | PlaceId: %s"):format(game.Name or "Unknown", tostring(currentGameId)); info.Parent=p
    local status=Instance.new("TextLabel"); status.BackgroundTransparency=1; status.Size=UDim2.new(1,-10,0,20); status.Font=Enum.Font.Gotham; status.TextColor3=colors.subtle; status.TextSize=14; status.TextXAlignment=Enum.TextXAlignment.Left
    status.Text="Mode: Universal (no per-game module)"; status.Parent=p
    local sessionInfo=Instance.new("TextLabel"); sessionInfo.BackgroundTransparency=1; sessionInfo.Size=UDim2.new(1,-10,0,20); sessionInfo.Font=Enum.Font.Gotham; sessionInfo.TextColor3=colors.subtle; sessionInfo.TextSize=13; sessionInfo.TextXAlignment=Enum.TextXAlignment.Left; sessionInfo.TextWrapped=true; sessionInfo.Parent=p
    task.spawn(function()
        while sessionInfo.Parent do
            local elapsed = math.floor(tick()-sessionStart)
            local lastTarget = _G.__lastTargetName or "none"
            local lastDist = _G.__lastTargetDist and (math.floor(_G.__lastTargetDist).."m") or "--"
            sessionInfo.Text = string.format("Session: %ds | Last preset: %s | Last config: %s | Last target: %s (%s)", elapsed, config.lastPreset ~= "" and config.lastPreset or "none", config.lastConfig ~= "" and config.lastConfig or "none", lastTarget, lastDist)
            task.wait(1)
        end
    end)
    local timelineBox=Instance.new("Frame"); timelineBox.Size=UDim2.new(1,-10,0,150); timelineBox.BackgroundColor3=colors.panel; timelineBox.BorderSizePixel=0; makeCorner(timelineBox,10); timelineBox.Parent=p
    local tlPad=Instance.new("UIPadding",timelineBox); tlPad.PaddingTop=UDim.new(0,8); tlPad.PaddingBottom=UDim.new(0,8); tlPad.PaddingLeft=UDim.new(0,10); tlPad.PaddingRight=UDim.new(0,10)
    local tlTitle=Instance.new("TextLabel"); tlTitle.BackgroundTransparency=1; tlTitle.Size=UDim2.new(1,0,0,18); tlTitle.Font=Enum.Font.GothamSemibold; tlTitle.TextColor3=colors.text; tlTitle.TextSize=14; tlTitle.TextXAlignment=Enum.TextXAlignment.Left; tlTitle.Text="Session Timeline"; tlTitle.Parent=timelineBox
    local tlList=Instance.new("UIListLayout",timelineBox); tlList.Padding=UDim.new(0,6); tlList.FillDirection=Enum.FillDirection.Vertical; tlList.SortOrder=Enum.SortOrder.LayoutOrder
    updateTimeline=function()
        for _,child in ipairs(timelineBox:GetChildren()) do
            if child:IsA("TextLabel") and child~=tlTitle then child:Destroy() end
        end
        for _,entry in ipairs(sessionEvents) do
            local row=Instance.new("TextLabel")
            row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,18); row.Font=Enum.Font.Gotham; row.TextColor3=colors.subtle; row.TextSize=13; row.TextXAlignment=Enum.TextXAlignment.Left; row.Text=entry; row.Parent=timelineBox
        end
    end
    pushSessionEvent("Session started")
    updateTimeline()
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
    addDivider(p)
    makeToggle(p,"Speed Lock",function(on) config.speedLock=on end, config.speedLock)
    local islandNote=Instance.new("TextLabel"); islandNote.BackgroundTransparency=1; islandNote.Size=UDim2.new(1,-10,0,32); islandNote.Font=Enum.Font.Gotham; islandNote.TextColor3=colors.subtle; islandNote.TextSize=13; islandNote.TextXAlignment=Enum.TextXAlignment.Left; islandNote.Text="Island Teleport: auto-detects island models and saved spots"; islandNote.Parent=p
    local islandOptions={"Rescan islands"}
    local selectedIsland = islandOptions[1]
    local islandDropdown = makeDropdown(p,"Island Destination", islandOptions, function(v) selectedIsland=v end)
    local function syncIslandOptions()
        local names={}
        for _,spot in ipairs(islandSpots) do table.insert(names, spot.name) end
        if #names==0 then table.insert(names, "No islands found") end
        for k in pairs(islandOptions) do islandOptions[k]=nil end
        for i,v in ipairs(names) do islandOptions[i]=v end
        selectedIsland = islandOptions[1]
        islandDropdown(selectedIsland)
    end
    makeButton(p,"Rescan Islands",function()
        refreshIslands()
        syncIslandOptions()
        toast("Islands refreshed")
    end)
    makeButton(p,"Teleport to Island",function()
        if not selectedIsland or selectedIsland=="No islands found" then toast("No island to teleport") return end
        for _,spot in ipairs(islandSpots) do
            if spot.name == selectedIsland and spot.pos then
                if HRP then
                    HRP.CFrame = CFrame.new(spot.pos + Vector3.new(0,6,0))
                    pushSessionEvent("Teleported to "..spot.name)
                    toast("Teleported to "..spot.name)
                else
                    toast("No character root")
                end
                return
            end
        end
        toast("Island not found in list")
    end)
    refreshIslands()
    syncIslandOptions()
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
    addDivider(p)
    local colorBox=Instance.new("Frame"); colorBox.Size=UDim2.new(1,-10,0,70); colorBox.BackgroundColor3=colors.panel; colorBox.BorderSizePixel=0; makeCorner(colorBox,10); colorBox.Parent=p
    local grid=Instance.new("UIGridLayout",colorBox); grid.CellSize=UDim2.new(0.24,0,0,30); grid.CellPadding=UDim2.new(0,6,0,6); grid.FillDirection=Enum.FillDirection.Horizontal
    local function colorInput(label, key)
        local tb=Instance.new("TextBox"); tb.BackgroundColor3=colors.bg; tb.BorderSizePixel=0; tb.TextColor3=colors.text; tb.Font=Enum.Font.Gotham; tb.TextSize=13; tb.PlaceholderText=label.." (R,G,B)"; tb.Text=formatColor(config.esp.colors[key]); makeCorner(tb,8); tb.Parent=colorBox; return tb
    end
    local accentBox=colorInput("Accent","accent")
    local outlineBox=colorInput("Outline","outline")
    local boxBox=colorInput("Box","box")
    local tracerBox=colorInput("Tracer","tracer")
    makeButton(p,"Apply ESP Colors",function()
        local acc, out, bx, tr = parseColor(accentBox.Text), parseColor(outlineBox.Text), parseColor(boxBox.Text), parseColor(tracerBox.Text)
        if acc and out and bx and tr then
            config.esp.colors = {accent=acc, outline=out, box=bx, tracer=tr, preset="Custom"}
            clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end
            toast("Applied custom ESP colors")
        else
            toast("Invalid color values")
        end
    end)
    makeSlider(p,"Box Thickness",1,6,config.esp.thicknessBox or 2,function(v) config.esp.thicknessBox=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeSlider(p,"Tracer Thickness",1,6,config.esp.thicknessTracer or 2,function(v) config.esp.thicknessTracer=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeSlider(p,"ESP Opacity",0.2,1,config.esp.opacity or 0.6,function(v) config.esp.opacity=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    addDivider(p)
    local filterBox=Instance.new("TextBox"); filterBox.Size=UDim2.new(1,-10,0,36); filterBox.BackgroundColor3=colors.bg; filterBox.TextColor3=colors.text; filterBox.PlaceholderText="World ESP name filter (comma separated)"; filterBox.Text=config.esp.nameFilter or ""; filterBox.BorderSizePixel=0; filterBox.Font=Enum.Font.Gotham; filterBox.TextSize=14; makeCorner(filterBox,8); filterBox.Parent=p
    filterBox.FocusLost:Connect(function() config.esp.nameFilter=filterBox.Text end)
    makeButton(p,"Rescan world tags",function()
        if worldEspState.tags then addWorldTagESP(worldEspState.tags, worldEspState.fill, worldEspState.outline); toast("World tags rescanned") else toast("No world tags active") end
    end)
    makeSlider(p,"World ESP rescan (s)",0,10,config.worldScanInterval or 0,function(v) config.worldScanInterval=v end)
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
    addDivider(p)
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
        worldEspState = {tags=tagList, fill=fill, outline=outline}
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
        makeToggle(p,"Fishing: Auto Interact (reel)",function(on) config.autoInteractFilter="reel"; autoInteractEnabled=on; pushSessionEvent("Auto interact "..(on and "on" or "off")) end)
        makeToggle(p,"Fishing: ESP (fish/hotspots)",function(on)
            if on then
                local tags={}
                for t in string.gmatch(string.lower(fishFilter.Text), "([^,]+)") do table.insert(tags, t:match("^%s*(.-)%s*$")) end
                addWorldTagESP(tags, Color3.fromRGB(60,200,255), Color3.fromRGB(10,120,200))
                pushSessionEvent("Fish ESP on")
            else
                clearWorldESP()
                pushSessionEvent("Fish ESP off")
            end
        end)
        addDivider(p)
        makeToggle(p,"Auto Cast",function(on) config.fisch.autoCast=on; pushSessionEvent("Auto Cast "..(on and "enabled" or "disabled")) end, config.fisch.autoCast)
        makeSlider(p,"Auto-cast delay",0,2,config.fisch.autoCastDelay or 0.6,function(v) config.fisch.autoCastDelay=v end)
        makeToggle(p,"Auto Reel",function(on) config.fisch.autoReel=on; pushSessionEvent("Auto Reel "..(on and "enabled" or "disabled")) end, config.fisch.autoReel)
        makeSlider(p,"Auto-reel delay",0,2,config.fisch.autoReelDelay or 0.4,function(v) config.fisch.autoReelDelay=v end)
        makeToggle(p,"Auto Mini-Game Solver",function(on) config.fisch.autoMiniGame=on; pushSessionEvent("Mini-game solver "..(on and "on" or "off")) end, config.fisch.autoMiniGame)
        makeToggle(p,"Perfect only mode",function(on) config.fisch.perfectOnly=on end, config.fisch.perfectOnly)
        makeToggle(p,"Loop Auto-Fish (cast→hook→reel)",function(on) config.fisch.loopAutoFish=on; pushSessionEvent("Loop auto-fish "..(on and "on" or "off")) end, config.fisch.loopAutoFish)
        addDivider(p)
        local rarityBox=Instance.new("TextBox"); rarityBox.Size=UDim2.new(1,-10,0,30); rarityBox.BackgroundColor3=colors.bg; rarityBox.TextColor3=colors.text; rarityBox.Text=config.fisch.rarityFilter; rarityBox.PlaceholderText="Rarity filter (comma)"; rarityBox.BorderSizePixel=0; rarityBox.Font=Enum.Font.Gotham; rarityBox.TextSize=14; makeCorner(rarityBox,8); rarityBox.Parent=p; rarityBox.FocusLost:Connect(function() config.fisch.rarityFilter=rarityBox.Text end)
        makeSlider(p,"Value filter (keep >= coins)",0,1000,config.fisch.valueFilter or 0,function(v) config.fisch.valueFilter=v end)
        makeToggle(p,"Ignore trash-tier fish",function(on) config.fisch.ignoreTrash=on end, config.fisch.ignoreTrash)
        local whitelistBox=Instance.new("TextBox"); whitelistBox.Size=UDim2.new(1,-10,0,30); whitelistBox.BackgroundColor3=colors.bg; whitelistBox.TextColor3=colors.text; whitelistBox.Text=config.fisch.whitelist; whitelistBox.PlaceholderText="Whitelist (comma fish names)"; whitelistBox.BorderSizePixel=0; whitelistBox.Font=Enum.Font.Gotham; whitelistBox.TextSize=14; makeCorner(whitelistBox,8); whitelistBox.Parent=p; whitelistBox.FocusLost:Connect(function() config.fisch.whitelist=whitelistBox.Text end)
        local blacklistBox=Instance.new("TextBox"); blacklistBox.Size=UDim2.new(1,-10,0,30); blacklistBox.BackgroundColor3=colors.bg; blacklistBox.TextColor3=colors.text; blacklistBox.Text=config.fisch.blacklist; blacklistBox.PlaceholderText="Blacklist (comma junk fish)"; blacklistBox.BorderSizePixel=0; blacklistBox.Font=Enum.Font.Gotham; blacklistBox.TextSize=14; makeCorner(blacklistBox,8); blacklistBox.Parent=p; blacklistBox.FocusLost:Connect(function() config.fisch.blacklist=blacklistBox.Text end)
        makeDropdown(p,"Focus mode",{"Balanced","Max XP/hour","Max Coins/hour"},function(v) config.fisch.focusMode=v; pushSessionEvent("Focus: "..v) end, config.fisch.focusMode)
        addDivider(p)
        makeDropdown(p,"Teleport fishing spot",{"Ocean","River","Lake","Lava","Ice Cave","Deep Sea"},function(v) config.fisch.spotTeleport=v end, config.fisch.spotTeleport ~= "" and config.fisch.spotTeleport or "Ocean")
        makeButton(p,"Teleport to spot",function() pushSessionEvent("Teleport to fishing spot: "..(config.fisch.spotTeleport or "Ocean")); toast("Teleporting to "..(config.fisch.spotTeleport or "Ocean")) end)
        makeButton(p,"Rescan hotspots",function() pushSessionEvent("Hotspots rescanned") end)
        local hotspotRow=Instance.new("Frame"); hotspotRow.Size=UDim2.new(1,-10,0,30); hotspotRow.BackgroundTransparency=1; hotspotRow.Parent=p
        local hl=Instance.new("UIListLayout",hotspotRow); hl.FillDirection=Enum.FillDirection.Horizontal; hl.Padding=UDim.new(0,6)
        for i,label in ipairs(config.fisch.hotspotQuick) do
            local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(90,26); b.BackgroundColor3=colors.bg; b.BorderSizePixel=0; b.TextColor3=colors.text; b.Font=Enum.Font.GothamSemibold; b.TextSize=13; b.Text=label; makeCorner(b,8); b.Parent=hotspotRow
            b.MouseButton1Click:Connect(function() pushSessionEvent("Hop to "..label); toast("Hotspot hop: "..label) end)
        end
        addDivider(p)
        makeToggle(p,"Auto-sell when full",function(on) config.fisch.autoSellOnFull=on end, config.fisch.autoSellOnFull)
        makeSlider(p,"Auto-sell value >=",0,500,config.fisch.autoSellThreshold or 0,function(v) config.fisch.autoSellThreshold=v end)
        makeDropdown(p,"Keep rarity or above",{"Common","Uncommon","Rare","Epic","Legendary","Mythical"},function(v) config.fisch.sellKeepRarity=v end, config.fisch.sellKeepRarity)
        makeSlider(p,"Keep value >=",0,1000,config.fisch.sellKeepValue or 0,function(v) config.fisch.sellKeepValue=v end)
        makeToggle(p,"Auto-discard trash",function(on) config.fisch.autoDiscardTrash=on end, config.fisch.autoDiscardTrash)
        makeDropdown(p,"Sort mode",{"Rarity","Value","Size"},function(v) config.fisch.sortMode=v end, config.fisch.sortMode)
        local lockBox=Instance.new("TextBox"); lockBox.Size=UDim2.new(1,-10,0,30); lockBox.BackgroundColor3=colors.bg; lockBox.TextColor3=colors.text; lockBox.Text=config.fisch.lockList; lockBox.PlaceholderText="Locked fish (never sell)"; lockBox.BorderSizePixel=0; lockBox.Font=Enum.Font.Gotham; lockBox.TextSize=14; makeCorner(lockBox,8); lockBox.Parent=p; lockBox.FocusLost:Connect(function() config.fisch.lockList=lockBox.Text end)
        addDivider(p)
        makeToggle(p,"Auto-equip best rod",function(on) config.fisch.autoEquipBest=on end, config.fisch.autoEquipBest)
        makeSlider(p,"Auto-upgrade rod to lvl",0,10,config.fisch.autoUpgradeLevel or 0,function(v) config.fisch.autoUpgradeLevel=v end)
        makeToggle(p,"Auto-bait (keep active)",function(on) config.fisch.autoBait=on end, config.fisch.autoBait)
        makeDropdown(p,"Loadout presets",{"XP Rod Setup","Money Rod Setup","Event Setup"},function(v) config.fisch.activeLoadout=v; pushSessionEvent("Loadout: "..v) end)
        addDivider(p)
        makeDropdown(p,"Depth preference",{"Any","Shallow","Deep","Special"},function(v) config.fisch.depthPreference=v end, config.fisch.depthPreference)
        makeToggle(p,"Boat assist (dock & teleport)",function(on) config.fisch.boatAssist=on end, config.fisch.boatAssist)
        makeToggle(p,"Fish HUD overlay",function(on) config.fisch.fishHud=on end, config.fisch.fishHud)
        makeToggle(p,"Anti-AFK for fishing",function(on) config.fisch.antiAfk=on end, config.fisch.antiAfk)
        makeToggle(p,"Event alerts",function(on) config.fisch.eventNotify=on end, config.fisch.eventNotify)
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
        makeToggle(p,"Auto insert ores",function(on) config.forge.autoInsert=on end, config.forge.autoInsert)
        makeToggle(p,"Auto collect ingots",function(on) config.forge.autoCollect=on end, config.forge.autoCollect)
        makeSlider(p,"Anvil timing tolerance",0,0.5,config.forge.anvilTolerance or 0.18,function(v) config.forge.anvilTolerance=v end)
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
    addDivider(p)
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
    addDivider(p)
    local recentBox=Instance.new("Frame"); recentBox.Size=UDim2.new(1,-10,0,90); recentBox.BackgroundColor3=colors.panel; recentBox.BorderSizePixel=0; makeCorner(recentBox,10); recentBox.Parent=p
    local recentPad=Instance.new("UIPadding",recentBox); recentPad.PaddingTop=UDim.new(0,8); recentPad.PaddingBottom=UDim.new(0,8); recentPad.PaddingLeft=UDim.new(0,10); recentPad.PaddingRight=UDim.new(0,10)
    local recentTitle=Instance.new("TextLabel"); recentTitle.BackgroundTransparency=1; recentTitle.Size=UDim2.new(1,0,0,18); recentTitle.Font=Enum.Font.GothamSemibold; recentTitle.TextColor3=colors.text; recentTitle.TextSize=14; recentTitle.TextXAlignment=Enum.TextXAlignment.Left; recentTitle.Text="Recent Configs"; recentTitle.Parent=recentBox
    local recList=Instance.new("UIListLayout", recentBox); recList.FillDirection=Enum.FillDirection.Vertical; recList.Padding=UDim.new(0,6)
    local function renderRecent()
        for _,child in ipairs(recentBox:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i,name in ipairs(config.recentConfigs) do
            if i>3 then break end
            local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,24); b.BackgroundColor3=colors.bg; b.BorderSizePixel=0; b.TextColor3=colors.text; b.Font=Enum.Font.Gotham; b.TextSize=13; b.Text=("Load %s"):format(name); makeCorner(b,8); b.Parent=recentBox
            b.MouseButton1Click:Connect(function()
                loadConfigFromFile(name)
                config.lastConfig = name
                pushLog("Loaded "..name)
            end)
        end
    end
    renderRecent()
    addDivider(p)
    makeDropdown(p,"Theme",{"Christmas","Midnight","NeoGreen","Amber","Purple"},function(v) config.theme=v; applyTheme() end)
    makeButton(p,"Apply Preset: Legit",function() local t=config.presets.legit; config.wsBoost=t.ws; config.jpBoost=t.jp; camera.FieldOfView=t.fov; config.aimbotEnabled=t.aimbot; config.esp.enabled=t.esp; config.lastPreset="Legit"; toast("Legit preset applied"); pushSessionEvent("Preset: Legit") end)
    makeButton(p,"Apply Preset: Rage",function() local t=config.presets.rage; config.wsBoost=t.ws; config.jpBoost=t.jp; camera.FieldOfView=t.fov; config.aimbotEnabled=t.aimbot; config.esp.enabled=t.esp; config.lastPreset="Rage"; toast("Rage preset applied"); pushSessionEvent("Preset: Rage") end)
    makeButton(p,"Apply Preset: Visuals",function() local t=config.presets.visuals; camera.FieldOfView=t.fov; config.aimbotEnabled=t.aimbot; config.esp.enabled=t.esp; config.lastPreset="Visuals"; toast("Visuals preset applied"); pushSessionEvent("Preset: Visuals") end)
    addDivider(p)
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
    local recentFrame=Instance.new("Frame"); recentFrame.Size=UDim2.new(1,-10,0,70); recentFrame.BackgroundColor3=colors.panel; recentFrame.BorderSizePixel=0; makeCorner(recentFrame,10); recentFrame.Parent=p
    local rfList=Instance.new("UIListLayout",recentFrame); rfList.FillDirection=Enum.FillDirection.Horizontal; rfList.Padding=UDim.new(0,6); rfList.VerticalAlignment=Enum.VerticalAlignment.Center; rfList.HorizontalAlignment=Enum.HorizontalAlignment.Center
    local function refreshRecent()
        for _,c in ipairs(recentFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for i,name in ipairs(config.recentConfigs) do
            local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(120,28); b.BackgroundColor3=colors.bg; b.BorderSizePixel=0; b.TextColor3=colors.text; b.Font=Enum.Font.Gotham; b.TextSize=13; b.Text=name; makeCorner(b,8); b.Parent=recentFrame
            b.MouseButton1Click:Connect(function()
                loadConfigFromFile(name)
                config.lastConfig = name
                pushLog("Quick-loaded "..name)
            end)
        end
    end
    refreshRecent()
    local kbFrame=Instance.new("Frame"); kbFrame.Size=UDim2.new(1,-10,0,140); kbFrame.BackgroundColor3=colors.panel; kbFrame.BorderSizePixel=0; makeCorner(kbFrame,10); kbFrame.Parent=p
    local kbList=Instance.new("UIListLayout",kbFrame); kbList.Padding=UDim.new(0,6); kbList.FillDirection=Enum.FillDirection.Vertical; kbList.HorizontalAlignment=Enum.HorizontalAlignment.Left
    local function addKeybindRow(label, keyPath)
        local row=Instance.new("Frame"); row.Size=UDim2.new(1,-12,0,26); row.BackgroundTransparency=1; row.Parent=kbFrame
        local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(0.5,0,1,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=row
        local b=Instance.new("TextButton"); b.Size=UDim2.new(0.5,-4,1,0); b.Position=UDim2.new(0.5,4,0,0); b.BackgroundColor3=colors.bg; b.BorderSizePixel=0; b.TextColor3=colors.text; b.Font=Enum.Font.GothamSemibold; b.TextSize=13; b.Text=tostring(keyPath()); makeCorner(b,8); b.Parent=row
        b.MouseButton1Click:Connect(function()
            b.Text = "Press key..."
            local conn; conn = UserInputService.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    conn:Disconnect()
                    b.Text = tostring(inp.KeyCode)
                    keyPath(inp.KeyCode)
                end
            end)
        end)
    end
    addKeybindRow("Toggle UI", function(k) if k then config.menuKey=k end return config.menuKey end)
    addKeybindRow("Soft Panic", function(k) if k then config.panicKey=k end return config.panicKey end)
    addKeybindRow("Toggle Aimbot", function(k) if k then config.keybinds.toggleAimbot=k end return config.keybinds.toggleAimbot end)
    addKeybindRow("Toggle ESP", function(k) if k then config.keybinds.toggleESP=k end return config.keybinds.toggleESP end)
    addKeybindRow("Toggle Fly", function(k) if k then config.keybinds.toggleFly=k end return config.keybinds.toggleFly end)
    addKeybindRow("Toggle Noclip", function(k) if k then config.keybinds.toggleNoclip=k end return config.keybinds.toggleNoclip end)
    addKeybindRow("Toggle Overlay", function(k) if k then config.overlayToggleKey=k end return config.overlayToggleKey end)
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
    addDivider(p)
    local box=Instance.new("TextBox"); box.Size=UDim2.new(1,-10,0,36); box.BackgroundColor3=colors.bg; box.TextColor3=colors.text; box.PlaceholderText="Username to whitelist"; box.Text=""; box.BorderSizePixel=0; box.Font=Enum.Font.Gotham; box.TextSize=14; makeCorner(box,8); box.Parent=p
    makeButton(p,"Add to Whitelist",function()
        if box.Text and box.Text~="" then table.insert(config.friendWhitelist, box.Text); pushLog("Whitelisted "..box.Text); box.Text="" end
    end)
    makeButton(p,"Clear Whitelist",function() config.friendWhitelist={} pushLog("Whitelist cleared") end)
end

-- UI / Theme
do
    local p=pages["UI / Theme"]
    makeDropdown(p,"Theme",{"Christmas","Midnight","NeoGreen","Amber","Purple"},function(v) config.theme=v; applyTheme(); pushSessionEvent("Theme: "..v) end)
    local themeGrid=Instance.new("Frame"); themeGrid.Size=UDim2.new(1,-10,0,92); themeGrid.BackgroundColor3=colors.panel; themeGrid.BorderSizePixel=0; makeCorner(themeGrid,10); themeGrid.Parent=p
    local gridPad=Instance.new("UIPadding",themeGrid); gridPad.PaddingTop=UDim.new(0,8); gridPad.PaddingBottom=UDim.new(0,8); gridPad.PaddingLeft=UDim.new(0,10); gridPad.PaddingRight=UDim.new(0,10)
    local swatchLayout=Instance.new("UIGridLayout",themeGrid); swatchLayout.CellSize=UDim2.new(0.31,0,0,36); swatchLayout.CellPadding=UDim2.new(0,8,0,8)
    for name,pal in pairs(themes) do
        local swatch=Instance.new("TextButton")
        swatch.Text=name
        swatch.Size=UDim2.new(0,120,0,30)
        swatch.BackgroundColor3=pal.panel
        swatch.TextColor3=pal.text
        swatch.Font=Enum.Font.GothamSemibold
        swatch.TextSize=13
        swatch.BorderSizePixel=0
        makeCorner(swatch,8)
        local stripe=Instance.new("Frame"); stripe.Size=UDim2.new(1,0,0,4); stripe.Position=UDim2.new(0,0,1,-4); stripe.BackgroundColor3=pal.accent; stripe.BorderSizePixel=0; stripe.Parent=swatch; makeCorner(stripe,4)
        swatch.MouseEnter:Connect(function() tween(swatch,0.12,{BackgroundColor3=pal.bg}) end)
        swatch.MouseLeave:Connect(function() tween(swatch,0.12,{BackgroundColor3=pal.panel}) end)
        swatch.MouseButton1Click:Connect(function()
            config.theme=name; applyTheme(); pushSessionEvent("Theme: "..name); toast("Applied "..name.." theme")
        end)
        swatch.Parent=themeGrid
    end
    makeSlider(p,"Menu Opacity",0.5,1,config.uiOpacity,function(v) config.uiOpacity=v; applyOpacity(main) end)
    makeSlider(p,"Menu Width",520,820,mainWidth,function(v) setMainSize(v, mainHeight) end)
    makeSlider(p,"Menu Height",360,640,mainHeight,function(v) setMainSize(mainWidth, v) end)
    makeSlider(p,"Blur Strength",0,15,config.blurSize,function(v) config.blurSize=v; if config.uiBlur then setBlur(true, v) end end)
    local comfortRow=Instance.new("Frame"); comfortRow.Size=UDim2.new(1,-10,0,70); comfortRow.BackgroundColor3=colors.panel; comfortRow.BorderSizePixel=0; makeCorner(comfortRow,10); comfortRow.Parent=p
    local comfortLayout=Instance.new("UIListLayout",comfortRow); comfortLayout.FillDirection=Enum.FillDirection.Horizontal; comfortLayout.Padding=UDim.new(0,8)
    comfortLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    local function comfortBtn(label,preset)
        local b=Instance.new("TextButton"); b.Size=UDim2.new(0.32,0,0,50); b.BackgroundColor3=colors.bg; b.BorderSizePixel=0; b.TextColor3=colors.text; b.Font=Enum.Font.GothamSemibold; b.TextSize=13; b.Text=label; makeCorner(b,10); b.Parent=comfortRow
        b.MouseButton1Click:Connect(function()
            config.uiOpacity=preset.opacity; config.uiBlur=preset.blur; config.blurSize=preset.blurSize; applyOpacity(main); setBlur(config.uiBlur, config.blurSize); pushSessionEvent("Comfort: "..label)
        end)
    end
    comfortBtn("Performance",{opacity=1,blur=false,blurSize=0})
    comfortBtn("Balanced",{opacity=0.9,blur=true,blurSize=6})
    comfortBtn("Cinematic",{opacity=0.8,blur=true,blurSize=12})
    makeToggle(p,"Compact Layout",function(on) config.compact=on; toast("Reopen UI to apply compact spacing") end, config.compact)
    makeToggle(p,"UI Animations",function(on) config.animations=on end,true)
    makeToggle(p,"UI Sounds",function(on) config.uiSounds=on end,false)
    addDivider(p)
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
local overlay = Instance.new("Frame"); overlay.Size=UDim2.new(0,220,0,24); overlay.Position=UDim2.new(0,8,0,8); overlay.BackgroundColor3=Color3.fromRGB(0,0,0); overlay.BackgroundTransparency=0.35; overlay.BorderSizePixel=0; overlay.Parent=gui; makeCorner(overlay,8); makeDraggable(overlay)
local overlayLabel=Instance.new("TextLabel"); overlayLabel.BackgroundTransparency=1; overlayLabel.Size=UDim2.new(1,-10,1,0); overlayLabel.Position=UDim2.new(0,6,0,0); overlayLabel.Font=Enum.Font.GothamSemibold; overlayLabel.TextColor3=Color3.new(1,1,1); overlayLabel.TextSize=13; overlayLabel.TextXAlignment=Enum.TextXAlignment.Left; overlayLabel.Parent=overlay
local function applyOverlayDock(pos)
    config.overlayDock = pos or config.overlayDock
    if pos=="TR" then overlay.Position=UDim2.new(1,-overlay.Size.X.Offset-8,0,8)
    elseif pos=="BL" then overlay.Position=UDim2.new(0,8,1,-overlay.Size.Y.Offset-8)
    elseif pos=="BR" then overlay.Position=UDim2.new(1,-overlay.Size.X.Offset-8,1,-overlay.Size.Y.Offset-8)
    else overlay.Position=UDim2.new(0,8,0,8) end
end
applyOverlayDock(config.overlayDock or "TL")
local dockBar=Instance.new("Frame"); dockBar.Size=UDim2.new(0,100,0,18); dockBar.Position=UDim2.new(1,-110,1,-22); dockBar.BackgroundTransparency=1; dockBar.Parent=overlay
local dockList=Instance.new("UIListLayout", dockBar); dockList.FillDirection=Enum.FillDirection.Horizontal; dockList.Padding=UDim.new(0,4); dockList.HorizontalAlignment=Enum.HorizontalAlignment.Right
local function dockButton(label,key)
    local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(22,18); b.BackgroundColor3=Color3.fromRGB(30,30,30); b.BorderSizePixel=0; b.TextColor3=Color3.new(1,1,1); b.TextSize=12; b.Font=Enum.Font.GothamSemibold; b.Text=label; makeCorner(b,6); b.Parent=dockBar
    b.MouseButton1Click:Connect(function() applyOverlayDock(key) end)
end
dockButton("TL","TL"); dockButton("TR","TR"); dockButton("BL","BL"); dockButton("BR","BR")

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
        if config.animations then
            tween(main, 0.22, {Position = hidden and UDim2.new(0.5, -320, 1.1, 0) or UDim2.new(0.5, -320, 0.5, -240)})
        else
            main.Position = hidden and UDim2.new(0.5, -320, 1.1, 0) or UDim2.new(0.5, -320, 0.5, -240)
        end
        main.Active = not hidden
        gui.Enabled = not hidden
        fovCircle.Visible = config.aimbotEnabled and not hidden
    elseif input.KeyCode == config.panicKey then
        softPanic()
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
        if worldEspState.tags and config.worldScanInterval and config.worldScanInterval > 0 then
            addWorldTagESP(worldEspState.tags, worldEspState.fill or colors.accent, worldEspState.outline or colors.accent2)
            task.wait(config.worldScanInterval)
        else
            task.wait(1)
        end
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
        if config.animations then
            tween(main,1.6,{Position=UDim2.new(main.Position.X.Scale,main.Position.X.Offset,main.Position.Y.Scale,main.Position.Y.Offset+4)},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.wait(1.6)
            tween(main,1.6,{Position=UDim2.new(main.Position.X.Scale,main.Position.X.Offset,main.Position.Y.Scale,main.Position.Y.Offset-4)},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.wait(1.6)
        else
            task.wait(1)
        end
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
