-- ============================================================
-- DOORS HUB  (Updated)
-- ============================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS               = game:GetService("UserInputService")
local PPS               = game:GetService("ProximityPromptService")

local LocalPlayer  = Players.LocalPlayer
local Character    = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP          = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
end)

local Workspace    = game:GetService("Workspace")
local CurrentRooms = Workspace:WaitForChild("CurrentRooms")
local Camera       = Workspace.CurrentCamera

-- ============================================================
-- LOAD REDZLIB
-- ============================================================
local RedzLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/rabarnazanm11/glowing-waffle/refs/heads/main/hh"
))()

-- ============================================================
--  ★ EASY-EDIT TABLES ★
-- ============================================================

local ENTITIES = {
    { Name = "RushMoving",      Display = "Rush",          Color = Color3.fromRGB(255, 80,  0),   notify = true,  highlight = true,  tracer = true  },
    { Name = "Eyes",            Display = "Eyes",          Color = Color3.fromRGB(255, 30,  30),  notify = true,  highlight = true,  tracer = true,  workspaceOnly = true },
    { Name = "AmbushMoving",    Display = "Ambush",        Color = Color3.fromRGB(160, 0,   255), notify = true,  highlight = true,  tracer = true  },
    { Name = "BackdoorRush",    Display = "Backdoor Rush", Color = Color3.fromRGB(255, 120, 0),   notify = true,  highlight = true,  tracer = true  },
    { Name = "Dread",           Display = "Dread",         Color = Color3.fromRGB(180, 0,   0),   notify = true,  highlight = true,  tracer = true  },
    { Name = "GiggleCeiling",   Display = "Giggle",        Color = Color3.fromRGB(255, 150, 200), notify = false, highlight = true,  tracer = true  },
    { Name = "SallyMoving",     Display = "Sally",         Color = Color3.fromRGB(180, 255, 80),  notify = true,  highlight = true,  tracer = true  },
    { Name = "GloombatSwarm",   Display = "GloombatSwarm", Color = Color3.fromRGB(80,  0,   120), notify = false, highlight = false, tracer = false },
    { Name = "A60",             Display = "A-60",          Color = Color3.fromRGB(50,  100, 255), notify = true,  highlight = true,  tracer = true  },
    { Name = "A120",            Display = "A-120",         Color = Color3.fromRGB(0,   220, 255), notify = true,  highlight = true,  tracer = true  },
    { Name = "Screech",         Display = "Screech",       Color = Color3.fromRGB(200, 200, 255), notify = true,  highlight = true,  tracer = true  },
    { Name = "BackdoorLookman", Display = "Lookman",       Color = Color3.fromRGB(160, 100, 50),  notify = true,  highlight = true,  tracer = true  },
    { Name = "MonumentEntity",  Display = "Monument",      Color = Color3.fromRGB(150, 150, 150), notify = true,  highlight = true,  tracer = true  },
    { Name = "JeffTheKiller",   Display = "Jeff",          Color = Color3.fromRGB(180, 0,   30),  notify = true,  highlight = true,  tracer = true  },
    { Name = "FigureRig",       Display = "Figure",        Color = Color3.fromRGB(80,  80,  80),  notify = true,  highlight = true,  tracer = true  },
    { Name = "Snare",           Display = "Snare",         Color = Color3.fromRGB(80,  80,  80),  notify = false, highlight = true,  tracer = false },
    { Name = "GloomPile",       Display = "GloomPile",     Color = Color3.fromRGB(80,  80,  80),  notify = false, highlight = true,  tracer = false },
    { Name = "Gloombat",        Display = "Gloombat",      Color = Color3.fromRGB(80,  80,  80),  notify = false, highlight = true,  tracer = false },
    { Name = "Grumbo",          Display = "Grumbo",        Color = Color3.fromRGB(80,  80,  80),  notify = false, highlight = true,  tracer = true  },
    { Name = "SeekHand",        Display = "SeekHand",      Color = Color3.fromRGB(80,  80,  80),  notify = false, highlight = true,  tracer = true  },
    { Name = "SeekSludge",      Display = "SeekSludge",    Color = Color3.fromRGB(80,  80,  80),  notify = false, highlight = true,  tracer = true  },
    { Name = "SeekWorm",        Display = "SeekWorm",      Color = Color3.fromRGB(80,  80,  80),  notify = false, highlight = true,  tracer = true  },
}

local SEARCH_ITEMS = {
    "KeyObtain", "Vitamins", "GoldPile", "Lockpick",
    "Crucifix",  "Lighter",  "Battery",  "Flashlight",
    "SkeletonKey", "Candle", "Smoothie", "CrucifixOnTheWall",
    "FuseObtain", "LiveBreakerPolePickup","KeyIron",
    "Donut", "Compass","BandagePack","ElectricalKeyObtain",
}

local ENTITY_MAP = {}
for _, e in ipairs(ENTITIES) do ENTITY_MAP[e.Name] = e end

local ITEM_SET = {}
for _, name in ipairs(SEARCH_ITEMS) do ITEM_SET[name] = true end

local AUTOPROXI_BLACKLIST = {
    Wardrobe         = true, WardrobeInner    = true,
    Double_Bed       = true, Painting_Big     = true,
    Painting_VeryBig = true, Toolshed         = true,
    Bed              = true, Toilet           = true,
    WallSink         = true, Painting_Tall    = true,
    Fireplace        = true, Painting_Small   = true,
    Typewriter       = true, ReviveRift       = true,
    Locker_Large     = true,
    LadderModel      = true,
    CircularVent     = true,
    Dumpster         = true,
    Ladder           = true,
    FireBarrel       = true,
}

-- ============================================================
-- ★ CUSTOM ESP TABLE ★
-- ============================================================
local CUSTOM_ESP = {
    { Name = "MinesGenerator", Display = "Mines Generator", Color = Color3.fromRGB(255, 200, 50),  toggle = true,  highlights = {}, cached = {} },
    { Name = "Cellar",         Display = "Cellar",          Color = Color3.fromRGB(120, 70,  30),  toggle = false, highlights = {}, cached = {} },
    { Name = "Shears",         Display = "Shears",          Color = Color3.fromRGB(200, 200, 200), toggle = false, highlights = {}, cached = {} },
    { Name = "Locker_Large",   Display = "Locker (Large)",  Color = Color3.fromRGB(80,  120, 200), toggle = false, highlights = {}, cached = {} },
    { Name = "CircularVent",   Display = "CircularVent",    Color = Color3.fromRGB(80,  120, 200), toggle = false, highlights = {}, cached = {} },
    { Name = "Dumpster",       Display = "Dumpster",        Color = Color3.fromRGB(80,  120, 200), toggle = false, highlights = {}, cached = {} },
    { Name = "Toolshed_Small", Display = "Toolshed_Small",  Color = Color3.fromRGB(80,  120, 200), toggle = false, highlights = {}, cached = {} },
    { Name = "WaterPump",      Display = "WaterPump",       Color = Color3.fromRGB(80,  120, 200), toggle = false, highlights = {}, cached = {} },
}

