local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Automatic Game Detection & Auto-Config
local placeId = game.PlaceId
local gameName = "Rivals"
local customTpOffset = 10
local autoTeamCheck = true
local flingDuration = 5.0
local shootDuration = 3.0 
local flingDistance = 1000
local targetSwitchInterval = 0.5

-- Feature states
local tracersEnabled = false
local aimAssistEnabled = false
local speedAssistEnabled = false
local speedMultiplier = 2.0
local jumpAssistEnabled = false
local jumpPowerVal = 100
local orbitRageEnabled = false
local rivalsTargetMode = false 
local selectedKey = Enum.KeyCode.RightControl
local bindingKey = false

if placeId == 286090429 or tostring(placeId) == "286090429" then
    gameName = "Arsenal"
    customTpOffset = 1
else
    gameName = "Rivals"
    customTpOffset = 10
end

pcall(function()
    local info = MarketplaceService:GetProductInfo(placeId)
    if info and info.Name then
        local lowerName = info.Name:lower()
        if lowerName:find("arsenal") then
            gameName = "Arsenal"
            customTpOffset = 1
        elseif lowerName:find("rivals") then
            gameName = "Rivals"
            customTpOffset = 10
        end
    end
end)

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clear out any previous instances
pcall(function()
    for _, child in ipairs(playerGui:GetChildren()) do
        if child.Name == "UltimateMultiGameSuite" then child:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateMultiGameSuite"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = playerGui

-- Sleek, Modern Minimalist UI Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 440)
MainFrame.Position = UDim2.new(0.5, -250, 0.3, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Premium Subtle Top Gradient Accent
local TopBarGradient = Instance.new("Frame")
TopBarGradient.Size = UDim2.new(1, 0, 0, 4)
TopBarGradient.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
TopBarGradient.BorderSizePixel = 0
TopBarGradient.Parent = MainFrame

local TopGradCorner = Instance.new("UICorner")
TopGradCorner.CornerRadius = UDim.new(0, 10)
TopGradCorner.Parent = TopBarGradient

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 45)
Title.Position = UDim2.new(0, 15, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "ULTIMATE SUITE  <font color='#888899'>[" .. gameName .. "]</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Modern Clean Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -30, 0, 36)
TabBar.Position = UDim2.new(0, 15, 0, 50)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 8)
TabBarCorner.Parent = TabBar

local function createTabButton(text, xPos, sizeX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(sizeX, -4, 1, -4)
    btn.Position = UDim2.new(xPos, 2, 0, 2)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(150, 150, 165)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = TabBar
    
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 0, 0, 2)
    indicator.Position = UDim2.new(0, 0, 1, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    indicator.Parent = btn
    
    return btn
end

local MainTabBtn = createTabButton("Automation", 0, 0.25)
local CombatTabBtn = createTabButton("Combat", 0.25, 0.25)
local VisualsTabBtn = createTabButton("Visuals", 0.50, 0.25)
local TargetsTabBtn = createTabButton("Targets", 0.75, 0.25)

-- Containers
local function createContainer()
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, -30, 0, 325)
    c.Position = UDim2.new(0, 15, 0, 95)
    c.BackgroundTransparency = 1
    c.Visible = false
    c.Parent = MainFrame
    return c
end

local MainContainer = createContainer()
MainContainer.Visible = true
local CombatContainer = createContainer()
local VisualsContainer = createContainer()
local TargetsContainer = createContainer()

-- Tab Switching Logic Handler
local function switchTab(tabName)
    MainContainer.Visible = (tabName == "Main")
    CombatContainer.Visible = (tabName == "Combat")
    VisualsContainer.Visible = (tabName == "Visuals")
    TargetsContainer.Visible = (tabName == "Targets")
    
    local tabs = {
        {btn = MainTabBtn, name = "Main"},
        {btn = CombatTabBtn, name = "Combat"},
        {btn = VisualsTabBtn, name = "Visuals"},
        {btn = TargetsTabBtn, name = "Targets"}
    }
    
    for _, t in ipairs(tabs) do
        local active = (t.name == tabName)
        t.btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 165)
        local ind = t.btn:FindFirstChild("Indicator")
        if ind then
            ind.BackgroundTransparency = active and 0 or 1
            ind.Size = active and UDim2.new(1, 0, 0, 2) or UDim2.new(0, 0, 0, 2)
        end
    end
