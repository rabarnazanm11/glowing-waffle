-- ╔══════════════════════════════════════════╗
-- ║     PLAYER ESP — MODERN EDITION          ║
-- ║   Corner Brackets · Health Bar · Tracers ║
-- ╚══════════════════════════════════════════╝

if getgenv().PlayerESP_Loaded then return end
getgenv().PlayerESP_Loaded = true

getgenv().PlayerESP = {
    Enabled       = false,
    TeamCheck     = false,
    ShowNames     = true,
    ShowDistance  = true,
    ShowHealth    = true,
    ShowTracers   = false,
    FullBox       = false,       -- false = cool corner brackets, true = plain full box
    Color         = Color3.fromRGB(0, 200, 255),
    Thickness     = 1.5,
    AutoThickness = true,
    MaxDistance   = 2000,
    CornerRatio   = 0.25,        -- how long each corner arm is (0.0 - 0.5)
}

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPContainer = {}

-- ─────────────────────────────────────────────
-- Drawing helpers
-- ─────────────────────────────────────────────

local function NewLine(color, thickness)
    local l = Drawing.new("Line")
    l.Visible     = false
    l.Color       = color or Color3.fromRGB(255, 255, 255)
    l.Thickness   = thickness or 1
    l.Transparency = 1
    return l
end

local function NewSquare()
    local s = Drawing.new("Square")
    s.Visible     = false
    s.Filled      = true
    s.Transparency = 0.55
    s.Color       = Color3.fromRGB(0, 0, 0)
    s.Thickness   = 0
    return s
end

local function NewText(size)
    local t = Drawing.new("Text")
    t.Visible      = false
    t.Color        = Color3.fromRGB(255, 255, 255)
    t.Size         = size or 13
    t.Center       = true
    t.Outline      = true
    t.OutlineColor = Color3.fromRGB(0, 0, 0)
    t.Font         = Drawing.Fonts.Plex
    return t
end

-- ─────────────────────────────────────────────
-- ESP object factory
-- ─────────────────────────────────────────────

local function MakeESPObjects()
    -- 8 corner lines (2 per corner)
    local corners = {}
    for i = 1, 8 do
        corners[i] = NewLine()
    end

    -- 4 full-box lines (shown only when FullBox = true)
    local fullbox = {}
    for i = 1, 4 do
        fullbox[i] = NewLine()
    end

    -- Health bar
    local hpBG      = NewLine(Color3.fromRGB(0, 0, 0), 4)
    local hpFill    = NewLine(Color3.fromRGB(0, 255, 0), 2)

    -- Name tag
    local nameBG    = NewSquare()
    local nameText  = NewText(13)

    -- Info line (distance + health %)
    local infoText  = NewText(11)

    -- Tracer
    local tracer    = NewLine()

    return {
        Corners   = corners,
        FullBox   = fullbox,
        HpBG      = hpBG,
        HpFill    = hpFill,
        NameBG    = nameBG,
        NameText  = nameText,
        InfoText  = infoText,
        Tracer    = tracer,
    }
end

local function HideAll(esp)
    if not esp then return end
    for _, l in ipairs(esp.Corners)  do l.Visible = false end
    for _, l in ipairs(esp.FullBox)  do l.Visible = false end
    esp.HpBG.Visible     = false
    esp.HpFill.Visible   = false
    esp.NameBG.Visible   = false
    esp.NameText.Visible = false
    esp.InfoText.Visible = false
    esp.Tracer.Visible   = false
end

local function RemoveESP(player)
    local esp = ESPContainer[player]
    if not esp then return end
    for _, l in ipairs(esp.Corners) do pcall(function() l:Remove() end) end
    for _, l in ipairs(esp.FullBox) do pcall(function() l:Remove() end) end
    local objs = {"HpBG","HpFill","NameBG","NameText","InfoText","Tracer"}
    for _, k in ipairs(objs) do pcall(function() esp[k]:Remove() end) end
    ESPContainer[player] = nil
end

-- ─────────────────────────────────────────────
-- HP color: green → yellow → red
-- ─────────────────────────────────────────────

local function HpColor(ratio)
    if ratio > 0.5 then
        local t = (ratio - 0.5) * 2
        return Color3.fromRGB(
            math.floor(255 * (1 - t)),
            255,
            0
        )
    else
        local t = ratio * 2
        return Color3.fromRGB(
            255,
            math.floor(255 * t),
            0
        )
    end
end

-- ─────────────────────────────────────────────
-- Draw corner brackets
-- Corners[1-2] = TL, [3-4] = TR, [5-6] = BR, [7-8] = BL
-- ─────────────────────────────────────────────

local function DrawCorners(esp, TL, TR, BR, BL, cfg, thickness)
    local ratio = cfg.CornerRatio
    local w = TR.X - TL.X
    local h = BL.Y - TL.Y
    local cx = w * ratio
    local cy = h * ratio

    local corners = esp.Corners
    local col = cfg.Color

    -- TL
    corners[1].From = TL; corners[1].To = Vector2.new(TL.X + cx, TL.Y)
    corners[2].From = TL; corners[2].To = Vector2.new(TL.X, TL.Y + cy)
    -- TR
    corners[3].From = TR; corners[3].To = Vector2.new(TR.X - cx, TR.Y)
    corners[4].From = TR; corners[4].To = Vector2.new(TR.X, TR.Y + cy)
    -- BR
    corners[5].From = BR; corners[5].To = Vector2.new(BR.X - cx, BR.Y)
    corners[6].From = BR; corners[6].To = Vector2.new(BR.X, BR.Y - cy)
    -- BL
    corners[7].From = BL; corners[7].To = Vector2.new(BL.X + cx, BL.Y)
    corners[8].From = BL; corners[8].To = Vector2.new(BL.X, BL.Y - cy)

    for _, l in ipairs(corners) do
        l.Visible   = true
        l.Color     = col
        l.Thickness = thickness + 0.5  -- corners slightly bolder
    end
