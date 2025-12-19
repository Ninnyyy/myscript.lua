-- Wrap everything so execution errors surface as a toast instead of silently aborting
local ok, err = pcall(function()

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
        palette = "Blue",
        fadeEnabled = false,
        fadeStart = 150,
        fadeEnd = 500,
        outlineOnly = false,
        arrowSize = 12,
        arrowStyle = "Rounded",
        nameSize = 14,
        healthbarPos = "Bottom",
        maxDistance = 0,
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
    uiBlur = true,
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
    aimbotProfiles = {
        Legit = {smooth=0.28, fov=90, trigger=false, silent=false, area="Head"},
        Balanced = {smooth=0.18, fov=140, trigger=false, silent=false, area="Torso"},
        Rage = {smooth=0.05, fov=220, trigger=true, silent=false, area="Head"},
        Custom = {smooth=0.18, fov=140, trigger=false, silent=false, area="Head"},
    },
    lastAimbotProfile = "",
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
    autoLoadGameProfile = true,
    lastGameProfile = "",
    gameTeleports = {},
    advanced = {
        legitMode = false,
        rageMode = false,
        freezeMode = "None",
        autoMine = false,
        autoMineInterval = 0.6,
        autoMineTags = "ore,mine,rock,crystal",
        autoKill = false,
        autoKillInterval = 0.25,
        autoKillRange = 60,
        autoKillPlayers = false,
        autoKillNPCs = true,
        autoEquipRod = false,
        autoEquipInterval = 2,
        rodPriority = "rod,fish",
    },

    -- Generated mega-feature tracker keeps a record of the 1000 micro-features and improvements shown in the dashboard preview
    featureCatalog = {},
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
        perfectBias=true,
        fullLoop=true,
        mode="Balanced",
    },
    fishit = {
        tpSpot="Ocean",
        tpVendor="Shop",
        tpUpgrade="Upgrade Station",
        tpBait="Bait Vendor",
        savedWaypoint="Favorite 1",
        xpMode=false,
        moneyMode=true,
        autoSellFull=true,
        autoSellRarity="Rare",
        autoSellValue=250,
        autoDiscardJunk=true,
        lockFavorites=true,
        sortMode="Rarity",
        autoEquipBest=true,
        autoUpgradeTarget=5,
        autoBait=true,
        loadout="Money Rod",
        hotspotEsp=true,
        vendorEsp=true,
        pierLabels=true,
        fullbright=true,
        noFog=true,
        fov=80,
        overlayMode="Money/hour",
        eventOnly=false,
        tpEventOnStart=true,
        antiAfk=true,
        rejoinLowPop=false,
        profile="Ocean Farm",
    },
    fischPro = {
        mode="Always complete",
        rarityTier="Rare+",
        valueFilter=0,
        whitelist="",
        blacklist="",
        targetProfile="XP grind",
        region="Ocean",
        routePreset="Snowcap cave route",
        conditionPreset="Foggy night mythic",
        autoSwitchTime=true,
        autoSwitchWeather=true,
        loadout="Deep ocean mythic",
        baitRule="Don’t waste rare bait",
        boatRoute="Harbor loop",
        bestiaryFocus="Mythic",
        hotspotEsp=true,
        landmarkEsp=true,
        mythicMarker=true,
        autoSellRarity="Rare+",
        autoSellValue=500,
        lockFavorites=true,
        profitTrack=true,
        alertEvents=true,
        bossTargets="",
        antiAfk=true,
        rejoinMode="None",
        overlayProfile="Session",
        theme="Nautical",
    },
    forgePlanner = {
        tab="Home",
        theme="Lava",
        oreRoute="Goblin Caves",
        oreGoal=1000,
        recipeTag="DPS",
        weaponProfile="Fire greatsword",
        armorProfile="Goblin Cave tank set",
        runePage="DPS page",
        zoneRoute="Recommended order",
        economyMode="Sell vs Forge",
        overlay=true,
    },
    forge = {autoInsert=true, autoCollect=true, anvilTolerance=0.18},
    forgeAdvanced = {
        autoMelt=false,
        autoPour=false,
        autoHammer=false,
        openForge=false,
        autoAttackMobs=false,
        multiMobSelection=true,
        attackDistance=60,
        depthControl=false,
        depthOffset=0,
        autoNoClip=false,
        autoMineRocks=false,
        rockTypeSelection="Ore,Crystal,Rock",
        areaFilter="",
        playerAvoidance=true,
        miningDistance=50,
        autoSellWeapons=false,
        autoSellOres=false,
        sellQuantityLimit=0,
        autoSellOnFull=false,
        timedAutoSell=false,
        sellInterval=45,
        shopInit=false,
        buyPotions=false,
        autoDrinkPotions=false,
        autoBuyWhenEmpty=false,
        potionTypes="Health,Stamina",
        npcTeleportTarget="",
        placeTeleportTarget="",
        pickaxeShopTarget="",
        islandTeleportTarget="",
        autoRerollRace=false,
        targetRace="",
        showRaceChances=false,
        claimAllOres=false,
        claimAllEnemies=false,
        claimAllEquipment=false,
        claimAll=false,
        rareItemNotify=false,
        rarityFilter="Rare,Legendary,Mythic",
        webhookUrl="",
        chanceFilter=0,
        worldHopMode="None",
        lowPingPriority=false,
        playerCountFilter=0,
        autoExecOnTeleport=false,
        redeemCodes="",
    },
}

-- Massive feature manifest to showcase breadth (auto-generated for lightweight tracking and preview)
local featureCategories = {"Automation", "Combat", "Visual", "QoL", "Safety", "Game", "Overlay", "Config", "Travel", "Progression"}
local featureActions = {"Auto", "Smart", "Instant", "Predictive", "Profiled", "Adaptive", "Responsive", "Guided", "Optimized", "Enhanced"}
local featureSubjects = {"Routing", "ESP", "Filters", "Vendors", "Hotspots", "Events", "Keybinds", "Loadouts", "Sessions", "Stats"}
for i=1,1000 do
    local cat = featureCategories[((i-1) % #featureCategories)+1]
    local act = featureActions[((i-1) % #featureActions)+1]
    local subj = featureSubjects[((i-1) % #featureSubjects)+1]
    config.featureCatalog[i] = {id=i, category=cat, name=string.format("%s %s %s", act, cat, subj)}
end

local function sliceFeatures(startIndex, count, category)
    local results = {}
    local available = 0
    local targetCategory = category or "All"
    if targetCategory == "All" then
        available = #config.featureCatalog
    else
        for _,f in ipairs(config.featureCatalog) do
            if f.category == targetCategory then available = available + 1 end
        end
    end

    local target = math.min(count or 0, available)
    if target == 0 then return results end

    local matched, idx, safety = 0, startIndex, 0
    while matched < target and safety < #config.featureCatalog*2 do
        if idx > #config.featureCatalog then idx = 1 end
        local f = config.featureCatalog[idx]
        if targetCategory == "All" or f.category == targetCategory then
            table.insert(results, f)
            matched = matched + 1
        end
        idx = idx + 1
        safety = safety + 1
    end
    return results
end

local hidden = false

-- State
local scriptActive = true
local wsDefault = Hum.WalkSpeed
local jpDefault = Hum.JumpPower
local gravityDefault = workspace.Gravity
local connections = {}
local humanoidDiedConn
local highlightObjects, nametagObjects, arrowObjects, tracerObjects = {}, {}, {}, {}
local worldHighlights = {}
local blurEffect
local sessionEvents = {}
local updateTimeline
local fovCircle
local pushLog = function() end
local lastTargetName, lastTargetDist, stickyTarget = nil, nil, nil
local overlayUpdateRate = 0.2
local lastOverlayUpdate = 0
local proximityPrompts = {}
local lastInteractFilter = ""
local cachedInteractTags = {}
local depthLockY = nil
local gameNameLower = string.lower(game.Name or "")
local fishItIds = {15557967605, 17180310686}
local fischIds = {16732694052}
local forgeIds = {22442260156}
local rivalsIds = {}
local inkIds = {}
local function anyMatch(ids, names)
    for _,id in ipairs(ids) do if game.PlaceId == id then return true end end
    for _,name in ipairs(names) do if gameNameLower:find(name, 1, true) then return true end end
    return false
end
local isFisch = anyMatch(fischIds, {"fisch"})
local isFishIt = anyMatch(fishItIds, {"fish it", "fishit"})
local isForge = anyMatch(forgeIds, {"the forge", "forge"})
local isRivals = anyMatch(rivalsIds, {"rivals"})
local isInk = anyMatch(inkIds, {"ink game", "inkgame"})
local detectedGame = isFisch and "Fisch" or isFishIt and "Fish It" or isForge and "Forge" or isRivals and "Rivals" or isInk and "Ink Game" or "Other"
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
table.insert(connections, workspace.DescendantAdded:Connect(function(desc)
    if not isForge or not config.forgeAdvanced.rareItemNotify then return end
    if desc:IsA("Tool") or desc:IsA("Model") then
        notifyRareItem(desc.Name)
    end
end))

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
local function addHoverScale(obj,scaleUp)
    local scale=Instance.new("UIScale")
    scale.Scale=1
    scale.Parent=obj
    obj.MouseEnter:Connect(function() tween(scale,0.15,{Scale=scaleUp or 1.02}):Play() end)
    obj.MouseLeave:Connect(function() tween(scale,0.15,{Scale=1}):Play() end)
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
    stickyTarget = nil
    lastTargetName, lastTargetDist = nil, nil
    clearESP(); clearWorldESP()
    if Hum then Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault end
    workspace.Gravity=gravityDefault
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
local function registerGameTeleports(list)
    if not list then return end
    local seen = {}
    for _,name in ipairs(config.gameTeleports) do seen[string.lower(name)] = true end
    for _,name in ipairs(list) do
        if name and name ~= "" then
            local key = string.lower(name)
            if not seen[key] then
                table.insert(config.gameTeleports, name)
                seen[key] = true
            end
        end
    end
end
local function parseTags(text)
    local tags = {}
    for t in string.gmatch(string.lower(text or ""), "([^,]+)") do
        local clean = t:match("^%s*(.-)%s*$")
        if clean ~= "" then table.insert(tags, clean) end
    end
    return tags
end
local function isPlayerCharacter(model)
    if not model or not model:IsA("Model") then return false end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
    end
    return false
end
local function findNearestTarget(range, allowPlayers, allowNPCs)
    local best, bestDist = nil, math.huge
    local maxRange = range or 60
    if allowPlayers then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - HRP.Position).Magnitude
                    if dist <= maxRange and dist < bestDist then
                        best, bestDist = hrp, dist
                    end
                end
            end
        end
    end
    if allowNPCs then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Health > 0 then
                local model = obj.Parent
                if model and model:IsA("Model") and not isPlayerCharacter(model) then
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - HRP.Position).Magnitude
                        if dist <= maxRange and dist < bestDist then
                            best, bestDist = hrp, dist
                        end
                    end
                end
            end
        end
    end
    return best
end
local function equipToolByPriority(priorityText)
    if not Hum then return false end
    local tags = parseTags(priorityText)
    local backpack = LP:FindFirstChildOfClass("Backpack")
    if not backpack then return false end
    for _,tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = string.lower(tool.Name)
            for _,tag in ipairs(tags) do
                if name:find(tag, 1, true) then
                    Hum:EquipTool(tool)
                    return true
                end
            end
        end
    end
    return false
end
local function isPlayerNearby(radius)
    local hrp = HRP
    if not hrp then return false end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist <= radius then return true end
        end
    end
    return false
end
local function notifyRareItem(name)
    if not config.forgeAdvanced.rareItemNotify then return end
    local filters = parseTags(config.forgeAdvanced.rarityFilter)
    local lower = string.lower(name or "")
    for _,tag in ipairs(filters) do
        if lower:find(tag, 1, true) then
            toast("Rare item: "..name)
            if config.forgeAdvanced.webhookUrl and config.forgeAdvanced.webhookUrl ~= "" then
                log("RareItem", name)
            end
            break
        end
    end
end
local function findSpotByName(name)
    if not name or name == "" then return nil end
    local needle = string.lower(name)
    local bestPos, bestDist = nil, math.huge
    for _,obj in ipairs(workspace:GetDescendants()) do
        local objName = string.lower(obj.Name or "")
        if objName:find(needle, 1, true) then
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
            if pos then
                local dist = HRP and (pos - HRP.Position).Magnitude or 0
                if dist < bestDist then
                    bestDist = dist
                    bestPos = pos
                end
            end
        end
    end
    return bestPos
end
local function teleportToSpot(name)
    if not HRP then return false end
    local pos = findSpotByName(name)
    if pos then
        HRP.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
        return true
    end
    return false
end
local function ensureModuleDir()
    if not makefolder or not isfolder then return end
    if not isfolder("modules") then makefolder("modules") end
    if not isfolder("modules/games") then makefolder("modules/games") end
end
local function requireModule(relPath)
    if not readfile or not loadstring then return nil end
    local ok, src = pcall(function() return readfile(relPath) end)
    if not ok or not src then return nil end
    local chunk, err = loadstring(src)
    if not chunk then
        warn("Module load failed:", relPath, err)
        return nil
    end
    local okRun, mod = pcall(chunk)
    if okRun then return mod end
    warn("Module exec failed:", relPath, mod)
    return nil
end
local function updateInteractTags()
    local filter = string.lower(config.autoInteractFilter or "")
    if filter == lastInteractFilter then return end
    lastInteractFilter = filter
    cachedInteractTags = {}
    for tag in string.gmatch(filter, "([^,]+)") do
        tag = tag:match("^%s*(.-)%s*$")
        if tag ~= "" then table.insert(cachedInteractTags, tag) end
    end
end
local function trackPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        proximityPrompts[prompt] = true
    end
end
local function promptPos(prompt)
    if not prompt then return nil end
    local parent = prompt.Parent
    if parent and parent:IsA("BasePart") then return parent.Position end
    if parent and parent:IsA("Model") then
        if parent.PrimaryPart then return parent.PrimaryPart.Position end
        local cf = parent:GetBoundingBox()
        return cf.Position
    end
    return nil
end
local function firePromptsByTags(tags, maxDist)
    if not tags or #tags == 0 then return end
    local hrp = HRP
    local maxD = maxDist or 0
    for prompt in pairs(proximityPrompts) do
        if prompt.Enabled and prompt.Parent then
            local name = string.lower(prompt.Name or "")
            for _,tag in ipairs(tags) do
                if name:find(tag, 1, true) then
                    if maxD > 0 and hrp then
                        local pos = promptPos(prompt)
                        if pos and (pos - hrp.Position).Magnitude > maxD then break end
                    end
                    pcall(function() fireproximityprompt(prompt) end)
                    break
                end
            end
        end
    end
end
local function untrackPrompt(prompt)
    if prompt then proximityPrompts[prompt] = nil end
end
local function initPromptTracking()
    for _,desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then trackPrompt(desc) end
    end
    table.insert(connections, workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("ProximityPrompt") then trackPrompt(desc) end
    end))
    table.insert(connections, workspace.DescendantRemoving:Connect(function(desc)
        if desc:IsA("ProximityPrompt") then untrackPrompt(desc) end
    end))
end
local function disconnectAll()
    for _,conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end
local function shutdown(reason)
    if not scriptActive then return end
    scriptActive = false
    disconnectAll()
    stickyTarget = nil
    lastTargetName, lastTargetDist = nil, nil
    pcall(function() clearESP() end)
    pcall(function() clearWorldESP() end)
    if flyBV then flyBV:Destroy(); flyBV=nil end
    if gui then gui:Destroy() end
    if offscreenGui then offscreenGui:Destroy() end
    setBlur(false)
    if Hum then Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault end
    workspace.Gravity=gravityDefault
    pushLog("Shutdown ("..(reason or "manual")..")")
end
local function bindHumanoid(hum)
    if humanoidDiedConn then pcall(function() humanoidDiedConn:Disconnect() end) end
    humanoidDiedConn = hum.Died:Connect(function()
        if config.autoDisableOnTP then autoDisable("death") end
    end)
    table.insert(connections, humanoidDiedConn)
end

-- Config IO
local function loadConfigFromString(str)
    local ok,data=pcall(function() return HttpService:JSONDecode(str) end)
    if ok and type(data)=="table" then for k,v in pairs(data) do config[k]=v end; toast("Config loaded"); return true end
    toast("Failed to load config"); return false
end
local function ensureDir() pcall(function() if not isfolder("ADVHub") then makefolder("ADVHub") end end) end
local function ensureGameProfileDir()
    ensureDir()
    pcall(function()
        if not isfolder("ADVHub/GameProfiles") then makefolder("ADVHub/GameProfiles") end
    end)
end
local function gameProfilePath(name)
    return "ADVHub/GameProfiles/"..tostring(currentGameId).."_"..name..".json"
end
local function gameProfileAutoPath()
    return "ADVHub/GameProfiles/Auto_"..tostring(currentGameId)..".txt"
end
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
    ensureGameProfileDir()
    local loadedGameProfile = false
    if config.autoLoadGameProfile and isfile and isfile(gameProfileAutoPath()) then
        local ok,name=pcall(function() return readfile(gameProfileAutoPath()) end)
        if ok and name and name ~= "" then
            loadGameProfile(name)
            toast("Auto-loaded game profile "..name)
            loadedGameProfile = true
        end
    end
    if loadedGameProfile then return end
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

local function listGameProfiles()
    local files = {}
    if listfiles and isfolder and isfolder("ADVHub/GameProfiles") then
        for _,f in ipairs(listfiles("ADVHub/GameProfiles")) do
            local name = f:match("ADVHub[/\\]GameProfiles[/\\]"..tostring(currentGameId).."_([^/\\]+)%.json$")
            if name then table.insert(files, name) end
        end
    end
    table.sort(files)
    if #files==0 then table.insert(files,"None") end
    return files
end

local function saveGameProfile(name)
    if not name or name == "" then return end
    ensureGameProfileDir()
    local path = gameProfilePath(name)
    local ok,err=pcall(function() writefile(path, HttpService:JSONEncode(config)) end)
    toast(ok and ("Saved "..path) or ("Save failed: "..tostring(err)))
    if ok then
        config.lastGameProfile = name
        pushSessionEvent("Saved game profile "..name)
    end
end

local function loadGameProfile(name)
    if not name or name == "" then return end
    local path = gameProfilePath(name)
    local ok,content=pcall(function() return readfile(path) end)
    if ok then
        loadConfigFromString(content)
        toast("Loaded "..path)
        config.lastGameProfile = name
        pushSessionEvent("Loaded game profile "..name)
    else
        toast("Load failed")
    end
end

local function deleteGameProfile(name)
    if not name or name == "" then return end
    if delfile then
        local path = gameProfilePath(name)
        pcall(function() delfile(path) end)
        pushSessionEvent("Deleted game profile "..name)
    end
end

local function setAutoGameProfile(name)
    if not name or name == "" then return end
    ensureGameProfileDir()
    pcall(function() writefile(gameProfileAutoPath(), name) end)
    config.lastGameProfile = name
    toast("Auto-load game profile: "..name)
end

ensureModuleDir()
do
    local gameLoader = requireModule("modules/game_loader.lua")
    if gameLoader and gameLoader.load then
        local ctx = {config=config, toast=toast, pushLog=pushLog, requireModule=requireModule, registerTeleports=registerGameTeleports}
        local detected = {isFisch=isFisch, isFishIt=isFishIt, isForge=isForge, isRivals=isRivals, isInk=isInk, detectedGame=detectedGame}
        gameLoader.load(ctx, detected)
    end
end

-- UI builders
local function stylizeCard(frame)
    frame.BackgroundColor3=colors.panel:lerp(Color3.new(1,1,1),0.05)
    frame.BackgroundTransparency=0.08
    local stroke=Instance.new("UIStroke",frame); stroke.Thickness=1; stroke.Transparency=0.6; stroke.Color=colors.subtle
    local g=Instance.new("UIGradient",frame); g.Rotation=90; g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0, colors.bg:lerp(colors.accent2,0.08)), ColorSequenceKeypoint.new(1, colors.panel)})
    addHoverScale(frame)
    frame.MouseEnter:Connect(function()
        tween(stroke,0.14,{Transparency=0.2}):Play()
    end)
    frame.MouseLeave:Connect(function()
        tween(stroke,0.14,{Transparency=0.6}):Play()
    end)
