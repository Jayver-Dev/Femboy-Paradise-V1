local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

-- Custom Theme
Library.Themes.CustomPinkBlue = {
	Main = Color3.fromRGB(255, 182, 193),
	Secondary = Color3.fromRGB(173, 216, 230),
	Tertiary = Color3.fromRGB(255, 105, 180),
	StrongText = Color3.fromRGB(255, 255, 255),
	WeakText = Color3.fromRGB(200, 200, 200)
}

local gui = Library:create{
	Theme = Library.Themes.CustomPinkBlue
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Aimbot
local aimbotEnabled = false
local targetPart = "Head"
local aimbotFOV = 100

local function getClosestTarget()
	local closest = nil
	local shortest = aimbotFOV

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(targetPart) then
			local part = player.Character[targetPart]
			local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
				if dist < shortest then
					shortest = dist
					closest = part
				end
			end
		end
	end
	return closest
end

local function aimbotLock()
	if not aimbotEnabled then return end
	local target = getClosestTarget()
	if target then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
	end
end

-- ESP
local espEnabled = false
local espObjects = {}

local function createESP(player)
	if player == LocalPlayer or not player.Character then return end
	if espObjects[player] then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP"
	billboard.Adornee = player.Character:FindFirstChild("Head")
	billboard.Size = UDim2.new(4, 0, 5, 0)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true

	local outline = Instance.new("Frame")
	outline.Size = UDim2.new(1, 0, 1, 0)
	outline.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
	outline.BackgroundTransparency = 0.4
	outline.BorderSizePixel = 2
	outline.BorderColor3 = Color3.fromRGB(255, 255, 255)
	outline.Parent = billboard

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Text = player.Name
	nameLabel.Size = UDim2.new(1, 0, 0.2, 0)
	nameLabel.Position = UDim2.new(0, 0, -0.2, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard

	billboard.Parent = player.Character
	espObjects[player] = billboard
end

local function clearESP()
	for player, gui in pairs(espObjects) do
		if gui then gui:Destroy() end
	end
	espObjects = {}
end

local function updateESP()
	if not espEnabled then return end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			createESP(player)
		end
	end
end

-- GUI Setup
local tab = gui:tab{
	Icon = "rbxassetid://6034996695",
	Name = "Stronger ESP/Aimbot"
}

tab:button({
	Name = "Toggle Aimbot",
	Callback = function()
		aimbotEnabled = not aimbotEnabled
		gui:set_status("Aimbot: " .. (aimbotEnabled and "ON" or "OFF"))
	end
})

tab:button({
	Name = "Toggle ESP",
	Callback = function()
		espEnabled = not espEnabled
		gui:set_status("ESP: " .. (espEnabled and "ON" or "OFF"))
		if not espEnabled then
			clearESP()
		end
	end
})

tab:dropdown({
	Name = "Target Part",
	StartingText = "Head",
	Items = {"Head", "Torso", "HumanoidRootPart"},
	Callback = function(part)
		targetPart = part
	end
})

tab:slider({
	Name = "Aimbot FOV",
	Min = 50,
	Max = 300,
	Default = 100,
	Callback = function(value)
		aimbotFOV = value
	end
})

tab:keybind({
	Name = "Toggle Aimbot",
	Key = Enum.KeyCode.Q,
	Callback = function()
		aimbotEnabled = not aimbotEnabled
	end
})

-- Heartbeat updates
RunService.RenderStepped:Connect(function()
	aimbotLock()
	updateESP()
end)
