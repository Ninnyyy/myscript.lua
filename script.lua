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

if not isfolder("click") then
    makefolder("click")
end

function Library:add_command(label, action)
    table.insert(self._commands, { label = label, action = action })
    self:_refresh_command_palette()
end

function Library:_refresh_command_palette(filter)
    if not self._command_palette then return end
    local holder = self._command_palette.List
    if not holder then return end
    for _, child in ipairs(holder:GetChildren()) do
        if child:IsA('TextButton') then child:Destroy() end
    end
    local query = string.lower(filter or self._command_palette.Search.Text or '')
    for _, cmd in ipairs(self._commands) do
        if query == '' or string.find(string.lower(cmd.label), query, 1, true) then
            local btn = Instance.new('TextButton', holder)
            btn.Size = UDim2.new(1,-6,0,28)
            btn.BackgroundTransparency = 0.1
            btn.Text = cmd.label
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.AutoButtonColor = false
            btn.BackgroundColor3 = self._current_theme.ButtonIdle
            self:_track_theme(btn, { BackgroundColor3 = 'ButtonIdle', TextColor3 = 'TextPrimary' })
            btn.MouseButton1Click:Connect(function()
                if cmd.action then pcall(cmd.action) end
                self:_toggle_palette(false)
            end)
        end
    end
end

function Library:_toggle_palette(state)
    if not self._command_palette then return end
    local target = state ~= false
    self._command_palette.Visible = target
    if target then
        self:_refresh_command_palette()
        self._command_palette.Search.Text = ''
        self._command_palette.Search:CaptureFocus()
    else
        self._command_palette.Search:ReleaseFocus()
    end
end

local BACKUP_FOLDER = "click/backups"
if not isfolder(BACKUP_FOLDER) then
    makefolder(BACKUP_FOLDER)
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
function Util.deep_clone(tbl)
    if type(tbl) ~= "table" then return tbl end
    local clone = {}
    for k,v in pairs(tbl) do
        if type(v) == "table" then
            clone[k] = Util.deep_clone(v)
        else
            clone[k] = v
        end
    end
    return clone
end
function Util.color_to_table(color)
    if typeof(color) == 'Color3' then
        return { r = color.R, g = color.G, b = color.B }
    end
    return color
end
function Util.table_to_color(tbl, fallback)
    if typeof(tbl) == 'Color3' then return tbl end
    if type(tbl) == 'table' and tbl.r and tbl.g and tbl.b then
        return Color3.new(tbl.r, tbl.g, tbl.b)
    end
    return fallback or Color3.new(1,1,1)
end
function Util.tween(instance, time, props, easingStyle, easingDirection)
    if not (instance and props) then return end
    local style = easingStyle or Enum.EasingStyle.Quad
    local dir = easingDirection or Enum.EasingDirection.Out
    local tween
    local ok, err = pcall(function()
        tween = TweenService:Create(instance, TweenInfo.new(time or 0.25, style, dir), props)
        tween:Play()
    end)
    if not ok then warn('[click][tween]', err) end
    return tween
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

local Config = {}
function Config.default(name)
    local now = os.time()
    return {
        _flags = {},
        _keybinds = {},
        _library = {},
        ui = {},
        meta = { name = name or 'default', created_at = now, updated_at = now }
    }
end
function Config:normalize(data, name, opts)
    data = data or {}
    opts = opts or {}
    data._flags = data._flags or {}
    data._keybinds = data._keybinds or {}
    data._library = data._library or {}
    data.ui = data.ui or {}
    data.meta = data.meta or {}
    data.meta.name = name or data.meta.name or 'default'
    data.meta.created_at = data.meta.created_at or os.time()
    if opts.touch_time == false then
        data.meta.updated_at = data.meta.updated_at or os.time()
    else
        data.meta.updated_at = os.time()
    end
    return data
end
function Config:save_file(file_name, data, opts)
    opts = opts or {}
    data = self:normalize(data, file_name, { touch_time = opts.touch_time })
    if opts.skip_backup ~= true then
        self:backup_file(file_name, opts.max_backups)
    end
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
        return self:normalize(HttpService:JSONDecode(s), file_name, { touch_time = false })
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
function Config:delete_file(file_name)
    local path = 'click/'..file_name..'.json'
    if not isfile(path) then return false end
    local ok, err = pcall(function()
        delfile(path)
    end)
    if not ok then warn('[click] delete failed:', err) return false end
    return true
end
function Config:clone_file(source_name, target_name)
    if not source_name or not target_name then return false, 'missing name' end
    local data = self:read_file(source_name)
    if not data then return false, 'missing source' end
    self:save_file(target_name, data)
    return true
end
function Config:rename_file(source_name, target_name)
    local ok, err = self:clone_file(source_name, target_name)
    if not ok then return ok, err end
    self:delete_file(source_name)
    return true
end
function Config:list_backups(file_name)
    local results = {}
    for _, file in pairs(listfiles(BACKUP_FOLDER)) do
        local name, ts = file:match("click/backups/(.+)%.(%d+)%.json")
        if name and ts and name == file_name then
            table.insert(results, { name = name, timestamp = tonumber(ts), path = file })
        end
    end
    table.sort(results, function(a, b)
        return (a.timestamp or 0) > (b.timestamp or 0)
    end)
    return results
end
function Config:prune_backups(file_name, max_backups)
    max_backups = max_backups or 5
    if max_backups <= 0 then return end
    local backups = self:list_backups(file_name)
    if #backups <= max_backups then return end
    for i = max_backups + 1, #backups do
        pcall(function() delfile(backups[i].path) end)
    end
end
function Config:backup_file(file_name, max_backups)
    local path = 'click/'..file_name..'.json'
    if not isfile(path) then return false, 'missing source' end
    local data = self:read_file(file_name)
    if not data then return false, 'missing data' end
    local stamp = os.time()
    local backup_path = string.format("%s/%s.%d.json", BACKUP_FOLDER, file_name, stamp)
    local ok, err = pcall(function()
        writefile(backup_path, HttpService:JSONEncode(data))
    end)
    if not ok then warn('[click] backup failed:', err) return false, err end
    self:prune_backups(file_name, max_backups)
    return true, backup_path, stamp
end
function Config:restore_backup(file_name, timestamp)
    local backups = self:list_backups(file_name)
    if #backups == 0 then return false, 'no backups' end
    local target = backups[1]
    if timestamp then
        for _, b in ipairs(backups) do
            if tostring(b.timestamp) == tostring(timestamp) then
                target = b
                break
            end
        end
    end
    local ok, decoded = pcall(function()
        local raw = readfile(target.path)
        return HttpService:JSONDecode(raw)
    end)
    if not ok or not decoded then return false, 'bad backup' end
    local normalized = self:normalize(decoded, file_name, { touch_time = false })
    self:save_file(file_name, normalized, { skip_backup = true, touch_time = false })
    return true, target.timestamp
end

