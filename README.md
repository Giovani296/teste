-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ===== VARIÁVEIS =====
getgenv().aimbotEnabled = false
local aiming = false
local FOV = 120

-- ===== INPUT (BOTÃO DIREITO) =====
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- ===== AIMBOT (HEAD) =====
local function getClosestHead()
    local closest, shortest = nil, math.huge
    local center = Camera.ViewportSize / 2

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, visible = Camera:WorldToViewportPoint(head.Position)
            if visible then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < shortest and dist < FOV then
                    shortest = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if getgenv().aimbotEnabled and aiming then
        local head = getClosestHead()
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)

-- ===== ESP AUTOMÁTICO (HITBOX REAL) =====
local ESP = {}

local function createESP(player)
    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(170, 0, 255)
    box.Thickness = 1
    box.Filled = false
    box.Visible = false

    local name = Drawing.new("Text")
    name.Color = Color3.fromRGB(255,255,255)
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Visible = false

    ESP[player] = {Box = box, Name = name}
end

local function removeESP(player)
    if ESP[player] then
        ESP[player].Box:Remove()
        ESP[player].Name:Remove()
        ESP[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    createESP(p)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESP) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChild("Humanoid")

        if hrp and head and hum and hum.Health > 0 then
            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local height = math.abs(headPos.Y - hrpPos.Y) * 2
                local width = height / 2

                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(
                    hrpPos.X - width / 2,
                    hrpPos.Y - height / 2
                )
                esp.Box.Visible = true

                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 15)
                esp.Name.Visible = true
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
        end
    end
end)

-- ===== GUI (CENTRALIZADA + ARRASTÁVEL) =====
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 110)

-- 🔥 CENTRALIZA NA TELA
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)

-- 🔥 CONTINUA ARRASTÁVEL
frame.Active = true
frame.Draggable = true

frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "GIOVANI GOSTOSO"
title.TextColor3 = Color3.fromRGB(170,0,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local on = Instance.new("TextButton", frame)
on.Size = UDim2.new(0.9,0,0,30)
on.Position = UDim2.new(0.05,0,0,40)
on.Text = "Ativar Aimbot"
on.BackgroundColor3 = Color3.fromRGB(70,170,70)
on.TextColor3 = Color3.new(1,1,1)
on.Font = Enum.Font.GothamBold
on.TextSize = 13
Instance.new("UICorner", on)

local off = Instance.new("TextButton", frame)
off.Size = UDim2.new(0.9,0,0,30)
off.Position = UDim2.new(0.05,0,0,75)
off.Text = "Desativar Aimbot"
off.BackgroundColor3 = Color3.fromRGB(170,70,70)
off.TextColor3 = Color3.new(1,1,1)
off.Font = Enum.Font.GothamBold
off.TextSize = 13
Instance.new("UICorner", off)

on.MouseButton1Click:Connect(function()
    getgenv().aimbotEnabled = true
end)

off.MouseButton1Click:Connect(function()
    getgenv().aimbotEnabled = false
end)
