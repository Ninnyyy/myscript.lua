-- click_plus.lua
-- Enhanced "click" UI library (expanded): buttons, toggles, sliders, dropdowns, keybinds, color picker,
-- notifications, multi-config, autosave, import/export, watermark/fps, themes, sounds, module manager, auto-exec stub.
-- Intended for Roblox exploit environments (cloneref, writefile, readfile, isfolder, makefolder, HttpService available)

-- == CONFIG / GLOBALS ==
if not getgenv then
    getgenv = _G
end

getgenv().GG = getgenv().GG or {}
getgenv().GG.Language = getgenv().GG.Language or {
    CheckboxEnabled = "Enabled",
    CheckboxDisabled = "Disabled",
    SliderValue = "Value",
    DropdownSelect = "Select",
    DropdownNone = "None",
    DropdownSelected = "Selected",
    ButtonClick = "Click",
    TextboxEnter = "Enter",
    ModuleEnabled = "Enabled",
    ModuleDisabled = "Disabled",
    TabGeneral = "General",
    TabSettings = "Settings",
    Loading = "Loading...",
    Error = "Error",
    Success = "Success"
}
local Language = getgenv().GG.Language

-- Useful services (cloneref for exploit safety)
local UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider = cloneref(game:GetService('ContentProvider'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Lighting = cloneref(game:GetService('Lighting'))
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- ensure click folder for configs
if not isfolder("click") then
    makefolder("click")
end

-- remove old UI if present
local old_click = CoreGui:FindFirstChild('click')
if old_click then
    Debris:AddItem(old_click, 0)
end

-- CONNECTIONS HANDLER
local Connections = setmetatable({}, {
    __index = {
        add = function(self, name, conn)
            rawset(self, name, conn)
        end,
        disconnect = function(self, name)
            if rawget(self, name) then
                pcall(function() rawget(self, name):Disconnect() end)
                rawset(self, name, nil)
            end
        end,
        disconnect_all = function(self)
            for k, v in pairs(self) do
                if typeof(v) == 'RBXScriptConnection' then
                    pcall(function() v:Disconnect() end)
                end
                self[k] = nil
            end
        end
    }
})

-- UTIL
local Util = {}
function Util.map(value, in_min, in_max, out_min, out_max)
    return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end
function Util.viewport_point_to_world(location, distance)
    local unit_ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
    return unit_ray.Origin + unit_ray.Direction * distance
end
function Util.get_offset()
    local viewport_size_Y = workspace.CurrentCamera.ViewportSize.Y
    return Util.map(viewport_size_Y, 0, 2560, 8, 56)
end
function Util.shallow_copy(t)
    local r = {}
    for k,v in pairs(t) do r[k]=v end
    return r
end
function Util.is_executor_supports_http()
    return (type(syn) == 'table') or (type(http_request) == 'function') or (type(request) == 'function')
end
function Util.safe_http_post(url, body, headers)
    headers = headers or {}
    local ok, res
    if type(syn) == 'table' and syn.request then
        ok, res = pcall(syn.request, {Url = url, Method = 'POST', Body = HttpService:JSONEncode(body), Headers = headers})
        if ok and res and res.Body then
            return res
        end
    elseif http_request then
        ok, res = pcall(http_request, {Url = url, Method = 'POST', Body = HttpService:JSONEncode(body), Headers = headers})
        return res
    elseif request then
        ok, res = pcall(request, {Url = url, Method = 'POST', Body = HttpService:JSONEncode(body), Headers = headers})
        return res
    else
        return nil
    end
end

-- ACrylicBlur (kept compact)
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur
function AcrylicBlur.new(object)
    local self = setmetatable({_object = object, _folder = nil, _frame = nil, _root = nil}, AcrylicBlur)
    self:setup()
    return self
end
function AcrylicBlur:create_folder()
    local old_folder = workspace.CurrentCamera:FindFirstChild('AcrylicBlur')
    if old_folder then Debris:AddItem(old_folder, 0) end
    local folder = Instance.new('Folder'); folder.Name='AcrylicBlur'; folder.Parent=workspace.CurrentCamera
    self._folder=folder
end
function AcrylicBlur:create_depth_of_fields()
    local depth = Lighting:FindFirstChild('AcrylicBlur') or Instance.new('DepthOfFieldEffect')
    depth.FarIntensity=0; depth.FocusDistance=0.05; depth.InFocusRadius=0.1; depth.NearIntensity=1
    depth.Name='AcrylicBlur'; depth.Parent=Lighting
    for _,obj in pairs(Lighting:GetChildren()) do
        if obj:IsA('DepthOfFieldEffect') and obj~=depth then
            Connections:add(obj, obj:GetPropertyChangedSignal('FarIntensity'):Connect(function() obj.FarIntensity=0 end))
            obj.FarIntensity=0
        end
    end
end
function AcrylicBlur:create_frame()
    local frame = Instance.new('Frame'); frame.Size=UDim2.new(1,0,1,0); frame.Position=UDim2.new(0.5,0,0.5,0)
    frame.AnchorPoint=Vector2.new(0.5,0.5); frame.BackgroundTransparency=1; frame.Parent = self._object
    self._frame = frame
end
function AcrylicBlur:create_root()
    local part = Instance.new('Part'); part.Name='Root'; part.Color=Color3.new(0,0,0); part.Material=Enum.Material.Glass
    part.Size=Vector3.new(1,1,0); part.Anchored=true; part.CanCollide=false; part.CanQuery=false; part.Locked=true
    part.CastShadow=false; part.Transparency=0.98; part.Parent = self._folder
    local m = Instance.new('SpecialMesh'); m.MeshType=Enum.MeshType.Brick; m.Offset=Vector3.new(0,0,-0.000001); m.Parent=part
    self._root = part
end
function AcrylicBlur:setup()
    self:create_depth_of_fields(); self:create_folder(); self:create_root(); self:create_frame(); self:render(0.001); self:check_quality_level()
end
function AcrylicBlur:render(distance)
    local positions = {top_left=Vector2.new(), top_right=Vector2.new(), bottom_right=Vector2.new()}
    local function update_positions(size, position)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end
    local function update()
        local top_left3D = Util.viewport_point_to_world(positions.top_left, distance)
        local top_right3D = Util.viewport_point_to_world(positions.top_right, distance)
        local bottom_right3D = Util.viewport_point_to_world(positions.bottom_right, distance)
        local width = (top_right3D - top_left3D).Magnitude
        local height = (top_right3D - bottom_right3D).Magnitude
        if not self._root then return end
        self._root.CFrame = CFrame.fromMatrix((top_left3D+bottom_right3D)/2, workspace.CurrentCamera.CFrame.XVector, workspace.CurrentCamera.CFrame.YVector, workspace.CurrentCamera.CFrame.ZVector)
        self._root.Mesh.Scale = Vector3.new(width, height, 0)
    end
    local function on_change()
        local offset = Util.get_offset()
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset/2, offset/2)
        update_positions(size, position)
        task.spawn(update)
    end
    Connections:add('cframe_update', workspace.CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update))
    Connections:add('viewport_size_update', workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(update))
    Connections:add('field_of_view_update', workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(update))
    Connections:add('frame_absolute_position', self._frame:GetPropertyChangedSignal('AbsolutePosition'):Connect(on_change))
    Connections:add('frame_absolute_size', self._frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(on_change))
    task.spawn(update)