-- ============================================================
-- COLORS / CFG
-- ============================================================
local CFG = {
    ItemColor       = Color3.fromRGB(80,  255, 120),
    EntranceColor   = Color3.fromRGB(187, 187, 14),
    LockedDoorColor = Color3.fromRGB(0,   0,   0),
    WardrobeColor   = Color3.fromRGB(200, 140, 60),
    LeverColor      = Color3.fromRGB(255, 220, 0),
    MinesColor      = Color3.fromRGB(255, 60,  60),
    TracerThick     = 1,
    TracerAlpha     = 0.5,
    LabelSize       = 14,
}

-- ============================================================
-- SHOW SETTINGS
-- ============================================================
local SHOW = {
    DoorHighlight     = false,
    DoorTracer        = true,
    ItemHighlight     = true,
    ItemTracer        = true,
    EntityHighlight   = true,
    EntityTracer      = false,
    WardrobeHighlight = true,
    WardrobeTracer    = true,
    LeverHighlight    = true,
    LeverTracer       = true,
}

-- ============================================================
-- STATE
-- ============================================================
local s                  = 3
local CurrentRoomToggle  = false
local EntityNotifyToggle = true
local ItemESPToggle      = true
local WardrobeESPToggle  = true
local LeverESPToggle     = true
local DoorRangeToggle    = true
local DoorNextToggle     = false

local CharJumpOn     = true
local CharSlideOn    = true
local CharCrouchOn   = true
local CharSpeedValue = 4

local entityHighlights   = {}
local itemHighlights     = {}
local doorHighlights     = {}
local wardrobeHighlights = {}
local leverHighlights    = {}

local entityConnections = {}
local espDrawings       = {}

local cachedItems     = {}
local cachedWardrobes = {}
local cachedLevers    = {}
local cachedDoors     = {}

-- Player
local ClientGlowOn        = true
local clientGlowLight     = nil
local InstantInteractConn = nil
local ProxiReachValue     = 5
local AutoProxiOn         = true
local autoProxiConn       = nil
local LootAuraOn          = false

-- ESP
local TestEntityESPOn = true
local TestChestESPOn  = true
local TestBookESPOn   = false
local TestPlayerESPOn = false

local testEntityHighlights = {}
local chestHighlights      = {}
local bookHighlights       = {}
local playerHighlights     = {}

local cachedChests = {}
local cachedBooks  = {}

local testEntityConns = {}

-- MinesAnchor ESP
local MinesAnchorESPOn      = false
local minesAnchorHighlights = {}
local cachedMinesAnchors    = {}

-- Seek Guide Path
local SeekGuidePathOn   = false
local seekGuideConn     = nil
local seekGuideModified = {}

-- ============================================================
-- HIGHLIGHT HELPERS
-- ============================================================
local function makeHighlight(inst, color)
    local h               = Instance.new("Highlight")
    h.FillColor           = color
    h.OutlineColor        = color
    h.FillTransparency    = 0.4
    h.OutlineTransparency = 0
    h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent              = inst
    return h
end

local function applyHL(tbl, inst, color)
    if tbl[inst] then return end
    tbl[inst] = makeHighlight(inst, color)
end

local function removeHL(tbl, inst)
    if tbl[inst] then tbl[inst]:Destroy(); tbl[inst] = nil end
end

local function clearHL(tbl)
    for inst in pairs(tbl) do
        if tbl[inst] then tbl[inst]:Destroy() end
        tbl[inst] = nil
    end
end

-- ============================================================
-- DRAWING HELPERS
-- ============================================================
local function W2S(pos)
    local v, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), onScreen, v.Z
end

local function clearESP()
    for _, d in ipairs(espDrawings) do pcall(function() d:Remove() end) end
    espDrawings = {}
end

