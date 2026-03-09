-- ╔══════════════════════════════════════════════════╗
-- ║     DOOR ESP — ANIME ETERNAL STYLE               ║
-- ║   Drawing API · Dungeon Door Highlighter         ║
-- ╚══════════════════════════════════════════════════╝

if getgenv().DoorESP_Loaded then return end
getgenv().DoorESP_Loaded = true

getgenv().DoorESP = {
    Enabled         = false,
    ShowTracers     = true,
    ShowLabels      = true,
    MaxDistance     = 350,
    RaycastDistance = 8,

    -- Room type colours
    Colors = {
        Start   = Color3.fromRGB(0,   255,   0),  -- Green
        Boss    = Color3.fromRGB(255,  50,  50),  -- Red
        Monster = Color3.fromRGB(255, 165,   0),  -- Orange
        Default = Color3.fromRGB(255, 165,   0),
    },
}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ─────────────────────────────────────────────
-- Drawing helpers
-- ─────────────────────────────────────────────

local function NewText(size)
    local t        = Drawing.new("Text")
    t.Visible      = false
    t.Size         = size or 13
    t.Center       = true
    t.Outline      = true
    t.OutlineColor = Color3.fromRGB(0, 0, 0)
    t.Font         = Drawing.Fonts.Plex
    return t
end

local function NewLine()
    local l        = Drawing.new("Line")
    l.Visible      = false
    l.Transparency = 1
    l.Thickness    = 1
    return l
end

-- ─────────────────────────────────────────────
-- Raycast helper — checks if a door still has
-- a wall blocking it (= door not yet open)
-- ─────────────────────────────────────────────

local rayParams = RaycastParams.new()
rayParams.FilterType  = Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

local function DoorHasWall(adornee)
    if not adornee then return true end

    -- Quick name-check on descendants
    for _, c in ipairs(adornee.Parent and adornee.Parent:GetDescendants() or {}) do
        if c:IsA("BasePart") and (c.Name == "Wall" or c.Name:lower():find("wall")) then
            return true
        end
    end

    -- Raycast in six directions
    for _, dir in ipairs({
        Vector3.new(1,0,0), Vector3.new(-1,0,0),
        Vector3.new(0,1,0), Vector3.new(0,-1,0),
        Vector3.new(0,0,1), Vector3.new(0,0,-1),
    }) do
        local r = workspace:Raycast(
            adornee.Position,
            dir * getgenv().DoorESP.RaycastDistance,
            rayParams
        )
        if r and r.Instance then
            local h = r.Instance
            if h.Name == "Wall" or h.Name:lower():find("wall")
            or (h.Parent and h.Parent.Name:lower():find("labr")) then
                return true
            end
        end
    end
    return false
end

-- ─────────────────────────────────────────────
-- Room-colour logic
-- ─────────────────────────────────────────────

local function GetRoomColor(room)
    local n = room.Name:lower()
    local c = getgenv().DoorESP.Colors
    if n:find("start")                        then return c.Start,   "START"
    elseif n:find("boss") or n:find("end")   then return c.Boss,    "BOSS"
    elseif n:find("monster")                 then return c.Monster, "MON"
    end
    return c.Default, "ROOM"
end

-- ─────────────────────────────────────────────
-- Door cache + Drawing objects
-- ─────────────────────────────────────────────
-- Structure:
--   DoorCache[door] = { adornee, room, label(Drawing.Text), tracer(Drawing.Line) }
-- ─────────────────────────────────────────────

local DoorCache = {}

local function GetAdornee(door)
    if door:IsA("Model") then
        return door.PrimaryPart or door:FindFirstChildWhichIsA("BasePart")
    elseif door:IsA("BasePart") then
        return door
    end
end

local function RemoveDoor(door)
    local d = DoorCache[door]
    if d then
        pcall(function() d.label:Remove()  end)
        pcall(function() d.tracer:Remove() end)
        DoorCache[door] = nil
    end