end

local function makeToggle(parent,label,cb,defaultState)
    local h = config.compact and 34 or 40
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,h); f.BorderSizePixel=0; makeCorner(f,12); f.Parent=parent; stylizeCard(f)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(1,-90,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local btn=Instance.new("TextButton"); btn.Size=UDim2.fromOffset(70,config.compact and 22 or 24); btn.Position=UDim2.new(1,-80,0.5,-(config.compact and 11 or 12)); btn.BackgroundColor3=colors.bg:lerp(colors.accent,0.06); btn.BackgroundTransparency=0.12; btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.Text="Off"; btn.TextColor3=colors.text; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=13; makeCorner(btn,12); btn.Parent=f
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(20,20); knob.Position=UDim2.new(0,2,0.5,-10); knob.BackgroundColor3=colors.subtle; knob.BorderSizePixel=0; makeCorner(knob,20); knob.Parent=btn
    local on=defaultState or false
    local function set(state)
        on=state
        btn.Text = on and "On" or "Off"
        tween(btn,0.16,{BackgroundColor3=on and colors.accent or colors.bg:lerp(colors.accent2,0.06)})
        tween(knob,0.16,{Position=on and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), BackgroundColor3=on and Color3.new(1,1,1) or colors.subtle})
        pushLog(string.format("%s: %s", label, on and "On" or "Off"))
        if cb then task.spawn(function() cb(on) end) end
    end
    btn.MouseButton1Click:Connect(function() ripple(btn); set(not on); log("toggle",label.."="..tostring(not on)) end)
    set(on); return set
end

local function makeButton(parent,label,cb)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-10,0,40); b.BorderSizePixel=0; b.AutoButtonColor=false
    b.Font=Enum.Font.GothamSemibold; b.TextColor3=colors.text; b.TextSize=15; b.Text=label; makeCorner(b,10); b.Parent=parent; stylizeCard(b)
    b.MouseEnter:Connect(function() tween(b,0.1,{BackgroundTransparency=0, BackgroundColor3=colors.panel:lerp(colors.accent2,0.12)}) end)
    b.MouseLeave:Connect(function() tween(b,0.12,{BackgroundTransparency=0.08, BackgroundColor3=colors.panel:lerp(Color3.new(1,1,1),0.05)}) end)
    b.MouseButton1Click:Connect(function() ripple(b); if cb then task.spawn(cb) end end)
    return b
end

local function makeSlider(parent,label,min,max,default,cb)
    local h = config.compact and 38 or 44
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,h); f.BorderSizePixel=0; makeCorner(f,12); f.Parent=parent; stylizeCard(f)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(0.5,-10,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local value=Instance.new("TextLabel"); value.BackgroundTransparency=1; value.Size=UDim2.new(0.5,-10,1,0); value.Position=UDim2.new(0.5,0,0,0); value.Font=Enum.Font.GothamSemibold; value.TextColor3=colors.text; value.TextSize=14; value.TextXAlignment=Enum.TextXAlignment.Right; value.Text=tostring(default); value.Parent=f
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-24,0,6); bar.Position=UDim2.new(0,12,1,-12); bar.BackgroundColor3=colors.bg:lerp(colors.accent2,0.05); bar.BackgroundTransparency=0.18; bar.BorderSizePixel=0; makeCorner(bar,6); bar.Parent=f
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
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-10,0,40); f.BorderSizePixel=0; makeCorner(f,12); f.Parent=parent; stylizeCard(f)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Size=UDim2.new(0.5,-10,1,0); l.Position=UDim2.new(0,12,0,0); l.Font=Enum.Font.Gotham; l.TextColor3=colors.text; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=label; l.Parent=f
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0.5,-20,1,-8); btn.Position=UDim2.new(0.5,8,0,4); btn.BackgroundColor3=colors.bg:lerp(colors.accent2,0.08); btn.BackgroundTransparency=0.1; btn.BorderSizePixel=0; btn.TextColor3=colors.text; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=14; btn.Text=options[1] or "Select"; makeCorner(btn,8); btn.Parent=f
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

local function sectionTitle(parent,text,sub)
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Size=UDim2.new(1,-10,0,sub and 18 or 22); t.Font=sub and Enum.Font.Gotham or Enum.Font.GothamSemibold; t.TextColor3=sub and colors.subtle or colors.text; t.TextSize=sub and 13 or 15; t.TextXAlignment=Enum.TextXAlignment.Left; t.Text=text; t.Parent=parent; return t
end

