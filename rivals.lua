local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(350, 200)
frame.Position = UDim2.new(0.5, -175, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Rivals Cheat - VoidSpam"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 60)
toggleBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
toggleBtn.Text = "VoidSpam: OFF"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = frame

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 8)
corner2.Parent = toggleBtn

local enabled = false
local connection = nil

local function startSpam()
    if connection then return end
    connection = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function()
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool:Activate()
                    end
                end
            end)
        end
    end)
end

local function stopSpam()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        toggleBtn.Text = "VoidSpam: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        startSpam()
    else
        toggleBtn.Text = "VoidSpam: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
        stopSpam()
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.L then
        enabled = not enabled
        if enabled then
            toggleBtn.Text = "VoidSpam: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
            startSpam()
        else
            toggleBtn.Text = "VoidSpam: OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
            stopSpam()
        end
    end
end)

print("Simple VoidSpam Loaded - Press L")
