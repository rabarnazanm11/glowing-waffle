-- Updated Sorted 
local _version = "1.6.64-fix"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "ARM WRESTLE SIMULATOR ",
    Icon = "house",
    Author = "Enjoy",
    Folder = "Aws",
    
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    
    Transparent = true,
    Theme = "Midnight",
    
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    BackgroundImageTransparency = 0.42,
    Background = "rbxassetid://1234",
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("clicked to the 'user icon'")
        end,
    },
})
local TrainerTable ={
  ---------------------------------------------
 --                 Wolrd 1                 --
 -----------------------------------------------

  ["Noob (Wolrd 1 - 2)"] = "Noob",
  ["Bacon Hair (Wolrd 1 - 2)"] = "Bacon Hair",
  ["Nerd (Wolrd 1 - 3)"] = "Nerd",
  ["Homeless Man (Wolrd 1 - 3)"] = "Homeless Man",
  ["Delivery Guy (Wolrd 1 - 4 )"] = "Delivery Guy",
  ["Police (Wolrd 1 - 6)"] = "Police",
  
  ---------------------------------------------
 --                 Wolrd 2                 --
 -----------------------------------------------

  ["Zombie (Wolrd 2 - 7)"] = "Zombie",
  
    ---------------------------------------------
 --                 Wolrd 3                 --
 -----------------------------------------------

  ["Firefighter (Wolrd 3 - 6)"] = "Firefighter",
  
    ---------------------------------------------
 --                 Wolrd 4                 --
 -----------------------------------------------

  ["Astronaut (Wolrd 4 - 7)"] = "Astronaut",
  
    ---------------------------------------------
 --                 Wolrd 5                 --
 -----------------------------------------------

  ["Mad Scientist (Wolrd 5 - 8)"] = "Mad Scientist",
  
    ---------------------------------------------
 --                 Wolrd 6                 --
 -----------------------------------------------

  ["Pirate (Wolrd 6 - 9)"] = "Pirate",
  ["Cowboy (Wolrd 6 - 10)"] = "Cowboy",
  
 ---------------------------------------------
 --                 Wolrd 7                 --
 -----------------------------------------------

  ["Hacker (Wolrd 7 - 11)"] = "Hacker",
  
 ---------------------------------------------
 --                 Wolrd 8                 --
 -----------------------------------------------

  ["Rich Man (Wolrd 8 - 11)"] = "Rich Man",
  
 ---------------------------------------------
 --                 Wolrd 9                 --
 -----------------------------------------------

  ["Wizard (Wolrd 9 - 12 )"] = "Wizard",
  ["Vampire (Wolrd 9 - 13)"] = "Vampire",
  
  ---------------------------------------------
 --                 Wolrd 10                 --
 -----------------------------------------------

  ["Dominus Lord (Wolrd 10 - 14)"] = "Dominus Lord",
  
    ---------------------------------------------
 --                 Wolrd 11                 --
 -----------------------------------------------

  ["Sensei (Wolrd 11 - 15)"] = "Sensei",
  
    ---------------------------------------------
 --                 Wolrd 12                 --
 -----------------------------------------------

  ["Rockstar (Wolrd 12 - 16)"] = "Rockstar",
    ["Princess (Wolrd 12 - 15)"] = "Princess",

    ---------------------------------------------
 --                 Wolrd 13                 --
 -----------------------------------------------
 
   ["Pirate Penguin (Wolrd 13 - 17)"] = "Pirate Penguin",

 
    ---------------------------------------------
 --                 Wolrd 14                 --
 -----------------------------------------------
 
   ["Soccer Player (Wolrd 14 - 18)"] = "Soccer Player",

 
    ---------------------------------------------
 --                 Wolrd 15                 --
 -----------------------------------------------

  ["Mr Robot (Wolrd 15 - 19)"] = "Mr Robot",
  
    ---------------------------------------------
 --                 Wolrd 16                 --
 -----------------------------------------------

  ["Builderman (Wolrd 16 - 20)"] = "Builderman",
    ["Evil Ninja (Wolrd 16 - 21)"] = "Evil Ninja",

    ---------------------------------------------
 --                 Wolrd 17                 --
 -----------------------------------------------

  ["Cozy Capybara (Wolrd 17 - 22)"] = "Cozy Capybara",
  
    ---------------------------------------------
 --                 Wolrd 18                 --
 -----------------------------------------------
  
  ["King Doge (Wolrd 18 - 24)"] = "King Doge",
  
      ---------------------------------------------
 --                 Wolrd 19                 --
 -----------------------------------------------
  
  ["Overseer (Wolrd 19 - 24)"] = "Overseer",
  
  
  

  
  
  
  --["Dont_Select (Wolrd Shhs - shshh)"] = "hshshjsjs",

  
}
table.sort(TrainerTable)
local Tab = Window:Tab({
    Title = "Trainers",
    Desc = "Use it On your Own risk", -- optional
    Icon = "octagon-minus", -- lucide icon or "rbxassetid://" or URL. optional
    IconColor = Color3.fromRGB(136,8,8), -- custom icon color. optional
    IconShape = "Square", -- "Square" or "Circle". optional
    IconThemed = true, -- use theme colors. optional
    Locked = false, -- disable tab interaction. optional
    ShowTabTitle = true, -- show title inside tab. optional
    Border = true, -- add border around tab. optional
    CustomEmptyPage = { -- custom empty page when no elements are added to the tab. optional
		Icon = "lucide:smile", -- icon for empty page. optional
		Title = "This is a cool empty tab", -- title for empty page. optional
		Desc = "I like it. its so great tab with cool 'custom empty page'", -- description for empty page. optional
	},
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
local function TableKeys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

local autoHireEnabled = false
local autoHireThread = nil

local Trainers = TableKeys(TrainerTable)
table.sort(Trainers) -- ← sort the array of keys alphabetically
local Selected = Trainers[1]


local zoneinput = ""
local function startAutoHire()
    autoHireThread = task.spawn(function()
        while autoHireEnabled do
            if zoneinput ~= "" then
                onHireAmbient:FireServer(
                    "65f4e0ef-c1f0-45d1-a216-9a38ded6bf88",
                    zoneinput,
                    TrainerTable[Selected] -- the value from your table (trainer name string)
                )
            end
            task.wait()
        end
    end)
end
--[[local function startAutoHire()
    autoHireThread = task.spawn(function()
        while autoHireEnabled do
            onHireAmbient:FireServer(
                "65f4e0ef-c1f0-45d1-a216-9a38ded6bf88",
                zoneinput,
                Selected
            )
            task.wait()
        end
    end)
end
]]
local function stopAutoHire()
    autoHireEnabled = false
    if autoHireThread then
        task.cancel(autoHireThread)
        autoHireThread = nil
    end
end



  local MyInput = Tab:Input({
    Title = "Zone",
    Desc = "Enter The zone of the Trainer You Choose From Dropdown",
    Type = "Input",              -- "Input" (single-line) or "Textarea" (multi-line)
    Placeholder = "Type here...", -- Hint text when empty
    Value = "",                   -- pre-filled text (always a string)
    InputIcon = "user",          -- Lucide icon name inside field (false/nil for none)
    ClearTextOnFocus = false,    -- Auto-clear text when user clicks in
    Width = 150,                 -- Field width in px (only applies to Type = "Input")
    Locked = false,          
    LockedTitle = "Locked",      
    Callback = function(text)    -- Fires on FocusLost (press Enter or click outside)
      zoneinput = text
        print("Submitted:", text)
    end,
})

local Dropdown = Tab:Dropdown({
    Title = "Select...",
    Desc = "Select which Trainer To get For Free",
    Locked = false,
    LockedTitle = "Locked",
    Values =  Trainers,
    Value =  Trainers[1],
    Multi = false,
    MenuWidth = 180,
    AllowNone = false,
    SearchBarEnabled = true, -- or false
    Callback = function(option) 
      Selected = option
        -- option is a table: { "Category A", "Category B" }
        print("Categories selected: " .. game:GetService("HttpService"):JSONEncode(option)) 
    end
})




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
