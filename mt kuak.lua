--[[
    Script: Kuak Hub v1.1 (Improved)
    Author: kuak saudi
    Game: Arsenal
    Description: Aimbot + ESP script with Chroma Key UI and major fixes.
]]

print("Kuak Hub (Arsenal) v1.1: Loading...")

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
    Aiming = false,
    Smoothness = 0.3 -- Increased smoothness for a stronger pull
}

local ESPConfig = {
    Enabled = true,
    Boxes = true
}

-- =================================================================
--                        Chroma Key GUI with Image Support
-- =================================================================
-- Clean up old GUI
if CoreGui:FindFirstChild("KuakHubArsenalGui") then
    CoreGui.KuakHubArsenalGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KuakHubArsenalGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Chroma Green (Fallback)
mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.01, 0, 0.5, -100)
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Draggable = true

-- [[ IMAGE SUPPORT ]] --
-- To use an image, replace "rbxassetid://YOUR_IMAGE_ID" with your image ID.
-- To go back to Chroma Green, just delete the line below.
local backgroundImage = Instance.new("ImageLabel", mainFrame)
backgroundImage.Image = "rbxassetid://YOUR_IMAGE_ID" -- << PUT YOUR IMAGE ID HERE
backgroundImage.Size = UDim2.new(1, 0, 1, 0)
backgroundImage.BackgroundTransparency = 1

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.BackgroundTransparency = 0.2
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Kuak Hub - Arsenal"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16

-- Create flags and buttons (same as before)
-- ... (Code for buttons is unchanged for brevity)

-- FOV Circle (unchanged)
-- ...

print("Kuak Hub: GUI Loaded.")

-- =================================================================
--                        ESP - REWRITTEN
-- =================================================================
local function DrawBox(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = player.Character.HumanoidRootPart
    local head = player.Character:FindFirstChild("Head")
    if not head then return end

    -- Calculate box position and size
    local top, onScreenTop = Camera:WorldToScreenPoint(rootPart.Position + Vector3.new(0, 2.5, 0))
    local bottom, onScreenBottom = Camera:WorldToScreenPoint(rootPart.Position - Vector3.new(0, 3, 0))

    if onScreenTop and onScreenBottom then
        local height = math.abs(top.Y - bottom.Y)
        local width = height * 0.6
        local x = top.X - (width / 2)
        local y = top.Y

        -- Create 4 lines to form a box
        local line1 = Drawing.new("Line") -- Top
        line1.From = Vector2.new(x, y)
        line1.To = Vector2.new(x + width, y)
        
        local line2 = Drawing.new("Line") -- Bottom
        line2.From = Vector2.new(x, y + height)
        line2.To = Vector2.new(x + width, y + height)

        local line3 = Drawing.new("Line") -- Left
        line3.From = Vector2.new(x, y)
        line3.To = Vector2.new(x, y + height)

        local line4 = Drawing.new("Line") -- Right
        line4.From = Vector2.new(x + width, y)
        line4.To = Vector2.new(x + width, y + height)

        local lines = {line1, line2, line3, line4}
        for _, line in pairs(lines) do
            line.Color = LocalPlayer.TeamColor == player.TeamColor and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            line.Thickness = 1
            line.Visible = true
        end

        -- Auto-destroy lines
        RunService.RenderStepped:Connect(function()
            if not player or not player.Parent or not ESPConfig.Boxes then
                for _, line in pairs(lines) do line:Remove() end
            end
        end)
    end
end

-- =================================================================
--                        Core Logic (Aimbot & Main Loop)
-- =================================================================
-- Aimbot input (unchanged)
-- ...

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Aimbot Logic
    if AimbotConfig.Enabled and AimbotConfig.Aiming then
        -- (Aimbot code is mostly the same, but uses the new Smoothness value)
    end

    -- ESP Logic
    if ESPConfig.Boxes then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                DrawBox(player)
            end
        end
    end
end)

print("Kuak Hub (Arsenal) v1.1: Fully loaded and operational.")
