-- Load core first- Modern
loadstring(game:HttpGet("https://raw.githubusercontent.com/rabarnazanm11/glowing-waffle/refs/heads/main/Modern%20Player%20esp.lua"))()

-- Rayfield Library 
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
-- Window 
local Window = Rayfield:CreateWindow({
   Name = "Player ESP ",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Esp",
   LoadingSubtitle = "by Bora",
   ShowText = "Rayfield", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes
})
-- Then wire up Rayfield toggles
local MainTab = Window:CreateTab("Main", "rewind")
local Section = MainTab:CreateSection("Player ESP") -- your existing MainTab variable

MainTab:CreateToggle({
    Name = " Enable Player ESP",
    CurrentValue = false,
    Flag = "ESP_Enabled",
    Callback = function(v) getgenv().PlayerESP.Enabled = v end
})

MainTab:CreateToggle({
    Name = " Team Check",
    CurrentValue = false,
    Flag = "ESP_TeamCheck",
    Callback = function(v) getgenv().PlayerESP.TeamCheck = v end
})

MainTab:CreateToggle({
    Name = " Show Names",
    CurrentValue = true,
    Flag = "ESP_Names",
    Callback = function(v) getgenv().PlayerESP.ShowNames = v end
})

MainTab:CreateToggle({
    Name = " Show Distance",
    CurrentValue = true,
    Flag = "ESP_Distance",
    Callback = function(v) getgenv().PlayerESP.ShowDistance = v end
})

MainTab:CreateToggle({
    Name = " Show Health Bar",
    CurrentValue = true,
    Flag = "ESP_Health",
    Callback = function(v) getgenv().PlayerESP.ShowHealth = v end
})

MainTab:CreateToggle({
    Name = " Auto Thickness",
    CurrentValue = true,
    Flag = "ESP_AutoThickness",
    Callback = function(v) getgenv().PlayerESP.AutoThickness = v end
})

MainTab:CreateToggle({
    Name = "ShowTracers",
    CurrentValue = true,
    Flag = "ESP_AutoThickness",
    Callback = function(v) getgenv().PlayerESP.ShowTracers = v end
})

MainTab:CreateToggle({
    Name = "FullBox",
    CurrentValue = true,
    Flag = "ESP_AutoThickness",
    Callback = function(v) getgenv().PlayerESP.FullBox = v end
})
-- Toggle on/off from anywhere in your script or console:
getgenv().PlayerESP.Enabled = true
getgenv().PlayerESP.Color   = Color3.fromRGB(0, 200, 255)