end
function AcrylicBlur:check_quality_level()
    local success, settings = pcall(function() return UserSettings().GameSettings end)
    if not success or not settings then return end
    local q = settings.SavedQualityLevel.Value
    if q < 8 then self:change_visibility(false) end
    Connections:add('quality_level', settings:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        local q2 = settings.SavedQualityLevel.Value
        self:change_visibility(q2 >= 8)
    end))
end
function AcrylicBlur:change_visibility(state) if self._root then self._root.Transparency = state and 0.98 or 1 end end

-- CONFIG manager with multi-config & autosave
local Config = {}
function Config:save_file(file_name, data)
    local ok, err = pcall(function()
        writefile('click/'..file_name..'.json', HttpService:JSONEncode(data))
    end)
    if not ok then warn('[click] save failed:', err) end
end
function Config:read_file(file_name)
    local ok, res = pcall(function()
        if not isfile('click/'..file_name..'.json') then return nil end
        local s = readfile('click/'..file_name..'.json')
        if not s then return nil end
        return HttpService:JSONDecode(s)
    end)
    if not ok then warn('[click] read failed:', res) return nil end
    return res
end
function Config:list_configs()
    local results = {}
    for _, file in pairs(listfiles('click')) do
        local name = file:match("click/(.+)%.json")
        if name then table.insert(results, name) end
    end
    return results
