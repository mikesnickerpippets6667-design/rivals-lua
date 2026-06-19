local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")

local player = Players.LocalPlayer

local THEME = {
    SunTop = Color3.fromRGB(255, 170, 60),
    SunBottom = Color3.fromRGB(255, 120, 40),
    SeaTop = Color3.fromRGB(60, 170, 220),
    SeaBottom = Color3.fromRGB(30, 110, 180),
    Sand = Color3.fromRGB(250, 240, 215),
    Accent = Color3.fromRGB(255, 140, 50),
    AccentHover = Color3.fromRGB(255, 165, 80),
    AccentDown = Color3.fromRGB(225, 110, 30),
    Field = Color3.fromRGB(235, 248, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Danger = Color3.fromRGB(225, 80, 80),
    Good = Color3.fromRGB(90, 200, 120),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Collision
local MY_GROUP = "MyPlayerGroup"
local OTHERS_GROUP = "OthersGroup"
pcall(function()
    PhysicsService:CreateCollisionGroup(MY_GROUP)
    PhysicsService:CreateCollisionGroup(OTHERS_GROUP)
end)
PhysicsService:CollisionGroupSetCollidable(MY_GROUP, OTHERS_GROUP, false)

local function setupCollisionFiltering()
    local character = player.Character
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(part, MY_GROUP)
        end
    end
end

player.CharacterAdded:Connect(function() task.wait(0.5) setupCollisionFiltering() end)
if player.Character then task.spawn(setupCollisionFiltering) end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function wireButtonTweens(btn, base, hover, down)
    local info = TweenInfo.new(0.12, Enum.EasingStyle.Quad)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, info, {BackgroundColor3 = hover}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, info, {BackgroundColor3 = base}):Play() end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(btn, info, {BackgroundColor3 = down}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(btn, info, {BackgroundColor3 = hover}):Play() end)
end

local function makeDraggable(frame, dragHandle)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(400, 380)
main.Position = UDim2.new(0.5, -200, 0.5, -190)
main.BackgroundColor3 = THEME.Field
main.Parent = screenGui
addCorner(main, 12)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = THEME.SunTop
titleBar.Parent = main
addCorner(titleBar, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Rivals Cheat"
title.TextColor3 = THEME.Text
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30,30)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundTransparency = 1
close.Text = "✕"
close.TextColor3 = THEME.Danger
close.TextSize = 20
close.Parent = titleBar
close.MouseButton1Click:Connect(function() screenGui:Destroy() end)

makeDraggable(main, titleBar)

-- VoidSpam
local voidSpamEnabled = false
local voidSpamConn = nil

local function startVoidSpam()
    if voidSpamConn then return end
    voidSpamConn = RunService.Heartbeat:Connect(function()
        if not voidSpamEnabled then return end
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        pcall(function()
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    tool:Activate()
                end
            end
            if math.random() < 0.3 then
                root.CFrame = root.CFrame * CFrame.new(0,0,-0.4) * CFrame.Angles(0, math.rad(math.random(-15,15)), 0)
            end
        end)
    end)
end

local function stopVoidSpam()
    if voidSpamConn then voidSpamConn:Disconnect() voidSpamConn = nil end
end

local voidBtn = Instance.new("TextButton")
voidBtn.Size = UDim2.new(1,-20,0,50)
voidBtn.Position = UDim2.new(0,10,0,60)
voidBtn.BackgroundColor3 = THEME.SeaTop
voidBtn.Text = "VoidSpam: OFF\nL | luaaa"
voidBtn.TextColor3 = THEME.Text
voidBtn.Font = Enum.Font.GothamBold
voidBtn.TextSize = 16
voidBtn.Parent = main
addCorner(voidBtn,8)
wireButtonTweens(voidBtn, THEME.SeaTop, THEME.AccentHover, THEME.AccentDown)

voidBtn.MouseButton1Click:Connect(function()
    voidSpamEnabled = not voidSpamEnabled
    if voidSpamEnabled then
        voidBtn.Text = "VoidSpam: ON\nL | luaaa"
        voidBtn.BackgroundColor3 = THEME.Good
        startVoidSpam()
    else
        voidBtn.Text = "VoidSpam: OFF\nL | luaaa"
        voidBtn.BackgroundColor3 = THEME.SeaTop
        stopVoidSpam()
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.L then
        voidSpamEnabled = not voidSpamEnabled
        if voidSpamEnabled then
            voidBtn.Text = "VoidSpam: ON\nL | luaaa"
            voidBtn.BackgroundColor3 = THEME.Good
            startVoidSpam()
        else
            voidBtn.Text = "VoidSpam: OFF\nL | luaaa"
            voidBtn.BackgroundColor3 = THEME.SeaTop
            stopVoidSpam()
        end
    elseif i.KeyCode == Enum.KeyCode.RightShift then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

player.Chatted:Connect(function(msg)
    if msg:lower() == "luaaa" then
        voidSpamEnabled = not voidSpamEnabled
        -- same toggle logic as above
        if voidSpamEnabled then
            voidBtn.Text = "VoidSpam: ON\nL | luaaa"
            voidBtn.BackgroundColor3 = THEME.Good
            startVoidSpam()
        else
            voidBtn.Text = "VoidSpam: OFF\nL | luaaa"
            voidBtn.BackgroundColor3 = THEME.SeaTop
            stopVoidSpam()
        end
    end
end)

print("Rivals Cheat Loaded - Press RightShift")