end

MainTabBtn.MouseButton1Click:Connect(function() switchTab("Main") end)
CombatTabBtn.MouseButton1Click:Connect(function() switchTab("Combat") end)
VisualsTabBtn.MouseButton1Click:Connect(function() switchTab("Visuals") end)
TargetsTabBtn.MouseButton1Click:Connect(function() switchTab("Targets") end)
switchTab("Main")

-- Helper for modern buttons
local function styleButton(btn, bgColor)
    btn.BackgroundColor3 = bgColor
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
end

-- ==================== MAIN TAB COMPONENTS ====================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 42)
ToggleBtn.Position = UDim2.new(0, 0, 0, 5)
ToggleBtn.Text = "Toggle Rage Mode: OFF"
ToggleBtn.TextSize = 13
styleButton(ToggleBtn, Color3.fromRGB(0, 120, 245))
ToggleBtn.Parent = MainContainer

local OrbitRageBtn = Instance.new("TextButton")
OrbitRageBtn.Size = UDim2.new(1, 0, 0, 38)
OrbitRageBtn.Position = UDim2.new(0, 0, 0, 54)
OrbitRageBtn.Text = "Orbit Rage Mode: OFF"
OrbitRageBtn.TextSize = 13
styleButton(OrbitRageBtn, Color3.fromRGB(45, 45, 58))
OrbitRageBtn.Parent = MainContainer

-- Keybind Selector Button
local KeybindBtn = Instance.new("TextButton")
KeybindBtn.Size = UDim2.new(1, 0, 0, 36)
KeybindBtn.Position = UDim2.new(0, 0, 0, 99)
KeybindBtn.Text = "Toggle Hotkey: RightControl (Click to Change)"
KeybindBtn.TextSize = 12
styleButton(KeybindBtn, Color3.fromRGB(35, 35, 45))
KeybindBtn.Parent = MainContainer

-- Timers layout container
local FlingDurationLabel = Instance.new("TextLabel")
FlingDurationLabel.Size = UDim2.new(1, 0, 0, 18)
FlingDurationLabel.Position = UDim2.new(0, 0, 0, 145)
FlingDurationLabel.BackgroundTransparency = 1
FlingDurationLabel.Text = "Flinging Time: " .. string.format("%.1f", flingDuration) .. "s"
FlingDurationLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
FlingDurationLabel.Font = Enum.Font.GothamSemibold
FlingDurationLabel.TextSize = 12
FlingDurationLabel.Parent = MainContainer

local FlingMinusBtn = Instance.new("TextButton")
FlingMinusBtn.Size = UDim2.new(0.48, 0, 0, 28)
FlingMinusBtn.Position = UDim2.new(0, 0, 0, 167)
FlingMinusBtn.Text = "Fling Time (-)"
FlingMinusBtn.TextSize = 11
styleButton(FlingMinusBtn, Color3.fromRGB(45, 45, 58))
FlingMinusBtn.Parent = MainContainer

local FlingPlusBtn = Instance.new("TextButton")
FlingPlusBtn.Size = UDim2.new(0.48, 0, 0, 28)
FlingPlusBtn.Position = UDim2.new(0.52, 0, 0, 167)
FlingPlusBtn.Text = "Fling Time (+)"
FlingPlusBtn.TextSize = 11
styleButton(FlingPlusBtn, Color3.fromRGB(45, 45, 58))
FlingPlusBtn.Parent = MainContainer