-- LIBRARY (main)
local Library = {}
Library.__index = Library
Library._themes = {
    DarkAmber = {
        BackgroundColor = Color3.fromRGB(27,27,29),
        AccentColor = Color3.fromRGB(153,68,0),
        AccentColorSecondary = Color3.fromRGB(255,140,0),
        TextPrimary = Color3.fromRGB(240, 232, 220),
        TextSecondary = Color3.fromRGB(200, 170, 140),
        BorderColor = Color3.fromRGB(40,40,42),
        ShadowColor = Color3.fromRGB(0,0,0),
        ButtonIdle = Color3.fromRGB(60,60,62),
        ButtonHover = Color3.fromRGB(80,70,65),
        ButtonPressed = Color3.fromRGB(50,40,35),
        ModuleBackground = Color3.fromRGB(34,34,36),
        ToggleOn = Color3.fromRGB(255,140,0),
        ToggleOff = Color3.fromRGB(90,40,20),
        NotificationBackground = Color3.fromRGB(28,28,30),
        NotificationAccent = Color3.fromRGB(255,140,0),
    },
    NeonPurple = {
        BackgroundColor = Color3.fromRGB(20,16,30),
        AccentColor = Color3.fromRGB(180,110,255),
        AccentColorSecondary = Color3.fromRGB(120,70,220),
        TextPrimary = Color3.fromRGB(240, 230, 255),
        TextSecondary = Color3.fromRGB(200, 180, 225),
        BorderColor = Color3.fromRGB(70,50,120),
        ShadowColor = Color3.fromRGB(10,6,20),
        ButtonIdle = Color3.fromRGB(45,35,70),
        ButtonHover = Color3.fromRGB(60,45,90),
        ButtonPressed = Color3.fromRGB(35,25,60),
        ModuleBackground = Color3.fromRGB(32,26,52),
        ToggleOn = Color3.fromRGB(180,110,255),
        ToggleOff = Color3.fromRGB(60,40,90),
        NotificationBackground = Color3.fromRGB(26,20,42),
        NotificationAccent = Color3.fromRGB(180,110,255),
    },
    CyberBlue = {
        BackgroundColor = Color3.fromRGB(15,24,36),
        AccentColor = Color3.fromRGB(70,170,255),
        AccentColorSecondary = Color3.fromRGB(40,120,220),
        TextPrimary = Color3.fromRGB(215, 235, 255),
        TextSecondary = Color3.fromRGB(170, 200, 230),
        BorderColor = Color3.fromRGB(40,80,120),
        ShadowColor = Color3.fromRGB(0,10,20),
        ButtonIdle = Color3.fromRGB(34,48,60),
        ButtonHover = Color3.fromRGB(48,70,90),
        ButtonPressed = Color3.fromRGB(30,42,54),
        ModuleBackground = Color3.fromRGB(22,32,44),
        ToggleOn = Color3.fromRGB(70,170,255),
        ToggleOff = Color3.fromRGB(40,70,100),
        NotificationBackground = Color3.fromRGB(18,26,38),
        NotificationAccent = Color3.fromRGB(70,170,255),
    },
    Midnight = {
        BackgroundColor = Color3.fromRGB(18,18,22),
        AccentColor = Color3.fromRGB(120,140,180),
        AccentColorSecondary = Color3.fromRGB(90,110,140),
        TextPrimary = Color3.fromRGB(225, 230, 240),
        TextSecondary = Color3.fromRGB(180, 190, 205),
        BorderColor = Color3.fromRGB(50,50,60),
        ShadowColor = Color3.fromRGB(0,0,0),
        ButtonIdle = Color3.fromRGB(40,40,46),
        ButtonHover = Color3.fromRGB(55,55,64),
        ButtonPressed = Color3.fromRGB(32,32,38),
        ModuleBackground = Color3.fromRGB(28,28,34),
        ToggleOn = Color3.fromRGB(120,140,180),
        ToggleOff = Color3.fromRGB(60,60,70),
        NotificationBackground = Color3.fromRGB(20,20,26),
        NotificationAccent = Color3.fromRGB(120,140,180),
    },
    CleanWhite = {
        BackgroundColor = Color3.fromRGB(242,244,248),
        AccentColor = Color3.fromRGB(60,120,220),
        AccentColorSecondary = Color3.fromRGB(40,90,190),
        TextPrimary = Color3.fromRGB(30,30,40),
        TextSecondary = Color3.fromRGB(80,80,90),
        BorderColor = Color3.fromRGB(210,215,220),
        ShadowColor = Color3.fromRGB(0,0,0),
        ButtonIdle = Color3.fromRGB(225,228,235),
        ButtonHover = Color3.fromRGB(215,220,230),
        ButtonPressed = Color3.fromRGB(200,205,215),
        ModuleBackground = Color3.fromRGB(235,238,244),
        ToggleOn = Color3.fromRGB(60,120,220),
        ToggleOff = Color3.fromRGB(180,185,195),
        NotificationBackground = Color3.fromRGB(240,242,246),
        NotificationAccent = Color3.fromRGB(60,120,220),
    }
}
Library._current_theme_name = 'DarkAmber'
Library._current_theme = Library._themes.DarkAmber
function Library.new()
    local self = setmetatable({
        _config = Config:read_file('default') or Config.default('default'),
        _ui = nil,
        _ui_loaded = false,
        _ui_animated = false,
        _tab = 0,
        _modules = {},
        _theme_targets = {},
        _tab_badges = {},
        _log_entries = {},
        _commands = {},
        _tabs = {},
        _parallax_strength = 0.03,
        _sound_theme = 'Off',
        _tooltip_layer = nil,
        _command_palette = nil,
        _console_output = nil,
        _animations_enabled = true,
        _search_boxes = {}
    }, Library)
    self._config._library = self._config._library or {}
    self._config._library.theme = self._config._library.theme or 'DarkAmber'
    self._config._library.ui_scale = self._config._library.ui_scale or 1
    self._config._library.blur_strength = self._config._library.blur_strength or 0.7
    self._config._library.parallax_enabled = self._config._library.parallax_enabled ~= false
    self._config._library.animations_enabled = self._config._library.animations_enabled ~= false
    self._config._library.sound_theme = self._config._library.sound_theme or 'Off'
    self._config._library.enable_command_palette = self._config._library.enable_command_palette ~= false
    self._config._library.appearance = self._config._library.appearance or { }
    self._config._library.appearance.accent_override = self._config._library.appearance.accent_override
    self._config._library.appearance.container_transparency = self._config._library.appearance.container_transparency or 0.06
    self._config._library.appearance.glassmorphism = self._config._library.appearance.glassmorphism or false
    self._config._library.sound_theme = self._config._library.sound_theme or 'Off'
    self._sound_theme = self._config._library.sound_theme
    self._current_theme_name = self._config._library.theme
    self._current_theme = self._themes[self._current_theme_name] or self._themes.DarkAmber
    self._animations_enabled = self._config._library.animations_enabled ~= false
    self:create_ui()
    return self
end

function Library:_track_theme(instance, propMap)
    if not instance then return end
    table.insert(self._theme_targets, { instance = instance, props = propMap })
end

function Library:apply_theme_to_existing_ui()
    local base = self._themes[self._current_theme_name] or self._themes.DarkAmber
    local appearance = self._config._library.appearance or {}
    local theme = Util.shallow_copy(base)
    if appearance.accent_override then
        local c = Util.table_to_color(appearance.accent_override, base.AccentColor)
        theme.AccentColor = c
        theme.ToggleOn = c
        theme.NotificationAccent = c
    end
    for _, target in ipairs(self._theme_targets) do
        local inst = target.instance
        if inst and inst.Parent then
            local props = {}
            for prop, key in pairs(target.props or {}) do
                local value = theme[key] or target.default
                props[prop] = value
            end
            Util.tween(inst, self._config._library.animations_enabled and 0.2 or 0, props)
        end
    end
end

function Library:set_theme(name)
    if not self._themes[name] then return end
    self._current_theme_name = name
    self._current_theme = self._themes[name]
    self._config._library.theme = name
    Config:save_file('default', self._config)
    self:apply_theme_to_existing_ui()
    self:log('info', 'Theme set to '..tostring(name))
end

function Library:_create_tooltip_layer()
    if self._tooltip_layer then return self._tooltip_layer end
    if not self._ui then return end
    local theme = self._current_theme or self._themes.DarkAmber
    local tip = Instance.new('Frame')
    tip.Name = 'Tooltip'
    tip.Size = UDim2.new(0,150,0,32)
    tip.BackgroundColor3 = theme.ModuleBackground
    tip.BackgroundTransparency = 0.05
    tip.Visible = false
    tip.Parent = self._ui
    tip.ZIndex = 10
    local stroke = Instance.new('UIStroke', tip)
    stroke.Thickness = 1
    stroke.Color = theme.BorderColor
    local corner = Instance.new('UICorner', tip)
    corner.CornerRadius = UDim.new(0,6)
    local label = Instance.new('TextLabel', tip)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,-10,1,-10)
    label.Position = UDim2.new(0,5,0,5)
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextColor3 = theme.TextPrimary
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Name = 'Text'
    self:_track_theme(tip, { BackgroundColor3 = 'ModuleBackground' })
    self:_track_theme(stroke, { Color = 'BorderColor' })
    self:_track_theme(label, { TextColor3 = 'TextPrimary' })
    self._tooltip_layer = tip
    return tip
end