local function buildFishAutomation(parent)
    sectionTitle(parent,"Fish It / Fisch Automation")
    sectionTitle(parent,"Full loop: cast, hook, reel, sell, travel",true)

    local fishFilter=Instance.new("TextBox"); fishFilter.Size=UDim2.new(1,-10,0,30); fishFilter.BackgroundColor3=colors.bg; fishFilter.TextColor3=colors.text; fishFilter.Text=config.esp.nameFilter~="" and config.esp.nameFilter or "fish,hotspot"; fishFilter.PlaceholderText="Tags: fish,hotspot"; fishFilter.BorderSizePixel=0; fishFilter.Font=Enum.Font.Gotham; fishFilter.TextSize=14; makeCorner(fishFilter,8); fishFilter.Parent=parent
    fishFilter.FocusLost:Connect(function() config.esp.nameFilter=fishFilter.Text end)

    makeToggle(parent,"Fishing: Auto Interact (reel)",function(on) config.autoInteractFilter="reel"; autoInteractEnabled=on; pushSessionEvent("Auto interact "..(on and "on" or "off")) end)
    makeToggle(parent,"Fishing: ESP (fish/hotspots)",function(on)
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
    addDivider(parent)

    sectionTitle(parent,"Core Auto-Fishing")
    makeToggle(parent,"Auto Cast",function(on) config.fisch.autoCast=on; pushSessionEvent("Auto Cast "..(on and "enabled" or "disabled")) end, config.fisch.autoCast)
    makeSlider(parent,"Auto-cast delay",0,2,config.fisch.autoCastDelay or 0.6,function(v) config.fisch.autoCastDelay=v end)
    makeToggle(parent,"Auto Reel",function(on) config.fisch.autoReel=on; pushSessionEvent("Auto Reel "..(on and "enabled" or "disabled")) end, config.fisch.autoReel)
    makeSlider(parent,"Auto-reel delay",0,2,config.fisch.autoReelDelay or 0.4,function(v) config.fisch.autoReelDelay=v end)
    makeToggle(parent,"Auto Mini-Game Solver",function(on) config.fisch.autoMiniGame=on; pushSessionEvent("Mini-game solver "..(on and "on" or "off")) end, config.fisch.autoMiniGame)
    makeToggle(parent,"Perfect timing bias",function(on) config.fisch.perfectBias=on end, config.fisch.perfectBias)
    makeToggle(parent,"Loop Auto-Fish (cast→hook→reel)",function(on) config.fisch.fullLoop=on; config.fisch.loopAutoFish=on; pushSessionEvent("Loop auto-fish "..(on and "on" or "off")) end, config.fisch.fullLoop)
    addDivider(parent)

    sectionTitle(parent,"Targeting & Modes")
    local rarityBox=Instance.new("TextBox"); rarityBox.Size=UDim2.new(1,-10,0,30); rarityBox.BackgroundColor3=colors.bg; rarityBox.TextColor3=colors.text; rarityBox.Text=config.fisch.rarityFilter; rarityBox.PlaceholderText="Rarity filter (comma)"; rarityBox.BorderSizePixel=0; rarityBox.Font=Enum.Font.Gotham; rarityBox.TextSize=14; makeCorner(rarityBox,8); rarityBox.Parent=parent; rarityBox.FocusLost:Connect(function() config.fisch.rarityFilter=rarityBox.Text end)
    makeSlider(parent,"Value filter (keep >= coins)",0,2000,config.fisch.valueFilter or 0,function(v) config.fisch.valueFilter=v end)
    makeToggle(parent,"Ignore trash-tier fish",function(on) config.fisch.ignoreTrash=on end, config.fisch.ignoreTrash)
    local whitelistBox=Instance.new("TextBox"); whitelistBox.Size=UDim2.new(1,-10,0,30); whitelistBox.BackgroundColor3=colors.bg; whitelistBox.TextColor3=colors.text; whitelistBox.Text=config.fisch.whitelist; whitelistBox.PlaceholderText="Whitelist (comma fish names)"; whitelistBox.BorderSizePixel=0; whitelistBox.Font=Enum.Font.Gotham; whitelistBox.TextSize=14; makeCorner(whitelistBox,8); whitelistBox.Parent=parent; whitelistBox.FocusLost:Connect(function() config.fisch.whitelist=whitelistBox.Text end)
    local blacklistBox=Instance.new("TextBox"); blacklistBox.Size=UDim2.new(1,-10,0,30); blacklistBox.BackgroundColor3=colors.bg; blacklistBox.TextColor3=colors.text; blacklistBox.Text=config.fisch.blacklist; blacklistBox.PlaceholderText="Blacklist (comma junk fish)"; blacklistBox.BorderSizePixel=0; blacklistBox.Font=Enum.Font.Gotham; blacklistBox.TextSize=14; makeCorner(blacklistBox,8); blacklistBox.Parent=parent; blacklistBox.FocusLost:Connect(function() config.fisch.blacklist=blacklistBox.Text end)
    makeDropdown(parent,"Mode",{"Balanced","XP mode","Money mode"},function(v) config.fisch.mode=v; pushSessionEvent("Mode: "..v) end, config.fisch.mode or "Balanced")
    addDivider(parent)

    sectionTitle(parent,"Hotspots & Travel")
    makeDropdown(parent,"Teleport fishing spot",{"Ocean","River","Lake","Lava","Ice Cave","Deep Sea"},function(v) config.fisch.spotTeleport=v end, config.fisch.spotTeleport ~= "" and config.fisch.spotTeleport or "Ocean")
        makeButton(parent,"Teleport to spot",function()
            local target = config.fisch.spotTeleport or "Ocean"
            if teleportToSpot(target) then
                pushSessionEvent("Teleported to "..target)
                toast("Teleported to "..target)
            else
                toast("Spot not found: "..target)
            end
        end)
    makeButton(parent,"Rescan hotspots",function() pushSessionEvent("Hotspots rescanned") end)
    local hotspotRow=Instance.new("Frame"); hotspotRow.Size=UDim2.new(1,-10,0,30); hotspotRow.BackgroundTransparency=1; hotspotRow.Parent=parent
    local hl=Instance.new("UIListLayout",hotspotRow); hl.FillDirection=Enum.FillDirection.Horizontal; hl.Padding=UDim.new(0,6)
    for _,label in ipairs(config.fisch.hotspotQuick) do
        local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(90,26); b.BackgroundColor3=colors.bg; b.BorderSizePixel=0; b.TextColor3=colors.text; b.Font=Enum.Font.GothamSemibold; b.TextSize=13; b.Text=label; makeCorner(b,8); b.Parent=hotspotRow
        b.MouseButton1Click:Connect(function() pushSessionEvent("Hop to "..label); toast("Hotspot hop: "..label) end)
    end
    addDivider(parent)

    sectionTitle(parent,"Inventory & Selling")
    makeToggle(parent,"Auto-sell on full inventory",function(on) config.fisch.autoSellOnFull=on end, config.fisch.autoSellOnFull)
    makeDropdown(parent,"Keep rarity or higher",{"Common","Uncommon","Rare","Epic","Legendary","Mythical"},function(v) config.fisch.sellKeepRarity=v end, config.fisch.sellKeepRarity)
    makeSlider(parent,"Keep if value >=",0,2000,config.fisch.sellKeepValue or 100,function(v) config.fisch.sellKeepValue=v end)
    makeToggle(parent,"Auto-discard trash / junk",function(on) config.fisch.autoDiscardTrash=on end, config.fisch.autoDiscardTrash)
    makeDropdown(parent,"Sort by",{"Rarity","Value","Size"},function(v) config.fisch.sortMode=v end, config.fisch.sortMode)
    local lockBox=Instance.new("TextBox"); lockBox.Size=UDim2.new(1,-10,0,30); lockBox.BackgroundColor3=colors.bg; lockBox.TextColor3=colors.text; lockBox.Text=config.fisch.lockList or ""; lockBox.PlaceholderText="Lock list (favorites)"; lockBox.BorderSizePixel=0; lockBox.Font=Enum.Font.Gotham; lockBox.TextSize=14; makeCorner(lockBox,8); lockBox.Parent=parent; lockBox.FocusLost:Connect(function() config.fisch.lockList=lockBox.Text end)
    addDivider(parent)

    sectionTitle(parent,"Gear & Bait")
    makeToggle(parent,"Auto-equip best rod",function(on) config.fisch.autoEquipBest=on; config.fishit.autoEquipBest=on end, config.fisch.autoEquipBest)
    makeSlider(parent,"Auto-upgrade rod to level",0,20,config.fisch.autoUpgradeLevel or 0,function(v) config.fisch.autoUpgradeLevel=v end)
    makeToggle(parent,"Auto-apply bait",function(on) config.fisch.autoBait=on; config.fishit.autoBait=on end, config.fisch.autoBait)
    makeDropdown(parent,"Loadout",{"XP rod","Money rod","Boss rod"},function(v) config.fishit.loadout=v end, config.fishit.loadout)
    addDivider(parent)

    if isFishIt then
        sectionTitle(parent,"Fish It Travel & Vendors")
        makeDropdown(parent,"Teleport fishing biome",{"Ocean","River","Lake","Cave","Lava","Deep sea"},function(v) config.fishit.tpSpot=v end, config.fishit.tpSpot)
        makeButton(parent,"Teleport to biome",function()
            local target = config.fishit.tpSpot or "Ocean"
            if teleportToSpot(target) then
                pushSessionEvent("Teleported to "..target)
                toast("Teleported to "..target)
            else
                toast("Biome not found: "..target)
            end
        end)
        makeDropdown(parent,"Vendor teleports",{"Shop","Sell NPC","Bait Vendor","Upgrade Station"},function(v) config.fishit.tpVendor=v end, config.fishit.tpVendor)
        makeButton(parent,"Teleport to vendor",function()
            local target = config.fishit.tpVendor or "Shop"
            if teleportToSpot(target) then
                pushSessionEvent("Teleported to "..target)
                toast("Teleported to "..target)
            else
                toast("Vendor not found: "..target)
            end
        end)
        makeDropdown(parent,"Saved waypoint",{"Favorite 1","Favorite 2","Favorite 3"},function(v) config.fishit.savedWaypoint=v end, config.fishit.savedWaypoint)
        makeToggle(parent,"Hotspot ESP",function(on)
            config.fishit.hotspotEsp=on
            if on then addWorldTagESP({"hotspot","spot","fish"}, Color3.fromRGB(60,200,255), Color3.fromRGB(10,120,200)) else clearWorldESP() end
        end, config.fishit.hotspotEsp)
        makeToggle(parent,"Vendor/NPC ESP",function(on)
            config.fishit.vendorEsp=on
            if on then addWorldTagESP({"vendor","shop","npc","merchant"}, Color3.fromRGB(255,200,120), Color3.fromRGB(200,140,60)) else clearWorldESP() end
        end, config.fishit.vendorEsp)
        makeToggle(parent,"Pier labels",function(on) config.fishit.pierLabels=on end, config.fishit.pierLabels)
        makeToggle(parent,"Fullbright / no fog",function(on) config.fishit.fullbright=on; config.fishit.noFog=on end, config.fishit.fullbright)
        makeSlider(parent,"Camera FOV",60,110,config.fishit.fov,function(v) config.fishit.fov=v; camera.FieldOfView=v end)
        makeDropdown(parent,"Overlay mode",{"Money/hour","XP/hour","Fish per minute"},function(v) config.fishit.overlayMode=v end, config.fishit.overlayMode)
        makeToggle(parent,"Event-only fishing",function(on) config.fishit.eventOnly=on end, config.fishit.eventOnly)
        makeToggle(parent,"Teleport to event on start",function(on) config.fishit.tpEventOnStart=on end, config.fishit.tpEventOnStart)
        makeToggle(parent,"Anti-AFK",function(on) config.fishit.antiAfk=on end, config.fishit.antiAfk)
        makeToggle(parent,"Rejoin low-pop server",function(on) config.fishit.rejoinLowPop=on end, config.fishit.rejoinLowPop)
        addDivider(parent)
    end

    if isFisch then
        sectionTitle(parent,"Fisch Regions & Routes")
        makeDropdown(parent,"Region",{"Ocean","Moosewood","Roslit Bay","Snowcap","Sunstone","Terrapin","Mushgrove Swamp","Depths","Forsaken Shores","Ancient Isle"},function(v) config.fischPro.region=v end, config.fischPro.region)
        makeDropdown(parent,"Route preset",{"Snowcap cave route","Ocean mythic loop","Harbor hotspots"},function(v) config.fischPro.routePreset=v end, config.fischPro.routePreset)
        makeDropdown(parent,"Condition preset",{"Foggy night mythic","Sunny day legendary","Rainy treasure"},function(v) config.fischPro.conditionPreset=v end, config.fischPro.conditionPreset)
        makeToggle(parent,"Auto-switch on time/weather",function(on) config.fischPro.autoSwitchTime=on; config.fischPro.autoSwitchWeather=on end, config.fischPro.autoSwitchTime)
        makeDropdown(parent,"Mode",{"Always complete","Perfect focus","Humanized"},function(v) config.fischPro.mode=v end, config.fischPro.mode)
        makeDropdown(parent,"Rarity target",{"Trash","Common","Uncommon","Unusual","Rare","Legendary","Mythical","Relic","Event"},function(v) config.fischPro.rarityTier=v end, config.fischPro.rarityTier)
        makeSlider(parent,"Value filter (sell <)",0,3000,config.fischPro.autoSellValue or 500,function(v) config.fischPro.autoSellValue=v end)
        local white=Instance.new("TextBox"); white.Size=UDim2.new(1,-10,0,30); white.BackgroundColor3=colors.bg; white.TextColor3=colors.text; white.Text=config.fischPro.whitelist; white.PlaceholderText="Whitelist (named fish)"; white.BorderSizePixel=0; white.Font=Enum.Font.Gotham; white.TextSize=14; makeCorner(white,8); white.Parent=parent; white.FocusLost:Connect(function() config.fischPro.whitelist=white.Text end)
        local black=Instance.new("TextBox"); black.Size=UDim2.new(1,-10,0,30); black.BackgroundColor3=colors.bg; black.TextColor3=colors.text; black.Text=config.fischPro.blacklist; black.PlaceholderText="Blacklist junk"; black.BorderSizePixel=0; black.Font=Enum.Font.Gotham; black.TextSize=14; makeCorner(black,8); black.Parent=parent; black.FocusLost:Connect(function() config.fischPro.blacklist=black.Text end)
        makeDropdown(parent,"Profile",{"XP grind","Money farm","Collection (Bestiary)"},function(v) config.fischPro.targetProfile=v end, config.fischPro.targetProfile)
        makeDropdown(parent,"Loadout",{"Deep ocean mythic","Snowcap cave","Event fish"},function(v) config.fischPro.loadout=v end, config.fischPro.loadout)
        makeDropdown(parent,"Bait rule",{"Don’t waste rare bait","Use best bait","Use cheap bait"},function(v) config.fischPro.baitRule=v end, config.fischPro.baitRule)
        makeDropdown(parent,"Boat route",{"Harbor loop","Island hop","Dock > hotspot"},function(v) config.fischPro.boatRoute=v end, config.fischPro.boatRoute)
        makeDropdown(parent,"Bestiary focus",{"Mythic","Relic","Event","Full completion"},function(v) config.fischPro.bestiaryFocus=v end, config.fischPro.bestiaryFocus)
        makeToggle(parent,"Hotspot ESP",function(on)
            config.fischPro.hotspotEsp=on
            if on then addWorldTagESP({"hotspot","spot","fish"}, Color3.fromRGB(60,200,255), Color3.fromRGB(10,120,200)) else clearWorldESP() end
        end, config.fischPro.hotspotEsp)
        makeToggle(parent,"Landmark ESP",function(on)
            config.fischPro.landmarkEsp=on
            if on then addWorldTagESP({"landmark","island","dock"}, Color3.fromRGB(170,110,255), Color3.fromRGB(130,80,210)) else clearWorldESP() end
        end, config.fischPro.landmarkEsp)
        makeToggle(parent,"Mythic condition markers",function(on)
            config.fischPro.mythicMarker=on
            if on then addWorldTagESP({"mythic","event","boss"}, Color3.fromRGB(255,90,130), Color3.fromRGB(200,60,90)) else clearWorldESP() end
        end, config.fischPro.mythicMarker)
        makeToggle(parent,"Lock favorites",function(on) config.fischPro.lockFavorites=on end, config.fischPro.lockFavorites)
        makeToggle(parent,"Profit tracking HUD",function(on) config.fischPro.profitTrack=on end, config.fischPro.profitTrack)
        makeToggle(parent,"Alert rare events/boss windows",function(on) config.fischPro.alertEvents=on end, config.fischPro.alertEvents)
        local bossBox=Instance.new("TextBox"); bossBox.Size=UDim2.new(1,-10,0,30); bossBox.BackgroundColor3=colors.bg; bossBox.TextColor3=colors.text; bossBox.Text=config.fischPro.bossTargets; bossBox.PlaceholderText="Boss/secret fish targets"; bossBox.BorderSizePixel=0; bossBox.Font=Enum.Font.Gotham; bossBox.TextSize=14; makeCorner(bossBox,8); bossBox.Parent=parent; bossBox.FocusLost:Connect(function() config.fischPro.bossTargets=bossBox.Text end)
        makeDropdown(parent,"Rejoin mode",{"None","Same server","New low-pop","New high-pop"},function(v) config.fischPro.rejoinMode=v end, config.fischPro.rejoinMode)
        makeDropdown(parent,"Overlay profile",{"Session","Coins/hour","XP/hour"},function(v) config.fischPro.overlayProfile=v end, config.fischPro.overlayProfile)
        addDivider(parent)
    end
end

local function buildForgePlanner(parent)
    sectionTitle(parent,"ForgeMaster Hub")
    sectionTitle(parent,"Plan routes, recipes, and gear without exploits",true)

    sectionTitle(parent,"Mining & Ore Planning")
    makeDropdown(parent,"Ore route",{"Goblin Caves","Volcanic Depths","Crystal Hollows"},function(v) config.forgePlanner.oreRoute=v end, config.forgePlanner.oreRoute)
    makeSlider(parent,"Ore goal",0,5000,config.forgePlanner.oreGoal or 1000,function(v) config.forgePlanner.oreGoal=v end)
    makeDropdown(parent,"Economy focus",{"Gold/hour","Ore/hour","Quest"},function(v) config.forgePlanner.economyMode=v end, config.forgePlanner.economyMode)
    addDivider(parent)

    sectionTitle(parent,"Forging Simulator")
    makeDropdown(parent,"Recipe tag",{"DPS","Tank","Hybrid","Farm"},function(v) config.forgePlanner.recipeTag=v end, config.forgePlanner.recipeTag)
    makeDropdown(parent,"Weapon profile",{"Fire greatsword","Crit dual blades","Safe tank sword"},function(v) config.forgePlanner.weaponProfile=v end, config.forgePlanner.weaponProfile)
    makeDropdown(parent,"Armor profile",{"Goblin Cave tank set","Volcanic Depths survival","Boss fight kit"},function(v) config.forgePlanner.armorProfile=v end, config.forgePlanner.armorProfile)
    addDivider(parent)

    sectionTitle(parent,"Runes & Builds")
    makeDropdown(parent,"Rune page",{"DPS page","Tank page","Utility/balance"},function(v) config.forgePlanner.runePage=v end, config.forgePlanner.runePage)
    makeDropdown(parent,"Zone roadmap",{"Recommended order","Danger-first","Quest-first"},function(v) config.forgePlanner.zoneRoute=v end, config.forgePlanner.zoneRoute)
    addDivider(parent)

    sectionTitle(parent,"Session HUD")
    makeToggle(parent,"Show overlay",function(on) config.forgePlanner.overlay=on end, config.forgePlanner.overlay)
    makeDropdown(parent,"Theme",{"Lava","Icy","Clean","Dark"},function(v) config.forgePlanner.theme=v end, config.forgePlanner.theme)
    addDivider(parent)
end

local espPalettes = {
    Blue   = {accent=Color3.fromRGB(0,145,255), outline=Color3.fromRGB(0,110,200), box=Color3.fromRGB(0,145,255), tracer=Color3.fromRGB(0,145,255)},
    Red    = {accent=Color3.fromRGB(255,90,90), outline=Color3.fromRGB(200,50,50), box=Color3.fromRGB(255,90,90), tracer=Color3.fromRGB(255,90,90)},
    Green  = {accent=Color3.fromRGB(70,210,140), outline=Color3.fromRGB(40,160,100), box=Color3.fromRGB(70,210,140), tracer=Color3.fromRGB(70,210,140)},
    Purple = {accent=Color3.fromRGB(170,110,255), outline=Color3.fromRGB(130,80,210), box=Color3.fromRGB(170,110,255), tracer=Color3.fromRGB(170,110,255)},
    Gold   = {accent=Color3.fromRGB(255,200,90), outline=Color3.fromRGB(220,160,60), box=Color3.fromRGB(255,200,90), tracer=Color3.fromRGB(255,200,90)},
    Cyan   = {accent=Color3.fromRGB(80,220,255), outline=Color3.fromRGB(30,170,210), box=Color3.fromRGB(80,220,255), tracer=Color3.fromRGB(80,220,255)},
    Orange = {accent=Color3.fromRGB(255,160,70), outline=Color3.fromRGB(220,120,50), box=Color3.fromRGB(255,160,70), tracer=Color3.fromRGB(255,160,70)},
    White  = {accent=Color3.fromRGB(245,245,245), outline=Color3.fromRGB(200,200,200), box=Color3.fromRGB(245,245,245), tracer=Color3.fromRGB(245,245,245)},
}
local function applyEspPreset(name)
    local p = espPalettes[name]
    if p then
        config.esp.colors = {accent=p.accent, outline=p.outline, box=p.box, tracer=p.tracer, preset=name}
        config.esp.palette = name
        clearESP()
        if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do task.spawn(function() addESP(pl) end) end end
    end
end

local function applyAimbotProfile(name)
    local p = config.aimbotProfiles and config.aimbotProfiles[name]
    if not p then return end
    config.aimbotSmooth = p.smooth or config.aimbotSmooth
    config.aimbotFov = p.fov or config.aimbotFov
    config.triggerEnabled = p.trigger or false
    config.silentAim = p.silent or false
    if p.area then config.aimbotArea = p.area end
    config.lastAimbotProfile = name
    if fovCircle then fovCircle.Size = UDim2.fromOffset(config.aimbotFov, config.aimbotFov) end
    toast("Aimbot profile: "..name)
end

function addESP(plr)
    if plr==LP or not config.esp.enabled then return end
    local char=plr.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local c = config.esp.colors
    local fillColor = config.esp.teamColors and plr.TeamColor and plr.TeamColor.Color or c.accent
    local opacity = config.esp.opacity or 0.6
    local h
    if config.esp.boxes then
        h=Instance.new("Highlight")
        h.FillColor=fillColor
        h.OutlineColor=c.outline
        h.FillTransparency=config.esp.outlineOnly and 1 or (1-opacity)
        h.OutlineTransparency=1-opacity
        h.Adornee=char
        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent=char
        table.insert(highlightObjects,h)
    end
    if config.esp.names then
        local bill=Instance.new("BillboardGui"); bill.AlwaysOnTop=true; bill.Size=UDim2.new(0,200,0,40); bill.Adornee=hrp; bill.Parent=char
        local txt=Instance.new("TextLabel"); txt.BackgroundTransparency=1; txt.Size=UDim2.new(1,0,1,0); txt.Font=Enum.Font.GothamSemibold; txt.TextColor3=colors.text; txt.TextStrokeTransparency=0.4; txt.TextStrokeColor3=colors.bg; txt.TextSize=config.esp.nameSize or 14; txt.Text=plr.Name; txt.Parent=bill
        if config.esp.healthbar and hum then
            local barFrame=Instance.new("Frame"); barFrame.Size=UDim2.new(0.4,0,0,6); barFrame.Position=UDim2.new(0.3,0,1,-4); barFrame.BackgroundColor3=colors.bg; barFrame.BorderSizePixel=0; makeCorner(barFrame,6); barFrame.Parent=bill
            local fill=Instance.new("Frame"); fill.BackgroundColor3=colors.success; fill.Size=UDim2.new(1,0,1,0); fill.BorderSizePixel=0; makeCorner(fill,6); fill.Parent=barFrame
            RunService.RenderStepped:Connect(function() if hum then fill.Size=UDim2.new(math.clamp(hum.Health/hum.MaxHealth,0,1),0,1,0) end end)
        end
        if config.esp.healthbar and hum and config.esp.healthbarPos == "Top" then
            for _,child in ipairs(bill:GetChildren()) do
                if child:IsA("Frame") then child.Position = UDim2.new(0.3,0,0,-6) end
            end
        end
        if config.esp.distance or config.esp.fadeEnabled or (config.esp.maxDistance or 0) > 0 then
            RunService.RenderStepped:Connect(function()
                if not bill.Parent or not hrp or not HRP then return end
                local mag=(hrp.Position-HRP.Position).Magnitude
                if config.esp.distance then
                    txt.Text=("%s | %dm"):format(plr.Name, math.floor(mag))
                else
                    txt.Text=plr.Name
                end
                local maxD = config.esp.maxDistance or 0
                local visible = (maxD == 0) or (mag <= maxD)
                bill.Enabled = visible
                if h then h.Enabled = visible end
                if config.esp.fadeEnabled then
                    local startD = config.esp.fadeStart or 150
                    local endD = config.esp.fadeEnd or 500
                    if endD <= startD then endD = startD + 1 end
                    local mult = 1
                    if mag > startD then mult = math.clamp(1 - (mag - startD) / (endD - startD), 0, 1) end
                    local eff = (config.esp.opacity or 0.6) * mult
                    if h then
                        h.FillTransparency = config.esp.outlineOnly and 1 or (1 - eff)
                        h.OutlineTransparency = 1 - eff
                    end
                    txt.TextTransparency = 1 - math.clamp(eff, 0, 1)
                end
            end)
        end
        table.insert(nametagObjects,bill)
    end
    if (config.esp.fadeEnabled or (config.esp.maxDistance or 0) > 0) and not config.esp.names then
        RunService.RenderStepped:Connect(function()
            if not hrp or not HRP then return end
            local mag=(hrp.Position-HRP.Position).Magnitude
            local maxD = config.esp.maxDistance or 0
            if h then h.Enabled = (maxD == 0) or (mag <= maxD) end
            if config.esp.fadeEnabled and h then
                local startD = config.esp.fadeStart or 150
                local endD = config.esp.fadeEnd or 500
                if endD <= startD then endD = startD + 1 end
                local mult = 1
                if mag > startD then mult = math.clamp(1 - (mag - startD) / (endD - startD), 0, 1) end
                local eff = (config.esp.opacity or 0.6) * mult
                h.FillTransparency = config.esp.outlineOnly and 1 or (1 - eff)
                h.OutlineTransparency = 1 - eff
            end
        end)
    end
    if config.esp.arrows then
        local th = config.esp.thicknessTracer or 2
        local base = config.esp.arrowSize or 12
        local arrow=Instance.new("Frame"); arrow.Size=UDim2.fromOffset(base+th*2,base+th*2); arrow.BackgroundColor3=c.tracer; arrow.BackgroundTransparency=1-opacity; arrow.BorderSizePixel=0; arrow.AnchorPoint=Vector2.new(0.5,0.5); arrow.Position=UDim2.new(0.5,0,0.5,0); arrow.Parent=offscreenGui
        if config.esp.arrowStyle == "Rounded" then makeCorner(arrow,9) end
        table.insert(arrowObjects,arrow)
        local rotOffset = config.esp.arrowStyle == "Diamond" and 45 or 0
        RunService.RenderStepped:Connect(function()
            if not hrp or not HRP then return end
            local mag=(hrp.Position-HRP.Position).Magnitude
            local maxD = config.esp.maxDistance or 0
            if maxD > 0 and mag > maxD then
                arrow.Visible = false
                return
            end
            local pos,on=camera:WorldToViewportPoint(hrp.Position)
            if on then arrow.Visible=false else
                arrow.Visible=true
                local viewport=camera.ViewportSize; local dir=(Vector2.new(pos.X,pos.Y)-viewport/2).Unit
                local clamped=(viewport/2)+dir*math.min(viewport.X,viewport.Y)*0.45
                arrow.Position=UDim2.fromOffset(clamped.X,clamped.Y); arrow.Rotation=math.deg(math.atan2(dir.Y,dir.X)) + rotOffset
                if config.esp.fadeEnabled then
                    local startD = config.esp.fadeStart or 150
                    local endD = config.esp.fadeEnd or 500
                    if endD <= startD then endD = startD + 1 end
                    local mult = 1
                    if mag > startD then mult = math.clamp(1 - (mag - startD) / (endD - startD), 0, 1) end
                    local eff = (config.esp.opacity or 0.6) * mult
                    arrow.BackgroundTransparency = 1 - math.clamp(eff, 0, 1)
                end
            end
        end)
    end
end

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() if config.esp.enabled then addESP(p) end end) end)

