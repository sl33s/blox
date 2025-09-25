--[[
    Script: Kuak Hub v1.0
    Author: kuak saudi
    Game: Arsenal
    Description: Aimbot + ESP script with Chroma Key UI.
]]

print("Kuak Hub (Arsenal) v1.0: Loading...")

-- =================================================================
--                        Services & Variables
-- =================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotConfig = {
    Enabled = true,
    TargetPart = "Head",
    FOV = 150,
    Aiming = false
}

local ESPConfig = {
    Enabled = true,
    Boxes = true,
    Names = true,
    Tracers = false
}

-- =================================================================
--                        Chroma Key GUI
-- =================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KuakHubArsenalGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Chroma Green
mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.01, 0, 0.5, -100)
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Kuak Hub - Arsenal"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16

-- Simple function to create a toggle button
local function createToggle(parent, text, flag, yPos)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Position = UDim2.new(0.05, 0, 0, yPos)
    button.Size = UDim2.new(0.9, 0, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    button.Font = Enum.Font.SourceSans
    button.Text = text .. ": ON"
    button.TextColor3 = Color3.fromRGB(0, 255, 0)
    button.TextSize = 14
    
    button.MouseButton1Click:Connect(function()
        flag.Value = not flag.Value
        button.Text = text .. ": " .. (flag.Value and "ON" or "OFF")
        button.TextColor3 = flag.Value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

-- Create flags and buttons
local aimbotFlag = {Value = true}
local espFlag = {Value = true}
local boxesFlag = {Value = true}

createToggle(mainFrame, "Aimbot", aimbotFlag, 30)
createToggle(mainFrame, "ESP", espFlag, 60)
createToggle(mainFrame, "Boxes", boxesFlag, 90)

AimbotConfig.Enabled = aimbotFlag
ESPConfig.Enabled = espFlag
ESPConfig.Boxes = boxesFlag

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Radius = AimbotConfig.FOV
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService:BindToRenderStep("FOV_Update", Enum.RenderPriority.Input.Value, function()
    fovCircle.Radius = AimbotConfig.FOV
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

print("Kuak Hub: GUI Loaded.")

-- =================================================================
--                        Core Logic
-- =================================================================

-- Aimbot
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotConfig.Aiming = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotConfig.Aiming = false
    end
end)

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = AimbotConfig.FOV + 1

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and LocalPlayer.Team ~= player.Team then
            local head = player.Character:FindFirstChild(AimbotConfig.TargetPart)
            if head then
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ESP
local function createESPDrawings(player)
    local drawings = {}
    local head = player.Character:FindFirstChild("Head")
    if not head then return end

    -- Box
    if ESPConfig.Boxes.Value then
        local box = Drawing.new("Quad")
        box.Visible = false
        table.insert(drawings, box)
        
        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPos = player.Character.HumanoidRootPart.Position
                local headPos = rootPos + Vector3.new(0, 2, 0)
                local footPos = rootPos - Vector3.new(0, 3, 0)
                
                local headScreen, onScreen1 = Camera:WorldToScreenPoint(headPos)
                local footScreen, onScreen2 = Camera:WorldToScreenPoint(footPos)

                if onScreen1 and onScreen2 then
                    local height = math.abs(headScreen.Y - footScreen.Y)
                    local width = height / 2
                    box.PointA = Vector2.new(headScreen.X - width / 2, headScreen.Y)
                    box.PointB = Vector2.new(headScreen.X + width / 2, headScreen.Y)
                    box.PointC = Vector2.new(headScreen.X + width / 2, footScreen.Y)
                    box.PointD = Vector2.new(headScreen.X - width / 2, footScreen.Y)
                    box.Color = LocalPlayer.TeamColor == player.TeamColor and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    box.Thickness = 1
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end)
    end
    return drawings
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESPDrawings(player)
    end
end
Players.PlayerAdded:Connect(createESPDrawings)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if AimbotConfig.Enabled.Value and AimbotConfig.Aiming then
        local target = getClosestPlayer()
        if target then
            local targetPos = target.Character[AimbotConfig.TargetPart].Position
            local newCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.2) -- Lerp for smoothness
        end
    end
end)

print("Kuak Hub (Arsenal) v1.0: Fully loaded and operational.")