function Library:_attach_tooltip(instance, text)
    if not instance then return end
    local tip = self:_create_tooltip_layer()
    if not tip then return end
    instance.MouseEnter:Connect(function()
        tip.Visible = true
        local lbl = tip:FindFirstChild('Text')
        if lbl then lbl.Text = text or '' end
    end)
    instance.MouseLeave:Connect(function()
        tip.Visible = false
    end)
    instance.MouseMoved:Connect(function(x,y)
        tip.Position = UDim2.fromOffset(x+12, y+12)
    end)
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
    local theme = Library._current_theme or Library._themes.DarkAmber
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(1,0,0,60); Notification.BackgroundTransparency = 1; Notification.BorderSizePixel = 0
    Notification.Name = "Notification"; Notification.Parent = NotificationContainer; Notification.AutomaticSize = Enum.AutomaticSize.Y

    local Inner = Instance.new("Frame", Notification)
    Inner.Size = UDim2.new(1,0,0,60); Inner.Position = UDim2.new(0,0,0,0); Inner.BackgroundColor3 = theme.NotificationBackground
    Inner.BackgroundTransparency = 0.05; Inner.BorderSizePixel=0; Inner.Name = "InnerFrame"; Inner.AutomaticSize = Enum.AutomaticSize.Y

    local accent = theme.NotificationAccent
    local typ = settings.type or 'info'
    local typeColors = {
        success = Color3.fromRGB(60,190,120),
        error = Color3.fromRGB(220,70,70),
        warning = Color3.fromRGB(235,170,70),
        info = accent
    }
    accent = typeColors[typ] or accent
    local AccentBar = Instance.new('Frame', Inner)
    AccentBar.Size = UDim2.new(0,4,1,0)
    AccentBar.Position = UDim2.new(0,0,0,0)
    AccentBar.BackgroundColor3 = accent
    AccentBar.BorderSizePixel = 0

    local UICorner = Instance.new("UICorner", Inner); UICorner.CornerRadius = UDim.new(0,6)
    local Title = Instance.new("TextLabel", Inner); Title.Text = settings.title or "Notification"; Title.TextSize=14; Title.Position=UDim2.new(0,10,0,6)
    Title.Size = UDim2.new(1,-16,0,20); Title.BackgroundTransparency=1; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.TextColor3 = theme.TextPrimary
    local Body = Instance.new("TextLabel", Inner); Body.Text = settings.text or ""; Body.Position = UDim2.new(0,10,0,26)
    Body.Size = UDim2.new(1,-16,0,30); Body.BackgroundTransparency=1; Body.TextSize=12; Body.TextXAlignment=Enum.TextXAlignment.Left; Body.TextYAlignment = Enum.TextYAlignment.Top; Body.TextColor3 = theme.TextSecondary

    local function destroy_now()
        Util.tween(Inner, 0.3, {Position = UDim2.new(1,310,0,Inner.Position.Y.Offset + NotificationContainer.Size.Y.Offset)})
        task.delay(0.32, function()
            Notification:Destroy()
        end)
    end

    Inner.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if settings.on_click then pcall(settings.on_click) end
            destroy_now()
        end
    end)

    task.spawn(function()
        task.wait(0.1)
        local totalHeight = Title.TextBounds.Y + Body.TextBounds.Y + 18
        Inner.Size = UDim2.new(1,0,0,totalHeight)
    end)
    task.spawn(function()
        Util.tween(Inner, 0.35, {Position = UDim2.new(0,0,0,10 + NotificationContainer.Size.Y.Offset)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local duration = settings.sticky and math.huge or settings.duration or 4
        task.wait(duration)
        destroy_now()
    end)
    SoundManager.play_event(Library._sound_theme, 'notify')
end

-- Basic sound manager (optional, uses sound instances)
local SoundManager = { _themes = {
    Off = {},
    Soft = {
        toggle_on = "rbxassetid://4590657391", toggle_off = "rbxassetid://4590657391",
        tab_switch = "rbxassetid://4590662769", button_click = "rbxassetid://4590657391", notify = "rbxassetid://4590657391"
    },
    Clicky = {
        toggle_on = "rbxassetid://9118823101", toggle_off = "rbxassetid://9118823101",
        tab_switch = "rbxassetid://9118823101", button_click = "rbxassetid://9118823101", notify = "rbxassetid://9118823101"
    },
    Retro = {
        toggle_on = "rbxassetid://7149255557", toggle_off = "rbxassetid://7149255557",
        tab_switch = "rbxassetid://7149255557", button_click = "rbxassetid://7149255557", notify = "rbxassetid://7149255557"
    }
}}
function SoundManager.play(soundId, volume)
    if not soundId or soundId == '' then return end
    volume = volume or 1
    local ok, s = pcall(function()
        local snd = Instance.new("Sound")
        snd.SoundId = soundId
        snd.Volume = volume
        snd.Parent = workspace
        snd.PlayOnRemove = false
        snd:Play()
        Debris:AddItem(snd, 3)
        return snd
    end)
    if not ok then return end
    return s
end
function SoundManager.play_event(theme_name, eventName)
    local theme = SoundManager._themes[theme_name or 'Off']
    if not theme then return end
    local soundId = theme[eventName]
    if not soundId then return end
    SoundManager.play(soundId, 0.8)
end

-- UI creation (main screen)
function Library:create_ui()
    local theme = self._current_theme or self._themes.DarkAmber
    local click = Instance.new('ScreenGui')
    click.ResetOnSpawn = false
    click.Name = 'click'
    click.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    click.Parent = CoreGui
    self._ui = click

    local Shadow = Instance.new('Frame', click)
    Shadow.Name = 'Shadow'
    Shadow.AnchorPoint = Vector2.new(0.5,0.5)
    Shadow.Position = UDim2.new(0.5,4,0.5,8)
    Shadow.Size = UDim2.fromOffset(710,491)
    Shadow.BackgroundColor3 = theme.ShadowColor
    Shadow.BackgroundTransparency = 0.7
    Shadow.BorderSizePixel = 0
    local shadowCorner = Instance.new('UICorner', Shadow); shadowCorner.CornerRadius = UDim.new(0,12)
    self:_track_theme(Shadow, { BackgroundColor3 = 'ShadowColor' })

    local Container = Instance.new('Frame', click)
    Container.Name = 'Container'
    Container.Size = UDim2.fromOffset(0,0)
    Container.Position = UDim2.new(0.5,0,0.5,0)
    Container.AnchorPoint = Vector2.new(0.5,0.5)
    Container.BackgroundColor3 = theme.BackgroundColor
    Container.BackgroundTransparency = self._config._library.appearance.container_transparency or 0.06
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    self._container = Container
    self._shadow = Shadow

    local UICorner = Instance.new("UICorner", Container); UICorner.CornerRadius = UDim.new(0,10)
    local UIStroke = Instance.new("UIStroke", Container); UIStroke.Color = theme.BorderColor; UIStroke.Transparency = 0.6
    self:_track_theme(Container, { BackgroundColor3 = 'BackgroundColor' })
    self:_track_theme(UIStroke, { Color = 'BorderColor' })

    local UIScale = Instance.new('UIScale', Container)
    UIScale.Scale = self._config._library.ui_scale or 1

    local AcrylicStrength = self._config._library.blur_strength or 0.7
    if AcrylicBlur and AcrylicBlur.new then
        pcall(function()
            self._blur = AcrylicBlur.new(Container, AcrylicStrength)
        end)
    end

    self:_create_tooltip_layer()

    local Handler = Instance.new('Frame', Container); Handler.Name='Handler'; Handler.Size=UDim2.new(0,698,0,479); Handler.BackgroundTransparency=1
    self:_track_theme(Handler, { BackgroundColor3 = 'BackgroundColor' })

    local Palette = Instance.new('Frame', click)
    Palette.Name = 'CommandPalette'
    Palette.AnchorPoint = Vector2.new(0.5,0.5)
    Palette.Position = UDim2.new(0.5,0,0.5,0)
    Palette.Size = UDim2.new(0,320,0,200)
    Palette.Visible = false
    Palette.BackgroundColor3 = theme.ModuleBackground
    Palette.BackgroundTransparency = 0.05
    Palette.ZIndex = 8
    local pCorner = Instance.new('UICorner', Palette); pCorner.CornerRadius = UDim.new(0,8)
    local pStroke = Instance.new('UIStroke', Palette); pStroke.Color = theme.BorderColor; pStroke.Thickness = 1
    self:_track_theme(Palette, { BackgroundColor3 = 'ModuleBackground' })
    self:_track_theme(pStroke, { Color = 'BorderColor' })
    local Search = Instance.new('TextBox', Palette)
    Search.Name = 'Search'
    Search.Size = UDim2.new(1,-16,0,28)
    Search.Position = UDim2.new(0,8,0,8)
    Search.BackgroundColor3 = theme.ButtonIdle
    Search.Text = ''
    Search.PlaceholderText = 'Type a command...'
    Search.TextColor3 = theme.TextPrimary
    Search.TextSize = 13
    Search.ClearTextOnFocus = false
    local sCorner = Instance.new('UICorner', Search); sCorner.CornerRadius = UDim.new(0,6)
    self:_track_theme(Search, { BackgroundColor3 = 'ButtonIdle', TextColor3 = 'TextPrimary' })
    local List = Instance.new('ScrollingFrame', Palette)
    List.Name = 'List'
    List.BackgroundTransparency = 1
    List.Position = UDim2.new(0,8,0,44)
    List.Size = UDim2.new(1,-16,1,-52)
    List.ScrollBarThickness = 4
    local listLayout = Instance.new('UIListLayout', List)
    listLayout.Padding = UDim.new(0,6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self._command_palette = Palette
    Palette.List = List
    Palette.Search = Search
    Search:GetPropertyChangedSignal('Text'):Connect(function()
        self:_refresh_command_palette(Search.Text)
    end)

    -- Left tabs
    local Tabs = Instance.new('ScrollingFrame', Handler); Tabs.Name='Tabs'
    Tabs.Size = UDim2.new(0,129,0,401); Tabs.Position = UDim2.new(0.026,0,0.111,0); Tabs.BackgroundTransparency=1; Tabs.ScrollBarImageTransparency=1
    local TabsLayout = Instance.new('UIListLayout', Tabs); TabsLayout.Padding = UDim.new(0,4); TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Title (animated)
    local ClientName = Instance.new('TextLabel', Handler)
    ClientName.Name='ClientName'; ClientName.Size=UDim2.new(0,150,0,20); ClientName.Position=UDim2.new(0.056,0,0.055,0)
    ClientName.BackgroundTransparency=1; ClientName.TextXAlignment=Enum.TextXAlignment.Left; ClientName.TextSize=13
    ClientName.Font = Enum.Font.GothamSemibold; ClientName.TextColor3 = theme.AccentColor
    self:_track_theme(ClientName, { TextColor3 = 'AccentColor' })
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
    Divider.BackgroundColor3 = theme.AccentColor; Divider.BackgroundTransparency = 0.4; Divider.BorderSizePixel = 0
    self:_track_theme(Divider, { BackgroundColor3 = 'AccentColor' })
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
        self:set_theme(self._config._library.theme or 'DarkAmber')
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

    function self:log(log_type, text)
        table.insert(self._log_entries, { type = log_type or 'info', text = tostring(text), timestamp = os.time() })
        if self._console_output then pcall(self._console_output) end
    end

    function self:_update_badge(tab_obj)
        local badge = self._tab_badges[tab_obj]
        if not badge then return end
        local count = 0
        for _, mod in pairs(self._modules) do
            if mod._tab == tab_obj and mod._state then
                count = count + 1
            end
        end
        badge.Text = tostring(count)
        badge.Visible = count > 0
    end

    Connections:add('palette_toggle', UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if not self._config._library.enable_command_palette then return end
        if input.KeyCode == Enum.KeyCode.K and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
            self:_toggle_palette(not (self._command_palette and self._command_palette.Visible))
        end
    end))

    -- Tab creation
    function self:create_tab(title, icon)
        local Tab = Instance.new('TextButton', Tabs); Tab.Name='Tab'; Tab.Size=UDim2.new(0,129,0,38); Tab.BackgroundTransparency=1; Tab.AutoButtonColor=false
        Tab.LayoutOrder = self._tab or 0
        local TextLabel = Instance.new('TextLabel', Tab); TextLabel.Size=UDim2.new(0,90,0,16); TextLabel.Position=UDim2.new(0.24,0,0.5,0)
        TextLabel.BackgroundTransparency=1; TextLabel.Text = title; TextLabel.TextXAlignment = Enum.TextXAlignment.Left; TextLabel.TextSize=13; TextLabel.Font = Enum.Font.GothamSemibold; TextLabel.TextColor3=self._current_theme.TextPrimary; TextLabel.TextTransparency=0.7
        local Icon = Instance.new('ImageLabel', Tab); Icon.Name='Icon'; Icon.Size=UDim2.new(0,16,0,16); Icon.Position=UDim2.new(0.1,0,0.5,0); Icon.AnchorPoint=Vector2.new(0,0.5); Icon.BackgroundTransparency=1; Icon.Image=icon; Icon.ImageTransparency=0.8
        local Badge = Instance.new('TextLabel', Tab); Badge.Name='Badge'; Badge.Size=UDim2.new(0,18,0,18); Badge.Position=UDim2.new(1,-22,0.5,0); Badge.AnchorPoint=Vector2.new(1,0.5)
        Badge.BackgroundColor3 = self._current_theme.AccentColorSecondary; Badge.TextColor3 = self._current_theme.TextPrimary; Badge.Font=Enum.Font.GothamBold; Badge.TextSize=11; Badge.Text="0"; Badge.BackgroundTransparency=0.2; Badge.Visible=false
        local badgeCorner = Instance.new('UICorner', Badge); badgeCorner.CornerRadius = UDim.new(1,0)
        self._tab_badges[Tab] = Badge
        self:_track_theme(TextLabel, { TextColor3 = 'TextPrimary' })
        self:_track_theme(Badge, { BackgroundColor3 = 'AccentColorSecondary', TextColor3 = 'TextPrimary' })

        local LeftSection = Instance.new('ScrollingFrame', Sections); LeftSection.Name='LeftSection'; LeftSection.Size=UDim2.new(0,243,0,445); LeftSection.Position = UDim2.new(0.259,0,0.5,0); LeftSection.BackgroundTransparency=1; LeftSection.Visible=false
        local RightSection = Instance.new('ScrollingFrame', Sections); RightSection.Name='RightSection'; RightSection.Size=UDim2.new(0,243,0,445); RightSection.Position=UDim2.new(0.629,0,0.5,0); RightSection.BackgroundTransparency=1; RightSection.Visible=false
        local layoutL = Instance.new('UIListLayout', LeftSection); layoutL.Padding=UDim.new(0,11); layoutL.HorizontalAlignment=Enum.HorizontalAlignment.Center
        local layoutR = Instance.new('UIListLayout', RightSection); layoutR.Padding=UDim.new(0,11); layoutR.HorizontalAlignment=Enum.HorizontalAlignment.Center

        local function add_search_box(section)
            local search = Instance.new('TextBox', section)
            search.Size = UDim2.new(1, -10, 0, 28)
            search.BackgroundColor3 = self._current_theme.ModuleBackground
            search.BackgroundTransparency = 0.2
            search.TextColor3 = self._current_theme.TextPrimary
            search.PlaceholderText = 'Search modules...'
            search.TextSize = 12
            search.Font = Enum.Font.Gotham
            search.ClearTextOnFocus = false
            local corner = Instance.new('UICorner', search); corner.CornerRadius = UDim.new(0,6)
            self:_track_theme(search, { BackgroundColor3 = 'ModuleBackground', TextColor3 = 'TextPrimary' })
            self._search_boxes[search] = true
            search:GetPropertyChangedSignal('Text'):Connect(function()
                local q = string.lower(search.Text)
                for _, mod in pairs(self._modules) do
                    if mod._section == section then
                        local name = string.lower(mod._title or '')
                        mod._frame.Visible = q == '' or string.find(name, q, 1, true) ~= nil
                    end
                end
            end)
        end
        add_search_box(LeftSection)
        add_search_box(RightSection)

        local function activate()
            for _,child in pairs(Tabs:GetChildren()) do
                if child.Name == 'Tab' and child ~= Tab then
                    pcall(function()
                        Util.tween(child, Library._animations_enabled and 0.25 or 0, {BackgroundTransparency = 1})
                        Util.tween(child.TextLabel, Library._animations_enabled and 0.25 or 0, {TextTransparency = 0.7, TextColor3 = Library._current_theme.TextSecondary})
                        Util.tween(child.Icon, Library._animations_enabled and 0.25 or 0, {ImageTransparency = 0.8})
                    end)
                end
            end
            Util.tween(Tab, Library._animations_enabled and 0.3 or 0, {BackgroundTransparency = 0.5})
            Util.tween(Tab.TextLabel, Library._animations_enabled and 0.3 or 0, {TextTransparency = 0.2})
            Util.tween(Tab.Icon, Library._animations_enabled and 0.3 or 0, {ImageTransparency = 0.2})
            self:update_sections(LeftSection, RightSection)
            SoundManager.play_event(Library._sound_theme, 'tab_switch')
        end

        Tab.MouseButton1Click:Connect(activate)
        if not Tabs:FindFirstChild('Tab') or self._tab == 0 then
            activate()
        end

        self._tab = (self._tab or 0) + 1

        if self._config._library.enable_command_palette then
            self:add_command('Open Tab: '..title, function()
                activate()
            end)
        end

        local TabManager = {}

        -- create module function
        function TabManager:create_module(settings)
            settings = settings or {}
            settings.section = settings.section == 'right' and RightSection or LeftSection
            local Module = Instance.new('Frame', settings.section); Module.Name='Module'; Module.Size=UDim2.new(0,241,0,93); Module.BackgroundTransparency=0.2; Module.BackgroundColor3 = self._current_theme.ModuleBackground
            Module.ClipsDescendants = true; Module.BorderSizePixel = 0
            local UICorner = Instance.new('UICorner', Module); UICorner.CornerRadius = UDim.new(0,5)
            local UIStroke = Instance.new('UIStroke', Module); UIStroke.Color = self._current_theme.BorderColor; UIStroke.Transparency = 0.6
            self:_track_theme(Module, { BackgroundColor3 = 'ModuleBackground' })
            self:_track_theme(UIStroke, { Color = 'BorderColor' })

            local Header = Instance.new('TextButton', Module); Header.Size=UDim2.new(1,0,1,0); Header.BackgroundTransparency=1; Header.AutoButtonColor=false
            local Icon = Instance.new('ImageLabel', Header); Icon.Size=UDim2.new(0,15,0,15); Icon.Position=UDim2.new(0.07,0,0.82,0); Icon.AnchorPoint=Vector2.new(0,0.5); Icon.BackgroundTransparency=1; Icon.Image = settings.icon or ''
            local ModuleName = Instance.new('TextLabel', Header); ModuleName.Text = settings.title or "Module"; ModuleName.Position = UDim2.new(0.073,0,0.24,0); ModuleName.TextSize=13; ModuleName.Font=Enum.Font.GothamSemibold; ModuleName.TextColor3=self._current_theme.AccentColor; ModuleName.BackgroundTransparency=1
            local Desc = Instance.new('TextLabel', Header); Desc.Text = settings.description or ""; Desc.TextSize=10; Desc.Position=UDim2.new(0.073,0,0.42,0); Desc.BackgroundTransparency=1; Desc.TextColor3 = self._current_theme.TextSecondary
            local Toggle = Instance.new('Frame', Header); Toggle.Size=UDim2.new(0,25,0,12); Toggle.Position=UDim2.new(0.82,0,0.757,0); Toggle.BackgroundColor3=self._current_theme.ToggleOff; Toggle.BackgroundTransparency=0.7
            local TC = Instance.new('UICorner', Toggle); TC.CornerRadius = UDim.new(1,0)
            local Circle = Instance.new('Frame', Toggle); Circle.Size=UDim2.new(0,12,0,12); Circle.Position=UDim2.new(0,0,0.5,0); Circle.AnchorPoint=Vector2.new(0,0.5); Circle.BackgroundColor3=self._current_theme.ToggleOff; local CC = Instance.new('UICorner', Circle); CC.CornerRadius = UDim.new(1,0)
            local Keybind = Instance.new('Frame', Header); Keybind.Size=UDim2.new(0,33,0,15); Keybind.Position=UDim2.new(0.15,0,0.735,0); Keybind.BackgroundTransparency=0.7; Keybind.BackgroundColor3=self._current_theme.AccentColor
            local KeybindLabel = Instance.new('TextLabel', Keybind); KeybindLabel.Size=UDim2.new(0,25,0,13); KeybindLabel.Position=UDim2.new(0.5,0,0.5,0); KeybindLabel.AnchorPoint=Vector2.new(0.5,0.5); KeybindLabel.Text='None'; KeybindLabel.BackgroundTransparency=1; KeybindLabel.TextSize=10
            self:_track_theme(ModuleName, { TextColor3 = 'AccentColor' })
            self:_track_theme(Desc, { TextColor3 = 'TextSecondary' })
            self:_track_theme(Toggle, { BackgroundColor3 = 'ToggleOff' })
            self:_track_theme(Circle, { BackgroundColor3 = 'ToggleOff' })
            self:_track_theme(Keybind, { BackgroundColor3 = 'AccentColor' })

            local Options = Instance.new('Frame', Module); Options.Position = UDim2.new(0,0,1,0); Options.Size=UDim2.new(0,241,0,8); Options.BackgroundTransparency=1
            local OptionsLayout = Instance.new('UIListLayout', Options); OptionsLayout.Padding = UDim.new(0,5); OptionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            -- module manager state
            local manager = { _state = false, _size = 0, _mult = 0, _frame = Module, _title = settings.title or "Module", _section = settings.section, _tab = Tab }
            function manager:change_state(state)
                manager._state = state
                if state then
                    Util.tween(Module, Library._animations_enabled and 0.3 or 0, {Size=UDim2.fromOffset(241,93 + manager._size + manager._mult)})
                    Util.tween(Toggle, Library._animations_enabled and 0.3 or 0, {BackgroundColor3 = Library._current_theme.ToggleOn})
                    Util.tween(Circle, Library._animations_enabled and 0.3 or 0, {Position = UDim2.fromScale(0.53,0.5), BackgroundColor3 = Library._current_theme.ToggleOn})
                    SoundManager.play_event(Library._sound_theme, 'toggle_on')
                else
                    Util.tween(Module, Library._animations_enabled and 0.25 or 0, {Size=UDim2.fromOffset(241,93)})
                    Util.tween(Toggle, Library._animations_enabled and 0.25 or 0, {BackgroundColor3 = Library._current_theme.ToggleOff})
                    Util.tween(Circle, Library._animations_enabled and 0.25 or 0, {Position = UDim2.fromScale(0,0.5), BackgroundColor3 = Library._current_theme.ToggleOff})
                    SoundManager.play_event(Library._sound_theme, 'toggle_off')
                end
                self._state = manager._state
                -- persist
                self:_persist_flag(settings.flag, manager._state)
                Library:_update_badge(Tab)
                -- callback
                if settings.callback then pcall(settings.callback, manager._state) end
            end

            function manager:_persist_flag(flag, state)
                if not flag then return end
                self_library = Library
                Library._config._flags[flag] = state
                Config:save_file('default', Library._config)
            end

            function manager:add_section(title)
                local SectionFrame = Instance.new('Frame', Options)
                SectionFrame.Size = UDim2.new(1,-10,0,30)
                SectionFrame.BackgroundTransparency = 1
                local HeaderRow = Instance.new('TextButton', SectionFrame)
                HeaderRow.Size = UDim2.new(1,0,0,26)
                HeaderRow.BackgroundTransparency = 1
                HeaderRow.AutoButtonColor = false
                local Arrow = Instance.new('TextLabel', HeaderRow)
                Arrow.Size = UDim2.new(0,18,0,18)
                Arrow.Position = UDim2.new(0,0,0.5,0)
                Arrow.AnchorPoint = Vector2.new(0,0.5)
                Arrow.Text = '>'
                Arrow.TextSize = 12
                Arrow.Font = Enum.Font.GothamBold
                Arrow.BackgroundTransparency = 1
                Arrow.TextColor3 = Library._current_theme.TextSecondary
                local TitleLbl = Instance.new('TextLabel', HeaderRow)
                TitleLbl.Size = UDim2.new(1,-20,1,0)
                TitleLbl.Position = UDim2.new(0,20,0,0)
                TitleLbl.BackgroundTransparency = 1
                TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                TitleLbl.Text = title or 'Section'
                TitleLbl.TextColor3 = Library._current_theme.TextPrimary
                TitleLbl.Font = Enum.Font.Gotham
                TitleLbl.TextSize = 12
                Library:_track_theme(Arrow, { TextColor3 = 'TextSecondary' })
                Library:_track_theme(TitleLbl, { TextColor3 = 'TextPrimary' })

                local Body = Instance.new('Frame', SectionFrame)
                Body.Size = UDim2.new(1,0,0,0)
                Body.Position = UDim2.new(0,0,1,0)
                Body.BackgroundTransparency = 1
                Body.Visible = false
                local layout = Instance.new('UIListLayout', Body)
                layout.Padding = UDim.new(0,5)
                layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

                local section = { _body = Body, _open = false, _size = 0 }
                function section:update_size()
                    manager._mult = manager._mult + (self._open and self._size or 0)
                    manager._size = manager._size + (self._open and self._size or 0)
                end
                function section:add_child(child)
                    if not child then return end
                    child.Parent = Body
                    Body.Visible = true
                    self._size = self._size + child.Size.Y.Offset + 5
                end
                local function toggle()
                    section._open = not section._open
                    Arrow.Text = section._open and 'v' or '>'
                    Body.Visible = section._open
                    Util.tween(Body, Library._animations_enabled and 0.25 or 0, {Size = UDim2.new(1,0,0, section._open and section._size or 0)})
                    if manager._state then
                        manager:change_state(true)
                    end
                end
                HeaderRow.MouseButton1Click:Connect(toggle)
                manager._mult = manager._mult + 30
                return section
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
            function manager:add_toggle(text, flag, callback)
                local row = Instance.new('Frame', Options); row.Size=UDim2.new(1, -10,0,26); row.BackgroundTransparency=1
                local label = Instance.new('TextLabel', row); label.Text = text; label.TextSize=12; label.BackgroundTransparency=1; label.Position=UDim2.new(0.02,0,0,0); label.Size=UDim2.new(0.6,0,1,0); label.TextXAlignment = Enum.TextXAlignment.Left
                local toggleFrame = Instance.new('Frame', row); toggleFrame.Size = UDim2.new(0,40,0,20); toggleFrame.Position = UDim2.new(1,-50,0.5,0); toggleFrame.AnchorPoint=Vector2.new(1,0.5); toggleFrame.BackgroundTransparency=0.6; toggleFrame.BackgroundColor3=Color3.fromRGB(90,40,20)
                local tcorner = Instance.new('UICorner', toggleFrame)
                local tcircle = Instance.new('Frame', toggleFrame); tcircle.Size=UDim2.new(0,16,0,16); tcircle.Position=UDim2.new(0,0.5,0,0); tcircle.AnchorPoint=Vector2.new(0,0.5); local tcc = Instance.new('UICorner', tcircle); tcc.CornerRadius=UDim.new(1,0)
                local state = Library._config._flags[flag] or false
                if state then tcircle.Position = UDim2.fromScale(0.75,0.5); tcircle.BackgroundColor3 = Library._current_theme.ToggleOn end
                row.MouseButton1Click = nil -- safe
                row.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        state = not state
                        Library._config._flags[flag] = state
                        Config:save_file('default', Library._config)
                        if state then TweenService:Create(tcircle, TweenInfo.new(0.2), {Position=UDim2.fromScale(0.75,0.5)}):Play(); tcircle.BackgroundColor3=Library._current_theme.ToggleOn
                        else TweenService:Create(tcircle, TweenInfo.new(0.2), {Position=UDim2.fromScale(0,0.5)}):Play(); tcircle.BackgroundColor3=Library._current_theme.ToggleOff end
                        if callback then pcall(callback, state) end
                    end
                end)
                manager._size = manager._size + 28
            end

            function manager:add_slider(settings)
                settings = settings or {}
                local min = settings.min or 0
                local max = settings.max or 1
                local default = settings.default or min
                local flag = settings.flag
                local value = Library._config._flags[flag] or default
                local row = Instance.new('Frame', Options); row.Size=UDim2.new(1, -10,0,32); row.BackgroundTransparency=1
                local label = Instance.new('TextLabel', row); label.BackgroundTransparency=1; label.Text = settings.text or 'Slider'; label.TextXAlignment = Enum.TextXAlignment.Left; label.Position=UDim2.new(0.02,0,0,0); label.Size=UDim2.new(0.6,0,1,0); label.TextColor3 = Library._current_theme.TextPrimary; label.Font = Enum.Font.Gotham; label.TextSize = 12
                local valueLabel = Instance.new('TextLabel', row); valueLabel.BackgroundTransparency=1; valueLabel.Text = tostring(value); valueLabel.TextSize=12; valueLabel.Font=Enum.Font.Gotham; valueLabel.TextColor3=Library._current_theme.TextSecondary; valueLabel.Position = UDim2.new(0.7,0,0,0); valueLabel.Size = UDim2.new(0.28,0,1,0)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                local bar = Instance.new('Frame', row); bar.Size=UDim2.new(0.6,0,0,6); bar.Position=UDim2.new(0.02,0,1,-8); bar.BackgroundColor3 = Library._current_theme.BorderColor; bar.BorderSizePixel=0
                local bcorner = Instance.new('UICorner', bar); bcorner.CornerRadius = UDim.new(1,0)
                local fill = Instance.new('Frame', bar); fill.Size = UDim2.new((value - min)/(max - min),0,1,0); fill.BackgroundColor3 = Library._current_theme.AccentColor; fill.BorderSizePixel=0
                local fcorner = Instance.new('UICorner', fill); fcorner.CornerRadius = UDim.new(1,0)
                Library:_track_theme(label, { TextColor3 = 'TextPrimary' })
                Library:_track_theme(valueLabel, { TextColor3 = 'TextSecondary' })
                Library:_track_theme(bar, { BackgroundColor3 = 'BorderColor' })
                Library:_track_theme(fill, { BackgroundColor3 = 'AccentColor' })
                local function set_value(new)
                    value = math.clamp(new, min, max)
                    Library._config._flags[flag] = value
                    Config:save_file('default', Library._config)
                    fill.Size = UDim2.new((value - min)/(max - min),0,1,0)
                    valueLabel.Text = string.format("%.2f", value)
                    if settings.on_changed then pcall(settings.on_changed, value) end
                end
                bar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        local conn
                        local function update(pos)
                            local rel = (pos.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X
                            set_value(min + (max-min) * rel)
                        end
                        update(inp.Position)
                        conn = UserInputService.InputChanged:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseMovement then
                                update(i.Position)
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(endInput)
                            if endInput.UserInputType == Enum.UserInputType.MouseButton1 and conn then conn:Disconnect() end
                        end)
                    end
                end)
                manager._size = manager._size + 36
                return set_value
            end

            function manager:add_dropdown(settings)
                settings = settings or {}
                local flag = settings.flag or settings.text
                local current = Library._config._flags[flag] or settings.default or (settings.items and settings.items[1])
                local row = Instance.new('Frame', Options); row.Size=UDim2.new(1,-10,0,32); row.BackgroundTransparency=1
                local label = Instance.new('TextLabel', row); label.Text = settings.text or 'Dropdown'; label.TextSize=12; label.BackgroundTransparency=1; label.Position=UDim2.new(0.02,0,0,0); label.Size=UDim2.new(0.6,0,1,0); label.TextXAlignment = Enum.TextXAlignment.Left
                local button = Instance.new('TextButton', row); button.Size=UDim2.new(0.36,0,0,24); button.Position=UDim2.new(0.62,0,0.5,0); button.AnchorPoint=Vector2.new(0,0.5); button.Text = tostring(current); button.TextSize=12; button.Font=Enum.Font.Gotham; button.BackgroundColor3 = Library._current_theme.ButtonIdle; button.AutoButtonColor=false
                local bcorner = Instance.new('UICorner', button); bcorner.CornerRadius = UDim.new(0,5)
                self:_track_theme(label, { TextColor3 = 'TextPrimary' })
                self:_track_theme(button, { BackgroundColor3 = 'ButtonIdle', TextColor3 = 'TextPrimary' })

                local popup = Instance.new('Frame', row)
                popup.Size = UDim2.new(1,-10,0,0)
                popup.Position = UDim2.new(0,5,1,2)
                popup.BackgroundColor3 = Library._current_theme.ModuleBackground
                popup.BorderSizePixel = 0
                popup.Visible = false
                popup.ClipsDescendants = true
                local pcorner = Instance.new('UICorner', popup); pcorner.CornerRadius = UDim.new(0,6)
                local search = Instance.new('TextBox', popup)
                search.Size = UDim2.new(1,-10,0,24)
                search.Position = UDim2.new(0,5,0,5)
                search.BackgroundColor3 = Library._current_theme.ButtonIdle
                search.PlaceholderText = 'Search...'
                search.TextSize = 12
                search.TextColor3 = Library._current_theme.TextPrimary
                search.ClearTextOnFocus = false
                local scorner = Instance.new('UICorner', search); scorner.CornerRadius = UDim.new(0,5)
                local list = Instance.new('ScrollingFrame', popup)
                list.Size = UDim2.new(1,-10,1,-38)
                list.Position = UDim2.new(0,5,0,34)
                list.BackgroundTransparency = 1
                list.ScrollBarThickness = 4
                local layout = Instance.new('UIListLayout', list)
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0,4)
                self:_track_theme(popup, { BackgroundColor3 = 'ModuleBackground' })
                self:_track_theme(search, { BackgroundColor3 = 'ButtonIdle', TextColor3 = 'TextPrimary' })

                local function refresh(filter)
                    for _, child in ipairs(list:GetChildren()) do
                        if child:IsA('TextButton') then child:Destroy() end
                    end
                    local query = string.lower(filter or '')
                    for _, item in ipairs(settings.items or {}) do
                        if query == '' or string.find(string.lower(item), query, 1, true) then
                            local opt = Instance.new('TextButton', list)
                            opt.Size = UDim2.new(1,0,0,22)
                            opt.BackgroundColor3 = Library._current_theme.ButtonIdle
                            opt.Text = item
                            opt.TextSize = 12
                            opt.Font = Enum.Font.Gotham
                            opt.AutoButtonColor = false
                            local ocorner = Instance.new('UICorner', opt); ocorner.CornerRadius = UDim.new(0,4)
                            self:_track_theme(opt, { BackgroundColor3 = 'ButtonIdle', TextColor3 = 'TextPrimary' })
                            opt.MouseButton1Click:Connect(function()
                                current = item
                                button.Text = item
                                popup.Visible = false
                                Library._config._flags[flag] = item
                                Config:save_file('default', Library._config)
                                if settings.on_changed then pcall(settings.on_changed, item) end
                            end)
                        end
                    end
                end
                refresh()
                search:GetPropertyChangedSignal('Text'):Connect(function()
                    refresh(search.Text)
                end)
                button.MouseButton1Click:Connect(function()
                    popup.Visible = not popup.Visible
                    popup.Size = popup.Visible and UDim2.new(1,-10,0,140) or UDim2.new(1,-10,0,0)
                    if popup.Visible then search:CaptureFocus() else search:ReleaseFocus() end
                end)
                manager._size = manager._size + 40
                return refresh
            end

            function manager:add_colorpicker(settings)
                settings = settings or {}
                local flag = settings.flag
                local default = settings.default or Color3.new(1,1,1)
                local stored = Util.table_to_color(Library._config._flags[flag], default)
                local current = stored
                local row = Instance.new('Frame', Options); row.Size=UDim2.new(1,-10,0,34); row.BackgroundTransparency=1
                local label = Instance.new('TextLabel', row); label.Text = settings.text or 'Color'; label.TextSize=12; label.BackgroundTransparency=1; label.Position=UDim2.new(0.02,0,0,0); label.Size=UDim2.new(0.5,0,1,0); label.TextXAlignment = Enum.TextXAlignment.Left
                local preview = Instance.new('TextButton', row); preview.Size=UDim2.new(0,30,0,24); preview.Position=UDim2.new(1,-40,0.5,0); preview.AnchorPoint=Vector2.new(1,0.5); preview.BackgroundColor3=current; preview.AutoButtonColor=false; preview.Text=""
                local pcorner = Instance.new('UICorner', preview); pcorner.CornerRadius = UDim.new(0,5)
                self:_track_theme(label, { TextColor3 = 'TextPrimary' })

                local popup = Instance.new('Frame', row)
                popup.Size = UDim2.new(1,-10,0,0)
                popup.Position = UDim2.new(0,5,1,4)
                popup.BackgroundColor3 = Library._current_theme.ModuleBackground
                popup.BorderSizePixel = 0
                popup.Visible = false
                popup.ClipsDescendants = true
                local popCorner = Instance.new('UICorner', popup); popCorner.CornerRadius = UDim.new(0,6)
                self:_track_theme(popup, { BackgroundColor3 = 'ModuleBackground' })

                local hueSlider = Instance.new('TextButton', popup)
                hueSlider.Size = UDim2.new(1,-12,0,20)
                hueSlider.Position = UDim2.new(0,6,0,6)
                hueSlider.AutoButtonColor = false
                hueSlider.Text = 'Hue'
                hueSlider.BackgroundColor3 = Library._current_theme.ButtonIdle
                self:_track_theme(hueSlider, { BackgroundColor3 = 'ButtonIdle', TextColor3 = 'TextPrimary' })
                local valSlider = Instance.new('TextButton', popup)
                valSlider.Size = UDim2.new(1,-12,0,20)
                valSlider.Position = UDim2.new(0,6,0,34)
                valSlider.AutoButtonColor = false
                valSlider.Text = 'Brightness'
                valSlider.BackgroundColor3 = Library._current_theme.ButtonIdle
                self:_track_theme(valSlider, { BackgroundColor3 = 'ButtonIdle', TextColor3 = 'TextPrimary' })
                local rgbInputs = Instance.new('Frame', popup)
                rgbInputs.Size = UDim2.new(1,-12,0,26)
                rgbInputs.Position = UDim2.new(0,6,0,62)
                rgbInputs.BackgroundTransparency = 1
                local layout = Instance.new('UIListLayout', rgbInputs)
                layout.FillDirection = Enum.FillDirection.Horizontal
                layout.Padding = UDim.new(0,4)
                local fields = {}
                for _, ch in ipairs({'R','G','B'}) do
                    local box = Instance.new('TextBox', rgbInputs)
                    box.Size = UDim2.new(0.3,0,1,0)
                    box.BackgroundColor3 = Library._current_theme.ButtonIdle
                    local base = (ch == 'R' and current.R) or (ch == 'G' and current.G) or current.B
                    box.Text = tostring(math.floor(base*255))
                    box.TextSize = 12
                    box.Font = Enum.Font.Gotham
                    box.TextColor3 = Library._current_theme.TextPrimary
                    box.ClearTextOnFocus = false
                    local bc = Instance.new('UICorner', box); bc.CornerRadius = UDim.new(0,4)
                    self:_track_theme(box, { BackgroundColor3 = 'ButtonIdle', TextColor3 = 'TextPrimary' })
                    fields[ch] = box
                end
                local hex = Instance.new('TextBox', popup)
                hex.Size = UDim2.new(1,-12,0,20)
                hex.Position = UDim2.new(0,6,0,94)
                hex.BackgroundColor3 = Library._current_theme.ButtonIdle
                hex.Text = string.format('#%02X%02X%02X', current.R*255, current.G*255, current.B*255)
                hex.TextSize = 12
                hex.Font = Enum.Font.Gotham
                hex.TextColor3 = Library._current_theme.TextPrimary
                hex.ClearTextOnFocus = false
                local hc = Instance.new('UICorner', hex); hc.CornerRadius = UDim.new(0,4)
                self:_track_theme(hex, { BackgroundColor3 = 'ButtonIdle', TextColor3 = 'TextPrimary' })

                local previewSwatch = Instance.new('Frame', popup)
                previewSwatch.Size = UDim2.new(1,-12,0,24)
                previewSwatch.Position = UDim2.new(0,6,0,120)
                previewSwatch.BackgroundColor3 = current
                local psCorner = Instance.new('UICorner', previewSwatch); psCorner.CornerRadius = UDim.new(0,5)

                local function apply_color(col)
                    current = col
                    preview.BackgroundColor3 = col
                    previewSwatch.BackgroundColor3 = col
                    fields.R.Text = tostring(math.floor(col.R*255))
                    fields.G.Text = tostring(math.floor(col.G*255))
                    fields.B.Text = tostring(math.floor(col.B*255))
                    hex.Text = string.format('#%02X%02X%02X', col.R*255, col.G*255, col.B*255)
                    Library._config._flags[flag] = Util.color_to_table(col)
                    Config:save_file('default', Library._config)
                    if settings.on_changed then pcall(settings.on_changed, col) end
                end

                local function slider_from_click(btn, cb)
                    btn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            local conn
                            local function update(pos)
                                local rel = (pos.X - btn.AbsolutePosition.X)/btn.AbsoluteSize.X
                                cb(math.clamp(rel,0,1))
                            end
                            update(inp.Position)
                            conn = UserInputService.InputChanged:Connect(function(i)
                                if i.UserInputType == Enum.UserInputType.MouseMovement then
                                    update(i.Position)
                                end
                            end)
                            UserInputService.InputEnded:Connect(function(endInput)
                                if endInput.UserInputType == Enum.UserInputType.MouseButton1 and conn then conn:Disconnect() end
                            end)
                        end
                    end)
                end

                slider_from_click(hueSlider, function(rel)
                    local h = rel
                    local s,v = 1, current and current.V or 1
                    local col = Color3.fromHSV(h,1,current and select(3, Color3.toHSV(current)) or 1)
                    apply_color(col)
                end)
                slider_from_click(valSlider, function(rel)
                    local h,s,_ = Color3.toHSV(current)
                    local col = Color3.fromHSV(h, s, rel)
                    apply_color(col)
                end)
                for ch, box in pairs(fields) do
                    box.FocusLost:Connect(function()
                        local r = tonumber(fields.R.Text) or current.R*255
                        local g = tonumber(fields.G.Text) or current.G*255
                        local b = tonumber(fields.B.Text) or current.B*255
                        apply_color(Color3.fromRGB(r,g,b))
                    end)
                end
                hex.FocusLost:Connect(function()
                    local txt = hex.Text:gsub('#','')
                    if #txt == 6 then
                        local r = tonumber(txt:sub(1,2),16) or current.R*255
                        local g = tonumber(txt:sub(3,4),16) or current.G*255
                        local b = tonumber(txt:sub(5,6),16) or current.B*255
                        apply_color(Color3.fromRGB(r,g,b))
                    end
                end)

                preview.MouseButton1Click:Connect(function()
                    popup.Visible = not popup.Visible
                    popup.Size = popup.Visible and UDim2.new(1,-10,0,150) or UDim2.new(1,-10,0,0)
                end)
                manager._size = manager._size + 44
                return apply_color
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

    -- parallax effect
    local basePosition = Container.Position
    Connections:add('parallax', UserInputService.InputChanged:Connect(function(input)
        if UI._config._library.parallax_enabled == false then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement and self._ui.Enabled then
            local viewport = workspace.CurrentCamera.ViewportSize
            local offset = Vector2.new((input.Position.X - viewport.X/2) * self._parallax_strength, (input.Position.Y - viewport.Y/2) * self._parallax_strength)
            Container.Position = basePosition + UDim2.new(0, offset.X, 0, offset.Y)
            if Shadow then Shadow.Position = UDim2.new(0.5,4+offset.X,0.5,8+offset.Y) end
        end
    end))

    -- utility: create bare button in a section
    function self:create_button(section, text, callback)
        local btn = Instance.new('TextButton', section); btn.Size=UDim2.new(0,220,0,32); btn.BackgroundColor3 = Color3.fromRGB(60,60,62); btn.AutoButtonColor=false; btn.Text = text; btn.TextSize = 13
        local corner = Instance.new('UICorner', btn)
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
            SoundManager.play_event(self._sound_theme, 'button_click')
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