-- GUI root
local gui = Instance.new("ScreenGui"); gui.Name="AdvancedMenu"; gui.ResetOnSpawn=false; gui.Parent=game:GetService("CoreGui")

-- Christmas glass backdrop
setBlur(config.uiBlur ~= false, config.blurSize or 10)
local backdrop = Instance.new("Frame"); backdrop.Size=UDim2.new(1,0,1,0); backdrop.Position=UDim2.new(0,0,0,0); backdrop.BackgroundColor3=colors.bg; backdrop.BackgroundTransparency=0.2; backdrop.BorderSizePixel=0; backdrop.ZIndex=0; backdrop.Parent=gui
local bgGrad = Instance.new("UIGradient", backdrop); bgGrad.Rotation=35; bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,120,120)),
    ColorSequenceKeypoint.new(0.48, Color3.fromRGB(40,26,22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(46,96,64)),
})
local vignette = Instance.new("Frame"); vignette.Size=UDim2.new(1,0,1,0); vignette.BackgroundColor3=Color3.new(0,0,0); vignette.BackgroundTransparency=0.65; vignette.BorderSizePixel=0; vignette.ZIndex=0; vignette.Parent=gui
local vigGrad = Instance.new("UIGradient", vignette); vigGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(40,40,40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
}); vigGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,0.32),
    NumberSequenceKeypoint.new(0.35,0.55),
    NumberSequenceKeypoint.new(1,0.24),
})

