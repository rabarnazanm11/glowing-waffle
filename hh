--[[
    RedzLib v2.1  -  Delta-safe, all window bugs fixed

    FIXES vs v2.0:
    [FIX] Enum.AutomaticCanvasSize crash on Delta  -- use string "Y" instead
    [FIX] Window jumps top-left on first drag      -- read AbsolutePosition
    [FIX] Close / Minimise eaten by drag handler   -- drag uses narrow overlay
    [FIX] Float button wrapped in pcall
    [FIX] Minimise reads AbsoluteSize so savedH is always correct
]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

pcall(function()
    local old = CoreGui:FindFirstChild("RedzLib_v2")
    if old then old:Destroy() end
end)

local Screen = Instance.new("ScreenGui")
Screen.Name           = "RedzLib_v2"
Screen.ResetOnSpawn   = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
Screen.IgnoreGuiInset = true
Screen.Parent         = CoreGui

local C = {
    bg        = Color3.fromRGB( 12,  12,  18),
    surface   = Color3.fromRGB( 20,  20,  30),
    card      = Color3.fromRGB( 28,  28,  42),
    hover     = Color3.fromRGB( 38,  38,  56),
    accent    = Color3.fromRGB(108,  99, 255),
    accentDim = Color3.fromRGB( 72,  65, 185),
    text      = Color3.fromRGB(232, 232, 245),
    sub       = Color3.fromRGB(120, 120, 150),
    border    = Color3.fromRGB( 40,  40,  62),
    toggleOff = Color3.fromRGB( 50,  50,  68),
    white     = Color3.fromRGB(255, 255, 255),
    red       = Color3.fromRGB(220,  55,  55),
    amber     = Color3.fromRGB(210, 150,  30),
}

local function tw(obj, props, t, style)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props):Play()
end

local function N(class, props, parent)
    local o = Instance.new(class)
    if props  then for k, v in pairs(props) do o[k] = v end end
    if parent then o.Parent = parent end
    return o
end

local function corner(p, r)
    N("UICorner", {CornerRadius = UDim.new(0, r or 8)}, p)
end

local function stroke(p, color, thick)
    N("UIStroke", {
        Color = color or C.border,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, p)
end

-- FIX: use AbsolutePosition on drag start so Scale-based UDim2 never causes a jump
local function draggable(frame, handle)
    handle = handle or frame
    handle.Active = true
    local down, ds, fs = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1
        and i.UserInputType ~= Enum.UserInputType.Touch then return end
        down = true
        ds   = UserInputService:GetMouseLocation()
        fs   = Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then down = false end
    end)
    RunService.Heartbeat:Connect(function()
        if not down then return end
        local d = UserInputService:GetMouseLocation() - ds
        frame.Position = UDim2.fromOffset(fs.X + d.X, fs.Y + d.Y)
    end)
end

local lib = {}

