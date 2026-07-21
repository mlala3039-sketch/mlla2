-- Memastikan tidak ada GUI ganda
if game.CoreGui:FindFirstChild("SimpleFishGUI") then
    game.CoreGui.SimpleFishGUI:Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local MaxFishCapacity = 50

local isRunning = false
local isAntiAfkOn = false
local antiAfkConnection = nil
local savedSellPosition = nil
local savedFishPosition = nil
local currentFishCaught = 0

-- Daftar rod & index yang dipilih
local SUPPORTED_RODS = {
    "ZombieRod",
    "AngelRod",
    "DarkBladeRod",
    "ZeusRod",
}
local selectedRodIndex = 1 -- Default: ZombieRod

-- ==========================================
-- GUI MANCING
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local AntiAfkButton = Instance.new("TextButton")
local FishCountLabel = Instance.new("TextLabel")
local SetFishPointButton = Instance.new("TextButton")
local SetSellPointButton = Instance.new("TextButton")
local SellButton = Instance.new("TextButton")
local ExitButton = Instance.new("TextButton")
local UICornerFrame = Instance.new("UICorner")

-- Tombol pilih rod
local RodLabel = Instance.new("TextLabel")
local RodPrevButton = Instance.new("TextButton")
local RodNextButton = Instance.new("TextButton")
local RodNameLabel = Instance.new("TextLabel")

ScreenGui.Name = "SimpleFishGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MainFrame diperbesar sedikit untuk menampung pilihan rod
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -75, 0.5, -137)
MainFrame.Size = UDim2.new(0, 150, 0, 275) -- Ditambah 50px tingginya
MainFrame.Active = true
MainFrame.Draggable = true
UICornerFrame.CornerRadius = UDim.new(0, 8)
UICornerFrame.Parent = MainFrame

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(0, 115, 0, 25)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "BY ORANG GANTENG"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.TextSize = 10
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

ExitButton.Name = "ExitButton"
ExitButton.Parent = MainFrame
ExitButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ExitButton.BorderSizePixel = 0
ExitButton.Position = UDim2.new(0, 125, 0, 0)
ExitButton.Size = UDim2.new(0, 25, 0, 25)
ExitButton.Font = Enum.Font.GothamBold
ExitButton.Text = "X"
ExitButton.TextColor3 = Color3.fromRGB(150, 150, 150)
ExitButton.TextSize = 12

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.Position = UDim2.new(0, 10, 0, 30)
ToggleButton.Size = UDim2.new(0, 130, 0, 30)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Auto Fish: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
ToggleButton.TextSize = 12
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

AntiAfkButton.Name = "AntiAfkButton"
AntiAfkButton.Parent = MainFrame
AntiAfkButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
AntiAfkButton.Position = UDim2.new(0, 10, 0, 65)
AntiAfkButton.Size = UDim2.new(0, 130, 0, 25)
AntiAfkButton.Font = Enum.Font.GothamBold
AntiAfkButton.Text = "Anti-AFK: OFF"
AntiAfkButton.TextColor3 = Color3.fromRGB(255, 75, 75)
AntiAfkButton.TextSize = 11
local AntiAfkCorner = Instance.new("UICorner")
AntiAfkCorner.CornerRadius = UDim.new(0, 6)
AntiAfkCorner.Parent = AntiAfkButton

FishCountLabel.Name = "FishCountLabel"
FishCountLabel.Parent = MainFrame
FishCountLabel.BackgroundTransparency = 1
FishCountLabel.Position = UDim2.new(0, 10, 0, 95)
FishCountLabel.Size = UDim2.new(0, 130, 0, 20)
FishCountLabel.Font = Enum.Font.GothamSemibold
FishCountLabel.Text = "Fish: 0 / " .. MaxFishCapacity
FishCountLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
FishCountLabel.TextSize = 11