local ShootDurationLabel = Instance.new("TextLabel")
ShootDurationLabel.Size = UDim2.new(1, 0, 0, 18)
ShootDurationLabel.Position = UDim2.new(0, 0, 0, 204)
ShootDurationLabel.BackgroundTransparency = 1
ShootDurationLabel.Text = "Shoot Time: " .. string.format("%.1f", shootDuration) .. "s"
ShootDurationLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
ShootDurationLabel.Font = Enum.Font.GothamSemibold
ShootDurationLabel.TextSize = 12
ShootDurationLabel.Parent = MainContainer

local ShootMinusBtn = Instance.new("TextButton")
ShootMinusBtn.Size = UDim2.new(0.48, 0, 0, 28)
ShootMinusBtn.Position = UDim2.new(0, 0, 0, 226)
ShootMinusBtn.Text = "Shoot Time (-)"
ShootMinusBtn.TextSize = 11
styleButton(ShootMinusBtn, Color3.fromRGB(45, 45, 58))
ShootMinusBtn.Parent = MainContainer

local ShootPlusBtn = Instance.new("TextButton")
ShootPlusBtn.Size = UDim2.new(0.48, 0, 0, 28)
ShootPlusBtn.Position = UDim2.new(0.52, 0, 0, 226)
ShootPlusBtn.Text = "Shoot Time (+)"
ShootPlusBtn.TextSize = 11
styleButton(ShootPlusBtn, Color3.fromRGB(45, 45, 58))
ShootPlusBtn.Parent = MainContainer

local RageStatus = Instance.new("TextLabel")
RageStatus.Size = UDim2.new(1, 0, 0, 52)
RageStatus.Position = UDim2.new(0, 0, 0, 264)
RageStatus.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
RageStatus.Text = " Status: Idle (Ready)"
RageStatus.TextColor3 = Color3.fromRGB(150, 150, 165)
RageStatus.Font = Enum.Font.GothamMedium
RageStatus.TextSize = 11
RageStatus.TextXAlignment = Enum.TextXAlignment.Left
RageStatus.Parent = MainContainer

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = RageStatus

-- ==================== COMBAT TAB COMPONENTS ====================
local AimAssistBtn = Instance.new("TextButton")
AimAssistBtn.Size = UDim2.new(1, 0, 0, 38)
AimAssistBtn.Position = UDim2.new(0, 0, 0, 5)
AimAssistBtn.Text = "Aim Assist / Lock-on: OFF"
AimAssistBtn.TextSize = 12
styleButton(AimAssistBtn, Color3.fromRGB(45, 45, 58))
AimAssistBtn.Parent = CombatContainer

local SpeedAssistBtn = Instance.new("TextButton")
SpeedAssistBtn.Size = UDim2.new(1, 0, 0, 38)
SpeedAssistBtn.Position = UDim2.new(0, 0, 0, 49)
SpeedAssistBtn.Text = "Speed Assist: OFF (" .. speedMultiplier .. "x)"
SpeedAssistBtn.TextSize = 12
styleButton(SpeedAssistBtn, Color3.fromRGB(45, 45, 58))
SpeedAssistBtn.Parent = CombatContainer

local JumpAssistBtn = Instance.new("TextButton")
JumpAssistBtn.Size = UDim2.new(1, 0, 0, 38)
JumpAssistBtn.Position = UDim2.new(0, 0, 0, 93)
JumpAssistBtn.Text = "Jump Power Assist: OFF (" .. jumpPowerVal .. ")"
JumpAssistBtn.TextSize = 12
styleButton(JumpAssistBtn, Color3.fromRGB(45, 45, 58))
JumpAssistBtn.Parent = CombatContainer

local FlingDistLabel = Instance.new("TextLabel")
FlingDistLabel.Size = UDim2.new(1, 0, 0, 18)
FlingDistLabel.Position = UDim2.new(0, 0, 0, 142)
FlingDistLabel.BackgroundTransparency = 1
FlingDistLabel.Text = "Fling Distance (Studs):"
FlingDistLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
FlingDistLabel.Font = Enum.Font.GothamSemibold
FlingDistLabel.TextSize = 12
FlingDistLabel.Parent = CombatContainer

