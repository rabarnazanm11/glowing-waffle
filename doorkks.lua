-- ============================================================
-- DOORS HUB (Optimized & Modular)
-- ============================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS               = game:GetService("UserInputService")
local PPS               = game:GetService("ProximityPromptService")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")

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
-- ★ GLOBAL SETTINGS & CONFIG ★
-- ============================================================
local ESP_SETTINGS = {
    Mode = "Text + highlight", -- "Text only", "highlight only", "Text + highlight"
    ShowTracers = false
}

local ESP_TOGGLES = {
    Doors = true,
    Entities = true,
    Players = false,
}

local CFG = {
    EntranceColor   = Color3.fromRGB(187, 187, 14),
    LockedDoorColor = Color3.fromRGB(0, 0, 0),
    TracerThick     = 1,
    TracerAlpha     = 0.5,
    LabelSize       = 14,
    FontFace        = Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
}

-- ============================================================
-- ★ ENTITIES & ITEMS DICTIONARY ★
-- ============================================================

local ENTITIES = {
    { Name = "RushMoving",      Display = "Rush",          Color = Color3.fromRGB(255, 80,  0)   },
    { Name = "Eyes",            Display = "Eyes",          Color = Color3.fromRGB(255, 30,  30), workspaceOnly = true },
    { Name = "AmbushMoving",    Display = "Ambush",        Color = Color3.fromRGB(160, 0,   255) },
    { Name = "BackdoorRush",    Display = "Backdoor Rush", Color = Color3.fromRGB(255, 120, 0)   },
    { Name = "Dread",           Display = "Dread",         Color = Color3.fromRGB(180, 0,   0)   },
    { Name = "GiggleCeiling",   Display = "Giggle",        Color = Color3.fromRGB(255, 150, 200) },
    { Name = "SallyMoving",     Display = "Sally",         Color = Color3.fromRGB(180, 255, 80)  },
    { Name = "GloombatSwarm",   Display = "GloombatSwarm", Color = Color3.fromRGB(80,  0,   120) },
    { Name = "A60",             Display = "A-60",          Color = Color3.fromRGB(50,  100, 255) },
    { Name = "A120",            Display = "A-120",         Color = Color3.fromRGB(0,   220, 255) },
    { Name = "Screech",         Display = "Screech",       Color = Color3.fromRGB(200, 200, 255) },
    { Name = "BackdoorLookman", Display = "Lookman",       Color = Color3.fromRGB(160, 100, 50)  },
    { Name = "MonumentEntity",  Display = "Monument",      Color = Color3.fromRGB(150, 150, 150) },
    { Name = "JeffTheKiller",   Display = "Jeff",          Color = Color3.fromRGB(180, 0,   30)  },
    { Name = "FigureRig",       Display = "Figure",        Color = Color3.fromRGB(80,  80,  80)  },
    { Name = "Snare",           Display = "Snare",         Color = Color3.fromRGB(80,  80,  80)  },
    { Name = "GloomPile",       Display = "GloomPile",     Color = Color3.fromRGB(80,  80,  80)  },
    { Name = "Gloombat",        Display = "Gloombat",      Color = Color3.fromRGB(80,  80,  80)  },
    { Name = "Grumbo",          Display = "Grumbo",        Color = Color3.fromRGB(80,  80,  80)  },
    { Name = "SeekHand",        Display = "SeekHand",      Color = Color3.fromRGB(80,  80,  80)  },
    { Name = "SeekSludge",      Display = "SeekSludge",    Color = Color3.fromRGB(80,  80,  80)  },
    { Name = "SeekWorm",        Display = "SeekWorm",      Color = Color3.fromRGB(80,  80,  80)  },
}

local ENTITY_MAP = {}
for _, e in ipairs(ENTITIES) do ENTITY_MAP[e.Name] = e end