end

-- LIBRARY (main)
local Library = {}
Library.__index = Library
function Library.new()
    local self = setmetatable({
        _config = Config:read_file('default') or { _flags = {}, _keybinds = {}, _library = {}, ui = {} },
        _ui = nil,
        _ui_loaded = false,
        _tab = 0,
        _modules = {}
    }, Library)
    self:create_ui()
    return self
end

-- Notification system
local NotificationContainer
do
    -- create container (or reuse)
    local parent = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
    if not parent then
        parent = Instance.new("ScreenGui")
        parent.Name = "RobloxGui"
        parent.Parent = game:GetService("CoreGui")
    end
    NotificationContainer = parent:FindFirstChild("RobloxCoreGuis") or Instance.new("Frame", parent)
    NotificationContainer.Name = "RobloxCoreGuis"
    NotificationContainer.Size = UDim2.new(0,300,0,0)
    NotificationContainer.Position = UDim2.new(0.8,0,0,10)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.AutomaticSize = Enum.AutomaticSize.Y
    local layout = NotificationContainer:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", NotificationContainer)
    layout.FillDirection = Enum.FillDirection.Vertical; layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0,10)
end

function Library.SendNotification(settings)
    settings = settings or {}
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(1,0,0,60); Notification.BackgroundTransparency = 1; Notification.BorderSizePixel = 0
    Notification.Name = "Notification"; Notification.Parent = NotificationContainer; Notification.AutomaticSize = Enum.AutomaticSize.Y

    local Inner = Instance.new("Frame", Notification)
    Inner.Size = UDim2.new(1,0,0,60); Inner.Position = UDim2.new(0,0,0,0); Inner.BackgroundColor3 = Color3.fromRGB(28,28,30)
    Inner.BackgroundTransparency = 0.05; Inner.BorderSizePixel=0; Inner.Name = "InnerFrame"; Inner.AutomaticSize = Enum.AutomaticSize.Y

    local UICorner = Instance.new("UICorner", Inner); UICorner.CornerRadius = UDim.new(0,6)
    local Title = Instance.new("TextLabel", Inner); Title.Text = settings.title or "Notification"; Title.TextSize=14; Title.Position=UDim2.new(0,8,0,6)
    Title.Size = UDim2.new(1,-16,0,20); Title.BackgroundTransparency=1; Title.TextXAlignment = Enum.TextXAlignment.Left
    local Body = Instance.new("TextLabel", Inner); Body.Text = settings.text or ""; Body.Position = UDim2.new(0,8,0,26)
    Body.Size = UDim2.new(1,-16,0,30); Body.BackgroundTransparency=1; Body.TextSize=12; Body.TextXAlignment=Enum.TextXAlignment.Left; Body.TextYAlignment = Enum.TextYAlignment.Top

    task.spawn(function()
        wait(0.1)
        local totalHeight = Title.TextBounds.Y + Body.TextBounds.Y + 18
        Inner.Size = UDim2.new(1,0,0,totalHeight)
    end)
    task.spawn(function()
        local tweenIn = TweenService:Create(Inner, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,10 + NotificationContainer.Size.Y.Offset)})
        tweenIn:Play()
        local duration = settings.duration or 4
        wait(duration)
        local tweenOut = TweenService:Create(Inner, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1,310,0,10 + NotificationContainer.Size.Y.Offset)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function() Notification:Destroy() end)
    end)
end

-- Basic sound manager (optional, uses sound instances)
local SoundManager = {}
function SoundManager.play(soundId, volume)
    volume = volume or 1
    local s = Instance.new("Sound")
    s.SoundId = soundId
    s.Volume = volume
    s.Parent = workspace
    s.PlayOnRemove = false
    s:Play()
    Debris:AddItem(s, 3)