local FlingDistBox = Instance.new("TextBox")
FlingDistBox.Size = UDim2.new(1, 0, 0, 36)
FlingDistBox.Position = UDim2.new(0, 0, 0, 165)
FlingDistBox.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
FlingDistBox.Text = tostring(flingDistance)
FlingDistBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingDistBox.Font = Enum.Font.GothamBold
FlingDistBox.TextSize = 13
FlingDistBox.ClearTextOnFocus = false
FlingDistBox.Parent = CombatContainer

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = FlingDistBox

-- ==================== VISUALS TAB COMPONENTS ====================
local EspToggleBtn = Instance.new("TextButton")
EspToggleBtn.Size = UDim2.new(1, 0, 0, 42)
EspToggleBtn.Position = UDim2.new(0, 0, 0, 5)
EspToggleBtn.Text = "Player ESP Chams: OFF"
EspToggleBtn.TextSize = 12
styleButton(EspToggleBtn, Color3.fromRGB(45, 45, 58))
EspToggleBtn.Parent = VisualsContainer

local TracersToggleBtn = Instance.new("TextButton")
TracersToggleBtn.Size = UDim2.new(1, 0, 0, 42)
TracersToggleBtn.Position = UDim2.new(0, 0, 0, 55)
TracersToggleBtn.Text = "Player Tracers Line ESP: OFF"
TracersToggleBtn.TextSize = 12
styleButton(TracersToggleBtn, Color3.fromRGB(45, 45, 58))
TracersToggleBtn.Parent = VisualsContainer

-- ==================== TARGET MANAGER TAB COMPONENTS ====================
local TeamCheckBtn = Instance.new("TextButton")
TeamCheckBtn.Size = UDim2.new(1, 0, 0, 36)
TeamCheckBtn.Position = UDim2.new(0, 0, 0, 5)
TeamCheckBtn.Text = "Team Check: ON (Auto)"
TeamCheckBtn.TextSize = 12
styleButton(TeamCheckBtn, Color3.fromRGB(0, 130, 80))
TeamCheckBtn.Parent = TargetsContainer

local RivalsModeBtn = Instance.new("TextButton")
RivalsModeBtn.Size = UDim2.new(1, 0, 0, 36)
RivalsModeBtn.Position = UDim2.new(0, 0, 0, 47)
RivalsModeBtn.Text = "Rivals Exclusivity Mode: OFF"
RivalsModeBtn.TextSize = 12
styleButton(RivalsModeBtn, Color3.fromRGB(45, 45, 58))
RivalsModeBtn.Parent = TargetsContainer

local TargetListTitle = Instance.new("TextLabel")
TargetListTitle.Size = UDim2.new(1, 0, 0, 18)
TargetListTitle.Position = UDim2.new(0, 0, 0, 91)
TargetListTitle.BackgroundTransparency = 1
TargetListTitle.Text = "Target List Selector:"
TargetListTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
TargetListTitle.Font = Enum.Font.GothamSemibold
TargetListTitle.TextSize = 12
TargetListTitle.Parent = TargetsContainer

local TargetScroll = Instance.new("ScrollingFrame")
TargetScroll.Size = UDim2.new(1, 0, 0, 205)
TargetScroll.Position = UDim2.new(0, 0, 0, 114)
TargetScroll.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
TargetScroll.BorderSizePixel = 0
TargetScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TargetScroll.ScrollBarThickness = 4
TargetScroll.Parent = TargetsContainer

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 6)
TargetCorner.Parent = TargetScroll

local TargetLayout = Instance.new("UIListLayout")
TargetLayout.Padding = UDim.new(0, 4)
TargetLayout.Parent = TargetScroll

-- Script State Variables
local active = false
local teamCheckEnabled = autoTeamCheck
local espEnabled = false
local hbConn = nil
local currentTarget = nil
local selectedTargets = {}
local savedCFrame = nil
local highlights = {}
local tracerDrawings = {}
local shootingActive = false
local lastTargetUserId = nil
local targetSwitchTimer = 0
local orbitAngle = 0

