--// Load CentrlV2 UI
local centrl = loadstring(game:HttpGet("https://raw.githubusercontent.com/yarrosvault/CentrlV2/refs/heads/main/centrl",true))()

centrl:load({
    Logo = '115513435189491',
    ConfigEnabled = {
        Enabled = true,
        Cfolder = 'femmy',
        Cfile = 'Config'
    },
    Theme = {
        Accent = Color3.fromRGB(234, 9, 215),
        Hitbox = Color3.fromRGB(234, 9, 215),
    }
})

local main = centrl:int({
    Title = 'Femmy',
    Sub = 'Universal'
})

local Tab = main:IntTab('Main')
local s1 = Tab:IntSection('Main', { Side = 'L' })

--// Sliders (WalkSpeed modifier)
s1:createSlider({
    Title = 'Modifiers',
    Sliders = {
        {
            title = 'WalkSpeed',
            range = {1,120},
            increment = 1,
            startvalue = 16,
            callback = function(v)
                pcall(function()
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
                end)
            end,
        },
    }
})

--// Toggles and Settings
getgenv().AimbotEnabled = false
getgenv().ESPEnabled = false
getgenv().TeamColorSync = false
getgenv().NPCESP = false
getgenv().ESPFont = Enum.Font.SourceSansBold
getgenv().ESPColor = Color3.fromRGB(255, 255, 255)

s1:createToggle({
    Title = 'Aimbot',
    Config = true,
    Value = false,
    Callback = function(val)
        getgenv().AimbotEnabled = val
    end,
})

s1:createToggle({
    Title = 'ESP (Boxes + Names)',
    Config = true,
    Value = false,
    Callback = function(val)
        getgenv().ESPEnabled = val
    end,
})

s1:createToggle({
    Title = 'NPC ESP',
    Config = true,
    Value = false,
    Callback = function(val)
        getgenv().NPCESP = val
    end,
})

s1:createToggle({
    Title = 'Team Color Sync',
    Config = true,
    Value = false,
    Callback = function(val)
        getgenv().TeamColorSync = val
    end,
})

s1:createDropdown({
    Title = 'ESP Font',
    Options = {'Legacy', 'Arial', 'Gotham', 'SciFi', 'Cartoon'},
    Callback = function(font)
        local fonts = {
            ['Legacy'] = Enum.Font.Legacy,
            ['Arial'] = Enum.Font.Arial,
            ['Gotham'] = Enum.Font.Gotham,
            ['SciFi'] = Enum.Font.SciFi,
            ['Cartoon'] = Enum.Font.Cartoon,
        }
        getgenv().ESPFont = fonts[font] or Enum.Font.SourceSansBold
    end
})

s1:createColorpicker({
    Title = 'ESP Fallback Color',
    Color = Color3.fromRGB(255, 255, 255),
    Callback = function(c)
        getgenv().ESPColor = c
    end
})

--// Aimbot (Camera lock-on)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Q then
        getgenv().AimbotEnabled = not getgenv().AimbotEnabled
    end
end)

local function getClosestTarget()
    local closest, shortest = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortest then
                    closest = v
                    shortest = dist
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if getgenv().AimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local dir = (target.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Unit
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
        end
    end
end)

--// ESP (BillboardGui-based)
local function createESP(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    if char.Head:FindFirstChild("FemmyESP") then return end

    local color = getgenv().TeamColorSync and player.TeamColor.Color or getgenv().ESPColor

    local esp = Instance.new("BillboardGui", char.Head)
    esp.Name = "FemmyESP"
    esp.Size = UDim2.new(4, 0, 5, 0)
    esp.AlwaysOnTop = true
    esp.Adornee = char.Head

    local nameLabel = Instance.new("TextLabel", esp)
    nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, -30)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextSize = 14
    nameLabel.Font = getgenv().ESPFont
    nameLabel.Text = player.Name

    local healthBar = Instance.new("Frame", esp)
    healthBar.Size = UDim2.new(0.2, 0, 1, 0)
    healthBar.Position = UDim2.new(-0.25, 0, 0, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Name = "HealthBar"
end

-- Update health bars & color
local function updateESP(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") or not char:FindFirstChild("Humanoid") then return end

    local gui = char.Head:FindFirstChild("FemmyESP")
    if gui then
        local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
        local bar = gui:FindFirstChild("HealthBar")
        if bar then
            bar.Size = UDim2.new(0.2, 0, math.clamp(hp, 0, 1), 0)
            bar.BackgroundColor3 = Color3.fromRGB(255 - hp * 255, hp * 255, 0)
        end

        local nameLabel = gui:FindFirstChildOfClass("TextLabel")
        if nameLabel then
            nameLabel.Font = getgenv().ESPFont
            nameLabel.TextColor3 = getgenv().TeamColorSync and player.TeamColor.Color or getgenv().ESPColor
        end
    end
end

-- Cleanup
local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local gui = player.Character.Head:FindFirstChild("FemmyESP")
        if gui then gui:Destroy() end
    end
end

-- Main Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if not getgenv().ESPEnabled then
        for _, plr in pairs(game.Players:GetPlayers()) do removeESP(plr) end
        return
    end

    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            if plr.Character and plr.Character:FindFirstChild("Head") then
                createESP(plr)
                updateESP(plr)
            end
        end
    end

    if getgenv().NPCESP then
        for _, npc in pairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and not game.Players:GetPlayerFromCharacter(npc) and npc:FindFirstChild("Head") and npc:FindFirstChild("Humanoid") then
                if not npc.Head:FindFirstChild("FemmyESP") then
                    createESP({Character = npc, Name = npc.Name, TeamColor = BrickColor.White})
                end
            end
        end
    end
end)

-- Clean up on leave
game.Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        removeESP(player)
    end
end)