local function getPos(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst.Position end
    if inst:IsA("Model") and inst.PrimaryPart then return inst.PrimaryPart.Position end
    local bp = inst:FindFirstChildWhichIsA("BasePart", true)
    if bp then return bp.Position end
    local ok, piv = pcall(function() return inst:GetPivot() end)
    if ok then return piv.Position end
    return nil
end

local function isInsideBookcase(inst)
    local p = inst.Parent
    while p and p ~= CurrentRooms and p ~= Workspace do
        if p.Name == "Bookcase" then return true end
        p = p.Parent
    end
    return false
end

local function makeLabel(text, pos, color)
    local l   = Drawing.new("Text")
    l.Text    = text; l.Position = pos; l.Size = CFG.LabelSize
    l.Color   = color; l.Outline = true; l.Center = true; l.Visible = true
    table.insert(espDrawings, l)
end

local function makeTracer(screenPos, color)
    local t        = Drawing.new("Line")
    t.From         = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    t.To           = screenPos; t.Color = color
    t.Thickness    = CFG.TracerThick; t.Transparency = CFG.TracerAlpha; t.Visible = true
    table.insert(espDrawings, t)
end

local function espPoint(worldPos, label, color, hrpPos, showTracer)
    local sPos, onScreen, depth = W2S(worldPos)
    if onScreen and depth > 0 then
        local dist = math.floor((worldPos - hrpPos).Magnitude + 0.5)
        makeLabel(label .. " | " .. dist .. "M", sPos, color)
        if showTracer then makeTracer(sPos, color) end
    end
end

-- ============================================================
-- ESP RANGE HELPER — currentRoom ±1
-- ============================================================
local function getRoomNum(inst)
    local p = inst
    while p and p.Parent do
        if p.Parent == CurrentRooms then return tonumber(p.Name) end
        p = p.Parent
    end
    return nil
end

local function isInESPRange(inst)
    local curRoom = LocalPlayer:GetAttribute("CurrentRoom")
    if not curRoom then return true end
    local roomNum = getRoomNum(inst)
    if not roomNum then return false end
    return math.abs(roomNum - curRoom) <= 1
end

-- ============================================================
-- DOOR LOCK DETECTION
-- ============================================================
local function isDoorLocked(room)
    local door = room:FindFirstChild("Door")
    return door and door:FindFirstChild("Lock") ~= nil
end

-- ============================================================
-- Eyes workspaceOnly check
-- ============================================================
local function isEntityAllowed(inst, ent)
    if ent.workspaceOnly then
        return inst.Parent == Workspace
    end
    return true
end

-- ============================================================
-- ENTITY NOTIFIER
-- ============================================================
local function setupEntityNotifier()
    for _, c in ipairs(entityConnections) do c:Disconnect() end
    entityConnections = {}
    if not EntityNotifyToggle then clearHL(entityHighlights); return end

    for _, inst in ipairs(Workspace:GetDescendants()) do
        local ent = ENTITY_MAP[inst.Name]
        if ent and ent.highlight and SHOW.EntityHighlight and isEntityAllowed(inst, ent) then
            applyHL(entityHighlights, inst, ent.Color)
        end
    end

    local added = Workspace.DescendantAdded:Connect(function(inst)
        if not EntityNotifyToggle then return end
        local ent = ENTITY_MAP[inst.Name]
        if ent and isEntityAllowed(inst, ent) then
            if ent.notify then
                RedzLib:Notify({ Title = "⚠ " .. ent.Display .. " Spotted!", Text = ent.Display .. " has appeared — hide now!", Duration = 4 })
            end
            if ent.highlight and SHOW.EntityHighlight then applyHL(entityHighlights, inst, ent.Color) end
        end
    end)

    local removed = Workspace.DescendantRemoving:Connect(function(inst)
        if entityHighlights[inst] then removeHL(entityHighlights, inst) end
    end)

    table.insert(entityConnections, added)
    table.insert(entityConnections, removed)
end

-- ============================================================
-- ENTITY ESP
-- ============================================================
local function setupTestEntityESP()
    for _, c in ipairs(testEntityConns) do c:Disconnect() end
    testEntityConns = {}
    clearHL(testEntityHighlights)
    if not TestEntityESPOn then return end

    for _, inst in ipairs(Workspace:GetDescendants()) do
        local ent = ENTITY_MAP[inst.Name]
        if ent and ent.highlight and isEntityAllowed(inst, ent) then
            applyHL(testEntityHighlights, inst, ent.Color)
        end
    end

    local added = Workspace.DescendantAdded:Connect(function(inst)
        if not TestEntityESPOn then return end
        local ent = ENTITY_MAP[inst.Name]
        if ent and ent.highlight and isEntityAllowed(inst, ent) then
            applyHL(testEntityHighlights, inst, ent.Color)
        end
    end)

    local removed = Workspace.DescendantRemoving:Connect(function(inst)
        removeHL(testEntityHighlights, inst)
    end)

    table.insert(testEntityConns, added)
    table.insert(testEntityConns, removed)
end

-- ============================================================
-- SEEK GUIDE PATH
-- ============================================================
local function enableSeekGuidePath()
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") and inst.Name:match("^MinecartNode") then
            pcall(function()
                inst.Transparency = 0
                seekGuideModified[inst] = true
            end)
        end
    end
    if not seekGuideConn then
        seekGuideConn = Workspace.DescendantAdded:Connect(function(inst)
            if not SeekGuidePathOn then return end
            if inst:IsA("BasePart") and inst.Name:match("^MinecartNode") then
                pcall(function()
                    inst.Transparency = 0
                    seekGuideModified[inst] = true
                end)
            end
        end)
    end
end

local function disableSeekGuidePath()
    for part in pairs(seekGuideModified) do
        pcall(function()
            if part and part.Parent then part.Transparency = 1 end
        end)
    end
    seekGuideModified = {}
    if seekGuideConn then seekGuideConn:Disconnect(); seekGuideConn = nil end
end

-- ============================================================
-- MISC HELPERS
-- ============================================================
local LOOT_NAMES = {
    Drawer=true, DrawerLargeModel=true, Chest=true, ChestLock=true, LockedChest=true,
    ChestBox=true, ChestBoxLocked=true, GoldPile=true, RollTop=true, RolltopDesk=true,
    Cabinet=true, LiveHintBook=true,
}
local LOOT_RANGE = 15

local function tryLootNearby()
    if not HRP then return end
    local pos = HRP.Position
    for _, inst in ipairs(CurrentRooms:GetDescendants()) do
        local isLootable = LOOT_NAMES[inst.Name] or ITEM_SET[inst.Name]
        if isLootable then
            if inst.Name == "Lighter" and isInsideBookcase(inst) then continue end
            local iPos = getPos(inst)
            if iPos and (iPos - pos).Magnitude <= LOOT_RANGE then
                for _, pp in ipairs(inst:GetDescendants()) do
                    if pp:IsA("ProximityPrompt") and pp.Enabled then pcall(function() fireproximityprompt(pp) end) end
                end
            end
        end
    end
end

-- ============================================================
-- REQUEST 3 HELPER: get MinesAnchor sign text
-- ============================================================
local function getMinesSignText(inst)
    local sign = inst:FindFirstChild("Sign")
    if not sign then return "" end
    local tl = sign:FindFirstChild("TextLabel")
    if tl and tl:IsA("TextLabel") then return tl.Text or "" end
    return ""
end

-- ============================================================
-- CACHE LOOPS
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        local curRoom = LocalPlayer:GetAttribute("CurrentRoom")

        -- Items
        if not ItemESPToggle then
            cachedItems = {}; clearHL(itemHighlights)
        else
            local newCache, seen = {}, {}
            for _, inst in ipairs(CurrentRooms:GetDescendants()) do
                if ITEM_SET[inst.Name] and isInESPRange(inst) then
                    if inst.Name == "Lighter" and isInsideBookcase(inst) then continue end
                    local pos = getPos(inst)
                    if pos then
                        table.insert(newCache, { inst=inst, pos=pos, name=inst.Name })
                        seen[inst] = true
                        if SHOW.ItemHighlight then applyHL(itemHighlights, inst, CFG.ItemColor) end
                    end
                end
            end
            for inst in pairs(itemHighlights) do if not seen[inst] then removeHL(itemHighlights, inst) end end
            cachedItems = newCache
        end

        -- Wardrobes + Toolshed
        if not WardrobeESPToggle then
            cachedWardrobes = {}; clearHL(wardrobeHighlights)
        else
            local newCache, seen = {}, {}
            for _, inst in ipairs(CurrentRooms:GetDescendants()) do
                if (inst.Name == "Wardrobe" or inst.Name == "Toolshed") and isInESPRange(inst) then
                    local pos = getPos(inst)
                    if pos then
                        table.insert(newCache, { inst=inst, pos=pos, label=inst.Name })
                        seen[inst] = true
                        if SHOW.WardrobeHighlight then applyHL(wardrobeHighlights, inst, CFG.WardrobeColor) end
                    end
                end
            end
            for inst in pairs(wardrobeHighlights) do if not seen[inst] then removeHL(wardrobeHighlights, inst) end end
            cachedWardrobes = newCache
        end

        -- Levers
        if not LeverESPToggle then
            cachedLevers = {}; clearHL(leverHighlights)
        else
            local newCache, seen = {}, {}
            for _, inst in ipairs(CurrentRooms:GetDescendants()) do
                if inst.Name == "LeverForGate" and isInESPRange(inst) then
                    local pos = getPos(inst)
                    if pos then
                        table.insert(newCache, { inst=inst, pos=pos })
                        seen[inst] = true
                        if SHOW.LeverHighlight then applyHL(leverHighlights, inst, CFG.LeverColor) end
                    end
                end
            end
            for inst in pairs(leverHighlights) do if not seen[inst] then removeHL(leverHighlights, inst) end end
            cachedLevers = newCache
        end

        -- Doors
        local doorActive = DoorRangeToggle or DoorNextToggle
        if not doorActive or not curRoom then
            cachedDoors = {}; clearHL(doorHighlights)
        else
            local roomSet = {}
            if DoorRangeToggle then for i = -5, 5 do roomSet[curRoom + i] = true end end
            if DoorNextToggle  then roomSet[curRoom + 1] = true end

            local newCache, seen = {}, {}
            for roomNum in pairs(roomSet) do
                local room = CurrentRooms:FindFirstChild(tostring(roomNum))
                if room then
                    local entrance = room:FindFirstChild("RoomEntrance")
                    if entrance then
                        local pos = getPos(entrance)
                        if pos then
                            local locked = isDoorLocked(room)
                            table.insert(newCache, { inst=entrance, pos=pos, roomNum=roomNum, locked=locked })
                            seen[entrance] = true
                            if SHOW.DoorHighlight then
                                applyHL(doorHighlights, entrance, locked and CFG.LockedDoorColor or CFG.EntranceColor)
                            end
                        end
                    end
                end
            end
            for inst in pairs(doorHighlights) do if not seen[inst] then removeHL(doorHighlights, inst) end end
            cachedDoors = newCache
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)

        -- Chests + Chest_Vine
        if not TestChestESPOn then
            cachedChests = {}; clearHL(chestHighlights)
        else
            local new, seen = {}, {}
            for _, inst in ipairs(CurrentRooms:GetDescendants()) do
                local n = inst.Name
                if (n == "ChestBox" or n == "ChestBoxLocked" or n == "Chest_Vine") and isInESPRange(inst) then
                    local pos = getPos(inst)
                    if pos then
                        local col = n == "ChestBox" and Color3.fromRGB(180, 0, 255)
                               or  n == "ChestBoxLocked" and Color3.fromRGB(255, 100, 200)
                               or  Color3.fromRGB(80, 200, 80)
                        table.insert(new, { inst=inst, pos=pos, name=n, color=col })
                        seen[inst] = true
                        applyHL(chestHighlights, inst, col)
                    end
                end
            end
            for inst in pairs(chestHighlights) do if not seen[inst] then removeHL(chestHighlights, inst) end end
            cachedChests = new
        end

        -- Books
        if not TestBookESPOn then
            cachedBooks = {}; clearHL(bookHighlights)
        else
            local new, seen = {}, {}
            for _, inst in ipairs(CurrentRooms:GetDescendants()) do
                if inst.Name == "LiveHintBook" and isInESPRange(inst) then
                    local pos = getPos(inst)
                    if pos then
                        table.insert(new, { inst=inst, pos=pos }); seen[inst] = true
                        applyHL(bookHighlights, inst, Color3.fromRGB(255, 200, 50))
                    end
                end
            end
            for inst in pairs(bookHighlights) do if not seen[inst] then removeHL(bookHighlights, inst) end end
            cachedBooks = new
        end

        -- Player ESP
        if not TestPlayerESPOn then
            clearHL(playerHighlights)
        else
            local seen = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    seen[plr.Character] = true
                    applyHL(playerHighlights, plr.Character, Color3.fromRGB(255, 255, 255))
                end
            end
            for inst in pairs(playerHighlights) do if not seen[inst] then removeHL(playerHighlights, inst) end end
        end

        -- Custom ESP
        for _, entry in ipairs(CUSTOM_ESP) do
            if not entry.toggle then
                entry.cached = {}; clearHL(entry.highlights)
            else
                local new, seen = {}, {}
                for _, inst in ipairs(CurrentRooms:GetDescendants()) do
                    if inst.Name == entry.Name and isInESPRange(inst) then
                        local pos = getPos(inst)
                        if pos then
                            table.insert(new, { inst=inst, pos=pos }); seen[inst] = true
                            applyHL(entry.highlights, inst, entry.Color)
                        end
                    end
                end
                for inst in pairs(entry.highlights) do if not seen[inst] then removeHL(entry.highlights, inst) end end
                entry.cached = new
            end
        end

        -- MinesAnchor ESP (room 50 only)
        if not MinesAnchorESPOn then
            cachedMinesAnchors = {}; clearHL(minesAnchorHighlights)
        else
            local new, seen = {}, {}
            for _, inst in ipairs(CurrentRooms:GetDescendants()) do
                if inst.Name == "MinesAnchor" then
                    local roomNum = getRoomNum(inst)
                    if roomNum == 50 then
                        local pos = getPos(inst)
                        if pos then
                            local signText = getMinesSignText(inst)
                            table.insert(new, { inst=inst, pos=pos, signText=signText })
                            seen[inst] = true
                            applyHL(minesAnchorHighlights, inst, CFG.MinesColor)
                        end
                    end
                end
            end
            for inst in pairs(minesAnchorHighlights) do if not seen[inst] then removeHL(minesAnchorHighlights, inst) end end
            cachedMinesAnchors = new
        end
    end