-- Easily add any interactable here. The UI parses this automatically to create toggles.
local ESP_OBJECTS = {
    -- Items
    KeyObtain             = { Name = "Key",          Color = Color3.fromRGB(80,  255, 120) },
    SkeletonKey           = { Name = "Skeleton Key", Color = Color3.fromRGB(150, 100, 255) },
    Lockpick              = { Name = "Lockpick",     Color = Color3.fromRGB(200, 200, 200) },
    Lighter               = { Name = "Lighter",      Color = Color3.fromRGB(150, 150, 150) },
    Flashlight            = { Name = "Flashlight",   Color = Color3.fromRGB(255, 255, 100) },
    Battery               = { Name = "Battery",      Color = Color3.fromRGB(100, 150, 255) },
    BandagePack           = { Name = "Bandage Pack", Color = Color3.fromRGB(100, 255, 100) },
    Vitamins              = { Name = "Vitamins",     Color = Color3.fromRGB(255, 100, 100) },
    Crucifix              = { Name = "Crucifix",     Color = Color3.fromRGB(255, 150, 255) },
    CrucifixOnTheWall     = { Name = "Crucifix",     Color = Color3.fromRGB(255, 150, 255) },
    Smoothie              = { Name = "Smoothie",     Color = Color3.fromRGB(255, 150, 50)  },
    Candle                = { Name = "Candle",       Color = Color3.fromRGB(255, 255, 200) },
    Compass               = { Name = "Compass",      Color = Color3.fromRGB(150, 150, 200) },
    GoldPile              = { Name = "Gold",         Color = Color3.fromRGB(255, 255, 0)   },
    FuseObtain            = { Name = "Fuse",         Color = Color3.fromRGB(255, 50,  50)  },
    LiveBreakerPolePickup = { Name = "Breaker Pole", Color = Color3.fromRGB(255, 50,  50)  },
    KeyIron               = { Name = "Iron Key",     Color = Color3.fromRGB(150, 150, 150) },
    Donut                 = { Name = "Donut",        Color = Color3.fromRGB(255, 100, 200) },

    -- Containers & Interactables
    Drawer                = { Name = "Drawer",       Color = Color3.fromRGB(130, 90,  40)  },
    ChestBox              = { Name = "Chest",        Color = Color3.fromRGB(180, 0,   255) },
    ChestBoxLocked        = { Name = "Locked Chest", Color = Color3.fromRGB(255, 100, 200) },
    Chest_Vine            = { Name = "Vine Chest",   Color = Color3.fromRGB(80,  200, 80)  },
    Wardrobe              = { Name = "Wardrobe",     Color = Color3.fromRGB(200, 140, 60)  },
    Toolshed              = { Name = "Toolshed",     Color = Color3.fromRGB(200, 140, 60)  },
    Locker_Large          = { Name = "Large Locker", Color = Color3.fromRGB(80,  120, 200) },
    LeverForGate          = { Name = "Lever",        Color = Color3.fromRGB(255, 220, 0)   },
    LiveHintBook          = { Name = "Hint Book",    Color = Color3.fromRGB(255, 200, 50)  },
    MinesGenerator        = { Name = "Generator",    Color = Color3.fromRGB(255, 200, 50)  },
    Cellar                = { Name = "Cellar",       Color = Color3.fromRGB(120, 70,  30)  },
    Shears                = { Name = "Shears",       Color = Color3.fromRGB(200, 200, 200) },
    CircularVent          = { Name = "Circular Vent",Color = Color3.fromRGB(80,  120, 200) },
    Dumpster              = { Name = "Dumpster",     Color = Color3.fromRGB(80,  120, 200) },
    WaterPump             = { Name = "Water Pump",   Color = Color3.fromRGB(80,  120, 200) },
    MinesAnchor           = { Name = "Mines Anchor", Color = Color3.fromRGB(255, 60,  60)  },
}

local AUTOPROXI_BLACKLIST = {
    Wardrobe = true, WardrobeInner = true, Double_Bed = true, Painting_Big = true,
    Painting_VeryBig = true, Toolshed = true, Bed = true, Toilet = true,
    WallSink = true, Painting_Tall = true, Fireplace = true, Painting_Small = true,
    Typewriter = true, ReviveRift = true, Locker_Large = true, LadderModel = true,
    CircularVent = true, Dumpster = true, Ladder = true, FireBarrel = true,
}

-- ============================================================
-- STATE VARIABLES
-- ============================================================
local s                   = 3
local CurrentRoomToggle   = false
local EntityNotifyToggle  = true

local CharJumpOn          = true
local CharSlideOn         = true
local CharSpeedValue      = 4

local ClientGlowOn        = true
local clientGlowLight     = nil
local InstantInteractConn = nil
local ProxiReachValue     = 5
local AutoProxiOn         = true
local autoProxiConn       = nil
local LootAuraOn          = false

