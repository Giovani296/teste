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

-- ===== INPUT =====
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

-- ===== AIMBOT =====
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