end)

-- ============================================================
-- SERVICE LOOPS
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = Character
        if not char then continue end
        pcall(function()
            if CharJumpOn   then char:SetAttribute("CanJump",   true) end
            if CharSlideOn  then char:SetAttribute("CanSlide",  true) end
            if CharCrouchOn then char:SetAttribute("Crouching", true) end
            char:SetAttribute("SpeedBoost", CharSpeedValue)
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if LootAuraOn then pcall(tryLootNearby) end
    end
end)

-- ============================================================
-- ESP HEARTBEAT
-- ============================================================
RunService.Heartbeat:Connect(function()
    clearESP()
    if not HRP then return end
    local hrpPos  = HRP.Position
    local curRoom = LocalPlayer:GetAttribute("CurrentRoom")

    for _, d in ipairs(cachedDoors) do
        local isNext = curRoom and (d.roomNum == curRoom + 1)
        local label  = (isNext and "NEXT [" or "Entrance [") .. d.roomNum .. "]"
        if d.locked then label = "🔒 " .. label end
        espPoint(d.pos, label, d.locked and CFG.LockedDoorColor or CFG.EntranceColor, hrpPos, SHOW.DoorTracer)
    end

    if ItemESPToggle then
        for _, item in ipairs(cachedItems) do espPoint(item.pos, item.name, CFG.ItemColor, hrpPos, SHOW.ItemTracer) end
    end

    if WardrobeESPToggle then
        for _, w in ipairs(cachedWardrobes) do espPoint(w.pos, w.label or "Wardrobe", CFG.WardrobeColor, hrpPos, SHOW.WardrobeTracer) end
    end

    if LeverESPToggle then
        for _, l in ipairs(cachedLevers) do espPoint(l.pos, "LeverForGate", CFG.LeverColor, hrpPos, SHOW.LeverTracer) end
    end

    if TestEntityESPOn then
        for inst in pairs(testEntityHighlights) do
            local ent = ENTITY_MAP[inst.Name]
            if ent then
                local pos = getPos(inst)
                if pos then espPoint(pos, ent.Display, ent.Color, hrpPos, ent.tracer) end
            end
        end
    end

    if TestChestESPOn then
        for _, c in ipairs(cachedChests) do espPoint(c.pos, c.name, c.color, hrpPos, true) end
    end

    if TestBookESPOn then
        for _, b in ipairs(cachedBooks) do espPoint(b.pos, "LiveHintBook", Color3.fromRGB(255, 200, 50), hrpPos, true) end
    end

    if TestPlayerESPOn then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local ph = plr.Character:FindFirstChild("HumanoidRootPart")
                if ph then espPoint(ph.Position, plr.DisplayName, Color3.fromRGB(255, 255, 255), hrpPos, true) end
            end
        end
    end

    for _, entry in ipairs(CUSTOM_ESP) do
        if entry.toggle then
            for _, c in ipairs(entry.cached) do espPoint(c.pos, entry.Display, entry.Color, hrpPos, true) end
        end
    end

    if MinesAnchorESPOn then
        for _, m in ipairs(cachedMinesAnchors) do
            local label = "MinesAnchor"
            if m.signText and m.signText ~= "" then
                label = label .. " [" .. m.signText .. "]"
            end
            espPoint(m.pos, label, CFG.MinesColor, hrpPos, true)
        end
    end
end)

-- ============================================================
-- UI
-- ============================================================
local Window      = RedzLib:MakeWindow({ "Doors Hub", "by YourName" })
local FloatButton = Window:MakeFloatButton("=")
local MainTab     = Window:MakeTab({ "Main" })
local PlayerTab   = Window:MakeTab({ "Player" })
local ESPTab      = Window:MakeTab({ "ESP" })
local VisualTab   = Window:MakeTab({ "Visual" })
local MiscTab     = Window:MakeTab({ "Misc" })
local SettingsTab = Window:MakeTab({ "Settings" })

