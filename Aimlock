local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Estado
local aimEnabled = false
local currentTarget = nil
local ESPs = {}
local button

-- Proteção leve
local function protectFunction(func)
    setreadonly(getfenv(func), false)
    for k, v in pairs(getfenv(func)) do
        if typeof(v) == "function" and k ~= "print" then
            rawset(getfenv(func), k, function(...) end)
        end
    end
    setreadonly(getfenv(func), true)
end

-- Verifica se tem símbolo azul
local function hasBlueSymbol(head)
	if not head then return false end
	for _, obj in pairs(head:GetChildren()) do
		if obj:IsA("Part") or obj:IsA("Decal") or obj:IsA("BillboardGui") then
			if obj:IsA("Part") and obj.Color == Color3.fromRGB(0, 0, 255) then
				return true
			elseif obj:IsA("Decal") and obj.Color3 == Color3.fromRGB(0, 0, 255) then
				return true
			elseif obj:IsA("BillboardGui") and obj:FindFirstChildWhichIsA("Frame") and obj:FindFirstChildWhichIsA("Frame").BackgroundColor3 == Color3.fromRGB(0, 0, 255) then
				return true
			end
		end
	end
	return false
end

-- Verifica se parte está visível (sem parede)
local function isVisible(targetPart)
	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin).Unit * 1000
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local result = Workspace:Raycast(origin, direction, raycastParams)
	if result and result.Instance and not targetPart:IsDescendantOf(result.Instance.Parent) then
		return false
	end
	return true
end

-- ESP
local function createESP(target)
	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Color = Color3.fromRGB(255, 0, 0)
	box.Filled = false
	box.Visible = true
	ESPs[target] = box
end

local function removeESP(target)
	if ESPs[target] then
		ESPs[target]:Remove()
		ESPs[target] = nil
	end
end

local function updateESP()
	for i, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if not ESPs[plr] then
				createESP(plr)
			end
			local hrp = plr.Character.HumanoidRootPart
			local vector, onscreen = Camera:WorldToViewportPoint(hrp.Position)
			if onscreen then
				local fixedSize = Vector2.new(50, 80) -- Tamanho fixo, não muda pela distância
				ESPs[plr].Size = fixedSize
				ESPs[plr].Position = Vector2.new(vector.X - fixedSize.X / 2, vector.Y - fixedSize.Y / 2)
				ESPs[plr].Visible = true
			else
				ESPs[plr].Visible = false
			end
		else
			removeESP(plr)
		end
	end
end

-- Encontra inimigo válido
local function getClosestValidEnemy()
	local closest = nil
	local shortest = math.huge

	for _, enemy in ipairs(Workspace:GetChildren()) do
		if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= LocalPlayer.Character then
			local head = enemy:FindFirstChild("Head")
			if enemy.Humanoid.Health > 0 and not hasBlueSymbol(head) then
				local hrp = enemy.HumanoidRootPart
				local screenPos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
				if onscreen and isVisible(hrp) then
					local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
					if dist < shortest then
						shortest = dist
						closest = enemy
					end
				end
			end
		end
	end

	return closest
end

-- AimLock
local function aimLock()
	pcall(function()
		if not aimEnabled then return end
		if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

		local target = getClosestValidEnemy()
		if target ~= currentTarget then
			currentTarget = target
		end

		if currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 and isVisible(currentTarget.HumanoidRootPart) then
			local pos = currentTarget.HumanoidRootPart.Position
			local cf = CFrame.new(Camera.CFrame.Position, pos)
			Camera.CFrame = cf
		else
			currentTarget = nil
		end
	end)
end

-- Cria GUI que resiste à morte
local function createGUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "DeltaAimGUI"
	gui.ResetOnSpawn = false
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 130, 0, 45)
	button.Position = UDim2.new(0, 20, 0, 60)
	button.Text = "Aim Lock: " .. (aimEnabled and "ON" or "OFF")
	button.BackgroundColor3 = aimEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
	button.TextScaled = true
	button.Parent = gui

	button.MouseButton1Click:Connect(function()
		aimEnabled = not aimEnabled
		button.Text = "Aim Lock: " .. (aimEnabled and "ON" or "OFF")
		button.BackgroundColor3 = aimEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
	end)
end

-- Recria GUI após morrer
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	createGUI()
end)

-- Primeira vez
createGUI()

-- Loop principal
RunService.RenderStepped:Connect(function()
	updateESP()
	if aimEnabled then
		aimLock()
	end
end)

-- Protege função
protectFunction(aimLock)