local FullbrightOn        = false
local origLightBright     = Lighting.Brightness
local origAmbient         = Lighting.Ambient
local origFogEnd          = Lighting.FogEnd
local origFogStart        = Lighting.FogStart

local SeekGuidePathOn     = false
local seekGuideConn       = nil
local seekGuideModified   = {} 
local entityConnections   = {}

-- ============================================================
-- HELPERS
-- ============================================================
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

local function W2S(pos)
    local v, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), onScreen, v.Z
end

local function isInsideBookcase(inst)
    local p = inst.Parent
    while p and p ~= CurrentRooms and p ~= Workspace do
        if p.Name == "Bookcase" then return true end
        p = p.Parent
    end
    return false
end

local function getRoomNum(inst)
    local p = inst
    while p and p.Parent do
        if p.Parent == CurrentRooms then return tonumber(p.Name) end
        p = p.Parent
    end
    return nil
end

local function isEntityAllowed(inst, ent)
    if ent.workspaceOnly then return inst.Parent == Workspace end
    return true
end

local function getMinesSignText(inst)
    local sign = inst:FindFirstChild("Sign")
    if not sign then return "" end
    local tl = sign:FindFirstChild("TextLabel")
    if tl and tl:IsA("TextLabel") then return tl.Text or "" end
    return ""
end

-- ============================================================
-- ESP RENDER ENGINE (Billboard + Highlight + Tracer)
-- ============================================================
local espFolder = Instance.new("Folder")
espFolder.Name = "DoorsHubESP"
pcall(function() espFolder.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui end)

local activeTracked    = {} -- [inst] = { Text, Color }
local activeBillboards = {}
local activeHighlights = {}
local tracerDrawings   = {}

local function clearTracers()
    for _, t in ipairs(tracerDrawings) do pcall(function() t:Remove() end) end
    tracerDrawings = {}
end

local function makeTracer(screenPos, color)
    local t = Drawing.new("Line")
    t.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    t.To = screenPos; t.Color = color
    t.Thickness = CFG.TracerThick; t.Transparency = CFG.TracerAlpha; t.Visible = true
    table.insert(tracerDrawings, t)
end

-- Update loop for gathering what should be tracked
task.spawn(function()
    while true do
        task.wait(0.25)
        local curRoom = LocalPlayer:GetAttribute("CurrentRoom") or 0
        local newTracked = {}

        -- Request 3: Strict Performance bounds (curRoom-1 to curRoom+2)
        for i = curRoom - 1, curRoom + 2 do
            local room = CurrentRooms:FindFirstChild(tostring(i))
            if room then
                -- Doors
                if ESP_TOGGLES["Doors"] then
                    local doorModel = room:FindFirstChild("Door")
                    if doorModel then
                        local realDoor = doorModel:FindFirstChild("Door") -- Physical Door
                        if realDoor then
                            local locked = doorModel:FindFirstChild("Lock") ~= nil
                            newTracked[realDoor] = {
                                Text = locked and "🔒 Door ["..i.."]" or "Door ["..i.."]",
                                Color = locked and CFG.LockedDoorColor or CFG.EntranceColor
                            }
                        end
                    end
                end

                -- Items & Interactables
                for _, inst in ipairs(room:GetDescendants()) do
                    local objDef = ESP_OBJECTS[inst.Name]
                    if objDef and ESP_TOGGLES[objDef.Name] then
                        if inst.Name == "Lighter" and isInsideBookcase(inst) then continue end
                        
                        local text = objDef.Name
                        if inst.Name == "MinesAnchor" then
                            local signText = getMinesSignText(inst)
                            if signText ~= "" then text = text .. " ["..signText.."]" end
                        end
                        
                        newTracked[inst] = { Text = text, Color = objDef.Color }
                    end
                end
            end
        end

        -- Entities & Players bypass the room limitations
        if ESP_TOGGLES["Entities"] then
            for _, inst in ipairs(Workspace:GetDescendants()) do
                local ent = ENTITY_MAP[inst.Name]
                if ent and isEntityAllowed(inst, ent) then
                    newTracked[inst] = { Text = ent.Display, Color = ent.Color }
                end
            end
        end

        if ESP_TOGGLES["Players"] then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        newTracked[root] = { Text = plr.DisplayName, Color = Color3.fromRGB(255, 255, 255) }
                    end
                end
            end
        end

        activeTracked = newTracked
    end
end)