-- ══════════════════════════════════════════════════════════
-- MAIN TAB
-- ══════════════════════════════════════════════════════════
MainTab:AddSection("Notifications")

MainTab:AddToggle({
    Name = "Current Room Notify", Description = "Notifies your current room number periodically",
    Default = false,
    Callback = function(value)
        CurrentRoomToggle = value
        if CurrentRoomToggle then
            task.spawn(function()
                while CurrentRoomToggle do
                    local room = LocalPlayer:GetAttribute("CurrentRoom")
                    RedzLib:Notify({ Title = "Current Room", Text = "You are in room: " .. tostring(room), Duration = s })
                    task.wait(s)
                end
            end)
        end
    end
})

MainTab:AddToggle({
    Name = "Entity Notifier", Description = "Notifies + highlights entities (uses per-entity notify/highlight flags)",
    Default = true,
    Callback = function(value) EntityNotifyToggle = value; setupEntityNotifier() end
})

MainTab:AddSlider({
    Name = "Notify Interval (s)", Description = "How often Current Room Notify fires",
    Min = 1, Max = 30, Default = 3,
    Callback = function(t) s = t end
})

-- ══════════════════════════════════════════════════════════
-- PLAYER TAB
-- ══════════════════════════════════════════════════════════
PlayerTab:AddSection("Character Attributes")

PlayerTab:AddToggle({
    Name = "CanJump", Description = "Keeps CanJump attribute true",
    Default = true,
    Callback = function(value)
        CharJumpOn = value
        if not value then pcall(function() Character:SetAttribute("CanJump", false) end) end
    end
})

PlayerTab:AddToggle({
    Name = "CanSlide", Description = "Keeps CanSlide attribute true",
    Default = true,
    Callback = function(value)
        CharSlideOn = value
        if not value then pcall(function() Character:SetAttribute("CanSlide", false) end) end
    end
})

PlayerTab:AddToggle({
    Name = "Crouching", Description = "Keeps Crouching attribute true",
    Default = true,
    Callback = function(value)
        CharCrouchOn = value
        if not value then pcall(function() Character:SetAttribute("Crouching", false) end) end
    end
})

PlayerTab:AddSlider({
    Name = "SpeedBoost", Description = "Sets Character SpeedBoost attribute",
    Min = 0, Max = 150, Default = 4,
    Callback = function(value) CharSpeedValue = value end
})

PlayerTab:AddSection("Interaction")

PlayerTab:AddToggle({
    Name = "Client Glow", Description = "Attaches a bright PointLight to your character",
    Default = true,
    Callback = function(value)
        ClientGlowOn = value
        if value then
            if clientGlowLight then clientGlowLight:Destroy() end
            pcall(function()
                local hrp = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
                if hrp then
                    clientGlowLight = Instance.new("PointLight")
                    clientGlowLight.Range = 10000; clientGlowLight.Brightness = 2
                    clientGlowLight.Parent = hrp
                end
            end)
        else
            if clientGlowLight then clientGlowLight:Destroy(); clientGlowLight = nil end
        end
    end
})

PlayerTab:AddToggle({
    Name = "Instant Interact", Description = "Auto-fires proximity prompts the moment you start holding them",
    Default = true,
    Callback = function(value)
        if value then
            if not InstantInteractConn then
                InstantInteractConn = PPS.PromptButtonHoldBegan:Connect(function(prompt)
                    pcall(function() fireproximityprompt(prompt) end)
                end)
            end
        else
            if InstantInteractConn then InstantInteractConn:Disconnect(); InstantInteractConn = nil end
        end
    end
})

PlayerTab:AddSlider({
    Name = "Proximity Prompt Reach", Description = "Extends max activation distance of all proximity prompts",
    Min = 0, Max = 30, Default = 5,
    Callback = function(value)
        ProxiReachValue = value
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ProximityPrompt") then pcall(function() v.MaxActivationDistance = value end) end
        end
    end
})

PlayerTab:AddToggle({
    Name = "Auto Proximity Interact", Description = "Automatically fires nearby prompts (blacklisted names skipped)",
    Default = true,
    Callback = function(value)
        AutoProxiOn = value
        if value then
            if not autoProxiConn then
                autoProxiConn = RunService.Heartbeat:Connect(function()
                    if not AutoProxiOn or not HRP then return end
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.Enabled then
                            local blocked = false
                            local p = v.Parent
                            while p and p ~= workspace do
                                if AUTOPROXI_BLACKLIST[p.Name] then blocked = true; break end
                                p = p.Parent
                            end
                            if blocked then continue end
                            local bp = v.Parent:IsA("BasePart") and v.Parent or v.Parent:FindFirstChildWhichIsA("BasePart", true)
                            if bp then
                                if (HRP.Position - bp.Position).Magnitude <= v.MaxActivationDistance + 5 then
                                    pcall(function() fireproximityprompt(v) end)
                                end
                            end
                        end
                    end
                end)
            end
        else
            if autoProxiConn then autoProxiConn:Disconnect(); autoProxiConn = nil end
        end
    end
})

PlayerTab:AddToggle({
    Name = "Loot Aura", Description = "Auto-loots drawers, chests, gold piles and pickupables within 15 studs",
    Default = false,
    Callback = function(value) LootAuraOn = value end
})

-- ══════════════════════════════════════════════════════════
-- ESP TAB
-- ══════════════════════════════════════════════════════════
ESPTab:AddSection("Door ESP")

ESPTab:AddToggle({
    Name = "Entrance ESP (±5 rooms)", Description = "ESP room entrances — black = locked door",
    Default = true,
    Callback = function(value) DoorRangeToggle = value end
})

ESPTab:AddToggle({
    Name = "Next Room Entrance", Description = "ESP only the very next room entrance — black = locked",
    Default = false,
    Callback = function(value) DoorNextToggle = value end
})

ESPTab:AddSection("Item ESP")

ESPTab:AddToggle({
    Name = "Item ESP", Description = "ESP items in current room ±1",
    Default = true,
    Callback = function(value)
        ItemESPToggle = value
        if not value then cachedItems = {}; clearHL(itemHighlights); clearESP() end
    end
})

ESPTab:AddSection("World Objects")

ESPTab:AddToggle({
    Name = "Wardrobe ESP", Description = "ESP wardrobes and Toolsheds in current room ±1",
    Default = true,
    Callback = function(value)
        WardrobeESPToggle = value
        if not value then cachedWardrobes = {}; clearHL(wardrobeHighlights) end
    end
})

ESPTab:AddToggle({
    Name = "LeverForGate ESP", Description = "ESP gate levers in current room ±1",
    Default = true,
    Callback = function(value)
        LeverESPToggle = value
        if not value then cachedLevers = {}; clearHL(leverHighlights) end
    end
})

ESPTab:AddSection("Entity ESP")

ESPTab:AddToggle({
    Name = "Entity ESP", Description = "Highlights entities — uses per-entity highlight/tracer flags",
    Default = true,
    Callback = function(value) TestEntityESPOn = value; setupTestEntityESP() end
})

ESPTab:AddSection("Chest & Book ESP")