end

local function DrawFullBox(esp, TL, TR, BR, BL, cfg, thickness)
    local fb = esp.FullBox
    local col = cfg.Color
    fb[1].From = TL; fb[1].To = TR
    fb[2].From = TR; fb[2].To = BR
    fb[3].From = BR; fb[3].To = BL
    fb[4].From = BL; fb[4].To = TL
    for _, l in ipairs(fb) do
        l.Visible   = true
        l.Color     = col
        l.Thickness = thickness
    end
end

-- ─────────────────────────────────────────────
-- Main CreateESP
-- ─────────────────────────────────────────────

local function CreateESP(player)
    if player == LocalPlayer then return end

    local esp = MakeESPObjects()
    ESPContainer[player] = esp

    RunService.RenderStepped:Connect(function()
        local e = ESPContainer[player]
        if not e then return end

        local cfg = getgenv().PlayerESP
        if not cfg.Enabled then HideAll(e) return end

        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not hrp or not hum or hum.Health <= 0 then HideAll(e) return end
        if cfg.TeamCheck and player.Team == LocalPlayer.Team then HideAll(e) return end

        local localChar = LocalPlayer.Character
        local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then HideAll(e) return end

        local dist = (localHRP.Position - hrp.Position).Magnitude
        if dist > cfg.MaxDistance then HideAll(e) return end

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then HideAll(e) return end

        -- ── Box geometry ──────────────────────────────
        local scale = 1 / (hrp.Position - Camera.CFrame.Position).Magnitude * 100
        local sx = 35 * scale
        local sy = 55 * scale

        local TL = Vector2.new(pos.X - sx, pos.Y - sy)
        local TR = Vector2.new(pos.X + sx, pos.Y - sy)
        local BL = Vector2.new(pos.X - sx, pos.Y + sy)
        local BR = Vector2.new(pos.X + sx, pos.Y + sy)

        local thickness = cfg.AutoThickness
            and math.clamp(1 / dist * 120, 1, 3)
            or cfg.Thickness

        -- ── Box style ─────────────────────────────────
        if cfg.FullBox then
            for _, l in ipairs(e.Corners) do l.Visible = false end
            DrawFullBox(e, TL, TR, BR, BL, cfg, thickness)
        else
            for _, l in ipairs(e.FullBox) do l.Visible = false end
            DrawCorners(e, TL, TR, BR, BL, cfg, thickness)
        end

        -- ── Health bar ────────────────────────────────
        local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)

        e.HpBG.Visible   = cfg.ShowHealth
        e.HpFill.Visible = cfg.ShowHealth

        if cfg.ShowHealth then
            local barX   = TL.X - 5
            local barTop = TL.Y
            local barBot = BL.Y

            e.HpBG.From      = Vector2.new(barX, barTop)
            e.HpBG.To        = Vector2.new(barX, barBot)
            e.HpBG.Thickness = 4
            e.HpBG.Color     = Color3.fromRGB(20, 20, 20)

            e.HpFill.From      = Vector2.new(barX, barBot)
            e.HpFill.To        = Vector2.new(barX, barBot - (barBot - barTop) * hpRatio)
            e.HpFill.Thickness = 2
            e.HpFill.Color     = HpColor(hpRatio)
        end

        -- ── Name tag ──────────────────────────────────
        e.NameBG.Visible   = cfg.ShowNames
        e.NameText.Visible = cfg.ShowNames

        if cfg.ShowNames then
            local label   = player.DisplayName
            local tagW    = #label * 7 + 10
            local tagH    = 16
            local tagX    = pos.X - tagW * 0.5
            local tagY    = TL.Y - tagH - 3

            e.NameBG.Position    = Vector2.new(tagX, tagY)
            e.NameBG.Size        = Vector2.new(tagW, tagH)
            e.NameBG.Color       = Color3.fromRGB(0, 0, 0)
            e.NameBG.Transparency = 0.45

            e.NameText.Text     = label
            e.NameText.Position = Vector2.new(pos.X, tagY + 1)
            e.NameText.Color    = cfg.Color
            e.NameText.Size     = math.clamp(scale * 90, 10, 14)
        end

        -- ── Info line (distance · hp%) ─────────────────
        e.InfoText.Visible = cfg.ShowDistance

        if cfg.ShowDistance then
            local hp = math.floor(hpRatio * 100)
            e.InfoText.Text     = string.format("%dm  •  %d%%", math.floor(dist), hp)
            e.InfoText.Position = Vector2.new(pos.X, BR.Y + 3)
            e.InfoText.Color    = Color3.fromRGB(180, 180, 180)
            e.InfoText.Size     = math.clamp(scale * 80, 9, 12)
        end

        -- ── Tracer ────────────────────────────────────
        e.Tracer.Visible = cfg.ShowTracers

        if cfg.ShowTracers then
            local vp = Camera.ViewportSize
            e.Tracer.From      = Vector2.new(vp.X * 0.5, vp.Y)
            e.Tracer.To        = Vector2.new(pos.X, BR.Y)
            e.Tracer.Color     = cfg.Color
            e.Tracer.Thickness = 1
        end
    end)

    player.CharacterRemoving:Connect(function()
        HideAll(ESPContainer[player])
    end)
end

-- ─────────────────────────────────────────────
-- Init
-- ─────────────────────────────────────────────

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not ESPContainer[player] then CreateESP(player) end
    end)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(RemoveESP)