-- === PILIHAN ROD ===
-- Label judul
RodLabel.Name = "RodLabel"
RodLabel.Parent = MainFrame
RodLabel.BackgroundTransparency = 1
RodLabel.Position = UDim2.new(0, 10, 0, 118)
RodLabel.Size = UDim2.new(0, 130, 0, 16)
RodLabel.Font = Enum.Font.GothamSemibold
RodLabel.Text = "Pilih Rod:"
RodLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
RodLabel.TextSize = 10
RodLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Tombol panah kiri ( < )
RodPrevButton.Name = "RodPrevButton"
RodPrevButton.Parent = MainFrame
RodPrevButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
RodPrevButton.Position = UDim2.new(0, 10, 0, 135)
RodPrevButton.Size = UDim2.new(0, 22, 0, 22)
RodPrevButton.Font = Enum.Font.GothamBold
RodPrevButton.Text = "<"
RodPrevButton.TextColor3 = Color3.fromRGB(200, 200, 200)
RodPrevButton.TextSize = 12
local PrevCorner = Instance.new("UICorner")
PrevCorner.CornerRadius = UDim.new(0, 4)
PrevCorner.Parent = RodPrevButton

-- Label nama rod yang dipilih
RodNameLabel.Name = "RodNameLabel"
RodNameLabel.Parent = MainFrame
RodNameLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
RodNameLabel.Position = UDim2.new(0, 35, 0, 135)
RodNameLabel.Size = UDim2.new(0, 72, 0, 22)
RodNameLabel.Font = Enum.Font.GothamBold
RodNameLabel.Text = SUPPORTED_RODS[selectedRodIndex]
RodNameLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
RodNameLabel.TextSize = 9
RodNameLabel.TextScaled = true
local RodNameCorner = Instance.new("UICorner")
RodNameCorner.CornerRadius = UDim.new(0, 4)
RodNameCorner.Parent = RodNameLabel

-- Tombol panah kanan ( > )
RodNextButton.Name = "RodNextButton"
RodNextButton.Parent = MainFrame
RodNextButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
RodNextButton.Position = UDim2.new(0, 110, 0, 135)
RodNextButton.Size = UDim2.new(0, 22, 0, 22)
RodNextButton.Font = Enum.Font.GothamBold
RodNextButton.Text = ">"
RodNextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
RodNextButton.TextSize = 12
local NextCorner = Instance.new("UICorner")
NextCorner.CornerRadius = UDim.new(0, 4)
NextCorner.Parent = RodNextButton

-- Fungsi update tampilan nama rod
local function UpdateRodDisplay()
    RodNameLabel.Text = SUPPORTED_RODS[selectedRodIndex]
end

-- Klik < untuk rod sebelumnya
RodPrevButton.MouseButton1Click:Connect(function()
    selectedRodIndex = selectedRodIndex - 1
    if selectedRodIndex < 1 then
        selectedRodIndex = #SUPPORTED_RODS
    end
    UpdateRodDisplay()
end)

-- Klik > untuk rod berikutnya
RodNextButton.MouseButton1Click:Connect(function()
    selectedRodIndex = selectedRodIndex + 1
    if selectedRodIndex > #SUPPORTED_RODS then
        selectedRodIndex = 1
    end
    UpdateRodDisplay()
end)
-- === AKHIR PILIHAN ROD ===

SetFishPointButton.Name = "SetFishPointButton"
SetFishPointButton.Parent = MainFrame
SetFishPointButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SetFishPointButton.Position = UDim2.new(0, 10, 0, 165)
SetFishPointButton.Size = UDim2.new(0, 130, 0, 28)
SetFishPointButton.Font = Enum.Font.GothamBold
SetFishPointButton.Text = "Set Point Mancing"
SetFishPointButton.TextColor3 = Color3.fromRGB(200, 200, 200)
SetFishPointButton.TextSize = 11
local FishCorner = Instance.new("UICorner")
FishCorner.CornerRadius = UDim.new(0, 6)
FishCorner.Parent = SetFishPointButton