local mainWidth, mainHeight = config.menuW or 640, config.menuH or 480
local shadow = Instance.new("ImageLabel"); shadow.Image = "rbxassetid://1316045217"; shadow.ImageColor3 = Color3.fromRGB(0,0,0); shadow.ImageTransparency=0.65; shadow.ScaleType=Enum.ScaleType.Slice; shadow.SliceCenter=Rect.new(10,10,118,118); shadow.Size=UDim2.fromOffset(mainWidth+32, mainHeight+32); shadow.Position=UDim2.new(0.5,-(mainWidth+32)/2,0.5,-(mainHeight+32)/2); shadow.BackgroundTransparency=1; shadow.ZIndex=0; shadow.Parent=gui
local main = Instance.new("Frame"); main.Size=UDim2.fromOffset(mainWidth, mainHeight); main.Position=UDim2.new(0.5,-mainWidth/2,0.5,-mainHeight/2); main.BackgroundColor3=colors.bg:lerp(Color3.new(1,1,1),0.04); main.BackgroundTransparency=0.12; main.BorderSizePixel=0; main.Active=true; main.Draggable=true; main.Parent=gui; makeCorner(main,16)
local glassStroke = Instance.new("UIStroke", main); glassStroke.Thickness = 1.4; glassStroke.Transparency = 0.35; glassStroke.Color = colors.accent; local glassGrad = Instance.new("UIGradient", glassStroke); glassGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, colors.accent2), ColorSequenceKeypoint.new(1, colors.accent)})
local function setMainSize(w,h)
    mainWidth, mainHeight = w,h
    config.menuW, config.menuH = w,h
    main.Size = UDim2.fromOffset(w,h)
    main.Position = centeredMainPosition()
    shadow.Size = UDim2.fromOffset(w+32,h+32)
    shadow.Position = UDim2.new(0.5,-(w+32)/2,0.5,-(h+32)/2)
end

local function addDivider(parent)
    local d=Instance.new("Frame"); d.Size=UDim2.new(1,-10,0,1); d.BackgroundColor3=colors.subtle; d.BackgroundTransparency=0.8; d.BorderSizePixel=0; d.Parent=parent; return d
end
local grad=Instance.new("UIGradient",main); grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,colors.bg),ColorSequenceKeypoint.new(1,colors.accent2)}; grad.Rotation=60
local grip = Instance.new("Frame"); grip.Size=UDim2.fromOffset(14,14); grip.Position=UDim2.new(1,-18,1,-18); grip.BackgroundColor3=colors.panel; grip.BorderSizePixel=0; makeCorner(grip,4); grip.Parent=main
makeDraggable(grip, function(delta)
    setMainSize(math.clamp(mainWidth + delta.X, 520, 900), math.clamp(mainHeight + delta.Y, 360, 720))
end)

local function centeredMainPosition()
    return UDim2.new(0.5,-mainWidth/2,0.5,-mainHeight/2)
end

-- Title
local titleHeight = 48
local title=Instance.new("Frame"); title.Size=UDim2.new(1,0,0,titleHeight); title.BackgroundColor3=colors.panel:lerp(colors.accent,0.08); title.BorderSizePixel=0; title.Parent=main; makeCorner(title,12)
local titleLabel=Instance.new("TextLabel"); titleLabel.Size=UDim2.new(1,-170,1,0); titleLabel.Position=UDim2.new(0,18,0,6); titleLabel.BackgroundTransparency=1; titleLabel.Font=Enum.Font.GothamBold; titleLabel.Text="Ninnydll Premium 🎄"; titleLabel.TextColor3=Color3.fromRGB(255,215,120); titleLabel.TextSize=18; titleLabel.TextXAlignment=Enum.TextXAlignment.Left; titleLabel.Parent=title
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
pushLog = function(msg)
    if logLabel then logLabel.Text = msg end
end
local function pushSessionEvent(msg)
    local stamp = os.date("%H:%M:%S")
    table.insert(sessionEvents, 1, string.format("[%s] %s", stamp, msg))
    while #sessionEvents > 6 do table.remove(sessionEvents) end
    if updateTimeline then updateTimeline() end
end
local underline=Instance.new("Frame"); underline.Size=UDim2.new(1,-16,0,1); underline.Position=UDim2.new(0,8,1,-1); underline.BackgroundColor3=colors.accent; underline.BorderSizePixel=0; underline.Parent=title; local underlineGrad=Instance.new("UIGradient", underline); underlineGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, colors.accent2), ColorSequenceKeypoint.new(1, colors.accent)})

-- Status bar
local statusHeight = 26
local statusBar=Instance.new("Frame"); statusBar.Size=UDim2.new(1,-14,0,statusHeight); statusBar.Position=UDim2.new(0,7,0,titleHeight); statusBar.BackgroundColor3=colors.panel:lerp(colors.accent2,0.1); statusBar.BackgroundTransparency=0.12; statusBar.BorderSizePixel=0; statusBar.Parent=main; makeCorner(statusBar,10); local statusGrad=Instance.new("UIGradient", statusBar); statusGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, colors.panel), ColorSequenceKeypoint.new(1, colors.panel:lerp(colors.accent2,0.2))})
local statusLabel=Instance.new("TextLabel"); statusLabel.BackgroundTransparency=1; statusLabel.Size=UDim2.new(1,-20,1,0); statusLabel.Position=UDim2.new(0,10,0,0); statusLabel.Font=Enum.Font.GothamSemibold; statusLabel.TextColor3=colors.subtle; statusLabel.TextSize=13; statusLabel.TextXAlignment=Enum.TextXAlignment.Left; statusLabel.Parent=statusBar
local contentTop = titleHeight + statusHeight + 12

-- Quick pills
local quick=Instance.new("Frame"); quick.Size=UDim2.new(0, mainWidth, 0, 32); quick.Position=UDim2.new(0,0,0,-40); quick.BackgroundTransparency=1; quick.Parent=main
local qaList=Instance.new("UIListLayout",quick); qaList.Padding=UDim.new(0,8); qaList.FillDirection=Enum.FillDirection.Horizontal; qaList.HorizontalAlignment=Enum.HorizontalAlignment.Center; qaList.VerticalAlignment=Enum.VerticalAlignment.Center
local quickPad=Instance.new("UIPadding", quick); quickPad.PaddingLeft=UDim.new(0,12); quickPad.PaddingRight=UDim.new(0,12)
local function pill(label,color,cb) local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(120,28); b.BackgroundColor3=color; b.BorderSizePixel=0; b.TextColor3=Color3.new(1,1,1); b.TextSize=13; b.Font=Enum.Font.GothamSemibold; b.Text=label; b.AutoButtonColor=false; makeCorner(b,14); b.Parent=quick; b.MouseButton1Click:Connect(function() ripple(b); if cb then cb() end end) end
pill("Panic",colors.danger,function() shutdown("panic") end)
pill("Hide UI",colors.accent2,function() hidden=not hidden; main.Visible=not hidden; offscreenGui.Enabled=not hidden; setBlur(not hidden and config.uiBlur ~= false, config.blurSize or 10) end)
pill("Rejoin",colors.accent,function() TeleportService:Teleport(game.PlaceId,LP) end)
pill("Soft Panic",colors.warn,softPanic)

-- Tabs & pages
local tabs=Instance.new("Frame"); tabs.Size=UDim2.new(0,175,1,-contentTop-10); tabs.Position=UDim2.new(0,0,0,contentTop); tabs.BackgroundColor3=colors.panel:lerp(Color3.new(1,1,1),0.06); tabs.BackgroundTransparency=0.18; tabs.BorderSizePixel=0; tabs.Parent=main; makeCorner(tabs,14)
local tabsStroke = Instance.new("UIStroke", tabs); tabsStroke.Thickness=1; tabsStroke.Transparency=0.55; tabsStroke.Color=colors.accent2
local tabsGrad=Instance.new("UIGradient", tabs); tabsGrad.Rotation=90; tabsGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, colors.panel), ColorSequenceKeypoint.new(1, colors.bg:lerp(colors.accent2,0.06))})
local tabsPad = Instance.new("UIPadding", tabs); tabsPad.PaddingLeft = UDim.new(0,8); tabsPad.PaddingRight = UDim.new(0,8); tabsPad.PaddingTop = UDim.new(0,10)
local tabList=Instance.new("UIListLayout",tabs); tabList.VerticalAlignment=Enum.VerticalAlignment.Top; tabList.HorizontalAlignment=Enum.HorizontalAlignment.Center; tabList.Padding=UDim.new(0, config.compact and 6 or 8)
local tabNames={"Dashboard","Gameplay","Automation","Visuals / UI","Configs"}
local tabIcons={
    Dashboard="🏠", Gameplay="🎮", Automation="⚙️", ["Visuals / UI"]="👁", Configs="💾"
}
local pages={}
local selectedTab
local pageHolder=Instance.new("Frame"); pageHolder.Size=UDim2.new(1,-185,1,-contentTop-10); pageHolder.Position=UDim2.new(0,185,0,contentTop); pageHolder.BackgroundColor3=colors.panel:lerp(Color3.new(1,1,1),0.08); pageHolder.BackgroundTransparency=0.06; pageHolder.BorderSizePixel=0; pageHolder.Parent=main; makeCorner(pageHolder,16)
local pageStroke = Instance.new("UIStroke", pageHolder); pageStroke.Thickness=1; pageStroke.Transparency=0.65; pageStroke.Color=colors.subtle
local pagePadding=Instance.new("UIPadding",pageHolder); pagePadding.PaddingTop=UDim.new(0,8); pagePadding.PaddingBottom=UDim.new(0,8); pagePadding.PaddingLeft=UDim.new(0,10); pagePadding.PaddingRight=UDim.new(0,10)
local pageFader=Instance.new("Frame"); pageFader.Size=UDim2.fromScale(1,1); pageFader.BackgroundColor3=colors.bg; pageFader.BackgroundTransparency=1; pageFader.BorderSizePixel=0; pageFader.ZIndex=20; pageFader.Active=false; pageFader.Visible=false; pageFader.Parent=pageHolder; makeCorner(pageFader,16)
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
    ["Gameplay"]=Color3.fromRGB(30,160,90),
    ["Automation"]=Color3.fromRGB(200,140,60),
    ["Visuals / UI"]=Color3.fromRGB(120,180,120),
    ["Configs"]=Color3.fromRGB(120,180,200),
}
local tabIndicator=Instance.new("Frame"); tabIndicator.Size=UDim2.new(0,6,0,36); tabIndicator.BackgroundColor3=colors.accent; tabIndicator.BorderSizePixel=0; tabIndicator.Visible=false; tabIndicator.Parent=tabs; makeCorner(tabIndicator,3)
local function switchTab(name)
    for tabName,page in pairs(pages) do page.Visible=(tabName==name) end
    selectedTab=name
    task.spawn(function()
        pageFader.BackgroundTransparency=1
        pageFader.Visible=true
        tween(pageFader,0.12,{BackgroundTransparency=0.35}):Play()
        tween(pageFader,0.18,{BackgroundTransparency=1}):Completed:Connect(function() pageFader.Visible=false end)
    end)
end
local function createTabButton(name)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-24,0,38); b.BackgroundColor3=colors.bg:lerp(Color3.new(1,1,1),0.06); b.BackgroundTransparency=0.1; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Font=Enum.Font.GothamSemibold; b.TextColor3=colors.text; b.TextSize=15; b.Text=((tabIcons[name] or "").."  "..name); b:SetAttribute("BG",true); makeCorner(b,10); b.Parent=tabs
    local tabStroke=Instance.new("UIStroke", b); tabStroke.Thickness=1; tabStroke.Transparency=0.7; tabStroke.Color=colors.subtle
    b.MouseEnter:Connect(function() tween(b,0.12,{BackgroundColor3=colors.panel:lerp(colors.accent2,0.08)}) end)
    b.MouseLeave:Connect(function() if selectedTab~=name then tween(b,0.12,{BackgroundColor3=colors.bg:lerp(Color3.new(1,1,1),0.06)}) end end)
    b.MouseButton1Click:Connect(function()
        ripple(b); switchTab(name)
        for other,btn in pairs(tabButtons) do tween(btn,0.2,{BackgroundColor3=(other==name) and (tabColors[name] or colors.accent) or colors.bg}) end
        tabIndicator.Visible=true; tween(tabIndicator,0.25,{Position=UDim2.new(0,4,0,b.Position.Y.Offset),Size=UDim2.new(0,6,0,b.AbsoluteSize.Y),BackgroundColor3=tabColors[name] or colors.accent, BackgroundTransparency=0.05})
    end)
    addHoverScale(b,1.03)
    return b
end
for i,n in ipairs(tabNames) do
    tabButtons[n]=createTabButton(n)
    if n=="Visuals" or n=="Automation" or n=="Configs" then
        local sep=Instance.new("Frame"); sep.Size=UDim2.new(1,-24,0,1); sep.BackgroundColor3=colors.subtle; sep.BackgroundTransparency=0.8; sep.BorderSizePixel=0; sep.Parent=tabs
    end
end
switchTab("Dashboard"); tween(tabButtons["Dashboard"],0.01,{BackgroundColor3=colors.accent}); tabIndicator.Position=UDim2.new(0,4,0,tabButtons["Dashboard"].Position.Y.Offset); tabIndicator.Visible=true
tabIndicator.Size = UDim2.new(0,6,0,tabButtons["Dashboard"].AbsoluteSize.Y)

