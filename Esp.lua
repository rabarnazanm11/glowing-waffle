--═══════════════════════════════════════════════════════════════════════════
--  💎 ESP MODULE
--  ─────────────────────────────────────────────────────────────────────────
--  TIP: To keep your main script clean you can host the entire ESP block
--  in a paste service (e.g. raw.githubusercontent.com / pastebin) and
--  replace this section with a single loadstring call:
--
--      local ESP = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--
--  The ESP table below is self-contained – just copy it to a separate file.
--═══════════════════════════════════════════════════════════════════════════
local ESP = {
    Enabled     = false,
    DoorCache   = {},
    ESPObjects  = {},
    LoopRunning = false,
    RaycastParams = nil,
}

function ESP:InitRaycast()
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Blacklist
    p.IgnoreWater = true
    p.FilterDescendantsInstances = {
        LocalPlayer.Character,
        Services.Workspace:FindFirstChild("AES_ESP_Folder"),
    }
    return p
end

function ESP:DoorHasWall(door)
    local adornee = door:IsA("Model")
        and (door.PrimaryPart or door:FindFirstChildWhichIsA("BasePart"))
        or  door
    if not adornee then return true end
    if door:FindFirstChild("Wall") then return true end
    for _, c in ipairs(door:GetDescendants()) do
        if c:IsA("BasePart") and (c.Name == "Wall" or c.Name:lower():find("wall")) then
            return true
        end
    end
    if not self.RaycastParams then self.RaycastParams = self:InitRaycast() end
    local pos = adornee.Position
    for _, dir in ipairs({
        Vector3.new(1,0,0), Vector3.new(-1,0,0),
        Vector3.new(0,1,0), Vector3.new(0,-1,0),
        Vector3.new(0,0,1), Vector3.new(0,0,-1),
    }) do
        local r = Services.Workspace:Raycast(pos, dir * Config.ESP.RaycastDistance, self.RaycastParams)
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

function ESP:GetAdornee(door)
    if door:IsA("Model")    then return door.PrimaryPart or door:FindFirstChildWhichIsA("BasePart")
    elseif door:IsA("BasePart") then return door end
end

function ESP:IsValidDoor(door)
    return door and door.Parent and self:GetAdornee(door) and not self:DoorHasWall(door)
end

function ESP:GetRoomColor(room)
    local n = room.Name:lower()
    if n:find("start")              then return Config.ESP.Colors.Start
    elseif n:find("boss") or n:find("end") then return Config.ESP.Colors.Boss
    elseif n:find("monster")        then return Config.ESP.Colors.Monster
    end
    return Config.ESP.Colors.Default
end

function ESP:RemoveESP(door)
    if self.ESPObjects[door] then
        if self.ESPObjects[door].folder then self.ESPObjects[door].folder:Destroy() end
        self.ESPObjects[door] = nil
    end
end

function ESP:Cleanup()
    for door in pairs(self.ESPObjects) do self:RemoveESP(door) end
    self.DoorCache  = {}
    self.ESPObjects = {}
end

function ESP:UpdateDoorESP(door, data, isClosest)
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not door.Parent then return self:RemoveESP(door) end

    local dist = (data.adornee.Position - hrp.Position).Magnitude
    if dist > Config.ESP.MaxDistance then return self:RemoveESP(door) end

    if not self.ESPObjects[door] then
        local folder   = Instance.new("Folder", data.adornee)
        folder.Name    = "AES_ESP"

        local box           = Instance.new("BoxHandleAdornment", folder)
        box.Adornee         = data.adornee
        box.AlwaysOnTop     = true
        box.ZIndex          = 5
        box.Size            = data.adornee.Size + Vector3.new(0.2, 0.2, 0.2)
        box.Transparency    = 0.5

        local bill          = Instance.new("BillboardGui", folder)
        bill.Adornee        = data.adornee
        bill.Size           = UDim2.fromScale(4, 1.5)
        bill.AlwaysOnTop    = true
        bill.StudsOffset    = Vector3.new(0, data.adornee.Size.Y / 2 + 2, 0)

        local txt           = Instance.new("TextLabel", bill)
        txt.Size            = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Font            = Enum.Font.GothamBold
        txt.TextSize        = 20
        txt.TextStrokeTransparency = 0.3
        txt.TextStrokeColor3 = Color3.new(0,0,0)

        local beam          = Instance.new("Beam", folder)
        beam.Attachment0    = Instance.new("Attachment", data.adornee)
        beam.Attachment1    = Instance.new("Attachment", Services.Workspace.Terrain)
        beam.Width0         = 0.05
        beam.Width1         = 0.05
        beam.Transparency   = NumberSequence.new(0.4)
        beam.Enabled        = false

        self.ESPObjects[door] = {
            folder = folder, box = box,
            text   = txt,    beam = beam,
            a1     = beam.Attachment1,
        }
    end

    local color = self:GetRoomColor(data.room)
    local obj   = self.ESPObjects[door]
    obj.box.Color3      = color
    obj.text.TextColor3 = color
    obj.text.Text       = string.format("[%.1fm]", dist)
    if isClosest then
        obj.beam.Enabled = true
        obj.beam.Color   = ColorSequence.new(color)
        obj.a1.WorldPosition = hrp.Position - Vector3.new(0,3,0)
    else
        obj.beam.Enabled = false
    end
end

function ESP:Run()
    if self.LoopRunning then return end
    self.LoopRunning = true
    while self.Enabled do
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            self.RaycastParams = self:InitRaycast()
            local dungeons = Services.Workspace:FindFirstChild("Dungeons")
            if dungeons then
                for _, dung in ipairs(dungeons:GetChildren()) do
                    for _, room in ipairs(dung:GetChildren()) do
                        local doors = room:FindFirstChild("Doors")
                        if doors then
                            for _, door in ipairs(doors:GetChildren()) do
                                local adornee = self:GetAdornee(door)
                                if adornee then
                                    local dist = (adornee.Position - hrp.Position).Magnitude
                                    if dist <= Config.ESP.MaxDistance
                                    and self:IsValidDoor(door)
                                    and not self.DoorCache[door] then
                                        self.DoorCache[door] = {adornee = adornee, room = room}
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local closestDoor, minDist = nil, math.huge
            for door, data in pairs(self.DoorCache) do
                if door.Parent and data.adornee then
                    local d = (data.adornee.Position - hrp.Position).Magnitude
                    if d < minDist then minDist = d; closestDoor = door end
                else
                    self.DoorCache[door] = nil
                    self:RemoveESP(door)
                end
            end

            for door, data in pairs(self.DoorCache) do
                self:UpdateDoorESP(door, data, door == closestDoor)
            end
        end
        task.wait(Config.ESP.UpdateRate)
    end
    self.LoopRunning = false
end