-- Keybind Action
KeybindBtn.MouseButton1Click:Connect(function()
    bindingKey = true
    KeybindBtn.Text = "Press any key..."
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if bindingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            selectedKey = input.KeyCode
            KeybindBtn.Text = "Toggle Hotkey: " .. selectedKey.Name .. " (Click to Change)"
            bindingKey = false
        end
    elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == selectedKey then
            ToggleBtn:Activate()
        end
    end
end)

-- Orbit Rage Toggle
OrbitRageBtn.MouseButton1Click:Connect(function()
    orbitRageEnabled = not orbitRageEnabled
    OrbitRageBtn.Text = "Orbit Rage Mode: " .. (orbitRageEnabled and "ON" or "OFF")
    OrbitRageBtn.BackgroundColor3 = orbitRageEnabled and Color3.fromRGB(0, 120, 245) or Color3.fromRGB(45, 45, 58)
end)

-- Rivals Exclusivity Switch Toggle
RivalsModeBtn.MouseButton1Click:Connect(function()
    rivalsTargetMode = not rivalsTargetMode
    RivalsModeBtn.Text = "Rivals Exclusivity Mode: " .. (rivalsTargetMode and "ON" or "OFF")
    RivalsModeBtn.BackgroundColor3 = rivalsTargetMode and Color3.fromRGB(0, 120, 245) or Color3.fromRGB(45, 45, 58)
    currentTarget = nil
end)

-- Duration Adjusters
FlingMinusBtn.MouseButton1Click:Connect(function()
    flingDuration = math.max(0.5, flingDuration - 0.5)
    FlingDurationLabel.Text = "Flinging Time: " .. string.format("%.1f", flingDuration) .. "s"
end)

FlingPlusBtn.MouseButton1Click:Connect(function()
    flingDuration = math.min(30.0, flingDuration + 0.5)
    FlingDurationLabel.Text = "Flinging Time: " .. string.format("%.1f", flingDuration) .. "s"
end)

ShootMinusBtn.MouseButton1Click:Connect(function()
    shootDuration = math.max(0.5, shootDuration - 0.5)
    ShootDurationLabel.Text = "Shoot Time: " .. string.format("%.1f", shootDuration) .. "s"
end)

ShootPlusBtn.MouseButton1Click:Connect(function()
    shootDuration = math.min(30.0, shootDuration + 0.5)
    ShootDurationLabel.Text = "Shoot Time: " .. string.format("%.1f", shootDuration) .. "s"
end)

FlingDistBox.FocusLost:Connect(function(enterPressed)
    local val = tonumber(FlingDistBox.Text)
    if val then
        flingDistance = math.clamp(math.floor(val), 1, 10000)
    end
    FlingDistBox.Text = tostring(flingDistance)
end)

-- Aim Assist Toggle
AimAssistBtn.MouseButton1Click:Connect(function()
    aimAssistEnabled = not aimAssistEnabled
    AimAssistBtn.Text = "Aim Assist / Lock-on: " .. (aimAssistEnabled and "ON" or "OFF")
    AimAssistBtn.BackgroundColor3 = aimAssistEnabled and Color3.fromRGB(0, 130, 80) or Color3.fromRGB(45, 45, 58)
end)

-- Speed Assist Toggle & Cycling
SpeedAssistBtn.MouseButton1Click:Connect(function()
    if not speedAssistEnabled then
        speedAssistEnabled = true
        speedMultiplier = 2.0
    elseif speedMultiplier == 2.0 then
        speedMultiplier = 3.5
    else
        speedAssistEnabled = false
        speedMultiplier = 2.0
    end
    
    SpeedAssistBtn.Text = "Speed Assist: " .. (speedAssistEnabled and ("ON (" .. speedMultiplier .. "x)") or "OFF")
    SpeedAssistBtn.BackgroundColor3 = speedAssistEnabled and Color3.fromRGB(0, 130, 80) or Color3.fromRGB(45, 45, 58)
end)