do
    local settingsTab = UI:create_tab(Language.TabSettings or "Settings", "")
    local left = select(2, settingsTab:create_module({ title = "UI", description = "Preferences", flag = "settings_ui", section = 'left' }))
    local uiMgr, uiModule = settingsTab:create_module({ title = "UI Scale", description = "Adjust size", flag = "ui_scale_mod", section = 'left' })
    if uiMgr then
        uiMgr:add_slider({ text = "Scale", flag = "ui_scale", min = 0.75, max = 1.25, default = UI._config._library.ui_scale or 1, on_changed = function(v)
            if UI._container and UI._container:FindFirstChildOfClass('UIScale') then
                UI._container:FindFirstChildOfClass('UIScale').Scale = v
            end
            UI._config._library.ui_scale = v
            Config:save_file('default', UI._config)
        end })
        uiMgr:add_toggle("Enable Parallax", "parallax_toggle", function(state)
            UI._config._library.parallax_enabled = state
            Config:save_file('default', UI._config)
        end)
        uiMgr:add_toggle("Enable Animations", "animations_toggle", function(state)
            UI._config._library.animations_enabled = state
            UI._animations_enabled = state
            Config:save_file('default', UI._config)
        end)
        UI._config._flags.parallax_toggle = UI._config._library.parallax_enabled ~= false
        UI._config._flags.animations_toggle = UI._config._library.animations_enabled ~= false
    end
    local prefMgr = select(1, settingsTab:create_module({ title = "Preferences", description = "Themes", flag = "pref_mod", section = 'right' }))
    if prefMgr then
        prefMgr:add_dropdown({ text = "Theme", flag = "theme", items = {"DarkAmber","NeonPurple","CyberBlue","Midnight","CleanWhite"}, default = UI._current_theme_name, on_changed = function(name) UI:set_theme(name) end })
        prefMgr:add_dropdown({ text = "Sound Theme", flag = "sound_theme", items = {"Off","Soft","Clicky","Retro"}, default = UI._sound_theme, on_changed = function(name)
            UI._sound_theme = name
            UI._config._library.sound_theme = name
            Config:save_file('default', UI._config)
        end })
        prefMgr:add_dropdown({ text = "Command Palette", flag = "palette", items = {"Enabled","Disabled"}, default = UI._config._library.enable_command_palette and "Enabled" or "Disabled", on_changed = function(val)
            UI._config._library.enable_command_palette = val == "Enabled"
            Config:save_file('default', UI._config)
        end })
    end