ESPTab:AddToggle({
    Name = "Chest ESP", Description = "purple=unlocked, pink=locked, green=Chest_Vine",
    Default = true,
    Callback = function(value)
        TestChestESPOn = value
        if not value then cachedChests = {}; clearHL(chestHighlights) end
    end
})

ESPTab:AddToggle({
    Name = "Book ESP (LiveHintBook)", Description = "Highlights hint books in yellow",
    Default = false,
    Callback = function(value)
        TestBookESPOn = value
        if not value then cachedBooks = {}; clearHL(bookHighlights) end
    end
})

ESPTab:AddSection("Player ESP")

ESPTab:AddToggle({
    Name = "Player ESP", Description = "Highlights all other players in white",
    Default = false,
    Callback = function(value)
        TestPlayerESPOn = value
        if not value then clearHL(playerHighlights) end
    end
})

ESPTab:AddSection("Custom ESP")

for _, entry in ipairs(CUSTOM_ESP) do
    local e = entry
    ESPTab:AddToggle({
        Name        = e.Display .. " ESP",
        Description = "ESP for " .. e.Name .. " in current room ±1",
        Default     = e.toggle,
        Callback    = function(value)
            e.toggle = value
            if not value then e.cached = {}; clearHL(e.highlights) end
        end
    })
end

ESPTab:AddSection("Mines ESP")

ESPTab:AddToggle({
    Name = "MinesAnchor ESP",
    Description = "ESP for MinesAnchor in room 50 — shows the sign text as label",
    Default = false,
    Callback = function(value)
        MinesAnchorESPOn = value
        if not value then cachedMinesAnchors = {}; clearHL(minesAnchorHighlights) end
    end
})

-- ══════════════════════════════════════════════════════════
-- VISUAL TAB
-- ══════════════════════════════════════════════════════════
VisualTab:AddSection("Visual")
-- ══════════════════════════════════════════════════════════
-- VISUAL TAB
-- ══════════════════════════════════════════════════════════

-- State for PathLights fix
local PathLightsBallFixOn = false
local originalPathLightsTransparency = {} -- Store original values to restore later
local pathLightsFixConn = nil -- Connection for auto-refresh loop

-- Helper function to apply the PathLights Ball visibility fix
local function applyPathLightsFix(enable)
    local pathLights = workspace:FindFirstChild("PathLights")
    if not pathLights then return end

    if enable then
        -- Store original transparency and set Ball shapes to visible
        for _, child in ipairs(pathLights:GetChildren()) do
            if child:IsA("BasePart") and child.Shape == Enum.PartType.Ball then
                if originalPathLightsTransparency[child] == nil then
                    originalPathLightsTransparency[child] = child.Transparency
                end
                child.Transparency = 0
            end
        end
    else
        -- Restore original transparency values
        for child, origTrans in pairs(originalPathLightsTransparency) do
            if child and child.Parent then
                child.Transparency = origTrans
            end
        end
        table.clear(originalPathLightsTransparency)
    end
end

-- Start/stop the auto-refresh loop
local function startPathLightsAutoFix()
    if pathLightsFixConn then return end -- Already running
    pathLightsFixConn = RunService.Heartbeat:Connect(function()
        if not PathLightsBallFixOn then return end
        local pathLights = workspace:FindFirstChild("PathLights")
        if not pathLights then return end
        
        for _, child in ipairs(pathLights:GetChildren()) do
            if child:IsA("BasePart") and child.Shape == Enum.PartType.Ball then
                if originalPathLightsTransparency[child] == nil then
                    originalPathLightsTransparency[child] = child.Transparency
                end
                if child.Transparency ~= 0 then
                    child.Transparency = 0
                end
            end
        end
    end)
end

local function stopPathLightsAutoFix()
    if pathLightsFixConn then
        pathLightsFixConn:Disconnect()
        pathLightsFixConn = nil
    end
end

VisualTab:AddSection("PathLights Visual Fix")

VisualTab:AddToggle({
    Name = "Show Ball PathLights",
    Description = "Makes all 'Ball' shaped parts in workspace.PathLights visible (Transparency = 0) • Auto-refreshes",
    Default = false,
    Callback = function(value)
        PathLightsBallFixOn = value
        if value then
            applyPathLightsFix(true)
            startPathLightsAutoFix()
        else
            stopPathLightsAutoFix()
            applyPathLightsFix(false)
        end
    end
})
-- ══════════════════════════════════════════════════════════
-- VISUAL TAB
-- ══════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════
-- VISUAL TAB
-- ══════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════
-- VISUAL TAB
-- ══════════════════════════════════════════════════════════

VisualTab:AddSection("testings")

-- Services
local PathfindingService = game:GetService("PathfindingService")

-- ============================================================
-- ★ SEEK FIX BRIDGE (Gap Detection - HORIZONTAL FIX) ★
-- ============================================================
local SeekFixBridgeOn = false
local bridgeFixParts = {}
local bridgeFixConn = nil

local function createWalkableBridgePart(cframe, size)
    local part = Instance.new("Part")
    part.Name = "SeekBridgeFix_" .. tostring(math.random(1000, 9999))
    part.Size = size or Vector3.new(6, 1, 10)
    part.Color = Color3.fromRGB(100, 100, 100)
    part.Material = Enum.Material.SmoothPlastic
    part.Transparency = 0.3
    part.Anchored = true
    part.CanCollide = true
    part.CastShadow = false
    part.CFrame = cframe
    part.Parent = workspace
    return part
end

local function cleanupBridgeFix()
    for _, part in ipairs(bridgeFixParts) do
        if part and part.Parent then 
            part:Destroy() 
        end
    end
    table.clear(bridgeFixParts)
end

local function findBridgeGapAndFix(bridgeModel)
    local bridgeParts = {}
    for _, child in ipairs(bridgeModel:GetDescendants()) do
        if child:IsA("BasePart") and child.Name ~= "Collision" and child.CanCollide then
            table.insert(bridgeParts, child)
        end
    end
    
    if #bridgeParts < 2 then 
        return     end
    
    local maxDistance = 0
    local part1, part2 = nil, nil
    
    for i = 1, #bridgeParts do
        for j = i + 1, #bridgeParts do
            local p1 = bridgeParts[i]
            local p2 = bridgeParts[j]
            local dist = (p1.Position - p2.Position).Magnitude
            
            if dist > maxDistance then
                maxDistance = dist
                part1 = p1
                part2 = p2
            end
        end
    end
    
    if not part1 or not part2 then 
        return 
    end
    
    local gapPosition = (part1.Position + part2.Position) / 2
    local direction = (part2.Position - part1.Position).Unit
    local avgHeight = (part1.Position.Y + part2.Position.Y) / 2
    local avgPartHeight = (part1.Size.Y + part2.Size.Y) / 4
    
    local horizontalCFrame = CFrame.new(
        gapPosition.X, 
        avgHeight + avgPartHeight + 0.5,
        gapPosition.Z
    ) * CFrame.Angles(0, math.atan2(direction.X, direction.Z), 0)
    
    local gapWidth = math.min(maxDistance / 2, 8)
    local fixPart = createWalkableBridgePart(horizontalCFrame, Vector3.new(gapWidth, 1, 10))
    table.insert(bridgeFixParts, fixPart)
end

