local centrl = loadstring(game:HttpGet("https://raw.githubusercontent.com/yarrosvault/CentrlV2/refs/heads/main/centrl", true))()

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

local s1 = Tab:IntSection('Main', {
    Side = 'L'
})

-- WalkSpeed Modifier
s1:createSlider({
    Title = 'WalkSpeed Modifier',
    Sliders = {
        {
            title = 'Speed',
            range = {1, 120},
            increment = 1,
            startvalue = 16,
            callback = function(value)
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
            end,
        }
    }
})

-- ESP Toggle
local espEnabled = false
s1:createToggle({
    Title = 'ESP Toggle',
    Config = true,
    Value = false,
    Callback = function(value)
        espEnabled = value
        if espEnabled then
            -- Enable ESP
        else
            -- Disable ESP
            for _, plr in pairs(game.Players:GetPlayers()) do
                removeESP(plr)
            end
        end
    end,
})

-- ESP Color Picker
s1:createColorpicker({
    Title = 'ESP Color',
    Color = Color3.fromRGB(255, 0, 4),
    Callback = function(value)
        getgenv().ESPColor = value
    end,
})

-- Team Color Sync Toggle
local teamColorSync = false
s1:createToggle({
    Title = 'Team Color Sync',
    Config = true,
    Value = false,
    Callback = function(value)
        teamColorSync = value
    end,
})

-- NPC ESP Toggle
local npcESP = false
s1:createToggle({
    Title = 'NPC ESP',
    Config = true,
    Value = false,
    Callback = function(value)
        npcESP = value
    end,
})

-- ESP Font Picker
local espFont = Enum.Font.SourceSans
s1:createDropdown({
    Title = 'ESP Font',
    Options = {"SourceSans", "Arial", "Garamond"},
    Callback = function(value)
        espFont = Enum.Font[value]
    end,
})

-- Aimbot Toggle
local aimbotEnabled = false
s1:createToggle({
    Title = 'Aimbot',
    Config = true,
    Value = false,
    Callback = function(value)
        aimbotEnabled = value
    end,
})

-- ESP Logic
local function createESP(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    if char.Head:FindFirstChild("FemmyESP") then return end

    -- Choose color based on team or fallback to default ESP color
    local color = teamColorSync and player.TeamColor.Color or getgenv().ESPColor

    -- Create BillboardGui for the ESP
    local esp = Instance.new("BillboardGui", char.Head)
    esp.Name = "FemmyESP"
    esp.Size = UDim2.new(4, 0, 5, 0)
    esp.AlwaysOnTop = true
    esp.Adornee = char.Head

    -- Create Name Label
    local nameLabel = Instance.new("TextLabel", esp)
    nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, -30)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextSize = 14
    nameLabel.Font = espFont
    nameLabel.Text = player.Name

    -- Create Health Bar (vertical)
    local healthBar = Instance.new("Frame", esp)
    healthBar.Size = UDim2.new(0.2, 0, 1, 0)
    healthBar.Position = UDim2.new(-0.25, 0, 0, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Name = "HealthBar"

    -- Create Box around the player
    local box = Instance.new("Frame", esp)
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundTransparency = 0.5
    box.BorderSizePixel = 2
    box.BorderColor3 = color
    box.Name = "ESPBox"
end

-- Update Health Bar and Box size
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

        -- Update ESP box size dynamically
        local box = gui:FindFirstChild("ESPBox")
        if box then
            box.Size = UDim2.new(1, 0, 1, 0)
        end

        -- Update Name Label
        local nameLabel = gui:FindFirstChildOfClass("TextLabel")
        if nameLabel then
            nameLabel.Font = espFont
            nameLabel.TextColor3 = teamColorSync and player.TeamColor.Color or getgenv().ESPColor
        end
    end
end

-- Remove ESP Logic
local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local gui = player.Character.Head:FindFirstChild("FemmyESP")
        if gui then gui:Destroy() end
    end
end

-- Aimbot Logic
local function aimbot()
    if not aimbotEnabled then return end
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (myPosition - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end

    if closestPlayer then
        -- Lock camera to closest player
        local camera = game.Workspace.CurrentCamera
        camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
    end
end

-- Main loop to manage ESP (Create & Update)
game:GetService("RunService").RenderStepped:Connect(function()
    if not espEnabled then
        for _, plr in pairs(game.Players:GetPlayers()) do
            removeESP(plr)
        end
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

    if npcESP then
        for _, npc in pairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and not game.Players:GetPlayerFromCharacter(npc) and npc:FindFirstChild("Head") and npc:FindFirstChild("Humanoid") then
                if not npc.Head:FindFirstChild("FemmyESP") then
                    createESP({Character = npc, Name = npc.Name, TeamColor = BrickColor.White})
                end
            end
        end
    end

    aimbot()  -- Call aimbot logic in each frame
end)

-- Clean up when players leave
game.Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        removeESP(player)
    end
end)