-- Jump Power Assist Toggle & Cycling
JumpAssistBtn.MouseButton1Click:Connect(function()
    if not jumpAssistEnabled then
        jumpAssistEnabled = true
        jumpPowerVal = 100
    elseif jumpPowerVal == 100 then
        jumpPowerVal = 200
    else
        jumpAssistEnabled = false
        jumpPowerVal = 100
    end
    
    JumpAssistBtn.Text = "Jump Power Assist: " .. (jumpAssistEnabled and ("ON (" .. jumpPowerVal .. ")") or "OFF")
    JumpAssistBtn.BackgroundColor3 = jumpAssistEnabled and Color3.fromRGB(0, 130, 80) or Color3.fromRGB(45, 45, 58)
end)

-- Populate Target List UI
local function updateTargetListUI()
    for _, child in ipairs(TargetScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local yOffset = 0
    local buttonHeight = 26
    local padding = 4
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isSelected = selectedTargets[player.UserId] == true
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, buttonHeight)
            pBtn.Position = UDim2.new(0, 0, 0, yOffset)
            pBtn.BackgroundColor3 = isSelected and Color3.fromRGB(0, 120, 80) or Color3.fromRGB(22, 22, 28)
            pBtn.Text = "  " .. player.Name .. (isSelected and " [SELECTED]" or "")
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.Font = Enum.Font.GothamMedium
            pBtn.TextSize = 11
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.Parent = TargetScroll
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = pBtn
            
            local targetPlayer = player
            pBtn.MouseButton1Click:Connect(function()
                if selectedTargets[targetPlayer.UserId] then
                    selectedTargets[targetPlayer.UserId] = nil
                    pBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                    pBtn.Text = "  " .. targetPlayer.Name
                else
                    selectedTargets[targetPlayer.UserId] = true
                    pBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
                    pBtn.Text = "  " .. targetPlayer.Name .. " [SELECTED]"
                end
            end)
            yOffset = yOffset + buttonHeight + padding
        end
    end
    TargetScroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

Players.PlayerAdded:Connect(updateTargetListUI)
Players.PlayerRemoving:Connect(updateTargetListUI)
updateTargetListUI()

-- Reloading Checker
local function isReloading()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if tool:GetAttribute("Reloading") == true then return true end
        if tool:FindFirstChild("Reloading") and tool.Reloading.Value == true then return true end
    end
    return false
end

-- Enemy Validator
local function isValidEnemy(player)
    if not player or player == LocalPlayer then return false end
    if rivalsTargetMode and not selectedTargets[player.UserId] then return false end
    
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return false end
    
    if teamCheckEnabled and not rivalsTargetMode then
        if gameName == "Arsenal" then
            if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return false end
            if LocalPlayer.TeamColor and player.TeamColor and LocalPlayer.TeamColor == player.TeamColor then return false end
        else
            if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return false end
            local success, matchTeam1 = pcall(function() return player:GetAttribute("Team") end)
            local success2, matchTeam2 = pcall(function() return LocalPlayer:GetAttribute("Team") end)
            if success and success2 and matchTeam1 ~= nil and matchTeam2 ~= nil then
                if matchTeam1 == matchTeam2 then return false end
            end
            if char:FindFirstChild("TeammateLabel") or char:FindFirstChild("AllyTag") then return false end
        end
    end
    return true
end