end

do
    local appTab = UI:create_tab("Appearance", "")
    local appMgr = select(1, appTab:create_module({ title = "Visuals", description = "Customize", flag = "appearance_mod", section = 'left' }))
    if appMgr then
        appMgr:add_colorpicker({ text = "Accent", flag = "accent_override", default = UI._current_theme.AccentColor, on_changed = function(col)
            UI._config._library.appearance = UI._config._library.appearance or {}
            UI._config._library.appearance.accent_override = Util.color_to_table(col)
            Config:save_file('default', UI._config)
            UI:apply_theme_to_existing_ui()
        end })
        appMgr:add_slider({ text = "Container Transparency", flag = "container_transparency", min = 0, max = 0.5, default = UI._config._library.appearance.container_transparency or 0.06, on_changed = function(v)
            UI._config._library.appearance.container_transparency = v
            if UI._container then UI._container.BackgroundTransparency = v end
            Config:save_file('default', UI._config)
        end })
        appMgr:add_slider({ text = "Blur Strength", flag = "blur_strength", min = 0, max = 1, default = UI._config._library.blur_strength or 0.7, on_changed = function(v)
            UI._config._library.blur_strength = v
            if UI._blur and UI._blur.render then pcall(function() UI._blur:render(v) end) end
            Config:save_file('default', UI._config)
        end })
        appMgr:add_toggle("Glassmorphism", "glass_toggle")
    end