end

local function HideDoor(door)
    local d = DoorCache[door]
    if d then
        d.label.Visible  = false
        d.tracer.Visible = false
    end
end

-- ─────────────────────────────────────────────
-- Main RenderStepped loop
-- ─────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    local cfg = getgenv().DoorESP

    -- Update raycast filter every frame so new characters are excluded
    local char = LocalPlayer.Character
    rayParams.FilterDescendantsInstances = char and {char} or {}

    local localHRP = char and char:FindFirstChild("HumanoidRootPart")

    -- ── 1. Scan Dungeons for new doors ──────────────────────────────
    if cfg.Enabled and localHRP then
        local dungeons = workspace:FindFirstChild("Dungeons")
        if dungeons then
            for _, dung in ipairs(dungeons:GetChildren()) do
                for _, room in ipairs(dung:GetChildren()) do
                    local doors = room:FindFirstChild("Doors")
                    if doors then
                        for _, door in ipairs(doors:GetChildren()) do
                            if not DoorCache[door] then
                                local adornee = GetAdornee(door)
                                if adornee then
                                    local dist = (adornee.Position - localHRP.Position).Magnitude
                                    if dist <= cfg.MaxDistance and not DoorHasWall(adornee) then
                                        DoorCache[door] = {
                                            adornee = adornee,
                                            room    = room,
                                            label   = NewText(13),
                                            tracer  = NewLine(),
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- ── 2. Find closest door (for tracer priority) ───────────────────
    local closestDoor, minDist = nil, math.huge
    if localHRP then
        for door, d in pairs(DoorCache) do
            if door.Parent and d.adornee then
                local dist = (d.adornee.Position - localHRP.Position).Magnitude
                if dist < minDist then minDist = dist; closestDoor = door end
            end
        end
    end

    -- ── 3. Update / hide each cached door ───────────────────────────
    for door, d in pairs(DoorCache) do
        -- Stale door — remove
        if not door.Parent or not d.adornee or not d.adornee.Parent then
            RemoveDoor(door)
            -- luacheck: ignore
            goto continue
        end

        if not cfg.Enabled or not localHRP then
            HideDoor(door)
            goto continue
        end

        local dist = (d.adornee.Position - localHRP.Position).Magnitude
        if dist > cfg.MaxDistance then
            HideDoor(door)
            goto continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(d.adornee.Position)
        if not onScreen then
            HideDoor(door)
            goto continue
        end

        local color, tag = GetRoomColor(d.room)
        local scale      = 1 / (d.adornee.Position - Camera.CFrame.Position).Magnitude * 100

        -- ── Label ──────────────────────────────────────────────
        d.label.Visible  = cfg.ShowLabels
        if cfg.ShowLabels then
            d.label.Text     = string.format("[ %s · %.0fm ]", tag, dist)
            d.label.Position = Vector2.new(pos.X, pos.Y - math.clamp(scale * 50, 20, 60) - 5)
            d.label.Color    = color
            d.label.Size     = math.clamp(scale * 90, 11, 15)
        end

        -- ── Tracer (only on the closest door) ──────────────────
        d.tracer.Visible = cfg.ShowTracers and (door == closestDoor)
        if d.tracer.Visible then
            local vp          = Camera.ViewportSize
            d.tracer.From     = Vector2.new(vp.X * 0.5, vp.Y)
            d.tracer.To       = Vector2.new(pos.X, pos.Y)
            d.tracer.Color    = color
            d.tracer.Thickness = 1
        end

        ::continue::
    end
end)

-- ─────────────────────────────────────────────
-- Cleanup when LocalPlayer respawns
-- (doors get re-scanned automatically)
-- ─────────────────────────────────────────────

LocalPlayer.CharacterRemoving:Connect(function()
    for door in pairs(DoorCache) do
        HideDoor(door)
    end
end)