-- NOTIFY
function lib:Notify(cfg)
    if type(cfg) ~= "table" then cfg = {cfg} end
    local title = cfg.Title    or cfg[1] or "Notification"
    local text  = cfg.Text     or cfg[2] or ""
    local dur   = cfg.Duration or cfg[3] or 3

    local stack = Screen:FindFirstChild("_notifStack")
    if not stack then
        stack = N("Frame", {
            Name = "_notifStack",
            Size = UDim2.new(0, 270, 1, 0),
            Position = UDim2.new(1, -282, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 300,
        }, Screen)
        N("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 6),
        }, stack)
        N("UIPadding", {
            PaddingBottom = UDim.new(0, 16),
            PaddingRight  = UDim.new(0,  6),
        }, stack)
    end

    local hasText = text ~= ""
    local targetH = hasText and 62 or 36
    local card = N("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = C.card,
        ClipsDescendants = true,
        ZIndex = 301,
    }, stack)
    corner(card, 10)
    stroke(card)
    N("Frame", {
        Size = UDim2.new(0, 3, 0.55, 0),
        Position = UDim2.new(0, 0, 0.225, 0),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        ZIndex = 302,
    }, card)
    N("TextLabel", {
        Size = UDim2.new(1, -18, 0, 16),
        Position = UDim2.fromOffset(12, hasText and 9 or 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 302,
    }, card)
    if hasText then
        N("TextLabel", {
            Size = UDim2.new(1, -18, 0, 28),
            Position = UDim2.fromOffset(12, 27),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = C.sub,
            Font = Enum.Font.Gotham,
            TextSize = 9,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 302,
        }, card)
    end
    tw(card, {Size = UDim2.new(1, 0, 0, targetH)}, 0.22, Enum.EasingStyle.Back)
    task.delay(dur, function()
        tw(card, {BackgroundTransparency = 1}, 0.2)
        task.wait(0.22)
        tw(card, {Size = UDim2.new(1, 0, 0, 0)}, 0.16)
        task.wait(0.18)
        pcall(function() card:Destroy() end)
    end)
end

-- MAKE WINDOW
function lib:MakeWindow(cfg)
    if type(cfg) ~= "table" then cfg = {cfg} end
    local title    = cfg[1] or cfg.Title or cfg.Name or "RedzLib"
    local subtitle = cfg[2] or cfg.Subtitle or "v2.1"

    local vp = workspace.CurrentCamera.ViewportSize
    local win = N("Frame", {
        Name = "RedzWindow",
        Size = UDim2.fromOffset(540, 400),
        Position = UDim2.fromOffset(
            math.floor((vp.X - 540) / 2),
            math.floor((vp.Y - 400) / 2)
        ),
        BackgroundColor3 = C.bg,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        ZIndex = 10,
    }, Screen)
    corner(win, 12)
    stroke(win, C.border, 1.5)

    -- Title bar
    local bar = N("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.surface,
        BorderSizePixel  = 0,
        ZIndex = 11,
        ClipsDescendants = true,
    }, win)
    corner(bar, 12)
    -- square off the bottom half of the rounded bar
    N("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = C.surface,
        BorderSizePixel  = 0,
        ZIndex = 11,
    }, bar)
    N("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.border,
        BorderSizePixel  = 0,
        ZIndex = 12,
    }, bar)

    local dot = N("Frame", {
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(0, 14, 0.5, -4),
        BackgroundColor3 = C.accent,
        BorderSizePixel  = 0,
        ZIndex = 13,
    }, bar)
    corner(dot, 4)

    N("TextLabel", {
        Size = UDim2.new(0.5, 0, 0, 18),
        Position = UDim2.new(0, 30, 0, 7),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    }, bar)
    N("TextLabel", {
        Size = UDim2.new(0.5, 0, 0, 13),
        Position = UDim2.new(0, 30, 0, 27),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = C.sub,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    }, bar)

    -- FIX: control buttons at ZIndex 15, drag handle at ZIndex 12
    -- so buttons always receive clicks before the drag overlay
    local closeBtn = N("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -10, 0.5, -11),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = C.red,
        AutoButtonColor  = false,
        Text = "x",
        TextColor3 = C.white,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        ZIndex = 15,
    }, bar)
    corner(closeBtn, 6)

    local minBtn = N("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -36, 0.5, -11),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = C.amber,
        AutoButtonColor  = false,
        Text = "-",
        TextColor3 = C.white,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        ZIndex = 15,
    }, bar)
    corner(minBtn, 6)

    for _, b in ipairs({closeBtn, minBtn}) do
        b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency = 0.3}, 0.1) end)
        b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = 0},   0.1) end)
    end

    -- Drag handle: transparent button covering left 80% of bar, ZIndex BELOW buttons
    local dragHandle = N("TextButton", {
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 12,
    }, bar)
    draggable(win, dragHandle)

    closeBtn.MouseButton1Click:Connect(function()
        win:Destroy()
    end)

    local minimized = false
    local savedSize = UDim2.fromOffset(540, 400)
    minBtn.MouseButton1Click:Connect(function()
        if minimized then
            tw(win, {Size = savedSize}, 0.22, Enum.EasingStyle.Back)
            minimized = false
        else
            savedSize = UDim2.fromOffset(win.AbsoluteSize.X, win.AbsoluteSize.Y)
            tw(win, {Size = UDim2.fromOffset(win.AbsoluteSize.X, 46)}, 0.22)
            minimized = true
        end
    end)

    -- Sidebar
    local sidebar = N("Frame", {
        Size = UDim2.new(0, 150, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = C.surface,
        BorderSizePixel  = 0,
        ZIndex = 11,
    }, win)
    N("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = C.border,
        BorderSizePixel  = 0,
        ZIndex = 12,
    }, sidebar)

    local tabList = N("ScrollingFrame", {
        Size = UDim2.new(1, -2, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = "Y",   -- FIX: string not Enum
        ScrollingDirection = "Y",
        BorderSizePixel = 0,
        ZIndex = 12,
    }, sidebar)
    N("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabList)
    N("UIPadding", {
        PaddingLeft  = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop   = UDim.new(0, 8),
    }, tabList)

    local contentArea = N("Frame", {
        Size = UDim2.new(1, -150, 1, -46),
        Position = UDim2.new(0, 150, 0, 46),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 11,
    }, win)

    local Win     = {}
    local tabData = {}
    local firstTab = true

    -- FLOAT BUTTON
    function Win:MakeFloatButton(_icon)
        local ok, floatGui = pcall(function()
            local g = Instance.new("ScreenGui")
            g.Name           = "RedzFloat"
            g.ResetOnSpawn   = false
            g.ZIndexBehavior = Enum.ZIndexBehavior.Global
            g.DisplayOrder   = 999
            g.Parent         = CoreGui
            return g
        end)
        if not ok or not floatGui then return end

        local pill = N("TextButton", {
            Size = UDim2.fromOffset(44, 44),
            Position = UDim2.fromOffset(28, 62),
            BackgroundColor3 = C.surface,
            AutoButtonColor  = false,
            Text = "=",
            TextColor3 = C.accent,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            ZIndex = 5,
        }, floatGui)
        corner(pill, 12)
        local pillStroke = N("UIStroke", {
            Color = C.accent,
            Thickness = 1.8,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, pill)

        task.spawn(function()
            while floatGui and floatGui.Parent do
                tw(pillStroke, {Transparency = 0.65}, 1.3, Enum.EasingStyle.Sine)
                task.wait(1.3)
                tw(pillStroke, {Transparency = 0},    1.3, Enum.EasingStyle.Sine)
                task.wait(1.3)
            end
        end)

        pill.MouseEnter:Connect(function()
            tw(pill,       {BackgroundColor3 = C.hover}, 0.12)
            tw(pillStroke, {Transparency = 0}, 0.12)
        end)
        pill.MouseLeave:Connect(function()
            tw(pill, {BackgroundColor3 = C.surface}, 0.12)
        end)

        local pressing, wasDragged, ds, ps = false, false, nil, nil
        pill.InputBegan:Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.MouseButton1
            and i.UserInputType ~= Enum.UserInputType.Touch then return end
            pressing = true; wasDragged = false
            ds = UserInputService:GetMouseLocation()
            ps = Vector2.new(pill.AbsolutePosition.X, pill.AbsolutePosition.Y)
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.MouseButton1
            and i.UserInputType ~= Enum.UserInputType.Touch then return end
            if pressing and not wasDragged then win.Visible = not win.Visible end
            pressing = false; wasDragged = false
        end)
        RunService.Heartbeat:Connect(function()
            if not pressing or not ds then return end
            local d = UserInputService:GetMouseLocation() - ds
            if d.Magnitude > 6 then
                wasDragged    = true
                pill.Position = UDim2.fromOffset(ps.X + d.X, ps.Y + d.Y)
            end
        end)
        return pill
    end

    -- MAKE TAB
    function Win:MakeTab(cfg)
        if type(cfg) ~= "table" then cfg = {cfg} end
        local tabName = cfg[1] or cfg.Name or cfg.Title or "Tab"

        local tabBtn = N("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = C.hover,
            BackgroundTransparency = firstTab and 0 or 1,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 13,
        }, tabList)
        corner(tabBtn, 8)

        local ind = N("Frame", {
            Size = firstTab and UDim2.fromOffset(3, 16) or UDim2.fromOffset(3, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = C.accent,
            BackgroundTransparency = firstTab and 0 or 1,
            BorderSizePixel = 0,
            ZIndex = 14,
        }, tabBtn)
        corner(ind, 2)

        local lbl = N("TextLabel", {
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.fromOffset(10, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = firstTab and C.text or C.sub,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 14,
        }, tabBtn)

        local scroll = N("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = C.accent,
            ScrollBarImageTransparency = 0.4,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = "Y",   -- FIX: string not Enum
            ScrollingDirection  = "Y",
            BorderSizePixel = 0,
            Visible = firstTab,
            ZIndex = 12,
        }, contentArea)
        N("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)
        N("UIPadding", {
            PaddingLeft   = UDim.new(0, 12),
            PaddingRight  = UDim.new(0, 14),
            PaddingTop    = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
        }, scroll)

        table.insert(tabData, {btn = tabBtn, ind = ind, lbl = lbl, scroll = scroll})

        local function activate()
            for _, t in ipairs(tabData) do
                local active = (t.scroll == scroll)
                t.scroll.Visible = active
                tw(t.btn, {BackgroundColor3 = C.hover, BackgroundTransparency = active and 0 or 1}, 0.15)
                tw(t.lbl, {TextColor3 = active and C.text or C.sub}, 0.15)
                tw(t.ind, {
                    Size = active and UDim2.fromOffset(3, 16) or UDim2.fromOffset(3, 0),
                    BackgroundTransparency = active and 0 or 1,
                }, 0.15)
            end
        end

        tabBtn.MouseButton1Click:Connect(activate)
        tabBtn.MouseEnter:Connect(function()
            if scroll.Visible then return end
            tw(tabBtn, {BackgroundColor3 = C.hover, BackgroundTransparency = 0.6}, 0.1)
        end)
        tabBtn.MouseLeave:Connect(function()
            if scroll.Visible then return end
            tw(tabBtn, {BackgroundTransparency = 1}, 0.1)
        end)

        firstTab = false

        local Tab = {}

        local function mkCard(h)
            local f = N("Frame", {
                Size = UDim2.new(1, 0, 0, h or 34),
                BackgroundColor3 = C.card,
                BorderSizePixel  = 0,
                ZIndex = 12,
            }, scroll)
            corner(f, 8)
            return f
        end

        local function mkLabels(parent, name, desc, rightGap)
            rightGap = rightGap or 0
            local hasDesc = desc ~= nil and desc ~= ""
            N("TextLabel", {
                Size = UDim2.new(1, -(rightGap + 16), 0, hasDesc and 16 or 0),
                AutomaticSize = hasDesc and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
                Position = hasDesc and UDim2.fromOffset(12, 9) or UDim2.new(0, 12, 0.5, 0),
                AnchorPoint = hasDesc and Vector2.new(0, 0) or Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = C.text,
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 13,
            }, parent)
            if hasDesc then
                N("TextLabel", {
                    Size = UDim2.new(1, -(rightGap + 16), 0, 13),
                    Position = UDim2.fromOffset(12, 22),
                    BackgroundTransparency = 1,
                    Text = desc,
                    TextColor3 = C.sub,
                    Font = Enum.Font.Gotham,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 13,
                }, parent)
            end
        end

        local function hoverCard(f, btn)
            btn = btn or f
            btn.MouseEnter:Connect(function() tw(f, {BackgroundColor3 = C.hover}, 0.1) end)
            btn.MouseLeave:Connect(function() tw(f, {BackgroundColor3 = C.card},  0.1) end)
        end

        -- AddSection
        function Tab:AddSection(cfg)
            local name = type(cfg) == "string" and cfg or cfg[1] or cfg.Name or cfg.Title or "Section"
            local f = N("Frame", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, ZIndex = 12}, scroll)
            N("TextLabel", {
                Size = UDim2.new(1, 0, 0, 14),
                Position = UDim2.new(0, 2, 0.5, -7),
                BackgroundTransparency = 1,
                Text = string.upper(name),
                TextColor3 = C.accent,
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 13,
            }, f)
            N("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = C.border,
                BorderSizePixel = 0,
                ZIndex = 13,
            }, f)
        end

        -- AddButton
        function Tab:AddButton(cfg)
            if type(cfg) ~= "table" then cfg = {cfg} end
            local name = cfg[1] or cfg.Name or cfg.Title or "Button"
            local desc = cfg.Desc or cfg.Description or ""
            local cb   = cfg[2] or cfg.Callback or function() end
            local h    = desc ~= "" and 44 or 34
            local f    = mkCard(h)
            local btn  = N("TextButton", {Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=14}, f)
            mkLabels(f, name, desc, 28)
            N("TextLabel", {
                Size = UDim2.fromOffset(22, h),
                Position = UDim2.new(1, -26, 0, 0),
                BackgroundTransparency = 1,
                Text = ">",
                TextColor3 = C.sub,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                ZIndex = 13,
            }, f)
            hoverCard(f, btn)
            btn.MouseButton1Click:Connect(function()
                tw(f, {BackgroundColor3 = C.accentDim}, 0.06)
                task.delay(0.12, function() tw(f, {BackgroundColor3 = C.card}, 0.14) end)
                task.spawn(cb)
            end)
            return {Set = function() end}
        end

        -- AddToggle
        function Tab:AddToggle(cfg)
            if type(cfg) ~= "table" then cfg = {cfg} end
            local name    = cfg[1] or cfg.Name or cfg.Title or "Toggle"
            local desc    = cfg.Desc or cfg.Description or ""
            local default = cfg.Default
            if default == nil then default = cfg[2] end
            if default == nil then default = false end
            local cb   = cfg[3] or cfg.Callback or function() end
            local h    = desc ~= "" and 44 or 34
            local val  = default
            local f    = mkCard(h)
            local btn  = N("TextButton", {Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=14}, f)
            mkLabels(f, name, desc, 52)
            local track = N("Frame", {
                Size = UDim2.fromOffset(36, 20),
                Position = UDim2.new(1, -46, 0.5, -10),
                BackgroundColor3 = val and C.accent or C.toggleOff,
                BorderSizePixel = 0, ZIndex = 13,
            }, f)
            corner(track, 10)
            local knob = N("Frame", {
                Size = UDim2.fromOffset(14, 14),
                Position = val and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3),
                BackgroundColor3 = C.white,
                BorderSizePixel = 0, ZIndex = 14,
            }, track)
            corner(knob, 7)
            local function set(v, fire)
                val = v
                tw(track, {BackgroundColor3 = v and C.accent or C.toggleOff}, 0.16)
                tw(knob,  {Position = v and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3)}, 0.16)
                if fire then task.spawn(cb, v) end
            end
            hoverCard(f, btn)
            btn.MouseButton1Click:Connect(function() set(not val, true) end)
            set(val, false)
            local obj = {}
            function obj:Set(v) set(v, true) end
            function obj:Get()  return val   end
            return obj
        end

        -- AddDropdown (opens downward, live search)
        function Tab:AddDropdown(cfg)
            if type(cfg) ~= "table" then cfg = {cfg} end
            local name        = cfg[1] or cfg.Name or cfg.Title or "Dropdown"
            local desc        = cfg.Desc or cfg.Description or ""
            local opts        = cfg[2] or cfg.Options or {}
            local default     = cfg[3] or cfg.Default
            local multiSelect = cfg.MultiSelect or false
            local cb          = cfg[4] or cfg.Callback or function() end
            local h           = desc ~= "" and 44 or 34

            local allOpts = {}
            for _, v in ipairs(opts) do table.insert(allOpts, tostring(v)) end

            local sel = {}
            if multiSelect then
                if type(default) == "table" then
                    for _, v in ipairs(default) do sel[tostring(v)] = true end
                end
            else
                if type(default) == "string" and default ~= "" and default ~= "None" then
                    sel[default] = true
                end
            end

            local f       = mkCard(h)
            local trigger = N("TextButton", {Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=14}, f)
            mkLabels(f, name, desc, 128)
            hoverCard(f, trigger)

            local dispF = N("Frame", {
                Size = UDim2.new(0, 118, 0, 24),
                Position = UDim2.new(1, -124, 0.5, -12),
                BackgroundColor3 = C.surface,
                BorderSizePixel = 0, ZIndex = 13,
            }, f)
            corner(dispF, 6)
            stroke(dispF)
            local dispLbl = N("TextLabel", {
                Size = UDim2.new(1, -22, 1, 0),
                Position = UDim2.fromOffset(8, 0),
                BackgroundTransparency = 1,
                Text = "Select...",
                TextColor3 = C.sub,
                Font = Enum.Font.GothamMedium,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 14,
            }, dispF)
            local arrowLbl = N("TextLabel", {
                Size = UDim2.fromOffset(18, 24),
                Position = UDim2.new(1, -19, 0, 0),
                BackgroundTransparency = 1,
                Text = "v",
                TextColor3 = C.sub,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                ZIndex = 14,
            }, dispF)

            local panel = N("Frame", {
                Size = UDim2.fromOffset(260, 0),
                BackgroundColor3 = C.surface,
                BorderSizePixel  = 0,
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 500,
            }, Screen)
            corner(panel, 8)
            stroke(panel, C.accent, 1.2)

            local searchRow = N("Frame", {
                Size = UDim2.new(1, -10, 0, 28),
                Position = UDim2.fromOffset(5, 5),
                BackgroundColor3 = C.card,
                BorderSizePixel  = 0,
                ZIndex = 501,
            }, panel)
            corner(searchRow, 6)
            N("TextLabel", {
                Size = UDim2.fromOffset(22, 28),
                Position = UDim2.fromOffset(3, 0),
                BackgroundTransparency = 1,
                Text = "?",
                TextColor3 = C.sub,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                ZIndex = 502,
            }, searchRow)
            local searchBox = N("TextBox", {
                Size = UDim2.new(1, -46, 1, 0),
                Position = UDim2.fromOffset(22, 0),
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                PlaceholderColor3 = C.sub,
                Text = "",
                TextColor3 = C.text,
                Font = Enum.Font.GothamMedium,
                TextSize = 10,
                ClearTextOnFocus = false,
                ZIndex = 502,
            }, searchRow)
            local clearBtn = N("TextButton", {
                Size = UDim2.fromOffset(22, 28),
                Position = UDim2.new(1, -22, 0, 0),
                BackgroundTransparency = 1,
                Text = "x",
                TextColor3 = C.sub,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                ZIndex = 502,
            }, searchRow)
            clearBtn.MouseButton1Click:Connect(function() searchBox.Text = "" end)

            local optScroll = N("ScrollingFrame", {
                Size = UDim2.new(1, -8, 1, -44),
                Position = UDim2.fromOffset(4, 38),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = C.accent,
                ScrollBarImageTransparency = 0.4,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = "Y",   -- FIX: string not Enum
                ScrollingDirection  = "Y",
                BorderSizePixel = 0,
                ZIndex = 501,
            }, panel)
            N("UIListLayout", {Padding = UDim.new(0, 2)}, optScroll)
            N("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 4)}, optScroll)

            local optBtns = {}
            local isOpen  = false

            local function getDispText()
                local parts = {}
                for k, v in pairs(sel) do if v then table.insert(parts, k) end end
                if #parts == 0 then return nil end
                table.sort(parts)
                return table.concat(parts, ", ")
            end
            local function updateDisplay()
                local t = getDispText()
                dispLbl.Text       = t or "Select..."
                dispLbl.TextColor3 = t and C.text or C.sub
            end
            local function fireCb()
                if multiSelect then
                    task.spawn(cb, sel)
                else
                    local v = nil
                    for k, s in pairs(sel) do if s then v = k break end end
                    task.spawn(cb, v)
                end
            end
            local function close()
                isOpen = false
                tw(panel,    {Size = UDim2.fromOffset(panel.AbsoluteSize.X, 0)}, 0.15)
                tw(arrowLbl, {Rotation = 0}, 0.15)
                task.delay(0.17, function()
                    if not isOpen then panel.Visible = false end
                end)
            end
            local function buildOpts(filter)
                for _, b in ipairs(optBtns) do pcall(function() b:Destroy() end) end
                optBtns = {}
                filter  = (filter or ""):lower()
                for _, opt in ipairs(allOpts) do
                    if filter == "" or opt:lower():find(filter, 1, true) then
                        local active = sel[opt] == true
                        local ob = N("TextButton", {
                            Size = UDim2.new(1, 0, 0, 32),
                            BackgroundColor3 = active and C.hover or C.surface,
                            BackgroundTransparency = active and 0 or 1,
                            AutoButtonColor = false,
                            Text = "",
                            ZIndex = 502,
                        }, optScroll)
                        corner(ob, 5)
                        N("TextLabel", {
                            Size = UDim2.fromOffset(24, 32),
                            Position = UDim2.fromOffset(4, 0),
                            BackgroundTransparency = 1,
                            Text = active and "+" or "",
                            TextColor3 = C.accent,
                            Font = Enum.Font.GothamBold,
                            TextSize = 13,
                            ZIndex = 503,
                        }, ob)
                        N("TextLabel", {
                            Size = UDim2.new(1, -32, 1, 0),
                            Position = UDim2.fromOffset(26, 0),
                            BackgroundTransparency = 1,
                            Text = opt,
                            TextColor3 = active and C.text or C.sub,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 10,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 503,
                        }, ob)
                        ob.MouseEnter:Connect(function()
                            if sel[opt] then return end
                            tw(ob, {BackgroundColor3 = C.hover, BackgroundTransparency = 0.5}, 0.1)
                        end)
                        ob.MouseLeave:Connect(function()
                            if sel[opt] then return end
                            tw(ob, {BackgroundTransparency = 1}, 0.1)
                        end)
                        ob.MouseButton1Click:Connect(function()
                            if multiSelect then
                                sel[opt] = not sel[opt]
                            else
                                for k in pairs(sel) do sel[k] = false end
                                sel[opt] = true
                                task.delay(0.08, close)
                            end
                            updateDisplay(); fireCb(); buildOpts(searchBox.Text)
                        end)
                        table.insert(optBtns, ob)
                    end
                end
            end
            local function positionPanel()
                local aP  = dispF.AbsolutePosition
                local aS  = dispF.AbsoluteSize
                local vp2 = workspace.CurrentCamera.ViewportSize
                local cnt = math.min(#allOpts, 7)
                local ph  = cnt * 34 + 52
                local pw  = math.max(260, aS.X + 10)
                local px  = math.min(aP.X, vp2.X - pw - 4)
                local py  = aP.Y + aS.Y + 4
                if py + ph > vp2.Y - 4 then
                    py = math.max(4, aP.Y - ph - 4)
                end
                panel.Size     = UDim2.fromOffset(pw, 0)
                panel.Position = UDim2.fromOffset(px, py)
                return ph
            end
            local function open()
                local targetH = positionPanel()
                panel.Visible = true
                isOpen = true
                searchBox.Text = ""
                buildOpts("")
                tw(panel,    {Size = UDim2.fromOffset(panel.AbsoluteSize.X, targetH)}, 0.2, Enum.EasingStyle.Back)
                tw(arrowLbl, {Rotation = 180}, 0.18)
            end
            trigger.MouseButton1Click:Connect(function()
                if isOpen then close() else open() end
            end)
            UserInputService.InputBegan:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                if not isOpen then return end
                local mp  = UserInputService:GetMouseLocation()
                local pp  = panel.AbsolutePosition; local ps2 = panel.AbsoluteSize
                local cp  = f.AbsolutePosition;     local cs  = f.AbsoluteSize
                local inP = mp.X>=pp.X and mp.X<=pp.X+ps2.X and mp.Y>=pp.Y and mp.Y<=pp.Y+ps2.Y
                local inC = mp.X>=cp.X and mp.X<=cp.X+cs.X  and mp.Y>=cp.Y and mp.Y<=cp.Y+cs.Y
                if not inP and not inC then close() end
            end)
            searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                buildOpts(searchBox.Text)
            end)
            updateDisplay()

            local obj = {}
            function obj:Set(val)
                sel = {}
                if type(val) == "table" then
                    if multiSelect then
                        for _, v in ipairs(val) do sel[tostring(v)] = true end
                    elseif val[1] then sel[tostring(val[1])] = true end
                elseif type(val) == "string" then
                    sel = {[val] = true}
                end
                updateDisplay()
                if isOpen then buildOpts(searchBox.Text) end
                fireCb()
            end
            function obj:Get()         return sel end
            function obj:GetSelected() return sel end
            function obj:Refresh(newOpts)
                allOpts = {}
                for _, v in ipairs(newOpts) do table.insert(allOpts, tostring(v)) end
                sel = {}
                updateDisplay()
                if isOpen then buildOpts(searchBox.Text) end
            end
            return obj
        end

        -- AddSlider
        function Tab:AddSlider(cfg)
            if type(cfg) ~= "table" then cfg = {cfg} end
            local name    = cfg[1] or cfg.Name or cfg.Title or "Slider"
            local desc    = cfg.Desc or cfg.Description or ""
            local min     = cfg.Min or cfg[2] or 0
            local max     = cfg.Max or cfg[3] or 100
            local default = cfg.Default or cfg[5] or min
            local cb      = cfg.Callback or cfg[6] or function() end
            local hasDesc = desc ~= ""
            local h       = hasDesc and 52 or 44
            local val     = math.clamp(default, min, max)
            local range   = math.max(max - min, 0.0001)
            local f       = mkCard(h)
            N("TextLabel", {
                Size = UDim2.new(1, -68, 0, 16),
                Position = UDim2.fromOffset(12, hasDesc and 8 or 6),
                BackgroundTransparency = 1,
                Text = name, TextColor3 = C.text,
                Font = Enum.Font.GothamMedium, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
            }, f)
            if hasDesc then
                N("TextLabel", {
                    Size = UDim2.new(1, -68, 0, 12),
                    Position = UDim2.fromOffset(12, 22),
                    BackgroundTransparency = 1,
                    Text = desc, TextColor3 = C.sub,
                    Font = Enum.Font.Gotham, TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
                }, f)
            end
            local valLbl = N("TextLabel", {
                Size = UDim2.fromOffset(56, 16),
                Position = UDim2.new(1, -60, 0, hasDesc and 8 or 6),
                BackgroundTransparency = 1,
                Text = tostring(val), TextColor3 = C.accent,
                Font = Enum.Font.GothamBold, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 13,
            }, f)
            local bar2 = N("Frame", {
                Size = UDim2.new(1, -24, 0, 4),
                Position = UDim2.new(0, 12, 1, -13),
                BackgroundColor3 = C.border,
                BorderSizePixel = 0, ZIndex = 13,
            }, f)
            corner(bar2, 2)
            local pct0 = (val - min) / range
            local fill = N("Frame", {Size = UDim2.fromScale(pct0, 1), BackgroundColor3 = C.accent, BorderSizePixel = 0, ZIndex = 14}, bar2)
            corner(fill, 2)
            local knob = N("Frame", {
                Size = UDim2.fromOffset(12, 12),
                Position = UDim2.new(pct0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = C.white,
                BorderSizePixel = 0, ZIndex = 15,
            }, bar2)
            corner(knob, 6)
            local hitbox = N("TextButton", {
                Size = UDim2.new(1, 8, 0, 22),
                Position = UDim2.new(0, -4, 0.5, -11),
                BackgroundTransparency = 1, Text = "", ZIndex = 16,
            }, bar2)
            local sliding = false
            local function update(mx)
                local bp  = bar2.AbsolutePosition
                local bs  = bar2.AbsoluteSize
                local pct = math.clamp((mx - bp.X) / bs.X, 0, 1)
                val = math.clamp(math.floor(pct * range + min + 0.5), min, max)
                local ap = (val - min) / range
                valLbl.Text = tostring(val)
                fill.Size = UDim2.fromScale(ap, 1)
                knob.Position = UDim2.new(ap, 0, 0.5, 0)
                task.spawn(cb, val)
            end
            hitbox.InputBegan:Connect(function(i)
                if i.UserInputType ~= Enum.UserInputType.MouseButton1
                and i.UserInputType ~= Enum.UserInputType.Touch then return end
                sliding = true; update(i.Position.X)
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)
            RunService.Heartbeat:Connect(function()
                if sliding then update(UserInputService:GetMouseLocation().X) end
            end)
            local obj = {}
            function obj:Set(v)
                val = math.clamp(v, min, max)
                local ap = (val - min) / range
                valLbl.Text = tostring(val)
                tw(fill, {Size = UDim2.fromScale(ap, 1)}, 0.15)
                tw(knob, {Position = UDim2.new(ap, 0, 0.5, 0)}, 0.15)
                task.spawn(cb, val)
            end
            function obj:Get() return val end
            return obj
        end

        -- AddTextBox
        function Tab:AddTextBox(cfg)
            if type(cfg) ~= "table" then cfg = {cfg} end
            local name        = cfg[1] or cfg.Name or cfg.Title or "TextBox"
            local desc        = cfg.Desc or cfg.Description or ""
            local default     = cfg[2] or cfg.Default or ""
            local placeholder = cfg.PlaceholderText or "Type here..."
            local cb          = cfg[4] or cfg.Callback or function() end
            local h           = desc ~= "" and 44 or 34
            local f           = mkCard(h)
            mkLabels(f, name, desc, 138)
            local box = N("TextBox", {
                Size = UDim2.new(0, 126, 0, 22),
                Position = UDim2.new(1, -132, 0.5, -11),
                BackgroundColor3 = C.surface,
                BorderSizePixel  = 0,
                Text = tostring(default),
                PlaceholderText = placeholder,
                PlaceholderColor3 = C.sub,
                TextColor3 = C.text,
                Font = Enum.Font.GothamMedium,
                TextSize = 10,
                ClearTextOnFocus = false,
                ZIndex = 13,
            }, f)
            corner(box, 6); stroke(box)
            N("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 6)}, box)
            box.Focused:Connect(function()    tw(box, {BackgroundColor3 = C.hover},   0.1) end)
            box.FocusLost:Connect(function()
                tw(box, {BackgroundColor3 = C.surface}, 0.1)
                task.spawn(cb, box.Text)
            end)
            local obj = {}
            function obj:Set(v) box.Text = tostring(v) end
            function obj:Get()  return box.Text        end
            return obj
        end

        -- AddKeybind
        function Tab:AddKeybind(cfg)
            if type(cfg) ~= "table" then cfg = {cfg} end
            local name    = cfg[1] or cfg.Name or cfg.Title or "Keybind"
            local desc    = cfg.Desc or cfg.Description or ""
            local default = cfg[2] or cfg.Default or Enum.KeyCode.Unknown
            local cb      = cfg[3] or cfg.Callback or function() end
            local h       = desc ~= "" and 44 or 34
            local curKey  = default
            local listening = false
            local f       = mkCard(h)
            mkLabels(f, name, desc, 96)
            local keyBtn = N("TextButton", {
                Size = UDim2.new(0, 86, 0, 22),
                Position = UDim2.new(1, -92, 0.5, -11),
                BackgroundColor3 = C.surface,
                BorderSizePixel  = 0,
                AutoButtonColor  = false,
                Text = curKey.Name,
                TextColor3 = C.text,
                Font = Enum.Font.GothamMedium,
                TextSize = 10,
                ZIndex = 13,
            }, f)
            corner(keyBtn, 6); stroke(keyBtn)
            keyBtn.MouseButton1Click:Connect(function()
                listening = not listening
                if listening then
                    keyBtn.Text = "..."
                    tw(keyBtn, {BackgroundColor3 = C.accentDim}, 0.1)
                else
                    keyBtn.Text = curKey.Name
                    tw(keyBtn, {BackgroundColor3 = C.surface}, 0.1)
                end
            end)
            UserInputService.InputBegan:Connect(function(inp, gpe)
                if not listening or gpe then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    curKey = inp.KeyCode
                    keyBtn.Text = curKey.Name
                    tw(keyBtn, {BackgroundColor3 = C.surface}, 0.1)
                    listening = false
                    task.spawn(cb, curKey)
                end
            end)
            local obj = {}
            function obj:Set(v)
                if typeof(v) == "EnumItem" then curKey = v
                elseif type(v) == "string" and Enum.KeyCode[v] then curKey = Enum.KeyCode[v] end
                keyBtn.Text = curKey.Name
            end
            function obj:Get() return curKey end
            return obj
        end

        -- AddColorPicker stub
        function Tab:AddColorPicker(cfg)
            if type(cfg) ~= "table" then cfg = {cfg} end
            local default = cfg[2] or cfg.Default or Color3.fromRGB(255,255,255)
            local cb      = cfg[3] or cfg.Callback or function() end
            local color   = default
            local obj = {}
            function obj:Set(c) color = c; task.spawn(cb, c) end
            function obj:Get()  return color end
            return obj
        end

        return Tab
    end -- MakeTab

    return Win
end -- MakeWindow

return lib