SetSellPointButton.Name = "SetSellPointButton"
SetSellPointButton.Parent = MainFrame
SetSellPointButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SetSellPointButton.Position = UDim2.new(0, 10, 0, 200)
SetSellPointButton.Size = UDim2.new(0, 130, 0, 28)
SetSellPointButton.Font = Enum.Font.GothamBold
SetSellPointButton.Text = "Set Point Jual"
SetSellPointButton.TextColor3 = Color3.fromRGB(200, 200, 200)
SetSellPointButton.TextSize = 11
local SellCorner = Instance.new("UICorner")
SellCorner.CornerRadius = UDim.new(0, 6)
SellCorner.Parent = SetSellPointButton

SellButton.Name = "SellButton"
SellButton.Parent = MainFrame
SellButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SellButton.Position = UDim2.new(0, 10, 0, 235)
SellButton.Size = UDim2.new(0, 130, 0, 28)
SellButton.Font = Enum.Font.GothamBold
SellButton.Text = "Sell Now"
SellButton.TextColor3 = Color3.fromRGB(150, 150, 150)
SellButton.TextSize = 11
local SellNowCorner = Instance.new("UICorner")
SellNowCorner.CornerRadius = UDim.new(0, 6)
SellNowCorner.Parent = SellButton

SetFishPointButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        savedFishPosition = rootPart.CFrame
        SetFishPointButton.Text = "Fish Point Saved!"
        task.wait(1.5)
        SetFishPointButton.Text = "Set Point Mancing"
    end
end)

SetSellPointButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        savedSellPosition = rootPart.CFrame
        SetSellPointButton.Text = "Sell Point Saved!"
        task.wait(1.5)
        SetSellPointButton.Text = "Set Point Jual"
    end
end)

local function ClickSellAllButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and (gui.Name:lower():find("sell") or (gui:IsA("TextButton") and gui.Text:lower():find("sell all"))) then
            local absPos = gui.AbsolutePosition
            local absSize = gui.AbsoluteSize
            local clickX = absPos.X + (absSize.X / 2)
            local clickY = absPos.Y + (absSize.Y / 2) + 36
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
            break
        end
    end
end

local function GoAndSell()
    if not savedSellPosition then return end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if rootPart and humanoid then
        local returnPos = savedFishPosition or rootPart.CFrame
        rootPart.CFrame = savedSellPosition
        task.wait(0.8)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(5.0)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.5)
        ClickSellAllButton()
        task.wait(1.0)
        rootPart.CFrame = returnPos
    end
end

SellButton.MouseButton1Click:Connect(function()
    if savedSellPosition then
        SellButton.Text = "Selling..."
        GoAndSell()
        currentFishCaught = 0
        SellButton.Text = "Sell Now"
    else
        SellButton.Text = "No Sell Point!"
        task.wait(1.5)
        SellButton.Text = "Sell Now"
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleButton.Text = "Auto Fish: ON"
        ToggleButton.TextColor3 = Color3.fromRGB(75, 255, 75)
    else
        ToggleButton.Text = "Auto Fish: OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
    end
end)

AntiAfkButton.MouseButton1Click:Connect(function()
    isAntiAfkOn = not isAntiAfkOn
    if isAntiAfkOn then
        AntiAfkButton.Text = "Anti-AFK: ON"
        AntiAfkButton.TextColor3 = Color3.fromRGB(75, 255, 75)
        if not antiAfkConnection then
            antiAfkConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    else
        AntiAfkButton.Text = "Anti-AFK: OFF"
        AntiAfkButton.TextColor3 = Color3.fromRGB(255, 75, 75)
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end
end)

ExitButton.MouseButton1Click:Connect(function()
    isRunning = false
    isAntiAfkOn = false
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    ScreenGui:Destroy()
end)

