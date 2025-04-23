-- Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

-- Custom Theme
Library.Themes.CustomPinkBlue = {
	Main = Color3.fromRGB(255, 182, 193),
	Secondary = Color3.fromRGB(173, 216, 230),
	Tertiary = Color3.fromRGB(255, 105, 180),
	StrongText = Color3.fromRGB(173, 173, 173),
	WeakText = Color3.fromRGB(211,211,211)
}

local gui = Library:create{
	Name = "FemboyHub",
	Theme = Library.Themes.CustomPinkBlue
}

gui:Notification{
	Title = "Welcome to FemboyHub",
	Text = "You little twink femboy",
	Duration = 3,
	Callback = function() end
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Aimbot Variables
local aimbotEnabled = false
local targetPart = "Head"
local aimbotFOV = 100

-- ESP Variables
local espEnabled = false
local boxESP = {}

-- Infinite Jump
local infJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)

-- Noclip
local noclipEnabled = false
RunService.Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide then
				v.CanCollide = false
			end
		end
	end
end)

-- Aimbot Function
local function getClosestTarget()
	local closest = nil
	local shortest = aimbotFOV
	local mouseLocation = UserInputService:GetMouseLocation()

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(targetPart) then
			local part = player.Character[targetPart]
			local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
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

-- ESP Drawing
function createBoxESP(player)
	if player == LocalPlayer then return end
	local box = Drawing.new("Square")
	box.Thickness = 2
	box.Transparency = 1
	box.Color = Color3.fromRGB(255, 105, 180)
	box.Filled = false
	box.Visible = false
	boxESP[player] = box
end

function removeBoxESP(player)
	if boxESP[player] then
		boxESP[player]:Remove()
		boxESP[player] = nil
	end
end

function updateBoxESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
			if not boxESP[player] then
				createBoxESP(player)
			end
			local char = player.Character
			local hrp = char.HumanoidRootPart
			local head = char.Head
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.3, 0))
				local feetPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
				local height = math.abs(headPos.Y - feetPos.Y)
				local width = height / 2
				local box = boxESP[player]
				box.Size = Vector2.new(width, height)
				box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
				box.Visible = espEnabled
			else
				boxESP[player].Visible = false
			end
		else
			removeBoxESP(player)
		end
	end
end

-- Tabs
local mainTab = gui:tab{
	Icon = "rbxassetid://6034996695",
	Name = "Femboy ESP/Aimbot"
}

mainTab:button({
	Name = "Toggle Aimbot",
	Callback = function()
		aimbotEnabled = not aimbotEnabled
		gui:set_status("Aimbot: " .. (aimbotEnabled and "ON" or "OFF"))
	end
})

mainTab:button({
	Name = "Toggle ESP",
	Callback = function()
		espEnabled = not espEnabled
		gui:set_status("ESP: " .. (espEnabled and "ON" or "OFF"))
	end
})

mainTab:dropdown({
	Name = "Target Part",
	StartingText = "Head",
	Items = {"Head", "Torso", "HumanoidRootPart"},
	Callback = function(part)
		targetPart = part
	end
})

mainTab:slider({
	Name = "Aimbot FOV",
	Min = 50,
	Max = 300,
	Default = 100,
	Callback = function(value)
		aimbotFOV = value
	end
})

mainTab:keybind({
	Name = "Toggle Aimbot",
	Key = Enum.KeyCode.Q,
	Callback = function()
		aimbotEnabled = not aimbotEnabled
	end
})

-- Misc Tab
local miscTab = gui:tab{
	Icon = "rbxassetid://6031280882",
	Name = "Femboy Misc"
}
miscTab:button({
	Name = "Toggle Floaty Jumps (Inf Jump)",
	Callback = function()
		infJumpEnabled = not infJumpEnabled
		gui:set_status("Infinite Jump: " .. (infJumpEnabled and "ENABLED" or "DISABLED"))
	end
})

-- Local Player Tab
-- Local Player Tab with Player Icon
local localPlayerTab = gui:tab{
    Icon = "rbxassetid://117259180607823",  -- Replace this with the ID of the player icon or your custom icon.
    Name = "Femboy Local Player"
}

-- Speed Control
local speed = 16  -- Default speed value
local speedSlider = localPlayerTab:slider({
    Name = "Speed Control",
    Min = 16,
    Max = 200,
    Default = speed,
    Callback = function(value)
        speed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    end
})

-- Jump Power Control
local jumpPower = 50  -- Default jump power value
local jumpSlider = localPlayerTab:slider({
    Name = "Jump Power Control",
    Min = 50,
    Max = 200,
    Default = jumpPower,
    Callback = function(value)
        jumpPower = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = jumpPower
        end
    end
})

