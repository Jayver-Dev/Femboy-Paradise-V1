local centrl = loadstring(game:HttpGet("https://raw.githubusercontent.com/yarrosvault/CentrlV2/refs/heads/main/centrl",true))()

centrl:load({
	Logo = '5632495668', -- ID Only (required, optional soon)
	ConfigEnabled = {
		Enabled = true, -- If Config Saving is desired leave true
		Cfolder = 'femmy', -- Folder Name
		Cfile = 'Config' -- Config File Name (credits to rayfield for layout (not skidded)
	},
	Theme = {
		Accent = Color3.fromRGB(234, 9, 215), -- Accent color
		Hitbox =  Color3.fromRGB(234, 9, 215) -- Hitbox color (ex. toggle, slider)
	}
})


local main = centrl:int({
	Title = 'Femmy', -- Title of UI
	Sub = 'Universal' -- Sub Text
})

local Tab = main:IntTab('Main') -- More Features Coming Soon!

local s1 = Tab:IntSection('Main', {
	Side = 'L' -- Side of section ('L' - Left, 'R' - Right)
})