-- Rendering Heartbeat
RunService.RenderStepped:Connect(function()
    local hrpPos = HRP and HRP.Position or Vector3.zero
    local mode = ESP_SETTINGS.Mode

    for inst, data in pairs(activeTracked) do
        -- Render Text
        if mode == "Text only" or mode == "Text + highlight" then
            local bb = activeBillboards[inst]
            if not bb or bb.Parent == nil then
                bb = Instance.new("BillboardGui")
                bb.Name = "HubESP_BB"
                bb.AlwaysOnTop = true
                bb.Size = UDim2.new(0, 200, 0, 30)
                bb.Adornee = inst:IsA("BasePart") and inst or (inst:IsA("Model") and inst.PrimaryPart or inst)
                
                local tl = Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.TextColor3 = data.Color
                tl.TextStrokeTransparency = 0
                tl.TextSize = CFG.LabelSize
                tl.FontFace = CFG.FontFace
                
                bb.Parent = espFolder
                activeBillboards[inst] = bb
            end

            local pos = getPos(inst)
            if pos then
                local dist = math.floor((pos - hrpPos).Magnitude + 0.5)
                local tl = bb:FindFirstChildOfClass("TextLabel")
                if tl then 
                    tl.Text = data.Text .. " | " .. dist .. "M" 
                    tl.TextColor3 = data.Color
                end
            end
        else
            if activeBillboards[inst] then activeBillboards[inst]:Destroy(); activeBillboards[inst] = nil end
        end

        -- Render Highlight
        if mode == "highlight only" or mode == "Text + highlight" then
            local hl = activeHighlights[inst]
            if not hl or hl.Parent == nil then
                hl = Instance.new("Highlight")
                hl.FillColor = data.Color
                hl.OutlineColor = data.Color
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = inst
                activeHighlights[inst] = hl
            end
        else
            if activeHighlights[inst] then activeHighlights[inst]:Destroy(); activeHighlights[inst] = nil end
        end
    end

    -- Cleanup unused visual elements
    for inst, bb in pairs(activeBillboards) do
        if not activeTracked[inst] then bb:Destroy(); activeBillboards[inst] = nil end
    end
    for inst, hl in pairs(activeHighlights) do
        if not activeTracked[inst] then hl:Destroy(); activeHighlights[inst] = nil end
    end

    -- Render Tracers
    clearTracers()
    if ESP_SETTINGS.ShowTracers then
        for inst, data in pairs(activeTracked) do
            local pos = getPos(inst)
            if pos then
                local sPos, onScreen, depth = W2S(pos)
                if onScreen and depth > 0 then
                    makeTracer(sPos, data.Color)
                end
            end
        end
    end
end)

-- ============================================================
-- LOOT AURA & UTILITIES
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
        if LOOT_NAMES[inst.Name] or (ESP_OBJECTS[inst.Name] and ESP_OBJECTS[inst.Name].Name == "Key") then
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

task.spawn(function()
    while true do
        task.wait(0.1)
        local char = Character
        if not char then continue end
        pcall(function()
            if CharJumpOn  then char:SetAttribute("CanJump",  true) end
            if CharSlideOn then char:SetAttribute("CanSlide", true) end
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
-- SEEK GUIDE PATH
-- ============================================================
local function enableSeekGuidePath()
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") and inst.Name:match("^MinecartNode") then
            pcall(function() inst.Transparency = 0; seekGuideModified[inst] = true end)
        end
    end
    if not seekGuideConn then
        seekGuideConn = Workspace.DescendantAdded:Connect(function(inst)
            if not SeekGuidePathOn then return end
            if inst:IsA("BasePart") and inst.Name:match("^MinecartNode") then
                pcall(function() inst.Transparency = 0; seekGuideModified[inst] = true end)
            end
        end)
    end
end

local function disableSeekGuidePath()
    for part in pairs(seekGuideModified) do
        pcall(function() if part and part.Parent then part.Transparency = 1 end end)
    end
    seekGuideModified = {}
    if seekGuideConn then seekGuideConn:Disconnect(); seekGuideConn = nil end
end

-- ============================================================
-- ENTITY NOTIFIER
-- ============================================================
local function setupEntityNotifier()
    for _, c in ipairs(entityConnections) do c:Disconnect() end
    entityConnections = {}
    if not EntityNotifyToggle then return end

    local added = Workspace.DescendantAdded:Connect(function(inst)
        if not EntityNotifyToggle then return end
        local ent = ENTITY_MAP[inst.Name]
        if ent and isEntityAllowed(inst, ent) then
            RedzLib:Notify({ Title = "⚠ " .. ent.Display .. " Spotted!", Text = ent.Display .. " has appeared — hide now!", Duration = 4 })
        end
    end)
    table.insert(entityConnections, added)
end

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
    Name = "Entity Notifier", Description = "Notifies when entities spawn",
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
    Name = "Auto Proximity Interact", Description = "Automatically fires nearby prompts",
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
-- ESP TAB (DYNAMIC UI)
-- ══════════════════════════════════════════════════════════
ESPTab:AddSection("Global ESP Settings")

ESPTab:AddDropdown({
    Name = "ESP Mode",
    Options = {"Text only", "highlight only", "Text + highlight"},
    Default = "Text + highlight",
    Callback = function(value) ESP_SETTINGS.Mode = value end
})

ESPTab:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Callback = function(value) ESP_SETTINGS.ShowTracers = value end
})