end

do
    local consoleTab = UI:create_tab("Console", "")
    local consoleMgr, consoleFrame = consoleTab:create_module({ title = "Logs", description = "Activity", flag = "logs", section = 'left' })
    if consoleMgr then
        local logFrame = Instance.new('ScrollingFrame', consoleFrame)
        logFrame.Size = UDim2.new(1,-10,0,150)
        logFrame.Position = UDim2.new(0,5,0,40)
        logFrame.BackgroundTransparency = 0.9
        logFrame.ScrollBarThickness = 4
        local layout = Instance.new('UIListLayout', logFrame); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0,4)
        UI._console_output = function(filter)
            for _, child in ipairs(logFrame:GetChildren()) do
                if child:IsA('TextLabel') then child:Destroy() end
            end
            local active = filter or UI._console_filter or 'all'
            for _, entry in ipairs(UI._log_entries) do
                if active == 'all' or entry.type == active then
                    local lbl = Instance.new('TextLabel', logFrame)
                    lbl.BackgroundTransparency = 1
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.TextSize = 12
                    lbl.Font = Enum.Font.Gotham
                    lbl.TextColor3 = UI._current_theme.TextPrimary
                    lbl.Size = UDim2.new(1,-4,0,18)
                    lbl.Text = string.format('[%s][%s] %s', os.date('%H:%M:%S', entry.timestamp), entry.type, entry.text)
                end
            end
        end
        UI._console_output('all')
        local filters = {'all','info','warn','error'}
        for i, f in ipairs(filters) do
            local btn = UI:create_button(consoleFrame, string.upper(f), function()
                UI._console_filter = f
                UI._console_output(f)
            end)
            if btn then btn.Position = UDim2.new(0, (i-1)*60,0,8) end
        end
        UI:create_button(consoleFrame, "Clear", function()
            UI._log_entries = {}
            UI._console_output('all')
        end)
    end
