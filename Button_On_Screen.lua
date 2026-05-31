local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "CircleButton"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

Button.Parent = ScreenGui
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Position = UDim2.new(0, 20, 0.5, 0) 
Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- change to your SchemeColor
Button.BorderSizePixel = 0
Button.Image = "rbxassetid://15307540148"
Button.AutoButtonColor = false
Button.Active = true
Button.Draggable = true

UICorner.CornerRadius = UDim.new(1, 0) -- makes it perfectly circular
UICorner.Parent = Button

-- Hover effect
Button.MouseEnter:Connect(function()
    TweenService:Create(Button, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(46, 209, 178),
        Size = UDim2.new(0, 55, 0, 55)
    }):Play()
end)

Button.MouseLeave:Connect(function()
    TweenService:Create(Button, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(26, 189, 158),
        Size = UDim2.new(0, 50, 0, 50)
    }):Play()
end)

-- Click action (plug in whatever you want here)
Button.MouseButton1Click:Connect(function()
    TweenService:Create(Button, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 44, 0, 44)
    }):Play()
    task.wait(0.08)
    TweenService:Create(Button, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 50, 0, 50)
    }):Play()

    -- your callback here, e.g.:
    Library:ToggleUI()
end)