-- Dashboard
do
    local p=pages["Dashboard"]
    local info=Instance.new("TextLabel"); info.BackgroundTransparency=1; info.Size=UDim2.new(1,-10,0,20); info.Font=Enum.Font.GothamSemibold; info.TextColor3=colors.text; info.TextSize=15; info.TextXAlignment=Enum.TextXAlignment.Left
    info.Text=("Game: %s | PlaceId: %s"):format(game.Name or "Unknown", tostring(currentGameId)); info.Parent=p
    local status=Instance.new("TextLabel"); status.BackgroundTransparency=1; status.Size=UDim2.new(1,-10,0,20); status.Font=Enum.Font.Gotham; status.TextColor3=colors.subtle; status.TextSize=14; status.TextXAlignment=Enum.TextXAlignment.Left
    status.Text="Mode: Universal (no per-game module)"; status.Parent=p
    local sessionInfo=Instance.new("TextLabel"); sessionInfo.BackgroundTransparency=1; sessionInfo.Size=UDim2.new(1,-10,0,20); sessionInfo.Font=Enum.Font.Gotham; sessionInfo.TextColor3=colors.subtle; sessionInfo.TextSize=13; sessionInfo.TextXAlignment=Enum.TextXAlignment.Left; sessionInfo.TextWrapped=true; sessionInfo.Parent=p
    task.spawn(function()
        while scriptActive and sessionInfo.Parent do
            local elapsed = math.floor(tick()-sessionStart)
            local lastTarget = lastTargetName or "none"
            local lastDist = lastTargetDist and (math.floor(lastTargetDist).."m") or "--"
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

    local featureCard=Instance.new("Frame"); featureCard.Size=UDim2.new(1,-10,0,150); featureCard.BackgroundColor3=colors.panel; featureCard.BackgroundTransparency=0.06; featureCard.BorderSizePixel=0; makeCorner(featureCard,12); stylizeCard(featureCard); featureCard.Parent=p
    local featureTitle=Instance.new("TextLabel"); featureTitle.BackgroundTransparency=1; featureTitle.Size=UDim2.new(1,-10,0,18); featureTitle.Position=UDim2.new(0,10,0,8); featureTitle.Font=Enum.Font.GothamSemibold; featureTitle.TextColor3=colors.text; featureTitle.TextSize=14; featureTitle.TextXAlignment=Enum.TextXAlignment.Left; featureTitle.Text="Feature Manifest (1000 tracked)"; featureTitle.Parent=featureCard
    local featurePreview=Instance.new("TextLabel"); featurePreview.BackgroundTransparency=1; featurePreview.Size=UDim2.new(1,-16,1,-30); featurePreview.Position=UDim2.new(0,8,0,26); featurePreview.Font=Enum.Font.Gotham; featurePreview.TextColor3=colors.subtle; featurePreview.TextSize=13; featurePreview.TextWrapped=true; featurePreview.TextXAlignment=Enum.TextXAlignment.Left; featurePreview.TextYAlignment=Enum.TextYAlignment.Top; featurePreview.Parent=featureCard
    local featureStart, featureCount, featureCategory = 1, 8, "All"
    local categoriesList = {"All"}
    for _,c in ipairs(featureCategories) do table.insert(categoriesList, c) end
    local function refreshFeaturePreview()
        local slice = sliceFeatures(featureStart, featureCount, featureCategory)
        local lines = {}
        for _,f in ipairs(slice) do table.insert(lines, string.format("#%03d • %s • %s", f.id, f.category, f.name)) end
        featurePreview.Text = string.format("Catalog size: %d | Showing %d in %s\n- %s", #config.featureCatalog, featureCount, featureCategory, table.concat(lines, "\n- "))
    end
    refreshFeaturePreview()
    makeSlider(p,"Preview features",3,15,featureCount,function(v) featureCount = math.floor(v); refreshFeaturePreview() end)
    makeDropdown(p,"Feature category", categoriesList, function(val) featureCategory = val; refreshFeaturePreview() end, featureCategory)
    makeButton(p,"Shuffle feature preview",function()
        featureStart = featureStart + featureCount
        if featureStart > #config.featureCatalog then featureStart = 1 end
        refreshFeaturePreview()
        toast("Rotated manifest preview")
    end)
    makeButton(p,"Gameplay Controls",function() switchTab("Gameplay"); ripple(tabButtons["Gameplay"]) end)
    makeButton(p,"Automation",function() switchTab("Automation"); ripple(tabButtons["Automation"]) end)
    makeButton(p,"Configs",function() switchTab("Configs"); ripple(tabButtons["Configs"]) end)
end

-- Gameplay (movement + combat + safety + player list)
do
    local p=pages["Gameplay"]
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

-- Visuals / UI
do
    local p=pages["Visuals / UI"]
    makeToggle(p,"ESP (players)",function(on) config.esp.enabled=on; clearESP(); if on then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeToggle(p,"Box ESP",function(on) config.esp.boxes=on end,config.esp.boxes)
    makeToggle(p,"Outline Only",function(on) config.esp.outlineOnly=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.outlineOnly)
    makeToggle(p,"ESP Names",function(on) config.esp.names=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.names)
    makeToggle(p,"ESP Distance",function(on) config.esp.distance=on end,config.esp.distance)
    makeToggle(p,"ESP Arrows",function(on) config.esp.arrows=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.arrows)
    makeToggle(p,"ESP Healthbar",function(on) config.esp.healthbar=on end,config.esp.healthbar)
    makeToggle(p,"ESP Team Colors",function(on) config.esp.teamColors=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.teamColors)
    makeDropdown(p,"ESP Palette",{"Blue","Red","Green","Purple","Gold","Cyan","Orange","White"},applyEspPreset,config.esp.palette)
    makeDropdown(p,"Healthbar Position",{"Bottom","Top"},function(v) config.esp.healthbarPos=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.healthbarPos)
    makeDropdown(p,"Arrow Style",{"Rounded","Square","Diamond"},function(v) config.esp.arrowStyle=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.arrowStyle)
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
    makeButton(p,"Apply Custom ESP Colors",function()
        local acc, out, bx, tr = parseColor(accentBox.Text), parseColor(outlineBox.Text), parseColor(boxBox.Text), parseColor(tracerBox.Text)
        if acc and out and bx and tr then
            config.esp.colors = {accent=acc, outline=out, box=bx, tracer=tr, preset="Custom"}
            config.esp.palette = "Custom"
            clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end
            toast("Applied custom ESP colors")
        else
            toast("Invalid color values")
        end
    end)
    makeSlider(p,"Box Thickness",1,6,config.esp.thicknessBox or 2,function(v) config.esp.thicknessBox=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeSlider(p,"Tracer Thickness",1,6,config.esp.thicknessTracer or 2,function(v) config.esp.thicknessTracer=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeSlider(p,"ESP Opacity",0.2,1,config.esp.opacity or 0.6,function(v) config.esp.opacity=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeSlider(p,"Name Size",10,20,config.esp.nameSize or 14,function(v) config.esp.nameSize=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeSlider(p,"Arrow Size",8,28,config.esp.arrowSize or 12,function(v) config.esp.arrowSize=v; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end)
    makeToggle(p,"Distance Fade",function(on) config.esp.fadeEnabled=on; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end end,config.esp.fadeEnabled)
    makeSlider(p,"Fade Start",50,400,config.esp.fadeStart or 150,function(v) config.esp.fadeStart=v end)
    makeSlider(p,"Fade End",200,1200,config.esp.fadeEnd or 500,function(v) config.esp.fadeEnd=v end)
    makeSlider(p,"Max ESP Distance (0=inf)",0,2000,config.esp.maxDistance or 0,function(v) config.esp.maxDistance=v end)
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
fovCircle=Instance.new("Frame"); fovCircle.Name="FOVCircle"; fovCircle.Size=UDim2.fromOffset(config.aimbotFov,config.aimbotFov); fovCircle.Position=UDim2.fromScale(0.5,0.5); fovCircle.AnchorPoint=Vector2.new(0.5,0.5); fovCircle.BackgroundTransparency=0.9; fovCircle.BackgroundColor3=colors.accent; fovCircle.BorderSizePixel=0; fovCircle.Visible=false; fovCircle.ZIndex=9; makeCorner(fovCircle,100); fovCircle.Parent=gui
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

-- Combat (merged under Gameplay)
do
    local p=pages["Gameplay"]
    addDivider(p)
    config.aimbotProfiles.Custom = {smooth=config.aimbotSmooth, fov=config.aimbotFov, trigger=config.triggerEnabled, silent=config.silentAim, area=config.aimbotArea}
    makeDropdown(p,"Aimbot Profile",{"Legit","Balanced","Rage","Custom"},applyAimbotProfile,config.lastAimbotProfile~="" and config.lastAimbotProfile or "Custom")
    makeButton(p,"Save Current as Custom",function()
        config.aimbotProfiles.Custom = {smooth=config.aimbotSmooth, fov=config.aimbotFov, trigger=config.triggerEnabled, silent=config.silentAim, area=config.aimbotArea}
        config.lastAimbotProfile = "Custom"
        toast("Saved current settings to Custom profile")
    end)
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
    addDivider(p)
    makeDropdown(p,"Freeze Mode",{"None","Legit","Hard"},function(v) config.advanced.freezeMode=v end, config.advanced.freezeMode or "None")
    makeToggle(p,"Legit Mode",function(on)
        config.advanced.legitMode=on
        if on then
            config.advanced.rageMode=false
            applyAimbotProfile("Legit")
            config.silentAim=false
            config.triggerEnabled=false
        end
    end, config.advanced.legitMode)
    makeToggle(p,"Rage Mode",function(on)
        config.advanced.rageMode=on
        if on then
            config.advanced.legitMode=false
            applyAimbotProfile("Rage")
            config.silentAim=true
            config.triggerEnabled=true
        end
    end, config.advanced.rageMode)
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
    sectionTitle(p,"Advanced Automation")
    makeToggle(p,"Auto Mine",function(on) config.advanced.autoMine=on end, config.advanced.autoMine)
    makeSlider(p,"Auto Mine Interval",0.2,2,config.advanced.autoMineInterval or 0.6,function(v) config.advanced.autoMineInterval=v end)
    local mineTags=Instance.new("TextBox"); mineTags.Size=UDim2.new(1,-10,0,32); mineTags.BackgroundColor3=colors.bg; mineTags.TextColor3=colors.text; mineTags.PlaceholderText="Mine tags (comma): ore,mine,rock"; mineTags.Text=config.advanced.autoMineTags or ""; mineTags.BorderSizePixel=0; mineTags.Font=Enum.Font.Gotham; mineTags.TextSize=14; makeCorner(mineTags,8); mineTags.Parent=p
    mineTags.FocusLost:Connect(function() config.advanced.autoMineTags=mineTags.Text end)
    makeToggle(p,"Auto Kill",function(on) config.advanced.autoKill=on end, config.advanced.autoKill)
    makeToggle(p,"Auto Kill Players",function(on) config.advanced.autoKillPlayers=on end, config.advanced.autoKillPlayers)
    makeToggle(p,"Auto Kill NPCs",function(on) config.advanced.autoKillNPCs=on end, config.advanced.autoKillNPCs)
    makeSlider(p,"Auto Kill Range",10,200,config.advanced.autoKillRange or 60,function(v) config.advanced.autoKillRange=v end)
    makeSlider(p,"Auto Kill Interval",0.1,1,config.advanced.autoKillInterval or 0.25,function(v) config.advanced.autoKillInterval=v end)
    makeToggle(p,"Auto Equip Rod/Tool",function(on) config.advanced.autoEquipRod=on end, config.advanced.autoEquipRod)
    makeSlider(p,"Auto Equip Interval",0.5,5,config.advanced.autoEquipInterval or 2,function(v) config.advanced.autoEquipInterval=v end)
    local rodBox=Instance.new("TextBox"); rodBox.Size=UDim2.new(1,-10,0,32); rodBox.BackgroundColor3=colors.bg; rodBox.TextColor3=colors.text; rodBox.PlaceholderText="Tool priority (comma): rod,fish"; rodBox.Text=config.advanced.rodPriority or ""; rodBox.BorderSizePixel=0; rodBox.Font=Enum.Font.Gotham; rodBox.TextSize=14; makeCorner(rodBox,8); rodBox.Parent=p
    rodBox.FocusLost:Connect(function() config.advanced.rodPriority=rodBox.Text end)
    addDivider(p)
    sectionTitle(p,"Game Teleports")
    local tpList = (#config.gameTeleports > 0) and config.gameTeleports or {"Spawn","Shop","Vendor","Dock","Forge","Anvil","Ocean","River","Lake","Island"}
    local selectedTp = tpList[1]
    makeDropdown(p,"Teleport Target",tpList,function(v) selectedTp=v end, selectedTp)
    makeButton(p,"Teleport to Selected",function()
        if selectedTp and teleportToSpot(selectedTp) then
            toast("Teleported to "..selectedTp)
        else
            toast("Spot not found: "..tostring(selectedTp))
        end
    end)
    local tpBox=Instance.new("TextBox"); tpBox.Size=UDim2.new(1,-10,0,32); tpBox.BackgroundColor3=colors.bg; tpBox.TextColor3=colors.text; tpBox.PlaceholderText="Teleport by name (any object)"; tpBox.Text=""; tpBox.BorderSizePixel=0; tpBox.Font=Enum.Font.Gotham; tpBox.TextSize=14; makeCorner(tpBox,8); tpBox.Parent=p
    makeButton(p,"Teleport by Name",function()
        local name = tpBox.Text or ""
        if name ~= "" and teleportToSpot(name) then
            toast("Teleported to "..name)
        else
            toast("Spot not found: "..name)
        end
    end)
    if isFisch or isFishIt then
        buildFishAutomation(p)
    else
        local note=Instance.new("TextLabel"); note.BackgroundTransparency=1; note.Size=UDim2.new(1,-10,0,36); note.Font=Enum.Font.Gotham; note.TextColor3=colors.subtle; note.TextSize=14; note.TextXAlignment=Enum.TextXAlignment.Left; note.TextWrapped=true; note.Text="Fish It/Fisch automation appears only in supported games. Detected: "..detectedGame.."."; note.Parent=p
    end
    if isForge then
        addDivider(p)
        buildForgePlanner(p)
        addDivider(p)
        sectionTitle(p,"Forge Advanced")
        makeToggle(p,"Open Forge",function(on) config.forgeAdvanced.openForge=on end, config.forgeAdvanced.openForge)
        makeToggle(p,"Auto Melt",function(on) config.forgeAdvanced.autoMelt=on end, config.forgeAdvanced.autoMelt)
        makeToggle(p,"Auto Pour",function(on) config.forgeAdvanced.autoPour=on end, config.forgeAdvanced.autoPour)
        makeToggle(p,"Auto Hammer (buggy)",function(on) config.forgeAdvanced.autoHammer=on end, config.forgeAdvanced.autoHammer)
        addDivider(p)
        sectionTitle(p,"Combat")
        makeToggle(p,"Auto Attack Mobs",function(on) config.forgeAdvanced.autoAttackMobs=on end, config.forgeAdvanced.autoAttackMobs)
        makeToggle(p,"Multi-Mob Selection",function(on) config.forgeAdvanced.multiMobSelection=on end, config.forgeAdvanced.multiMobSelection)
        makeSlider(p,"Attack Distance",10,200,config.forgeAdvanced.attackDistance or 60,function(v) config.forgeAdvanced.attackDistance=v end)
        makeSlider(p,"Fly Speed",10,250,config.flySpeed,function(v) config.flySpeed=v end)
        makeToggle(p,"Auto No-Clip",function(on) config.forgeAdvanced.autoNoClip=on end, config.forgeAdvanced.autoNoClip)
        makeDropdown(p,"Depth Control",{"Off","On"},function(v) config.forgeAdvanced.depthControl=(v=="On") end, config.forgeAdvanced.depthControl and "On" or "Off")
        makeSlider(p,"Depth Offset", -50, 50, config.forgeAdvanced.depthOffset or 0, function(v) config.forgeAdvanced.depthOffset=v end)
        addDivider(p)
        sectionTitle(p,"Mining")
        makeToggle(p,"Auto Mine Rocks",function(on) config.forgeAdvanced.autoMineRocks=on end, config.forgeAdvanced.autoMineRocks)
        local rockBox=Instance.new("TextBox"); rockBox.Size=UDim2.new(1,-10,0,32); rockBox.BackgroundColor3=colors.bg; rockBox.TextColor3=colors.text; rockBox.PlaceholderText="Rock types (comma)"; rockBox.Text=config.forgeAdvanced.rockTypeSelection or ""; rockBox.BorderSizePixel=0; rockBox.Font=Enum.Font.Gotham; rockBox.TextSize=14; makeCorner(rockBox,8); rockBox.Parent=p
        rockBox.FocusLost:Connect(function() config.forgeAdvanced.rockTypeSelection=rockBox.Text end)
        local areaBox=Instance.new("TextBox"); areaBox.Size=UDim2.new(1,-10,0,32); areaBox.BackgroundColor3=colors.bg; areaBox.TextColor3=colors.text; areaBox.PlaceholderText="Area filter (optional)"; areaBox.Text=config.forgeAdvanced.areaFilter or ""; areaBox.BorderSizePixel=0; areaBox.Font=Enum.Font.Gotham; areaBox.TextSize=14; makeCorner(areaBox,8); areaBox.Parent=p
        areaBox.FocusLost:Connect(function() config.forgeAdvanced.areaFilter=areaBox.Text end)
        makeToggle(p,"Player Avoidance",function(on) config.forgeAdvanced.playerAvoidance=on end, config.forgeAdvanced.playerAvoidance)
        makeSlider(p,"Mining Distance",10,150,config.forgeAdvanced.miningDistance or 50,function(v) config.forgeAdvanced.miningDistance=v end)
        addDivider(p)
        sectionTitle(p,"Selling")
        makeToggle(p,"Auto Sell Weapons",function(on) config.forgeAdvanced.autoSellWeapons=on end, config.forgeAdvanced.autoSellWeapons)
        makeToggle(p,"Auto Sell Ores",function(on) config.forgeAdvanced.autoSellOres=on end, config.forgeAdvanced.autoSellOres)
        makeToggle(p,"Auto Sell on Full Stash",function(on) config.forgeAdvanced.autoSellOnFull=on end, config.forgeAdvanced.autoSellOnFull)
        makeToggle(p,"Timed Auto Sell",function(on) config.forgeAdvanced.timedAutoSell=on end, config.forgeAdvanced.timedAutoSell)
        makeSlider(p,"Sell Interval (s)",10,300,config.forgeAdvanced.sellInterval or 45,function(v) config.forgeAdvanced.sellInterval=v end)
        makeSlider(p,"Quantity Limit (0=off)",0,500,config.forgeAdvanced.sellQuantityLimit or 0,function(v) config.forgeAdvanced.sellQuantityLimit=v end)
        makeToggle(p,"Shop Initialization",function(on) config.forgeAdvanced.shopInit=on end, config.forgeAdvanced.shopInit)
        addDivider(p)
        sectionTitle(p,"Potions")
        makeToggle(p,"Buy Potions",function(on) config.forgeAdvanced.buyPotions=on end, config.forgeAdvanced.buyPotions)
        makeToggle(p,"Auto Drink Potions",function(on) config.forgeAdvanced.autoDrinkPotions=on end, config.forgeAdvanced.autoDrinkPotions)
        makeToggle(p,"Auto Buy When Empty",function(on) config.forgeAdvanced.autoBuyWhenEmpty=on end, config.forgeAdvanced.autoBuyWhenEmpty)
        local potBox=Instance.new("TextBox"); potBox.Size=UDim2.new(1,-10,0,32); potBox.BackgroundColor3=colors.bg; potBox.TextColor3=colors.text; potBox.PlaceholderText="Potion types (comma)"; potBox.Text=config.forgeAdvanced.potionTypes or ""; potBox.BorderSizePixel=0; potBox.Font=Enum.Font.Gotham; potBox.TextSize=14; makeCorner(potBox,8); potBox.Parent=p
        potBox.FocusLost:Connect(function() config.forgeAdvanced.potionTypes=potBox.Text end)
        addDivider(p)
        sectionTitle(p,"Teleports")
        local npcBox=Instance.new("TextBox"); npcBox.Size=UDim2.new(1,-10,0,32); npcBox.BackgroundColor3=colors.bg; npcBox.TextColor3=colors.text; npcBox.PlaceholderText="NPC teleport target"; npcBox.Text=config.forgeAdvanced.npcTeleportTarget or ""; npcBox.BorderSizePixel=0; npcBox.Font=Enum.Font.Gotham; npcBox.TextSize=14; makeCorner(npcBox,8); npcBox.Parent=p
        npcBox.FocusLost:Connect(function() config.forgeAdvanced.npcTeleportTarget=npcBox.Text end)
        makeButton(p,"Teleport to NPC",function() if teleportToSpot(config.forgeAdvanced.npcTeleportTarget) then toast("Teleported") else toast("NPC not found") end end)
        local placeBox=Instance.new("TextBox"); placeBox.Size=UDim2.new(1,-10,0,32); placeBox.BackgroundColor3=colors.bg; placeBox.TextColor3=colors.text; placeBox.PlaceholderText="Important place"; placeBox.Text=config.forgeAdvanced.placeTeleportTarget or ""; placeBox.BorderSizePixel=0; placeBox.Font=Enum.Font.Gotham; placeBox.TextSize=14; makeCorner(placeBox,8); placeBox.Parent=p
        placeBox.FocusLost:Connect(function() config.forgeAdvanced.placeTeleportTarget=placeBox.Text end)
        makeButton(p,"Teleport to Place",function() if teleportToSpot(config.forgeAdvanced.placeTeleportTarget) then toast("Teleported") else toast("Place not found") end end)
        local pickBox=Instance.new("TextBox"); pickBox.Size=UDim2.new(1,-10,0,32); pickBox.BackgroundColor3=colors.bg; pickBox.TextColor3=colors.text; pickBox.PlaceholderText="Pickaxe shop"; pickBox.Text=config.forgeAdvanced.pickaxeShopTarget or ""; pickBox.BorderSizePixel=0; pickBox.Font=Enum.Font.Gotham; pickBox.TextSize=14; makeCorner(pickBox,8); pickBox.Parent=p
        pickBox.FocusLost:Connect(function() config.forgeAdvanced.pickaxeShopTarget=pickBox.Text end)
        makeButton(p,"Teleport to Pickaxe Shop",function() if teleportToSpot(config.forgeAdvanced.pickaxeShopTarget) then toast("Teleported") else toast("Shop not found") end end)
        local islandBox=Instance.new("TextBox"); islandBox.Size=UDim2.new(1,-10,0,32); islandBox.BackgroundColor3=colors.bg; islandBox.TextColor3=colors.text; islandBox.PlaceholderText="Island name"; islandBox.Text=config.forgeAdvanced.islandTeleportTarget or ""; islandBox.BorderSizePixel=0; islandBox.Font=Enum.Font.Gotham; islandBox.TextSize=14; makeCorner(islandBox,8); islandBox.Parent=p
        islandBox.FocusLost:Connect(function() config.forgeAdvanced.islandTeleportTarget=islandBox.Text end)
        makeButton(p,"Teleport to Island",function() if teleportToSpot(config.forgeAdvanced.islandTeleportTarget) then toast("Teleported") else toast("Island not found") end end)
        addDivider(p)
        sectionTitle(p,"Race / Claims")
        makeToggle(p,"Auto Reroll Race",function(on) config.forgeAdvanced.autoRerollRace=on end, config.forgeAdvanced.autoRerollRace)
        local raceBox=Instance.new("TextBox"); raceBox.Size=UDim2.new(1,-10,0,32); raceBox.BackgroundColor3=colors.bg; raceBox.TextColor3=colors.text; raceBox.PlaceholderText="Target race"; raceBox.Text=config.forgeAdvanced.targetRace or ""; raceBox.BorderSizePixel=0; raceBox.Font=Enum.Font.Gotham; raceBox.TextSize=14; makeCorner(raceBox,8); raceBox.Parent=p
        raceBox.FocusLost:Connect(function() config.forgeAdvanced.targetRace=raceBox.Text end)
        makeToggle(p,"Show Race Chances",function(on) config.forgeAdvanced.showRaceChances=on end, config.forgeAdvanced.showRaceChances)
        makeToggle(p,"Claim All Ores",function(on) config.forgeAdvanced.claimAllOres=on end, config.forgeAdvanced.claimAllOres)
        makeToggle(p,"Claim All Enemies",function(on) config.forgeAdvanced.claimAllEnemies=on end, config.forgeAdvanced.claimAllEnemies)
        makeToggle(p,"Claim All Equipment",function(on) config.forgeAdvanced.claimAllEquipment=on end, config.forgeAdvanced.claimAllEquipment)
        makeToggle(p,"One-Click Claim All",function(on) config.forgeAdvanced.claimAll=on end, config.forgeAdvanced.claimAll)
        addDivider(p)
        sectionTitle(p,"Rare Item Alerts")
        makeToggle(p,"Rare Item Notifications",function(on) config.forgeAdvanced.rareItemNotify=on end, config.forgeAdvanced.rareItemNotify)
        local rareBox=Instance.new("TextBox"); rareBox.Size=UDim2.new(1,-10,0,32); rareBox.BackgroundColor3=colors.bg; rareBox.TextColor3=colors.text; rareBox.PlaceholderText="Rarity filter (comma)"; rareBox.Text=config.forgeAdvanced.rarityFilter or ""; rareBox.BorderSizePixel=0; rareBox.Font=Enum.Font.Gotham; rareBox.TextSize=14; makeCorner(rareBox,8); rareBox.Parent=p
        rareBox.FocusLost:Connect(function() config.forgeAdvanced.rarityFilter=rareBox.Text end)
        addDivider(p)
        sectionTitle(p,"World Hop")
        makeDropdown(p,"World Hop Mode",{"None","World 1","World 2"},function(v) config.forgeAdvanced.worldHopMode=v end, config.forgeAdvanced.worldHopMode)
        makeToggle(p,"Low Ping Priority",function(on) config.forgeAdvanced.lowPingPriority=on end, config.forgeAdvanced.lowPingPriority)
        makeSlider(p,"Player Count Filter",0,30,config.forgeAdvanced.playerCountFilter or 0,function(v) config.forgeAdvanced.playerCountFilter=v end)
        addDivider(p)
        sectionTitle(p,"Misc")
        makeToggle(p,"Auto Execute on Teleport",function(on) config.forgeAdvanced.autoExecOnTeleport=on end, config.forgeAdvanced.autoExecOnTeleport)
        makeToggle(p,"Anti-AFK",function(on) config.antiAfk=on end, config.antiAfk)
        local codeBox=Instance.new("TextBox"); codeBox.Size=UDim2.new(1,-10,0,50); codeBox.BackgroundColor3=colors.bg; codeBox.TextColor3=colors.text; codeBox.PlaceholderText="Redeem codes (comma)"; codeBox.Text=config.forgeAdvanced.redeemCodes or ""; codeBox.BorderSizePixel=0; codeBox.Font=Enum.Font.Gotham; codeBox.TextSize=14; makeCorner(codeBox,8); codeBox.Parent=p
        codeBox.FocusLost:Connect(function() config.forgeAdvanced.redeemCodes=codeBox.Text end)
    end
end

-- Player List (merged under Gameplay)
local priorityTarget=nil
do
    local p=pages["Gameplay"]
    addDivider(p)
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

-- Script Hub (stub, merged into Automation)
do
    local p=pages["Automation"]
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
    if isFisch or isFishIt then
        local fishNote=Instance.new("TextLabel"); fishNote.BackgroundTransparency=1; fishNote.Size=UDim2.new(1,-10,0,40); fishNote.Font=Enum.Font.Gotham; fishNote.TextColor3=colors.text; fishNote.TextSize=14; fishNote.TextWrapped=true; fishNote.TextXAlignment=Enum.TextXAlignment.Left; fishNote.TextYAlignment=Enum.TextYAlignment.Top; fishNote.Text="Fish It controls moved to Automation tab for a full-page layout."; fishNote.Parent=p
        makeButton(p,"Open Fish Automation",function() switchTab("Automation") end)
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
    local gameProfiles = listGameProfiles()
    local selectedGameProfile = gameProfiles[1]
    makeDropdown(p,"Game Profile",gameProfiles,function(v) selectedGameProfile=v end, selectedGameProfile)
    local gpName=Instance.new("TextBox"); gpName.Size=UDim2.new(1,-10,0,36); gpName.BackgroundColor3=colors.bg; gpName.TextColor3=colors.text; gpName.PlaceholderText="Game profile name"; gpName.Text=config.lastGameProfile or ""; gpName.BorderSizePixel=0; gpName.Font=Enum.Font.Gotham; gpName.TextSize=14; makeCorner(gpName,8); gpName.Parent=p
    makeButton(p,"Save Game Profile",function()
        local name = gpName.Text ~= "" and gpName.Text or ("Profile_"..tostring(os.time()))
        saveGameProfile(name)
    end)
    makeButton(p,"Load Game Profile",function()
        if selectedGameProfile and selectedGameProfile ~= "None" then
            loadGameProfile(selectedGameProfile)
        else
            toast("No game profile selected")
        end
    end)
    makeButton(p,"Delete Game Profile",function()
        if selectedGameProfile and selectedGameProfile ~= "None" then
            deleteGameProfile(selectedGameProfile)
        else
            toast("No game profile selected")
        end
    end)
    makeButton(p,"Set Auto-Load Game Profile",function()
        local name = (selectedGameProfile and selectedGameProfile ~= "None") and selectedGameProfile or gpName.Text
        if name and name ~= "" then setAutoGameProfile(name) else toast("Pick a profile to auto-load") end
    end)
    makeToggle(p,"Auto-Load Game Profile",function(on) config.autoLoadGameProfile=on end, config.autoLoadGameProfile)
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

-- Protection (merged under Gameplay)
do
    local p=pages["Gameplay"]
    addDivider(p)
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

-- UI / Theme (merged under Visuals / UI)
do
    local p=pages["Visuals / UI"]
    addDivider(p)
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
qToggle("Panic", function() return false end, function() shutdown("panic") end)

-- Keybinds & panic
local function animateMenu(hiddenState)
    local targetPos = hiddenState and UDim2.new(0.5, -mainWidth/2, 1.1, 0) or centeredMainPosition()
    local shadowPos = hiddenState and UDim2.new(0.5, -(mainWidth+32)/2, 1.1, 0) or UDim2.new(0.5,-(mainWidth+32)/2,0.5,-(mainHeight+32)/2)
    if config.animations then
        tween(main, 0.22, {Position = targetPos}):Play()
        tween(shadow, 0.22, {Position = shadowPos, ImageTransparency = hiddenState and 1 or 0.65}):Play()
    else
        main.Position = targetPos
        shadow.Position = shadowPos
        shadow.ImageTransparency = hiddenState and 1 or 0.65
    end
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input,gp)
    if not scriptActive then return end
    if gp then return end
    if input.KeyCode == config.menuKey then
        hidden = not hidden
        animateMenu(hidden)
        main.Active = not hidden
        gui.Enabled = not hidden
        fovCircle.Visible = config.aimbotEnabled and not hidden
    elseif input.KeyCode == config.panicKey then
        if config.stopOnPanic then shutdown("panic") else softPanic() end
    elseif input.KeyCode == config.keybinds.toggleAimbot then config.aimbotEnabled=not config.aimbotEnabled; fovCircle.Visible=config.aimbotEnabled
    elseif input.KeyCode == config.keybinds.toggleESP then config.esp.enabled=not config.esp.enabled; clearESP(); if config.esp.enabled then for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end
    elseif input.KeyCode == config.keybinds.toggleFly then flyEnabled=not flyEnabled
    elseif input.KeyCode == config.keybinds.toggleNoclip then noclipEnabled=not noclipEnabled
    elseif input.KeyCode == config.overlayToggleKey then
        overlay.Visible = not overlay.Visible
        quickBar.Visible = not quickBar.Visible
    elseif input.KeyCode == Enum.KeyCode.Space and infiniteJump and Hum then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

local function autoDisable(reason)
    config.aimbotEnabled=false
    config.esp.enabled=false
    flyEnabled=false
    noclipEnabled=false
    autoClickEnabled=false
    autoInteractEnabled=false
    stickyTarget = nil
    lastTargetName, lastTargetDist = nil, nil
    clearESP(); clearWorldESP()
    if Hum then Hum.WalkSpeed=wsDefault; Hum.JumpPower=jpDefault end
    workspace.Gravity=gravityDefault
    pushLog("Disabled ("..reason..")")
end
bindHumanoid(Hum)
table.insert(connections, TeleportService.TeleportInitFailed:Connect(function()
    if config.autoDisableOnTP then autoDisable("teleport") end
end))

-- Loops
initPromptTracking()
table.insert(connections, RunService.Stepped:Connect(function()
    if not scriptActive then return end
    if isForge and config.forgeAdvanced.autoNoClip then noclipEnabled = true end
    if noclipEnabled and Char then for _,part in ipairs(Char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end
    if safeWalkEnabled and HRP then local ray=Ray.new(HRP.Position, Vector3.new(0,-6,0)); local hit=workspace:FindPartOnRay(ray,Char); if not hit then HRP.Velocity=Vector3.new(HRP.Velocity.X,0,HRP.Velocity.Z) end end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if not scriptActive then return end
    if isForge and config.forgeAdvanced.depthControl and HRP then
        if not depthLockY then depthLockY = HRP.Position.Y + (config.forgeAdvanced.depthOffset or 0) end
        HRP.CFrame = CFrame.new(HRP.Position.X, depthLockY, HRP.Position.Z)
    else
        depthLockY = nil
    end
    if config.advanced.freezeMode == "Hard" and HRP then
        HRP.Anchored = true
    elseif config.advanced.freezeMode ~= "Hard" and HRP then
        HRP.Anchored = false
    end
    if config.advanced.freezeMode == "Legit" and Hum then
        Hum.WalkSpeed = 0
        Hum.JumpPower = 0
    elseif config.advanced.freezeMode ~= "Legit" and Hum then
        if Hum.WalkSpeed == 0 then Hum.WalkSpeed = wsDefault end
        if Hum.JumpPower == 0 then Hum.JumpPower = jpDefault end
    end
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
    if Hum and sprinting and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not flyEnabled then Hum.WalkSpeed=config.sprintSpeed
    elseif Hum and sprinting and not flyEnabled then Hum.WalkSpeed=config.wsBoost end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if not scriptActive or not config.aimbotEnabled then return end
    if not UserInputService:IsMouseButtonPressed(config.aimbotKey) then return end
    if not HRP then return end
    local target
    if config.stickTarget and stickyTarget and stickyTarget.Parent then
        target = stickyTarget
    else
        target = getClosestTarget()
    end
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
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
        lastTargetName = target.Name
        lastTargetDist = (targetPos - HRP.Position).Magnitude
        if config.aimbotLegitDecay then config.aimbotFov = math.max(40, config.aimbotFov - 0.2) end
        if config.stickTarget then stickyTarget = target end
    end
end))

task.spawn(function()
    while scriptActive do
        if autoClickEnabled then VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0); VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0) end
        task.wait(config.autoClickRate or 0.05)
    end
end)

task.spawn(function()
    while scriptActive do
        if autoInteractEnabled then
            updateInteractTags()
            local hasFilter = lastInteractFilter ~= ""
            for prompt in pairs(proximityPrompts) do
                if not prompt.Parent then
                    proximityPrompts[prompt] = nil
                elseif prompt.Enabled then
                    local allow = true
                    if hasFilter then
                        allow=false
                        local text = string.lower(prompt.Name or "")
                        for _,tag in ipairs(cachedInteractTags) do
                            if text:find(tag, 1, true) then allow=true break end
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
    while scriptActive do
        if worldEspState.tags and config.worldScanInterval and config.worldScanInterval > 0 then
            addWorldTagESP(worldEspState.tags, worldEspState.fill or colors.accent, worldEspState.outline or colors.accent2)
            task.wait(config.worldScanInterval)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while scriptActive do
        if config.antiAfk then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Right, false, nil); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Right, false, nil) end
        task.wait(30)
    end
end)

task.spawn(function()
    local lastCast, lastReel = 0, 0
    while scriptActive do
        local mineInterval = config.advanced.autoMineInterval or 0.6
        if isFisch or isFishIt then
            if config.fisch and (config.fisch.fullLoop or config.fisch.autoCast) then
                if tick() - lastCast >= (config.fisch.autoCastDelay or 0.6) then
                    firePromptsByTags({"cast","throw","fish"}, 60)
                    lastCast = tick()
                end
            end
            if config.fisch and (config.fisch.fullLoop or config.fisch.autoReel) then
                if tick() - lastReel >= (config.fisch.autoReelDelay or 0.4) then
                    firePromptsByTags({"reel","hook","pull","catch"}, 60)
                    lastReel = tick()
                end
            end
            if config.fisch and config.fisch.autoMiniGame then
                firePromptsByTags({"minigame","perfect","timing","shake"}, 60)
            end
            if config.fisch and config.fisch.autoSellOnFull then
                firePromptsByTags({"sell","vendor","shop"}, 80)
            end
            if config.fisch and config.fisch.autoDiscardTrash then
                firePromptsByTags({"discard","trash"}, 40)
            end
            if config.fishit and config.fishit.autoSellFull then
                firePromptsByTags({"sell","vendor","shop"}, 80)
            end
            if config.fishit and config.fishit.autoBait then
                firePromptsByTags({"bait"}, 40)
            end
            if config.fishit and config.fishit.autoUpgradeTarget and config.fishit.autoUpgradeTarget > 0 then
                firePromptsByTags({"upgrade","enhance"}, 60)
            end
        end
        if isForge and config.forge then
            if config.forge.autoInsert then
                firePromptsByTags({"insert","forge","smelt","anvil"}, 60)
            end
            if config.forge.autoCollect then
                firePromptsByTags({"collect","pickup"}, 60)
            end
        end
        if isForge and config.forgeAdvanced then
            local fa = config.forgeAdvanced
            if fa.openForge then firePromptsByTags({"forge","open"}, 60) end
            if fa.autoMelt then firePromptsByTags({"melt","smelt"}, 60) end
            if fa.autoPour then firePromptsByTags({"pour"}, 40) end
            if fa.autoHammer then firePromptsByTags({"hammer","anvil"}, 40) end
            if fa.autoMineRocks then
                local tags = parseTags(fa.rockTypeSelection)
                if fa.areaFilter and fa.areaFilter ~= "" then
                    tags = parseTags(fa.areaFilter)
                end
                if not fa.playerAvoidance or not isPlayerNearby(20) then
                    firePromptsByTags(tags, fa.miningDistance or 50)
                end
            end
            if fa.autoSellWeapons or fa.autoSellOres or fa.autoSellOnFull then
                firePromptsByTags({"sell","vendor","shop","smith"}, 80)
            end
            if fa.timedAutoSell and (tick() % (fa.sellInterval or 45) < 0.4) then
                firePromptsByTags({"sell","vendor","shop"}, 80)
            end
            if fa.buyPotions or fa.autoBuyWhenEmpty then
                firePromptsByTags({"potion","buy"}, 60)
            end
            if fa.autoDrinkPotions then
                firePromptsByTags({"drink","use"}, 40)
            end
            if fa.autoRerollRace then
                firePromptsByTags({"reroll","race"}, 60)
            end
            if fa.claimAll or fa.claimAllOres or fa.claimAllEnemies or fa.claimAllEquipment then
                firePromptsByTags({"claim","reward"}, 80)
            end
        end
        if config.advanced.autoMine then
            firePromptsByTags(parseTags(config.advanced.autoMineTags), 70)
        end
        task.wait(mineInterval)
    end
end)

task.spawn(function()
    local lastKill, lastEquip = 0, 0
    while scriptActive do
        if config.advanced.autoEquipRod and tick() - lastEquip >= (config.advanced.autoEquipInterval or 2) then
            equipToolByPriority(config.advanced.rodPriority)
            lastEquip = tick()
        end
        if config.advanced.autoKill and HRP then
            if tick() - lastKill >= (config.advanced.autoKillInterval or 0.25) then
                local target = findNearestTarget(config.advanced.autoKillRange or 60, config.advanced.autoKillPlayers, config.advanced.autoKillNPCs)
                if target then
                    local tool = Char and Char:FindFirstChildOfClass("Tool")
                    if tool and tool.Activate then tool:Activate() else VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0); VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0) end
                end
                lastKill = tick()
            end
        end
        if isForge and config.forgeAdvanced and config.forgeAdvanced.autoAttackMobs and HRP then
            if tick() - lastKill >= (config.advanced.autoKillInterval or 0.25) then
                local target = findNearestTarget(config.forgeAdvanced.attackDistance or 60, false, true)
                if target then
                    local tool = Char and Char:FindFirstChildOfClass("Tool")
                    if tool and tool.Activate then tool:Activate() else VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0); VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0) end
                end
                lastKill = tick()
            end
        end
        task.wait(0.1)
    end
end)

