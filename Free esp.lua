if getgenv().PlayerESP_Loaded then return end -- prevent double-loading
getgenv().PlayerESP_Loaded = true

getgenv().PlayerESP = {
    Enabled       = false,
    TeamCheck     = false,
    ShowNames     = true,
    ShowDistance  = true,
    ShowHealth    = true,
    Color         = Color3.fromRGB(0, 170, 255),
    Thickness     = 1.5,
    AutoThickness = true,
    MaxDistance   = 2000,
}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPContainer = {}

local function NewLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.Color = getgenv().PlayerESP.Color
    l.Thickness = getgenv().PlayerESP.Thickness
    l.Transparency = 1
    return l
end

local function NewText()
    local t = Drawing.new("Text")
    t.Visible = false
    t.Color = Color3.fromRGB(255, 255, 255)
    t.Size = 13
    t.Center = true
    t.Outline = true
    t.OutlineColor = Color3.fromRGB(0, 0, 0)
    return t
end

local function NewHealthBar()
    local bg = Drawing.new("Line")
    bg.Visible = false
    bg.Color = Color3.fromRGB(0, 0, 0)
    bg.Thickness = 4
    bg.Transparency = 1

    local fg = Drawing.new("Line")
    fg.Visible = false
    fg.Color = Color3.fromRGB(0, 255, 0)
    fg.Thickness = 2
    fg.Transparency = 1

    return bg, fg
end

local function HideBox(esp)
    if not esp then return end
    for _, line in pairs(esp.Box) do line.Visible = false end
    esp.NameLabel.Visible = false
    esp.DistLabel.Visible  = false
    esp.HealthBG.Visible   = false
    esp.HealthFG.Visible   = false
end

local function RemoveESP(player)
    local esp = ESPContainer[player]
    if not esp then return end
    for _, line in pairs(esp.Box) do pcall(function() line:Remove() end) end
    pcall(function() esp.NameLabel:Remove() end)
    pcall(function() esp.DistLabel:Remove()  end)
    pcall(function() esp.HealthBG:Remove()   end)
    pcall(function() esp.HealthFG:Remove()   end)
    ESPContainer[player] = nil
end

local function CreateESP(player)
    if player == LocalPlayer then return end

    local box = {
        Top    = NewLine(),
        Right  = NewLine(),
        Bottom = NewLine(),
        Left   = NewLine(),
    }

    local nameLabel        = NewText()
    local distLabel        = NewText()
    local healthBG, healthFG = NewHealthBar()

    ESPContainer[player] = {
        Box        = box,
        NameLabel  = nameLabel,
        DistLabel  = distLabel,
        HealthBG   = healthBG,
        HealthFG   = healthFG,
    }

    RunService.RenderStepped:Connect(function()
        local esp = ESPContainer[player]
        if not esp then return end

        local cfg = getgenv().PlayerESP

        if not cfg.Enabled then HideBox(esp) return end

        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not hrp or not hum or hum.Health <= 0 then HideBox(esp) return end

        if cfg.TeamCheck and player.Team == LocalPlayer.Team then HideBox(esp) return end

        local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not localHRP then HideBox(esp) return end

        local distance = (localHRP.Position - hrp.Position).Magnitude
        if distance > cfg.MaxDistance then HideBox(esp) return end

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then HideBox(esp) return end

        local scale = 1 / (hrp.Position - Camera.CFrame.Position).Magnitude * 100
        local sx, sy = 35 * scale, 55 * scale

        local TL = Vector2.new(pos.X - sx, pos.Y - sy)
        local TR = Vector2.new(pos.X + sx, pos.Y - sy)
        local BL = Vector2.new(pos.X - sx, pos.Y + sy)
        local BR = Vector2.new(pos.X + sx, pos.Y + sy)

        box.Top.From    = TL; box.Top.To    = TR
        box.Right.From  = TR; box.Right.To  = BR
        box.Bottom.From = BR; box.Bottom.To = BL
        box.Left.From   = BL; box.Left.To   = TL

        local thickness = cfg.AutoThickness
            and math.clamp(1 / distance * 120, 1, 4)
            or cfg.Thickness

        for _, line in pairs(box) do
            line.Visible   = true
            line.Color     = cfg.Color
            line.Thickness = thickness
        end

        nameLabel.Visible = cfg.ShowNames
        if cfg.ShowNames then
            nameLabel.Text     = player.DisplayName
            nameLabel.Position = Vector2.new(pos.X, TL.Y - 15)
            nameLabel.Color    = cfg.Color
        end

        distLabel.Visible = cfg.ShowDistance
        if cfg.ShowDistance then
            distLabel.Text     = string.format("[%dm]", math.floor(distance))
            distLabel.Position = Vector2.new(pos.X, BR.Y + 2)
            distLabel.Color    = Color3.fromRGB(200, 200, 200)
        end

        local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        healthBG.Visible = cfg.ShowHealth
        healthFG.Visible = cfg.ShowHealth

        if cfg.ShowHealth then
            local barX = TL.X - 5
            healthBG.From = Vector2.new(barX, TL.Y)
            healthBG.To   = Vector2.new(barX, BL.Y)
            healthFG.From = Vector2.new(barX, BL.Y)
            healthFG.To   = Vector2.new(barX, BL.Y - (BL.Y - TL.Y) * hpRatio)
            healthFG.Color = Color3.fromRGB(
                math.floor(255 * (1 - hpRatio)),
                math.floor(255 * hpRatio),
                0
            )
        end
    end)

    player.CharacterRemoving:Connect(function()
        HideBox(ESPContainer[player])
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not ESPContainer[player] then CreateESP(player) end
    end)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(RemoveESP)
