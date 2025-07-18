local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 100, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 80)
ToggleButton.Text = "Aimlock: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.BorderSizePixel = 0

local aimlockEnabled = false
ToggleButton.MouseButton1Click:Connect(function()
	aimlockEnabled = not aimlockEnabled
	ToggleButton.Text = "Aimlock: " .. (aimlockEnabled and "ON" or "OFF")
end)

-- Verifica se é inimigo (modo solo ou com equipe)
local function isEnemy(player)
	if player == LocalPlayer then return false end
	if LocalPlayer.Team ~= nil and player.Team ~= nil then
		return player.Team ~= LocalPlayer.Team
	end
	return true
end

-- Cria ESP
local function createESP(part)
	if part:FindFirstChild("ESP") then return end
	local esp = Instance.new("BillboardGui")
	esp.Name = "ESP"
	esp.AlwaysOnTop = true
	esp.Size = UDim2.new(0, 5, 0, 5)
	esp.Adornee = part
	esp.Parent = part

	local box = Instance.new("Frame", esp)
	box.Size = UDim2.new(1, 0, 1, 0)
	box.BackgroundColor3 = Color3.new(1, 0, 0)
	box.BackgroundTransparency = 0.3
	box.BorderSizePixel = 0
end

-- Aplica ESP em players
local function applyESP(player)
	player.CharacterAdded:Connect(function(character)
		local head = character:WaitForChild("Head", 5)
		if head then
			task.wait(1) -- Espera possíveis atualizações de Team
			if isEnemy(player) then
				createESP(head)
			end
		end
	end)
end

-- Aplica nos players já existentes
for _, p in ipairs(Players:GetPlayers()) do
	applyESP(p)
end

-- Para novos jogadores
Players.PlayerAdded:Connect(function(player)
	applyESP(player)
end)

-- Visibilidade (linha de visão e na tela)
local function isVisible(part)
	if not part then return false end
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin).Unit * 500
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
	local result = Workspace:Raycast(origin, direction, rayParams)

	if result and result.Instance and result.Instance:IsDescendantOf(part.Parent) then
		local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
		return onScreen
	end
	return false
end

-- Inimigo mais próximo e visível
local function getClosestEnemy()
	local closestPlayer = nil
	local shortestDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if isEnemy(player) and character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid") then
			local hrp = character.HumanoidRootPart
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid.Health > 0 and isVisible(hrp) then
				local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	return closestPlayer
end

-- Aimlock render
RunService.RenderStepped:Connect(function()
	if aimlockEnabled then
		local target = getClosestEnemy()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = target.Character.HumanoidRootPart
			local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
			end
		end
	end
end)
