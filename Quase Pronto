local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ToggleAimlock = false
local AimPart = "Head"
local AimRadius = 500
local ESPs = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimLockGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.Text = "AimLock: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.Parent = ScreenGui
ToggleButton.Active = true
ToggleButton.Draggable = true

ToggleButton.MouseButton1Click:Connect(function()
    ToggleAimlock = not ToggleAimlock
    ToggleButton.Text = ToggleAimlock and "AimLock: ON" or "AimLock: OFF"
end)

local function isEnemy(plr)
    if not plr.Team or not LocalPlayer.Team then
        return plr ~= LocalPlayer
    end
    return plr.Team ~= LocalPlayer.Team
end

local function removeESP(plr)
    if ESPs[plr] then
        ESPs[plr]:Remove()
        ESPs[plr] = nil
    end
end

local function createESP(plr)
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    ESPs[plr] = box
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if isEnemy(plr) then
                if not ESPs[plr] then
                    createESP(plr)
                end
                local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if onScreen then
                    local fixedSize = Vector2.new(50, 80)
                    ESPs[plr].Size = fixedSize
                    ESPs[plr].Position = Vector2.new(pos.X - fixedSize.X / 2, pos.Y - fixedSize.Y / 2)
                    ESPs[plr].Visible = true
                else
                    ESPs[plr].Visible = false
                end
            else
                removeESP(plr)
            end
        else
            removeESP(plr)
        end
    end
end

local function getClosestEnemy()
    local closestDist = math.huge
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isEnemy(plr) and plr.Character and plr.Character:FindFirstChild(AimPart) then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local pos, visible = Camera:WorldToViewportPoint(plr.Character[AimPart].Position)
                local noWall = #Camera:GetPartsObscuringTarget({plr.Character[AimPart].Position}, {LocalPlayer.Character}) == 0
                if visible and noWall then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < closestDist and dist < AimRadius then
                        closestDist = dist
                        target = plr
                    end
                end
            end
        end
    end
    return target
end

local CurrentTarget = nil

RunService.RenderStepped:Connect(function()
    updateESP()
    if ToggleAimlock then
        if CurrentTarget then
            local humanoid = CurrentTarget.Character and CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
            if not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChild(AimPart) or (humanoid and humanoid.Health <= 0) or not isEnemy(CurrentTarget) then
                CurrentTarget = nil
            end
        end
        if not CurrentTarget then
            CurrentTarget = getClosestEnemy()
        end
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild(AimPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, CurrentTarget.Character[AimPart].Position)
        end
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        wait(1)
        if isEnemy(plr) and not ESPs[plr] then
            createESP(plr)
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if not ScreenGui.Parent then
        ScreenGui.Parent = game.CoreGui
    end
end)