ESPTab:AddSection("Entities & Players")

ESPTab:AddToggle({
    Name = "Entities ESP",
    Default = true,
    Callback = function(v) ESP_TOGGLES["Entities"] = v end
})

ESPTab:AddToggle({
    Name = "Players ESP",
    Default = false,
    Callback = function(v) ESP_TOGGLES["Players"] = v end
})

ESPTab:AddSection("General Structure")

ESPTab:AddToggle({
    Name = "Doors ESP",
    Default = true,
    Callback = function(v) ESP_TOGGLES["Doors"] = v end
})

ESPTab:AddSection("Items & Objects ESP")

-- Extracts all unique Display Names from your Object Dictionary to generate clean literal toggles
local uniqueToggles = {}
for _, data in pairs(ESP_OBJECTS) do
    if not table.find(uniqueToggles, data.Name) then
        table.insert(uniqueToggles, data.Name)
    end
end
table.sort(uniqueToggles)

for _, toggleName in ipairs(uniqueToggles) do
    ESPTab:AddToggle({
        Name = toggleName .. " ESP",
        Default = false,
        Callback = function(v) ESP_TOGGLES[toggleName] = v end
    })
end

-- ══════════════════════════════════════════════════════════
-- VISUAL TAB
-- ══════════════════════════════════════════════════════════
VisualTab:AddSection("Visual")

VisualTab:AddToggle({
    Name = "Fullbright", Description = "Maximises ambient lighting and removes fog",
    Default = false,
    Callback = function(value)
        FullbrightOn = value
        pcall(function()
            if value then
                Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
                Lighting.FogEnd = 100000; Lighting.FogStart = 99999
            else
                Lighting.Brightness = origLightBright; Lighting.Ambient = origAmbient
                Lighting.FogEnd = origFogEnd; Lighting.FogStart = origFogStart
            end
        end)
    end
})

-- ══════════════════════════════════════════════════════════
-- MISC TAB
-- ══════════════════════════════════════════════════════════
MiscTab:AddSection("Misc")

MiscTab:AddToggle({
    Name = "Seek Guide Path",
    Description = "Reveals RunnerNodes & PathLights in rooms 40-99 (Runner path nodes)",
    Default = false,
    Callback = function(value)
        SeekGuidePathOn = value
        if value then enableSeekGuidePath() else disableSeekGuidePath() end
    end
})

-- ============================================================
-- ★ BOOT BLOCK
-- ============================================================
task.defer(function()
    setupEntityNotifier()

    pcall(function()
        local hrp = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
        if hrp then
            clientGlowLight = Instance.new("PointLight")
            clientGlowLight.Range = 10000; clientGlowLight.Brightness = 2
            clientGlowLight.Parent = hrp
        end
    end)

    if not InstantInteractConn then
        InstantInteractConn = PPS.PromptButtonHoldBegan:Connect(function(prompt)
            pcall(function() fireproximityprompt(prompt) end)
        end)
    end

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

    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            pcall(function() v.MaxActivationDistance = ProxiReachValue end)
        end
    end
end)