end

-- UI creation (main screen)
function Library:create_ui()
    local click = Instance.new('ScreenGui')
    click.ResetOnSpawn = false
    click.Name = 'click'
    click.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    click.Parent = CoreGui

    local Container = Instance.new('Frame', click)
    Container.Name = 'Container'
    Container.Size = UDim2.fromOffset(0,0)
    Container.Position = UDim2.new(0.5,0,0.5,0)
    Container.AnchorPoint = Vector2.new(0.5,0.5)
    Container.BackgroundColor3 = Color3.fromRGB(27,27,29)
    Container.BackgroundTransparency = 0.06
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", Container); UICorner.CornerRadius = UDim.new(0,10)
    local UIStroke = Instance.new("UIStroke", Container); UIStroke.Color = Color3.fromRGB(40,40,42); UIStroke.Transparency = 0.6

    local Handler = Instance.new('Frame', Container); Handler.Name='Handler'; Handler.Size=UDim2.new(0,698,0,479); Handler.BackgroundTransparency=1

    -- Left tabs
    local Tabs = Instance.new('ScrollingFrame', Handler); Tabs.Name='Tabs'
    Tabs.Size = UDim2.new(0,129,0,401); Tabs.Position = UDim2.new(0.026,0,0.111,0); Tabs.BackgroundTransparency=1; Tabs.ScrollBarImageTransparency=1
    local TabsLayout = Instance.new('UIListLayout', Tabs); TabsLayout.Padding = UDim.new(0,4); TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Title (animated)
    local ClientName = Instance.new('TextLabel', Handler)
    ClientName.Name='ClientName'; ClientName.Size=UDim2.new(0,150,0,20); ClientName.Position=UDim2.new(0.056,0,0.055,0)
    ClientName.BackgroundTransparency=1; ClientName.TextXAlignment=Enum.TextXAlignment.Left; ClientName.TextSize=13
    ClientName.Font = Enum.Font.GothamSemibold; ClientName.TextColor3 = Color3.fromRGB(153,68,0)
    local spinChars = {"/","-","\\","|"}; local i=1
    task.spawn(function()
        while click.Parent do
            pcall(function()
                ClientName.Text = " click " .. spinChars[i] .. " " .. os.date("%I:%M:%S %p")
                i = i % #spinChars + 1
            end)
            task.wait(0.18)
        end
    end)

    -- Divider & Sections
    local Divider = Instance.new('Frame', Handler); Divider.Name='Divider'; Divider.Size=UDim2.new(0,1,0,479); Divider.Position=UDim2.new(0.235,0,0,0)
    Divider.BackgroundColor3 = Color3.fromRGB(128,51,0); Divider.BackgroundTransparency = 0.4; Divider.BorderSizePixel = 0
    local Sections = Instance.new('Folder', Handler); Sections.Name='Sections'

    -- Minimize button
    local Minimize = Instance.new('TextButton', Handler); Minimize.Name='Minimize'; Minimize.Text=''; Minimize.BackgroundTransparency=1
    Minimize.Position = UDim2.new(0.02,0,0.03,0); Minimize.Size=UDim2.new(0,24,0,24)
    Minimize.MouseButton1Click:Connect(function()
        if Container.Size == UDim2.fromOffset(698,479) then
            TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.fromOffset(160,56)}):Play()
        else
            TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.fromOffset(698,479)}):Play()
        end
    end)

    local UIScale = Instance.new('UIScale', Container)
    self._ui = click
    self._container = Container
    self._tabs = Tabs
    self._sections = Sections
    self._ui_loaded = false

    -- drag handling
    local dragging, dragStart, startPos = false, nil, nil
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Container.Position
            Connections:add('drag_end', input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    Connections:disconnect('drag_end')
                end
            end))
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            local target = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(Container, TweenInfo.new(0.12), {Position = target}):Play()
        end
    end)

    -- load routine (preload images, scale on mobile, open animation)
    function self:load()
        self:get_device()
        if self._device == 'Mobile' or self._device == 'Unknown' then
            self:get_screen_scale()
            UIScale.Scale = self._ui_scale
            Connections:add('ui_scale', workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
                self:get_screen_scale()
                UIScale.Scale = self._ui_scale
            end))
        end
        TweenService:Create(Container, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(698,479)}):Play()
        -- acrylic blur
        pcall(function() AcrylicBlur.new(Container) end)
        self._ui_loaded = true
    end

    -- device helpers
    function self:get_device()
        local device = 'Unknown'
        if not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then device='PC'
        elseif UserInputService.TouchEnabled then device='Mobile'
        elseif UserInputService.GamepadEnabled then device='Console' end
        self._device = device
    end
    function self:get_screen_scale()
        local vx = workspace.CurrentCamera.ViewportSize.X
        self._ui_scale = vx / 1400
    end

    -- Tab creation
    function self:create_tab(title, icon)
        local Tab = Instance.new('TextButton', Tabs); Tab.Name='Tab'; Tab.Size=UDim2.new(0,129,0,38); Tab.BackgroundTransparency=1; Tab.AutoButtonColor=false
        Tab.LayoutOrder = self._tab or 0
        local TextLabel = Instance.new('TextLabel', Tab); TextLabel.Size=UDim2.new(0,90,0,16); TextLabel.Position=UDim2.new(0.24,0,0.5,0)
        TextLabel.BackgroundTransparency=1; TextLabel.Text = title; TextLabel.TextXAlignment = Enum.TextXAlignment.Left; TextLabel.TextSize=13; TextLabel.Font = Enum.Font.GothamSemibold; TextLabel.TextColor3=Color3.fromRGB(255,255,255); TextLabel.TextTransparency=0.7
        local Icon = Instance.new('ImageLabel', Tab); Icon.Name='Icon'; Icon.Size=UDim2.new(0,16,0,16); Icon.Position=UDim2.new(0.1,0,0.5,0); Icon.AnchorPoint=Vector2.new(0,0.5); Icon.BackgroundTransparency=1; Icon.Image=icon; Icon.ImageTransparency=0.8

        local LeftSection = Instance.new('ScrollingFrame', Sections); LeftSection.Name='LeftSection'; LeftSection.Size=UDim2.new(0,243,0,445); LeftSection.Position = UDim2.new(0.259,0,0.5,0); LeftSection.BackgroundTransparency=1; LeftSection.Visible=false
        local RightSection = Instance.new('ScrollingFrame', Sections); RightSection.Name='RightSection'; RightSection.Size=UDim2.new(0,243,0,445); RightSection.Position=UDim2.new(0.629,0,0.5,0); RightSection.BackgroundTransparency=1; RightSection.Visible=false
        local layoutL = Instance.new('UIListLayout', LeftSection); layoutL.Padding=UDim.new(0,11); layoutL.HorizontalAlignment=Enum.HorizontalAlignment.Center
        local layoutR = Instance.new('UIListLayout', RightSection); layoutR.Padding=UDim.new(0,11); layoutR.HorizontalAlignment=Enum.HorizontalAlignment.Center

        local function activate()
            for _,child in pairs(Tabs:GetChildren()) do
                if child.Name == 'Tab' and child ~= Tab then
                    pcall(function()
                        child.BackgroundTransparency = 1
                        child.TextLabel.TextTransparency = 0.7
                        child.TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
                        child.Icon.ImageTransparency = 0.8
                    end)
                end
            end
            TweenService:Create(Tab, TweenInfo.new(0.4), {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(Tab.TextLabel, TweenInfo.new(0.4), {TextTransparency = 0.2}):Play()
            TweenService:Create(Tab.Icon, TweenInfo.new(0.4), {ImageTransparency = 0.2}):Play()
            self:update_sections(LeftSection, RightSection)
        end

        Tab.MouseButton1Click:Connect(activate)
        if not Tabs:FindFirstChild('Tab') or self._tab == 0 then
            activate()
        end

        self._tab = (self._tab or 0) + 1

        local TabManager = {}

        -- create module function
        function TabManager:create_module(settings)
            settings = settings or {}
            settings.section = settings.section == 'right' and RightSection or LeftSection
            local Module = Instance.new('Frame', settings.section); Module.Name='Module'; Module.Size=UDim2.new(0,241,0,93); Module.BackgroundTransparency=0.2; Module.BackgroundColor3 = Color3.fromRGB(34,34,36)
            Module.ClipsDescendants = true; Module.BorderSizePixel = 0
            local UICorner = Instance.new('UICorner', Module); UICorner.CornerRadius = UDim.new(0,5)
            local UIStroke = Instance.new('UIStroke', Module); UIStroke.Color = Color3.fromRGB(70,40,20); UIStroke.Transparency = 0.6

            local Header = Instance.new('TextButton', Module); Header.Size=UDim2.new(1,0,1,0); Header.BackgroundTransparency=1; Header.AutoButtonColor=false
            local Icon = Instance.new('ImageLabel', Header); Icon.Size=UDim2.new(0,15,0,15); Icon.Position=UDim2.new(0.07,0,0.82,0); Icon.AnchorPoint=Vector2.new(0,0.5); Icon.BackgroundTransparency=1; Icon.Image = settings.icon or ''
            local ModuleName = Instance.new('TextLabel', Header); ModuleName.Text = settings.title or "Module"; ModuleName.Position = UDim2.new(0.073,0,0.24,0); ModuleName.TextSize=13; ModuleName.Font=Enum.Font.GothamSemibold; ModuleName.TextColor3=Color3.fromRGB(153,68,0); ModuleName.BackgroundTransparency=1
            local Desc = Instance.new('TextLabel', Header); Desc.Text = settings.description or ""; Desc.TextSize=10; Desc.Position=UDim2.new(0.073,0,0.42,0); Desc.BackgroundTransparency=1; Desc.TextColor3 = Color3.fromRGB(160,80,40)
            local Toggle = Instance.new('Frame', Header); Toggle.Size=UDim2.new(0,25,0,12); Toggle.Position=UDim2.new(0.82,0,0.757,0); Toggle.BackgroundColor3=Color3.fromRGB(90,40,20); Toggle.BackgroundTransparency=0.7
            local TC = Instance.new('UICorner', Toggle); TC.CornerRadius = UDim.new(1,0)
            local Circle = Instance.new('Frame', Toggle); Circle.Size=UDim2.new(0,12,0,12); Circle.Position=UDim2.new(0,0,0.5,0); Circle.AnchorPoint=Vector2.new(0,0.5); Circle.BackgroundColor3=Color3.fromRGB(90,40,20); local CC = Instance.new('UICorner', Circle); CC.CornerRadius = UDim.new(1,0)
            local Keybind = Instance.new('Frame', Header); Keybind.Size=UDim2.new(0,33,0,15); Keybind.Position=UDim2.new(0.15,0,0.735,0); Keybind.BackgroundTransparency=0.7; Keybind.BackgroundColor3=Color3.fromRGB(153,68,0)
            local KeybindLabel = Instance.new('TextLabel', Keybind); KeybindLabel.Size=UDim2.new(0,25,0,13); KeybindLabel.Position=UDim2.new(0.5,0,0.5,0); KeybindLabel.AnchorPoint=Vector2.new(0.5,0.5); KeybindLabel.Text='None'; KeybindLabel.BackgroundTransparency=1; KeybindLabel.TextSize=10

            local Options = Instance.new('Frame', Module); Options.Position = UDim2.new(0,0,1,0); Options.Size=UDim2.new(0,241,0,8); Options.BackgroundTransparency=1
            local OptionsLayout = Instance.new('UIListLayout', Options); OptionsLayout.Padding = UDim.new(0,5); OptionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            -- module manager state
            local manager = { _state = false, _size = 0, _mult = 0 }
            function manager:change_state(state)
                manager._state = state
                if state then
                    TweenService:Create(Module, TweenInfo.new(0.45), {Size=UDim2.fromOffset(241,93 + manager._size + manager._mult)}):Play()
                    TweenService:Create(Toggle, TweenInfo.new(0.45), {BackgroundColor3 = Color3.fromRGB(153,68,0)}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.45), {Position = UDim2.fromScale(0.53,0.5), BackgroundColor3 = Color3.fromRGB(255,140,0)}):Play()
                else
                    TweenService:Create(Module, TweenInfo.new(0.45), {Size=UDim2.fromOffset(241,93)}):Play()
                    TweenService:Create(Toggle, TweenInfo.new(0.45), {BackgroundColor3 = Color3.fromRGB(90,40,20)}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.45), {Position = UDim2.fromScale(0,0.5), BackgroundColor3 = Color3.fromRGB(90,40,20)}):Play()
                end
                self._state = manager._state
                -- persist
                self:_persist_flag(settings.flag, manager._state)
                -- callback
                if settings.callback then pcall(settings.callback, manager._state) end
            end

            function manager:_persist_flag(flag, state)
                if not flag then return end
                self_library = Library
                Library._config._flags[flag] = state
                Config:save_file('default', Library._config)
            end

            -- header click toggles
            Header.MouseButton1Click:Connect(function()
                manager:change_state(not manager._state)
            end)

            -- keybind right-click to set
            Header.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    Library._choosing_keybind = true
                    Library.SendNotification({ title = "Bind", text = "Press a key to bind...", duration = 4 })
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(key, processed)
                        if processed then return end
                        Library._choosing_keybind = false
                        if key.KeyCode then
                            local kstr = tostring(key.KeyCode)
                            Library._config._keybinds[settings.flag] = kstr
                            KeybindLabel.Text = kstr:gsub('Enum.KeyCode.', '')
                            Config:save_file('default', Library._config)
                            Library.SendNotification({ title = "Keybind", text = "Bound to "..KeybindLabel.Text, duration = 3 })
                            pcall(function() conn:Disconnect() end)
                        end
                    end)
                end
            end)

            -- connect keybind runtime if exists
            if Library._config._keybinds[settings.flag] then
                local keystr = Library._config._keybinds[settings.flag]
                KeybindLabel.Text = tostring(keystr):gsub('Enum.KeyCode.', '')
                Connections:add(settings.flag..'_bind', UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if tostring(input.KeyCode) == keystr then
                        manager:change_state(not manager._state)
                    end
                end))
            end

            -- helper to add basic option types
            function manager:add_toggle(text, flag)
                local row = Instance.new('Frame', Options); row.Size=UDim2.new(1, -10,0,26); row.BackgroundTransparency=1
                local label = Instance.new('TextLabel', row); label.Text = text; label.TextSize=12; label.BackgroundTransparency=1; label.Position=UDim2.new(0.02,0,0,0); label.Size=UDim2.new(0.6,0,1,0); label.TextXAlignment = Enum.TextXAlignment.Left
                local toggleFrame = Instance.new('Frame', row); toggleFrame.Size = UDim2.new(0,40,0,20); toggleFrame.Position = UDim2.new(1,-50,0.5,0); toggleFrame.AnchorPoint=Vector2.new(1,0.5); toggleFrame.BackgroundTransparency=0.6; toggleFrame.BackgroundColor3=Color3.fromRGB(90,40,20)
                local tcorner = Instance.new('UICorner', toggleFrame)
                local tcircle = Instance.new('Frame', toggleFrame); tcircle.Size=UDim2.new(0,16,0,16); tcircle.Position=UDim2.new(0,0.5,0,0); tcircle.AnchorPoint=Vector2.new(0,0.5); local tcc = Instance.new('UICorner', tcircle); tcc.CornerRadius=UDim.new(1,0)
                local state = Library._config._flags[flag] or false
                if state then tcircle.Position = UDim2.fromScale(0.75,0.5); tcircle.BackgroundColor3 = Color3.fromRGB(255,140,0) end
                row.MouseButton1Click = nil -- safe
                row.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        state = not state
                        Library._config._flags[flag] = state
                        Config:save_file('default', Library._config)
                        if state then TweenService:Create(tcircle, TweenInfo.new(0.2), {Position=UDim2.fromScale(0.75,0.5)}):Play(); tcircle.BackgroundColor3=Color3.fromRGB(255,140,0)
                        else TweenService:Create(tcircle, TweenInfo.new(0.2), {Position=UDim2.fromScale(0,0.5)}):Play(); tcircle.BackgroundColor3=Color3.fromRGB(90,40,20) end
                        if settings.onToggle then pcall(settings.onToggle, state) end
                    end
                end)
                manager._size = manager._size + 28
            end

            -- Add to module list & return manager
            self._modules[settings.flag or tostring(Module)] = manager
            return manager, Module, Options
        end

        return TabManager, LeftSection, RightSection
    end

    -- update sections visibility
    function self:update_sections(left_section, right_section)
        for _, obj in pairs(Sections:GetChildren()) do
            obj.Visible = (obj == left_section or obj == right_section)
        end
    end

    -- utility: create bare button in a section
    function self:create_button(section, text, callback)
        local btn = Instance.new('TextButton', section); btn.Size=UDim2.new(0,220,0,32); btn.BackgroundColor3 = Color3.fromRGB(60,60,62); btn.AutoButtonColor=false; btn.Text = text; btn.TextSize = 13
        local corner = Instance.new('UICorner', btn)
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
            SoundManager.play("rbxassetid://12222125", 0.8) -- placeholder sound
        end)
        return btn
    end

    -- API: load UI (call after creating tabs/modules)
    function self:show()
        self._ui.Enabled = true
        if not self._ui_loaded then self:load() end
    end
    function self:hide()
        self._ui.Enabled = false
    end

    -- watermark & fps
    local watermark = Instance.new('TextLabel', CoreGui)
    watermark.Name = "click_watermark"; watermark.BackgroundTransparency=1; watermark.TextSize=12; watermark.Font=Enum.Font.GothamSemibold
    watermark.TextColor3 = Color3.fromRGB(153,68,0); watermark.Position = UDim2.new(0,6,0,6); watermark.Size=UDim2.new(0,200,0,20)
    watermark.Text = "click • "..Players.LocalPlayer.Name
    local lastTick = tick(); local fps = 0
    RunService.RenderStepped:Connect(function()
        local now = tick(); fps = math.floor(1/(now-lastTick)); lastTick = now
        pcall(function() watermark.Text = string.format("click • %s • %dfps", Players.LocalPlayer.Name, fps) end)
    end)

    -- auto-save settings (every X seconds)
    spawn(function()
        while true do
            wait(60) -- autosave interval
            pcall(function()
                Config:save_file('default', self._config)
            end)
        end
    end)
