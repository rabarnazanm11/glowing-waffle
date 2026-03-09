-- ╔══════════════════════════════════════════╗
-- ║     PLAYER ESP — ANIME FINALS STYLE      ║
-- ║   Game-Native Labels + Tracers           ║
-- ╚══════════════════════════════════════════╝

if getgenv().PlayerESP_Loaded then return end
getgenv().PlayerESP_Loaded = true

getgenv().PlayerESP = {
    Enabled      = false,
    TeamCheck    = false,
    ShowTracers  = true,
    MaxDistance  = 2000,
    AllyColor    = Color3.fromRGB(0, 255, 100),
    EnemyColor   = Color3.fromRGB(255, 60, 60),
    TracerColor  = Color3.fromRGB(0, 200, 255),
}

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPContainer = {}

-- ─────────────────────────────────────────────
-- Safe font fallback
-- ─────────────────────────────────────────────
local SafeFont = (Drawing.Fonts and Drawing.Fonts.Plex) or 2

-- ─────────────────────────────────────────────
-- Drawing helpers
-- ─────────────────────────────────────────────

local function NewText(size)
    local ok, t = pcall(Drawing.new, "Text")
    if not ok then return nil end
    t.Visible      = false
    t.Size         = size or 13
    t.Center       = true
    t.Outline      = true
    t.OutlineColor = Color3.fromRGB(0, 0, 0)
    t.Font         = SafeFont
    return t
end

local function NewLine()
    local ok, l = pcall(Drawing.new, "Line")
    if not ok then return nil end
    l.Visible      = false
    l.Transparency = 1
    l.Thickness    = 1
    return l
end

-- ─────────────────────────────────────────────
-- ESP object factory
-- ─────────────────────────────────────────────

local function MakeESPObjects()
    return {
        NameLine = NewText(13),
        HpLine   = NewText(12),
        Tracer   = NewLine(),
    }
end

local function HideAll(esp)
    if not esp then return end
    if esp.NameLine then esp.NameLine.Visible = false end
    if esp.HpLine   then esp.HpLine.Visible   = false end
    if esp.Tracer   then esp.Tracer.Visible   = false end
end

local function RemoveESP(player)
    local esp = ESPContainer[player]
    if not esp then return end
    pcall(function() if esp.NameLine then esp.NameLine:Remove() end end)
    pcall(function() if esp.HpLine   then esp.HpLine:Remove()   end end)
    pcall(function() if esp.Tracer   then esp.Tracer:Remove()   end end)
    ESPContainer[player] = nil
end

-- ─────────────────────────────────────────────
-- Main CreateESP
-- ─────────────────────────────────────────────

local function CreateESP(player)
    if player == LocalPlayer then return end

    local esp = MakeESPObjects()
    -- Bail out if Drawing failed entirely
    if not esp.NameLine or not esp.HpLine or not esp.Tracer then
        warn("[PlayerESP] Drawing API unavailable — ESP disabled")
        return
    end

    ESPContainer[player] = esp

    RunService.RenderStepped:Connect(function()
        local e = ESPContainer[player]
        if not e then return end

        local cfg = getgenv().PlayerESP
        if not cfg or not cfg.Enabled then HideAll(e) return end

        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not hrp or not hum or hum.Health <= 0 then HideAll(e) return end

        local localChar = LocalPlayer.Character
        local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then HideAll(e) return end

        local dist = math.floor((localHRP.Position - hrp.Position).Magnitude)
        if dist > cfg.MaxDistance then HideAll(e) return end

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then HideAll(e) return end

        -- ── Team label ──────────────────────────────
        local isAlly     = (player.Team ~= nil and player.Team == LocalPlayer.Team)
        local teamLabel  = isAlly and "Ally" or "Enemy"
        local labelColor = isAlly and cfg.AllyColor or cfg.EnemyColor

        if cfg.TeamCheck and isAlly then HideAll(e) return end

        -- ── Scale ───────────────────────────────────
        local camDist = (hrp.Position - Camera.CFrame.Position).Magnitude
        local scale   = 1 / camDist * 100
        local sy      = 55 * scale

        local namePos = Vector2.new(pos.X, pos.Y - sy - 18)
        local hpPos   = Vector2.new(pos.X, pos.Y - sy - 3)

        -- ── Name line ───────────────────────────────
        e.NameLine.Visible  = true
        e.NameLine.Text     = string.format("[ %s | %d Studs | %s ]", player.Name, dist, teamLabel)
        e.NameLine.Position = namePos
        e.NameLine.Color    = labelColor
        e.NameLine.Size     = math.clamp(scale * 95, 11, 14)

        -- ── HP line ─────────────────────────────────
        local curHP = math.floor(hum.Health)
        local maxHP = math.floor(hum.MaxHealth)

        e.HpLine.Visible  = true
        e.HpLine.Text     = string.format("[ HP: %d / %d ]", curHP, maxHP)
        e.HpLine.Position = hpPos
        e.HpLine.Color    = labelColor
        e.HpLine.Size     = math.clamp(scale * 85, 10, 13)

        -- ── Tracer ──────────────────────────────────
        e.Tracer.Visible = cfg.ShowTracers
        if cfg.ShowTracers then
            local vp = Camera.ViewportSize
            e.Tracer.From      = Vector2.new(vp.X * 0.5, vp.Y)
            e.Tracer.To        = Vector2.new(pos.X, pos.Y + sy)
            e.Tracer.Color     = cfg.TracerColor
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
