--[[
    Script: Kuak Hub v2.0 (Stable & Complete)
    Author: kuak saudi
    Game: Blox Fruits
]]

print("Kuak Hub v2.0: Loading...")

-- =================================================================
--                        Rayfield GUI Library
-- =================================================================
-- Using a trusted, stable library to ensure the GUI works 100%
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield.lua' ))()
print("Kuak Hub: GUI Library loaded.")

-- =================================================================
--                        Main Window
-- =================================================================
local Window = Rayfield:CreateWindow({
    Name = "Kuak Hub v2.0",
    LoadingTitle = "Kuak Hub - Loading...",
    LoadingSubtitle = "by kuak saudi",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "KuakHub",
        FileName = "BloxFruits"
    },
    Discord = {
        Enabled = true,
        Invite = "YprBskZdc9",
        RememberJoins = true
    }
})

-- =================================================================
--                        Services & Variables
-- =================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local AutoFarmConfig = {
    Enabled = false,
    Method = "Melee",
    BringMobs = true
}

local ESPConfig = {
    Players = false,
    Fruits = false,
    Chests = false
}

print("Kuak Hub: Services and variables initialized.")

-- =================================================================
--                        Farming Tab
-- =================================================================
local FarmingTab = Window:CreateTab("Main", 4483362458)

FarmingTab:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        AutoFarmConfig.Enabled = Value
        print("Auto Farm set to: " .. tostring(Value))
    end,
})

FarmingTab:CreateToggle({
    Name = "Bring Mobs",
    CurrentValue = true,
    Flag = "BringMobsToggle",
    Callback = function(Value)
        AutoFarmConfig.BringMobs = Value
    end,
})

FarmingTab:CreateDropdown({
    Name = "Select Farm Method",
    Options = {"Melee", "Sword", "Fruit"},
    CurrentValue = "Melee",
    Flag = "FarmMethodDropdown",
    Callback = function(Value)
        AutoFarmConfig.Method = Value
        print("Farm method set to: " .. Value)
    end,
})

FarmingTab:CreateButton({
    Name = "Auto-assign Stats (Melee, Defense, Sword)",
    Callback = function()
        local stats = {"Melee", "Defense", "Sword"}
        for _, stat in ipairs(stats) do
            for i = 1, 100 do -- Assign up to 100 points per click
                game:GetService("ReplicatedStorage").Remotes.Stat:InvokeServer(stat)
            end
        end
        Rayfield:Notify({
            Title = "Stats Assigned",
            Content = "Points have been assigned to Melee, Defense, and Sword.",
            Duration = 5
        })
    end,
})

-- =================================================================
--                        ESP Tab
-- =================================================================
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "ESPPlayersToggle",
    Callback = function(Value)
        ESPConfig.Players = Value
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Fruits",
    CurrentValue = false,
    Flag = "ESPFruitsToggle",
    Callback = function(Value)
        ESPConfig.Fruits = Value
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Chests",
    CurrentValue = false,
    Flag = "ESPChestsToggle",
    Callback = function(Value)
        ESPConfig.Chests = Value
    end,
})

-- =================================================================
--                        Player Tab
-- =================================================================
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

-- =================================================================
--                        Core Logic (Auto Farm & ESP)
-- =================================================================

-- Auto Farm Loop
RunService.Heartbeat:Connect(function()
    if not AutoFarmConfig.Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local currentQuest = Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
    if currentQuest == "No Quest" then
        -- This part needs to be improved later to find the correct quest giver
        return
    end

    local questProgress = Player.PlayerGui.Main.Quest.Container.QuestTitle.Progress.Text
    local needed = tonumber(questProgress:match("/(%d+)"))
    local current = tonumber(questProgress:match("(%d+)/"))

    if current and needed and current >= needed then return end -- Quest complete

    local mobName = currentQuest:match("Defeat %d+ (.+)")
    if not mobName then return end

    local targetMob = nil
    local minDist = math.huge
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v.Name == mobName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                targetMob = v
            end
        end
    end

    if targetMob then
        if AutoFarmConfig.BringMobs then
            targetMob.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)
        end
        -- This is a simplified attack logic, can be expanded
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
    end
end)

-- ESP Loop
local function CreateESP(target, color, name)
    local esp = Instance.new("BillboardGui", target)
    esp.Name = "KuakESP"
    esp.AlwaysOnTop = true
    esp.Size = UDim2.new(0, 100, 0, 50)
    
    local text = Instance.new("TextLabel", esp)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundColor3 = color
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Text = name
    text.Font = Enum.Font.SourceSans
    return esp
end

RunService.RenderStepped:Connect(function()
    -- Clear old ESP
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "KuakESP" then v:Destroy() end
    end

    if ESPConfig.Players then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                CreateESP(player.Character.Head, Color3.fromRGB(255, 0, 0), player.Name)
            end
        end
    end

    if ESPConfig.Fruits then
        for _, v in pairs(Workspace:GetChildren()) do
            if v.Name:find("Fruit") and v:IsA("Model") and v:FindFirstChild("Handle") then
                CreateESP(v.Handle, Color3.fromRGB(255, 0, 255), v.Name)
            end
        end
    end

    if ESPConfig.Chests then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "Chest" and v:IsA("MeshPart") then
                CreateESP(v, Color3.fromRGB(255, 255, 0), "Chest")
            end
        end
    end
end)

print("Kuak Hub v2.0: Fully loaded and operational.")