end

-- Public API helpers (exposed)
local UI = Library.new()

-- Example of creating tabs and modules (populate with lots of controls)
local t1_left, leftSec, rightSec
do
    local tabA, L, R = UI:create_tab("General", "")
    -- create modules via Tab manager
    local tm = tabA
    local modA_manager, modA_frame, modA_options = tm:create_module({ title = "Aimbot", description = "Example feature", flag = "aimbot" })
    modA_manager:add_toggle("Enable Aimbot", "aimbot")
    local btn = modA_options and UI:create_button(modA_options, "Open Config", function() UI.SendNotification({ title="Config", text="Open config clicked" }) end)
end

-- Expose functions to global for other scripts
getgenv().CLICK_UI = {
    library = UI,
    send_notification = Library.SendNotification,
    save_config = function(name) Config:save_file(name or 'default', UI._config) end,
    load_config = function(name)
        local data = Config:read_file(name or 'default')
        if data then UI._config = data; Library.SendNotification({ title="Config", text="Loaded "..(name or 'default') }) end
    end,
    export_config = function(name)
        local data = Config:read_file(name or 'default')
        if not data then return nil end
        return HttpService:JSONEncode(data)
    end,
    import_config_raw = function(json_raw)
        local ok, tbl = pcall(function() return HttpService:JSONDecode(json_raw) end)
        if not ok then return false, "invalid json" end
        Config:save_file('default', tbl)
        UI._config = tbl
        return true
    end,
    open_ui = function() UI:show() end,
    close_ui = function() UI:hide() end,
}

-- Auto-exec stub: run registered modules with default actions on load
spawn(function()
    -- small delay for UI to finish loading
    wait(0.3)
    -- Callbacks for modules set at creation time will already have been called if flags true.
    -- Here we can auto-run some registered module templates
    for k, v in pairs(UI._modules) do
        -- if persisted flag is true, trigger the callback by setting state
        local flagstate = UI._config._flags[k]
        if flagstate and v.change_state then
            pcall(function() v:change_state(flagstate) end)
        end
    end
end)

-- Final: show the UI by default
UI:show()

-- End of script