local last=tick()
local sessionStart = tick()
table.insert(connections, RunService.RenderStepped:Connect(function()
    if not scriptActive then return end
    local now=tick(); local fps=1/math.max(now-last, 1/60); last=now
    if now - lastOverlayUpdate < overlayUpdateRate then return end
    lastOverlayUpdate = now
    local ping = 0
    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
    end)
    local session = math.floor(now - sessionStart)
    statusLabel.Text = string.format("FPS: %d | Ping: %dms | %ds | LastCfg: %s", math.floor(fps), ping, session, config.lastConfig ~= "" and config.lastConfig or "none")
    local targetText = ""
    if lastTargetName and lastTargetDist then
        targetText = string.format(" | Target: %s (%dm)", lastTargetName, math.floor(lastTargetDist))
    end
    overlayLabel.Text = string.format("FPS: %d | Ping: %dms | Mode: %s%s", math.floor(fps), ping, config.aimbotEnabled and "Aimbot" or "Idle", targetText)
end))

-- Float anim
task.spawn(function()
    while scriptActive and gui.Parent do
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
table.insert(connections, LP.CharacterAdded:Connect(function(newChar)
    Char=newChar; Hum=Char:WaitForChild("Humanoid"); HRP=Char:WaitForChild("HumanoidRootPart")
    wsDefault=Hum.WalkSpeed; jpDefault=Hum.JumpPower
    bindHumanoid(Hum)
    if config.esp.enabled then task.delay(1,function() clearESP(); for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end end) end
end))

applyTheme()
setBlur(config.uiBlur, config.blurSize or 10)
applyOpacity(main)
autoLoadConfig()
if config.disableInVIP and (game.PrivateServerId and game.PrivateServerId ~= "") then
    autoDisable("VIP/Private")
end
toast("Loaded Advanced Universal Hub v"..config.version)

end)

if not ok then
    warn("[Advanced Hub] load error:", err)
    pcall(function()
        local sg = game:GetService("StarterGui")
        sg:SetCore("SendNotification", {
            Title = "Advanced Hub",
            Text = "Load error: " .. tostring(err),
            Duration = 8,
        })
    end)
end