end

-- Expose functions to global for other scripts
getgenv().CLICK_UI = {
    library = UI,
    send_notification = Library.SendNotification,
    save_config = function(name)
        Config:save_file(name or 'default', UI._config)
    end,
    save_config_as = function(name)
        if not name or name == '' then return false, 'missing name' end
        Config:save_file(name, UI._config)
        Library.SendNotification({ title = "Config", text = "Saved as "..name })
        return true
    end,
    load_config = function(name)
        local data = Config:read_file(name or 'default')
        if data then UI._config = data; Library.SendNotification({ title="Config", text="Loaded "..(name or 'default') }) end
    end,
    export_config = function(name)
        local data = Config:read_file(name or 'default')
        if not data then return nil end
        return HttpService:JSONEncode(data)
    end,
    get_config_metadata = function(name)
        local data = Config:read_file(name or 'default')
        return data and data.meta or nil
    end,
    list_configs = function()
        return Config:list_configs()
    end,
    delete_config = function(name)
        local target = name or 'default'
        local ok = Config:delete_file(target)
        if ok then
            Library.SendNotification({ title = "Config", text = "Deleted "..target })
        else
            Library.SendNotification({ title = "Config", text = "Unable to delete "..target })
        end
        return ok
    end,
    rename_config = function(source, target)
        local from = source or 'default'
        local to = target or 'default'
        local ok, err = Config:rename_file(from, to)
        if ok then
            if UI._config.meta and UI._config.meta.name == from then
                UI._config.meta.name = to
            end
            Library.SendNotification({ title = "Config", text = string.format("Renamed %s to %s", from, to) })
        else
            Library.SendNotification({ title = "Config", text = "Rename failed: "..(err or "") })
        end
        return ok
    end,
    reset_default_config = function()
        UI._config = Config.default('default')
        Config:save_file('default', UI._config)
        Library.SendNotification({ title = "Config", text = "Reset default configuration" })
        return UI._config
    end,
    backup_config = function(name, max_backups)
        local target = name or 'default'
        local ok, path_or_err, stamp = Config:backup_file(target, max_backups)
        if ok then
            Library.SendNotification({ title = "Config", text = string.format("Backed up %s (%d)", target, stamp or 0) })
        else
            Library.SendNotification({ title = "Config", text = "Backup failed: "..(path_or_err or "") })
        end
        return ok, path_or_err, stamp
    end,
    list_backups = function(name)
        return Config:list_backups(name or 'default')
    end,
    restore_backup = function(name, timestamp)
        local target = name or 'default'
        local ok, info = Config:restore_backup(target, timestamp)
        if ok then
            Library.SendNotification({ title = "Config", text = string.format("Restored %s from backup", target) })
        else
            Library.SendNotification({ title = "Config", text = "Restore failed: "..(info or "") })
        end
        return ok, info
    end,
    import_config_raw = function(json_raw)
        local ok, tbl = pcall(function() return HttpService:JSONDecode(json_raw) end)
        if not ok then return false, "invalid json" end
        local normalized = Config:normalize(tbl, 'default')
        Config:save_file('default', normalized)
        UI._config = normalized
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