local function scanAndFixSeekBridges()
    if not SeekFixBridgeOn or not CurrentRooms then 
        return 
    end
    
    local curRoomNumRaw = LocalPlayer:GetAttribute("CurrentRoom")
    local curRoomNum = nil
    
    if curRoomNumRaw then
        if type(curRoomNumRaw) == "number" then
            curRoomNum = curRoomNumRaw        elseif type(curRoomNumRaw) == "string" then
            curRoomNum = tonumber(curRoomNumRaw:match("^%d+"))
        end
    end
    
    if not curRoomNum then 
        return 
    end
    
    for i = -1, 1 do
        local room = CurrentRooms:FindFirstChild(tostring(curRoomNum + i))
        if room then
            for _, desc in ipairs(room:GetDescendants()) do
                if desc.Name == "CollapseBridge" and desc:IsA("Model") then
                    local alreadyFixed = false
                    local bridgePivot = desc:GetPivot()
                    
                    for _, fixedPart in ipairs(bridgeFixParts) do
                        if fixedPart and fixedPart.Parent and 
                           (fixedPart.Position - bridgePivot.Position).Magnitude < 15 then
                            alreadyFixed = true
                            break
                        end
                    end
                    
                    if not alreadyFixed then
                        findBridgeGapAndFix(desc)
                    end
                end
            end
        end
    end
end

-- ============================================================
-- ★ SEEK GUIDING (FIXED - Always Moves to Exit) ★
-- ============================================================
local SeekPathGuidingOn = false
local guideBall = nil
local currentWaypoints = {}
local currentWaypointIndex = 1
local guideBallConn = nil
local lastRoomNum = nil
local lastExitPos = nil

local BALL_HEIGHT = 3
local SMOOTH_FACTOR = 0.1
local BALL_SPEED = 18 -- studs per second

local function createGuideBall(position)    local ball = Instance.new("Part")
    ball.Name = "SeekGuideBall"
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(1.5, 1.5, 1.5)
    ball.Color = Color3.fromRGB(0, 200, 100)
    ball.Material = Enum.Material.Plastic
    ball.Transparency = 0.3
    ball.Anchored = true
    ball.CanCollide = false
    ball.CastShadow = false
    ball.CFrame = CFrame.new(position)
    ball.Parent = workspace
    
    return ball
end

local function cleanupGuideBall()
    if guideBall and guideBall.Parent then
        guideBall:Destroy()
    end
    guideBall = nil
    currentWaypoints = {}
    currentWaypointIndex = 1
end

local function getExitPosition(roomNum)
    if not CurrentRooms then 
        return nil 
    end
    
    local room = CurrentRooms:FindFirstChild(tostring(roomNum))
    if not room then 
        return nil 
    end
    
    local roomExit = room:FindFirstChild("RoomExit")
    if not roomExit then 
        return nil 
    end
    
    local exitPos = nil
    if roomExit:IsA("BasePart") then
        exitPos = roomExit.Position
    elseif roomExit:IsA("Model") and roomExit.PrimaryPart then
        exitPos = roomExit.PrimaryPart.Position
    else
        local bp = roomExit:FindFirstChildWhichIsA("BasePart", true)
        if bp then 
            exitPos = bp.Position 
        end    end
    
    return exitPos
end

local function computePathToExit()
    if not HRP then 
        return false 
    end
    
    local curRoomNumRaw = LocalPlayer:GetAttribute("CurrentRoom")
    local curRoomNum = nil
    
    if curRoomNumRaw then
        if type(curRoomNumRaw) == "number" then
            curRoomNum = curRoomNumRaw
        elseif type(curRoomNumRaw) == "string" then
            curRoomNum = tonumber(curRoomNumRaw:match("^%d+"))
        end
    end
    
    if not curRoomNum then 
        return false 
    end
    
    local exitPos = getExitPosition(curRoomNum)
    if not exitPos then 
        return false 
    end
    
    lastExitPos = exitPos
    
    local playerPos = HRP.Position
    local startPos = playerPos + Vector3.new(0, -2, 0)
    
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentMaxSlope = 50
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(startPos, exitPos)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        if waypoints and #waypoints > 1 then
            currentWaypoints = waypoints            currentWaypointIndex = 2 -- Start from 2 (1 is usually player position)
            return true
        end
    end
    
    -- Fallback: Create simple waypoints straight to exit
    currentWaypoints = {
        {Position = playerPos},
        {Position = exitPos}
    }
    currentWaypointIndex = 2
    return true
end

local function updateGuideBallPosition(dt)
    if not guideBall or not HRP then 
        return 
    end
    
    -- ✅ FIX: Always try to follow waypoints to exit
    if #currentWaypoints > 0 and currentWaypointIndex <= #currentWaypoints then
        local targetWaypoint = currentWaypoints[currentWaypointIndex]
        local targetPos = targetWaypoint.Position + Vector3.new(0, BALL_HEIGHT, 0)
        
        -- Raycast to keep ball visible (not in walls/floor)
        local rayDown = workspace:Raycast(targetPos, Vector3.new(0, -15, 0))
        if rayDown then
            targetPos = rayDown.Position + Vector3.new(0, BALL_HEIGHT, 0)
        end
        
        -- ✅ FIX: Move ball toward target at constant speed (not just lerp)
        local currentPos = guideBall.Position
        local direction = (targetPos - currentPos).Unit
        local distanceToTarget = (targetPos - currentPos).Magnitude
        
        -- Move at BALL_SPEED studs per second
        local moveDistance = BALL_SPEED * dt
        local newPos
        
        if distanceToTarget <= moveDistance then
            -- Reached this waypoint
            newPos = targetPos
            currentWaypointIndex = currentWaypointIndex + 1
            
            -- ✅ Check if reached the FINAL waypoint (goal)
            if currentWaypointIndex > #currentWaypoints then
                -- Ball reached the exit! Recreate after delay
                task.delay(1, function()
                    if SeekPathGuidingOn then
                        cleanupGuideBall()                        computePathToExit()
                        if guideBall then
                            local playerPos = HRP.Position
                            guideBall.CFrame = CFrame.new(playerPos + Vector3.new(0, BALL_HEIGHT, 0))
                        else
                            guideBall = createGuideBall(HRP.Position + Vector3.new(0, BALL_HEIGHT, 0))
                        end
                    end
                end)
            end
        else
            -- Still moving toward waypoint
            newPos = currentPos + (direction * moveDistance)
        end
        
        guideBall.CFrame = CFrame.new(newPos)
    else
        -- ✅ No waypoints - compute them immediately
        computePathToExit()
    end
end

local lastUpdateTime = 0

-- ============================================================
-- ★ TOGGLE CONTROLS ★
-- ============================================================

VisualTab:AddToggle({
    Name = "Seek Fix Bridge",
    Description = "Detects GAP and fills with HORIZONTAL walkable part",
    Default = false,
    Callback = function(value)
        SeekFixBridgeOn = value
        if value then
            scanAndFixSeekBridges()
            if not bridgeFixConn then
                bridgeFixConn = RunService.Heartbeat:Connect(function()
                    if SeekFixBridgeOn then
                        scanAndFixSeekBridges()
                    end
                end)
            end
        else
            if bridgeFixConn then 
                bridgeFixConn:Disconnect()
                bridgeFixConn = nil 
            end
            cleanupBridgeFix()
        end    end
})

