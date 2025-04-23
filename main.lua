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
	Name = "FemboyHub",
	Theme = Library.Themes.CustomPinkBlue
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Drawing API check
local Drawing = (Drawing or getgenv and getgenv().Drawing)
if not Drawing then
	warn("Drawing API not supported on this executor.")
	return
end

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
local boxESP = {}

function createBoxESP(player)
	if player == LocalPlayer then return end
	boxESP[player] = Drawing.new("Square")
	boxESP[player].Thickness = 2
	boxESP[player].Transparency = 1
	boxESP[player].Color = Color3.fromRGB(255, 105, 180)
	boxESP[player].Filled = false
	boxESP[player].Visible = false
end

function removeBoxESP(player)
	if boxESP[player] then
		boxESP[player]:Remove()
		boxESP[player] = nil
	end
end

function clearESP()
	for player, box in pairs(boxESP) do
		box:Remove()
	end
	boxESP = {}
end

function updateBoxESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
			if not boxESP[player] then
				createBoxESP(player)
			end

			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			local head = player.Character:FindFirstChild("Head")
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

			if onScreen then
				local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.3, 0))
				local feetPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))

				local height = math.abs(headPos.Y - feetPos.Y)
				local width = height / 2

				boxESP[player].Size = Vector2.new(width, height)
				boxESP[player].Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
				boxESP[player].Visible = espEnabled
			else
				boxESP[player].Visible = false
			end
		else
			removeBoxESP(player)
		end
	end
end

-- Cleanup
Players.PlayerRemoving:Connect(removeBoxESP)

-- GUI Tab
local tab = gui:tab{
	Icon = "rbxassetid://6034996695",
	Name = "Femboy ESP/Aimbot"
}

-- Buttons
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

-- Frame updates
RunService.RenderStepped:Connect(function()
	aimbotLock()
	if espEnabled then
		updateBoxESP()
	end
end)