-- God Mode
local godModeEnabled = false
local godModeButton = localPlayerTab:button({
    Name = "Toggle God Mode",
    Callback = function()
        godModeEnabled = not godModeEnabled
        if godModeEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
            end
        end
        gui:set_status("God Mode: " .. (godModeEnabled and "ON" or "OFF"))
    end
})

-- Invisibility (Client-side)
local function applyClientInvisibility()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end

    -- Set transparency to 1 for all body parts and accessories
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        elseif part:IsA("Accessory") then
            part:Destroy() -- Remove accessories entirely
        end
    end

    -- Hide the humanoid health bar completely
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    end
end

local function revertInvisibility()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end

    -- Reset transparency and collision for all parts
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
        end
    end

    -- Show the humanoid health bar again
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.Both
    end
end

local invisibilityEnabled = false
local invisibilityButton = localPlayerTab:button({
    Name = "Toggle Invisibility",
    Callback = function()
        invisibilityEnabled = not invisibilityEnabled
        if invisibilityEnabled then
            applyClientInvisibility()
        else
            revertInvisibility()
        end
        gui:set_status("Invisibility: " .. (invisibilityEnabled and "ON" or "OFF"))
    end
})

-- Reset Character
local resetCharacterButton = localPlayerTab:button({
    Name = "Reset Character",
    Callback = function()
        -- Force character reset by setting Character to nil
        LocalPlayer.Character = nil

        -- Wait a moment and let the character respawn automatically
        wait(1)
        -- Optionally, you could apply any other behavior after respawn if necessary
    end
})

-- Apply Speed and Jump Power on Character Spawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    -- Set initial values
    char:WaitForChild("Humanoid").WalkSpeed = speed
    char:WaitForChild("Humanoid").JumpPower = jumpPower
end)


-- Update ESP
RunService.RenderStepped:Connect(function()
	updateBoxESP()
	aimbotLock()
end)

Players.PlayerRemoving:Connect(function(player)
	removeBoxESP(player)
end)

gui:Credit{
	Name = "J4Y",
	Description = "Script Developer",
	Discord = "j4y11"
}


-- Wall Hack
mainTab:button({
    Name = "Toggle Wall Hack",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Players.LocalPlayer.Character) then
                obj.LocalTransparencyModifier = 0.5
            end
        end
        gui:set_status("Wall Hack activated!")
    end
})

-- Teleport to Player
miscTab:textbox({
    Name = "Teleport To Player",
    Placeholder = "Enter Player Name",
    Callback = function(input)
        local target = Players:FindFirstChild(input)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position)
            gui:set_status("Teleported to " .. input)
        else
            gui:set_status("Player not found!")
        end
    end
})

-- Name Tag ESP
mainTab:toggle({
    Name = "Name Tag ESP",
    Callback = function(enabled)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if enabled then
                    local tag = Instance.new("BillboardGui", player.Character)
                    tag.Name = "NameTag"
                    tag.Size = UDim2.new(0, 100, 0, 20)
                    tag.AlwaysOnTop = true
                    tag.StudsOffset = Vector3.new(0, 3, 0)

                    local label = Instance.new("TextLabel", tag)
                    label.Text = player.Name
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.TextColor3 = Color3.fromRGB(255, 105, 180)
                    label.BackgroundTransparency = 1
                else
                    local existing = player.Character:FindFirstChild("NameTag")
                    if existing then existing:Destroy() end
                end
            end
        end
    end
})

-- Sound Toggle
miscTab:toggle({
    Name = "Mute Game Sound",
    Callback = function(enabled)
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") then
                sound.Volume = enabled and 0 or 1
            end
        end
    end
})

-- Player Follow
miscTab:textbox({
    Name = "Follow Player",
    Placeholder = "Enter Player Name",
    Callback = function(input)
        local followTarget = Players:FindFirstChild(input)
        if followTarget and followTarget.Character then
            RunService.RenderStepped:Connect(function()
                if followTarget.Character and followTarget.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character:MoveTo(followTarget.Character.HumanoidRootPart.Position + Vector3.new(2, 0, 2))
                end
            end)
            gui:set_status("Following " .. input)
        else
            gui:set_status("Player not found!")
        end
    end
})


localPlayerTab:button({
	Name = "Toggle Wall Phase (Noclip)",
	Callback = function()
		noclipEnabled = not noclipEnabled
		gui:set_status("Noclip: " .. (noclipEnabled and "ENABLED" or "DISABLED"))
	end
})