VisualTab:AddToggle({
    Name = "Seek Guiding",
    Description = "Ball ALWAYS moves to exit at constant speed",
    Default = false,
    Callback = function(value)
        SeekPathGuidingOn = value
        lastRoomNum = nil
        
        if value then
            cleanupGuideBall()
            computePathToExit()
            
            -- Create ball at player position
            if HRP then
                guideBall = createGuideBall(HRP.Position + Vector3.new(0, BALL_HEIGHT, 0))
            end
            
            if not guideBallConn then
                guideBallConn = RunService.Heartbeat:Connect(function()
                    if not SeekPathGuidingOn then 
                        return 
                    end
                    
                    local curRoomNumRaw = LocalPlayer:GetAttribute("CurrentRoom")
                    local curRoomNum = nil
                    
                    if curRoomNumRaw then
                        if type(curRoomNumRaw) == "number" then
                            curRoomNum = curRoomNumRaw
                        elseif type(curRoomNumRaw) == "string" then
                            curRoomNum = tonumber(curRoomNumRaw:match("^%d+"))
                        end
                    end
                    
                    if not curRoomNum then 
                        return 
                    end
                    
                    -- Room changed - recreate everything
                    if curRoomNum ~= lastRoomNum then
                        lastRoomNum = curRoomNum
                        cleanupGuideBall()
                        computePathToExit()
                        if HRP then
                            guideBall = createGuideBall(HRP.Position + Vector3.new(0, BALL_HEIGHT, 0))
                        end
                        return                    end
                    
                    -- ✅ FIX: Use delta time for smooth, consistent movement
                    local now = tick()
                    local dt = now - lastUpdateTime
                    lastUpdateTime = now
                    
                    -- Cap dt to prevent huge jumps if lag
                    dt = math.min(dt, 0.1)
                    
                    updateGuideBallPosition(dt)
                end)
            end
        else
            if guideBallConn then 
                guideBallConn:Disconnect()
                guideBallConn = nil 
            end
            cleanupGuideBall()
        end
    end
})
-- ══════════════════════════════════════════════════════════
-- MISC TAB
-- ══════════════════════════════════════════════════════════
MiscTab:AddSection("Misc")

MiscTab:AddToggle({
    Name = "Notify Entities via Message", Description = "Shows a notification when a dangerous entity appears",
    Default = false,
    Callback = function(value) EntityNotifyToggle = value; setupEntityNotifier() end
})

MiscTab:AddToggle({
    Name = "Seek Guide Path",
    Description = "Reveals RunnerNodes & PathLights in rooms 40-99 (Runner path nodes)",
    Default = false,
    Callback = function(value)
        SeekGuidePathOn = value
        if value then enableSeekGuidePath() else disableSeekGuidePath() end
    end
})

-- ══════════════════════════════════════════════════════════
-- SETTINGS TAB
-- ══════════════════════════════════════════════════════════
SettingsTab:AddSection("Door ESP Settings")

SettingsTab:AddToggle({
    Name = "Door Highlight", Default = false,
    Callback = function(value)
        SHOW.DoorHighlight = value
        if not value then clearHL(doorHighlights)
        else for _, d in ipairs(cachedDoors) do applyHL(doorHighlights, d.inst, d.locked and CFG.LockedDoorColor or CFG.EntranceColor) end end
    end
})
SettingsTab:AddToggle({ Name = "Door Tracer", Default = true, Callback = function(v) SHOW.DoorTracer = v end })

SettingsTab:AddSection("Item ESP Settings")
SettingsTab:AddToggle({
    Name = "Item Highlight", Default = true,
    Callback = function(value)
        SHOW.ItemHighlight = value
        if not value then clearHL(itemHighlights)
        else for _, item in ipairs(cachedItems) do applyHL(itemHighlights, item.inst, CFG.ItemColor) end end
    end
})
SettingsTab:AddToggle({ Name = "Item Tracer", Default = true, Callback = function(v) SHOW.ItemTracer = v end })

SettingsTab:AddSection("Entity Settings")
SettingsTab:AddToggle({
    Name = "Entity Highlight", Default = true,
    Callback = function(value)
        SHOW.EntityHighlight = value
        if not value then clearHL(entityHighlights)
        else
            for _, inst in ipairs(Workspace:GetDescendants()) do
                local ent = ENTITY_MAP[inst.Name]
                if ent and ent.highlight and isEntityAllowed(inst, ent) then
                    applyHL(entityHighlights, inst, ent.Color)
                end
            end
        end
    end
})
SettingsTab:AddToggle({ Name = "Entity Tracer (Global Override)", Default = false, Callback = function(v) SHOW.EntityTracer = v end })

SettingsTab:AddSection("Wardrobe Settings")
SettingsTab:AddToggle({
    Name = "Wardrobe Highlight", Default = true,
    Callback = function(value)
        SHOW.WardrobeHighlight = value
        if not value then clearHL(wardrobeHighlights)
        else for _, w in ipairs(cachedWardrobes) do applyHL(wardrobeHighlights, w.inst, CFG.WardrobeColor) end end
    end
})
SettingsTab:AddToggle({ Name = "Wardrobe Tracer", Default = true, Callback = function(v) SHOW.WardrobeTracer = v end })

SettingsTab:AddSection("LeverForGate Settings")
SettingsTab:AddToggle({
    Name = "Lever Highlight", Default = true,
    Callback = function(value)
        SHOW.LeverHighlight = value
        if not value then clearHL(leverHighlights)
        else for _, l in ipairs(cachedLevers) do applyHL(leverHighlights, l.inst, CFG.LeverColor) end end
    end
})
SettingsTab:AddToggle({ Name = "Lever Tracer", Default = true, Callback = function(v) SHOW.LeverTracer = v end })

-- ============================================================
-- ★ BOOT BLOCK
-- ============================================================
task.defer(function()

    -- Entity Notifier (Default = true)
    setupEntityNotifier()

    -- Entity ESP (Default = true)
    setupTestEntityESP()

    -- Client Glow (Default = true)
    pcall(function()
        local hrp = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
        if hrp then
            clientGlowLight = Instance.new("PointLight")
            clientGlowLight.Range = 10000; clientGlowLight.Brightness = 2
            clientGlowLight.Parent = hrp
        end
    end)

    -- Instant Interact (Default = true)
    if not InstantInteractConn then
        InstantInteractConn = PPS.PromptButtonHoldBegan:Connect(function(prompt)
            pcall(function() fireproximityprompt(prompt) end)
        end)
    end

    -- Auto Proximity Interact (Default = true)
    if not autoProxiConn then
        autoProxiConn = RunService.Heartbeat:Connect(function()
            if not AutoProxiOn or not HRP then return end
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Enabled then
                    local blocked = false
                    local p = v.Parent
                    while p and p ~= workspace do
                        if AUTOPROXI_BLACKLIST[p.Name] then blocked = true; break end
                        p = p.Parent
                    end
                    if blocked then continue end
                    local bp = v.Parent:IsA("BasePart") and v.Parent or v.Parent:FindFirstChildWhichIsA("BasePart", true)
                    if bp and (HRP.Position - bp.Position).Magnitude <= v.MaxActivationDistance + 5 then
                        pcall(function() fireproximityprompt(v) end)
                    end
                end
            end
        end)
    end

    -- Proximity Prompt Reach (Default slider = 5)
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            pcall(function() v.MaxActivationDistance = ProxiReachValue end)
        end
    end

end)