-- Rotating Target Selector
local function getNewTarget()
    local validPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if isValidEnemy(p) then
            table.insert(validPlayers, p)
        end
    end
    
    if #validPlayers == 0 then return nil end
    
    if gameName == "Arsenal" or not rivalsTargetMode then
        if #validPlayers > 1 and lastTargetUserId then
            local filtered = {}
            for _, p in ipairs(validPlayers) do
                if p.UserId ~= lastTargetUserId then
                    table.insert(filtered, p)
                end
            end
            if #filtered > 0 then
                validPlayers = filtered
            end
        end
    end
    
    local chosenPlayer = validPlayers[math.random(1, #validPlayers)]
    lastTargetUserId = chosenPlayer.UserId
    return chosenPlayer.Character.HumanoidRootPart
end

-- Tracers Rendering Logic
local function updateTracers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not tracerDrawings[player] then
                local line = Drawing.new("Line")
                line.Visible = false
                line.Color = Color3.fromRGB(0, 140, 255)
                line.Thickness = 1.5
                tracerDrawings[player] = line
            end
            
            local line = tracerDrawings[player]
            local char = player.Character
            if tracersEnabled and isValidEnemy(player) and char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(vector.X, vector.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end
end

-- ESP System Logic
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if espEnabled and isValidEnemy(player) and char then
                if not highlights[player] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "UltimateSuiteESP"
                    hl.Adornee = char
                    hl.FillColor = Color3.fromRGB(0, 140, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                    highlights[player] = hl
                else
                    highlights[player].Adornee = char
                    highlights[player].Parent = char
                end
            else
                if highlights[player] then
                    highlights[player]:Destroy()
                    highlights[player] = nil
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if espEnabled then updateESP() end
    if tracersEnabled then updateTracers() end
    
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if char and humanoid then
        if speedAssistEnabled then
            humanoid.WalkSpeed = 16 * speedMultiplier
        end
        if jumpAssistEnabled then
            humanoid.JumpPower = jumpPowerVal
        end
    end
    
    if aimAssistEnabled then
        local t = getNewTarget()
        if t then
            pcall(function()
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
            end)
        end
    end
end)

EspToggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    EspToggleBtn.Text = "Player ESP Chams: " .. (espEnabled and "ON" or "OFF")
    EspToggleBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 130, 80) or Color3.fromRGB(45, 45, 58)
    if not espEnabled then
        for _, hl in pairs(highlights) do if hl then hl:Destroy() end end
        highlights = {}
    end
end)

TracersToggleBtn.MouseButton1Click:Connect(function()
    tracersEnabled = not tracersEnabled
    TracersToggleBtn.Text = "Player Tracers Line ESP: " .. (tracersEnabled and "ON" or "OFF")
    TracersToggleBtn.BackgroundColor3 = tracersEnabled and Color3.fromRGB(0, 130, 80) or Color3.fromRGB(45, 45, 58)
    if not tracersEnabled then
        for _, line in pairs(tracerDrawings) do if line then line.Visible = false end end
    end
end)

-- Main Toggle Feature Loop
local function toggleFeature()
    active = not active
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if active then
        ToggleBtn.Text = "Toggle Rage Mode: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        currentTarget = nil
        lastTargetUserId = nil
        
        if root then 
            savedCFrame = root.CFrame 
        else
            savedCFrame = CFrame.new(0, 5, 0)
        end
        
        local stateTimer = 0
        local isAttacking = true 
        shootingActive = false
        targetSwitchTimer = 0
        
        hbConn = RunService.Heartbeat:Connect(function(dt)
            local currentCharm = LocalPlayer.Character
            local currentRoot = currentCharm and currentCharm:FindFirstChild("HumanoidRootPart")
            
            if currentRoot then
                if isReloading() then
                    currentTarget = nil
                    isAttacking = true
                    stateTimer = 0
                    targetSwitchTimer = 0
                    RageStatus.Text = " Status: Reloading... Flinging Active (" .. flingDistance .. " studs)"
                    
                    currentRoot.CFrame = savedCFrame + Vector3.new(
                        math.random(-flingDistance, flingDistance), 
                        math.random(1, math.max(10, flingDistance / 2)), 
                        math.random(-flingDistance, flingDistance)
                    )
                    currentRoot.Velocity = Vector3.new(50000, 50000, 50000)
                    currentRoot.RotVelocity = Vector3.new(50000, 50000, 50000)
                else
                    stateTimer = stateTimer + dt
                    
                    if isAttacking then
                        shootingActive = false
                        currentTarget = nil
                        
                        if stateTimer >= flingDuration then
                            stateTimer = 0
                            isAttacking = false 
                            currentTarget = getNewTarget()
                            if currentTarget then
                                shootingActive = true
                                task.spawn(function()
                                    while shootingActive and active do
                                        pcall(function()
                                            if mouse1press and mouse1release then
                                                mouse1press()
                                                task.wait(0.03)
                                                mouse1release()
                                            end
                                        end)
                                        task.wait(0.05)
                                    end
                                    pcall(function() if mouse1release then mouse1release() end end)
                                end)
                            end
                        else
                            RageStatus.Text = " Status: Flinging Outward... (" .. string.format("%.1f", flingDuration - stateTimer) .. "s left)"
                            currentRoot.CFrame = savedCFrame + Vector3.new(
                                math.random(-flingDistance, flingDistance), 
                                math.random(1, math.max(10, flingDistance / 2)), 
                                math.random(-flingDistance, flingDistance)
                            )
                            currentRoot.Velocity = Vector3.new(50000, 50000, 50000)
                            currentRoot.RotVelocity = Vector3.new(50000, 50000, 50000)
                        end
                    else
                        targetSwitchTimer = targetSwitchTimer + dt
                        
                        if targetSwitchTimer >= targetSwitchInterval then
                            targetSwitchTimer = 0
                            local newT = getNewTarget()
                            if newT then
                                currentTarget = newT
                            end
                        end
                        
                        if stateTimer >= shootDuration then
                            shootingActive = false
                            stateTimer = 0
                            isAttacking = true 
                            currentTarget = nil
                            targetSwitchTimer = 0
                        else
                            local targetPlayer = nil
                            if currentTarget and currentTarget.Parent then
                                for _, p in ipairs(Players:GetPlayers()) do
                                    if p.Character == currentTarget.Parent then
                                        targetPlayer = p
                                        break
                                    end
                                end
                            end
                            
                            if targetPlayer and isValidEnemy(targetPlayer) then
                                if orbitRageEnabled then
                                    orbitAngle = orbitAngle + (dt * 5)
                                    local offsetX = math.cos(orbitAngle) * 10
                                    local offsetZ = math.sin(orbitAngle) * 10
                                    local orbitPos = currentTarget.Position + Vector3.new(offsetX, 4, offsetZ)
                                    
                                    RageStatus.Text = " Status: Orbiting & Aiming at Enemy!"
                                    currentRoot.CFrame = CFrame.new(orbitPos, currentTarget.Position)
                                    currentRoot.Velocity = Vector3.new(0, 0, 0)
                                    currentRoot.RotVelocity = Vector3.new(0, 0, 0)
                                else
                                    RageStatus.Text = " Status: Shooting Phase... (" .. string.format("%.1f", shootDuration - stateTimer) .. "s left)"
                                    currentRoot.CFrame = currentTarget.CFrame * CFrame.new(0, customTpOffset, 0)
                                    currentRoot.Velocity = Vector3.new(0, 0, 0)
                                    currentRoot.RotVelocity = Vector3.new(0, 0, 0)
                                end
                                
                                pcall(function()
                                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
                                end)
                            else
                                currentTarget = getNewTarget()
                            end
                        end
                    end
                end
            end
        end)
    else
        ToggleBtn.Text = "Toggle Rage Mode: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 245)
        RageStatus.Text = " Status: Idle (Ready)"
        currentTarget = nil
        shootingActive = false
        targetSwitchTimer = 0
        
        if hbConn then hbConn:Disconnect() end
        
        pcall(function()
            if mouse1release then mouse1release() end
        end)
        
        if root then
            root.Velocity = Vector3.new(0, 0, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
            if savedCFrame then root.CFrame = savedCFrame end
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(toggleFeature)

TeamCheckBtn.MouseButton1Click:Connect(function()
    teamCheckEnabled = not teamCheckEnabled
    TeamCheckBtn.Text = "Team Check: " .. (teamCheckEnabled and "ON (Auto)" or "OFF")
    TeamCheckBtn.BackgroundColor3 = teamCheckEnabled and Color3.fromRGB(0, 130, 80) or Color3.fromRGB(130, 40, 40)
    currentTarget = nil
end)

print("[Ultimate Suite] Loaded successfully with fixed UI generation!")
