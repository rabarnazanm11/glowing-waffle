local _version = "1.6.64-fix"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "My Super Hub",
    Icon = "door-open",
    Author = "by .ftgs and .ftgs",
    Folder = "MySuperHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    BackgroundImageTransparency = 0.42,
    Background = "rbxassetid://1234",
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("clicked to the 'user icon'")
        end,
    },
})

local Tab = Window:Tab({
    Title = "My Tab",
    Desc = "Tab description",
    Icon = "bird",
})

-- Shared remote (both features use the same one)
local onHireAmbient = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("TrainerService")
    :WaitForChild("RE")
    :WaitForChild("onHireAmbient")

-- ─────────────────────────────────────────
-- TOGGLE 1: Auto Hire (spam loop)
-- ─────────────────────────────────────────
local autoHireEnabled = false
local autoHireThread = nil

local function startAutoHire()
    autoHireThread = task.spawn(function()
        while autoHireEnabled do
            onHireAmbient:FireServer(
                "65f4e0ef-c1f0-45d1-a216-9a38ded6bf88",
                "20",
                "Cozy Capybara"
            )
            task.wait()
        end
    end)
end

local function stopAutoHire()
    autoHireEnabled = false
    if autoHireThread then
        task.cancel(autoHireThread)
        autoHireThread = nil
    end
end

local AutoHireToggle

AutoHireToggle = Tab:Toggle({
    Title = "Get Free Trainer ",
    Desc = "You May Get Banned , You need to Have enough Wins too ",
    Icon = "zap",
    Value = false,
    Type = "Toggle",
    Callback = function(state)
        if state then
            Window:Dialog({
                Icon = "triangle-alert",
                Title = "Ban Risk Warning",
                IconThemed = true,
                Content = "This feature may get you banned.\nI am not responsible — it's your choice.",
                Buttons = {
                    {
                        Title = "I Understand, Enable",
                        Icon = "check",
                        Variant = "Destructive",
                        Callback = function()
                            autoHireEnabled = true
                            startAutoHire()
                        end,
                    },
                    {
                        Title = "Cancel",
                        Icon = "x",
                        Variant = "Secondary",
                        Callback = function()
                            AutoHireToggle:Set(false)
                        end,
                    },
                },
            })
        else
            stopAutoHire()
        end
    end,
})

-- ─────────────────────────────────────────
-- TOGGLE 2: Ambient Trainer Watcher
-- ─────────────────────────────────────────
local folderAmbient = workspace.AmbientTrainers
local watcherConnection = nil
local watcherEnabled = false

local function hireAmbient(v)
    local AmbientId   = v:GetAttribute("AmbientId")
    local TrainerName = v:GetAttribute("TrainerName")
    local Zone        = v:GetAttribute("Zone")

    onHireAmbient:FireServer(
        tostring(AmbientId),
        tostring(Zone),
        tostring(TrainerName)
    )
end

local function startWatcher()
    -- Fire for all existing trainers with 1s delay between each
    task.spawn(function()
        for _, v in pairs(folderAmbient:GetChildren()) do
            if not watcherEnabled then return end
            hireAmbient(v)
            task.wait(4)
        end
    end)

    -- Listen for new ones
    watcherConnection = folderAmbient.ChildAdded:Connect(function(v)
        if not watcherEnabled then return end
        task.wait(4)
        hireAmbient(v)
    end)
end

local function stopWatcher()
    watcherEnabled = false
    if watcherConnection then
        watcherConnection:Disconnect()
        watcherConnection = nil
    end
end

local AmbientWatcherToggle

AmbientWatcherToggle = Tab:Toggle({
    Title = " Auto Ambient Trainer ",
    Desc = "Hires trainers from Your current Wolrd your in as they appear",
    Icon = "radar",
    Value = false,
    Type = "Toggle",
    Callback = function(state)
        if state then
            Window:Dialog({
                Icon = "triangle-alert",
                Title = "Ban Risk Warning",
                IconThemed = true,
                Content = "This feature may get you banned.\nI am not responsible — it's your choice.",
                Buttons = {
                    {
                        Title = "I Understand, Enable",
                        Icon = "check",
                        Variant = "Destructive",
                        Callback = function()
                            watcherEnabled = true
                            startWatcher()
                        end,
                    },
                    {
                        Title = "Cancel",
                        Icon = "x",
                        Variant = "Secondary",
                        Callback = function()
                            AmbientWatcherToggle:Set(false)
                        end,
                    },
                },
            })
        else
            stopWatcher()
        end
    end,
})