task.spawn(function()
    while ScreenGui.Parent ~= nil do
        task.wait(1)
        FishCountLabel.Text = "Fish: " .. currentFishCaught .. " / " .. MaxFishCapacity
        if isRunning then
            if savedSellPosition ~= nil and currentFishCaught >= MaxFishCapacity then
                SellButton.Text = "Bag Full!"
                GoAndSell()
                currentFishCaught = 0
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                for i = 20, 1, -1 do
                    if not isRunning then break end
                    SellButton.Text = "Waiting " .. i .. "s"
                    if rootPart and savedFishPosition then
                        rootPart.CFrame = savedFishPosition
                    end
                    task.wait(1)
                end
                SellButton.Text = "Sell Now"
            end

            local character = LocalPlayer.Character
            -- Gunakan rod yang dipilih user
            local selectedRodName = SUPPORTED_RODS[selectedRodIndex]
            local rod = character and character:FindFirstChild(selectedRodName)
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")

            if rod and rootPart then
                if savedFishPosition then
                    rootPart.CFrame = savedFishPosition
                end
                local targetPos = rootPart.CFrame * CFrame.new(0, 0, -50).Position
                rod.CastToPosition:FireServer(targetPos)
                task.wait(17)
                local miniGameEvent = rod:FindFirstChild("MiniGame")
                if miniGameEvent then
                    miniGameEvent:FireServer("Complete")
                    currentFishCaught = currentFishCaught + 1
                end
                task.wait(math.random(2, 4))
            end
        end
    end
end)

-- ==========================================
-- FLY SCRIPT
-- ==========================================
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = LocalPlayer
local camera = workspace.CurrentCamera

local isFlying = false
local speedLevel = 5
local speedMultiplier = 15
local actualFlySpeed = speedLevel * speedMultiplier

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local openMenuBtn = Instance.new("TextButton")
openMenuBtn.Size = UDim2.new(0, 50, 0, 50)
openMenuBtn.Position = UDim2.new(0, 20, 0, 150)
openMenuBtn.Text = "✈️"
openMenuBtn.TextSize = 20
openMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
openMenuBtn.Visible = false
openMenuBtn.Parent = screenGui
local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 10)
openCorner.Parent = openMenuBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 160)
mainFrame.Position = UDim2.new(0, 20, 0, 150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "✈️ CONTROL PANEL"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Position = UDim2.new(0.1, 0, 0.25, 0)
toggleButton.Text = "Terbang: OFF"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Parent = mainFrame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.8, 0, 0, 20)
speedLabel.Position = UDim2.new(0.1, 0, 0.55, 0)
speedLabel.Text = "Kecepatan (1 - 10):"
speedLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.BackgroundTransparency = 1
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.8, 0, 0, 35)
speedInput.Position = UDim2.new(0.1, 0, 0.7, 0)
speedInput.Text = tostring(speedLevel)
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 14
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.Parent = mainFrame
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = speedInput

local bodyVelocity
local bodyGyro
local flyConnection

local function startFlying()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return end
    isFlying = true
    toggleButton.Text = "Terbang: ON"
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    humanoid.PlatformStand = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 15000
    bodyGyro.CFrame = camera.CFrame
    bodyGyro.Parent = rootPart
    flyConnection = RunService.RenderStepped:Connect(function()
        if not isFlying or not character.Parent then return end
        local direction = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then direction = direction - Vector3.new(0, 1, 0) end
        if direction.Magnitude > 0 then direction = direction.Unit end
        bodyVelocity.Velocity = direction * actualFlySpeed
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function stopFlying()
    isFlying = false
    toggleButton.Text = "Terbang: OFF"
    toggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    if flyConnection then flyConnection:Disconnect() end
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

toggleButton.MouseButton1Click:Connect(function()
    if isFlying then stopFlying() else startFlying() end
end)

speedInput.FocusLost:Connect(function()
    local inputNumber = tonumber(speedInput.Text)
    if inputNumber then
        speedLevel = math.clamp(math.floor(inputNumber), 1, 10)
        speedInput.Text = tostring(speedLevel)
        actualFlySpeed = speedLevel * speedMultiplier
    else
        speedInput.Text = tostring(speedLevel)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openMenuBtn.Visible = true
end)

openMenuBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openMenuBtn.Visible = false
end)

player.CharacterAdded:Connect(function()
    if isFlying then stopFlying() end
end)
